(* use ANTECEDENT char devices for boot messages *)

procedure KPutc (* c -- *)
	ACIPutc
end

procedure KGetc (* -- c *)
	ACIGetc
	dup if (0xFFFF ==) drop ERR return end
end

table KConsoleDigits
	'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'
endtable

procedure KPuts (* s -- *)
	auto s
	s!

	while (s@ gb 0 ~=)
		s@ gb KPutc
		s@ 1 + s!
	end
end

procedure KPutx (* nx -- *)
	auto nx
	nx!

	if (nx@ 15 >)
		auto a
		nx@ 16 / a!

		nx@ 16 a@ * - nx!
		a@ KPutx
	end

	[nx@]KConsoleDigits@ KPutc
end

procedure KPutn (* n -- *)
	auto n
	n!

	if (n@ 9 >)
		auto a
		n@ 10 / a!

		n@ 10 a@ * - n!
		a@ KPutn
	end

	[n@]KConsoleDigits@ KPutc
end

procedure KConsoleInit (* -- *)
end