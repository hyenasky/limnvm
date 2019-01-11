(* use ANTECEDENT char devices for boot messages *)

var KConsoleOut 0
var KConsoleIn 0

const KVERBOSEOUT 1
const KVERBOSEIN 2

procedure KPutc (* c -- *)
	KConsoleOut@ ACIPutChar
end

procedure KGetc (* -- c *)
	KConsoleIn@ ACIGetChar
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
	"KConsole: init\n" KPrintf

	if ("-v" ArgsCheck)
		KVERBOSEOUT KConsoleOut!
		KVERBOSEIN KConsoleIn!
		"!!! kernel messages printed prior to this one can be found in serial out !!!\nKConsole: verbose mode\n" KPrintf
	end

	"KConsole: init done\n" KPrintf
end