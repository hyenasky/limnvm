var ArgsBuffer 0

procedure ArgsInit (* argsptr -- *)
	auto argp
	argp!

	if (argp@ 0 ==)
		return
	end

	argp@ strlen 1 + KMalloc ArgsBuffer!

	ArgsBuffer@ argp@ strcpy

	argp@ "vnix arguments: %s\n" KPrintf
end

procedure ArgsValue (* arg -- value or 0 *)
	auto arg
	arg!

	auto wordbuf
	256 KCalloc wordbuf!

	auto namebuf
	256 KCalloc namebuf!

	if (wordbuf@ 0 ==)
		"Out of memory\n" KPanic
	end

	if (namebuf@ 0 ==)
		"Out of memory\n" KPanic
	end

	auto nt
	ArgsBuffer@ nt!

	auto out
	0 out!

	while (nt@ 0 ~=)
		auto rmnd

		nt@ wordbuf@ ' ' 255 strntok nt!
		wordbuf@ namebuf@ '=' 255 strntok 1 + rmnd!
		if (namebuf@ arg@ strcmp)
			256 KCalloc out!
			if (out@ 0 ==)
				"Out of memory\n" KPanic
			end

			out@ rmnd@ strcpy

			break
		end
	end

	wordbuf@ KFree
	namebuf@ KFree

	out@
end

procedure ArgsCheck (* arg -- present? *)
	auto arg
	arg!

	auto wordbuf
	256 KCalloc wordbuf!

	if (wordbuf@ 0 ==)
		"Out of memory\n" KPanic
	end

	auto nt
	ArgsBuffer@ nt!

	auto out
	0 out!

	while (nt@ 0 ~=)
		nt@ wordbuf@ ' ' 255 strntok nt!
		if (wordbuf@ arg@ strcmp)
			1 out! break
		end
	end

	wordbuf@ KFree

	out@
end