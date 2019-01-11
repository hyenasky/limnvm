var ArgsBuffer 0

procedure ArgsInit (* argsptr -- *)
	auto argp
	argp!

	if (argp@ 0 ==)
		return
	end

	argp@ strlen 1 + KMalloc ArgsBuffer!

	ArgsBuffer@ argp@ strcpy

	argp@ "vnix arguments:%s\n" KPrintf
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