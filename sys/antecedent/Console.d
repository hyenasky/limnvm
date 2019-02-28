var ConsoleOut 0
var ConsoleIn 0

procedure Putc (* c -- *)
	if (ConsoleOut@ 0 ==)

	asm "

	call _POP
	.db 0xF1

	"

	return
	end

	ConsoleOut@ DeviceSelectNode
		"write" DCallMethod drop
	DeviceExit
end

procedure Getc (* -- c *)
	if (ConsoleIn@ 0 ==) ERR return end

	ConsoleIn@ DeviceSelectNode
		"read" DCallMethod drop
	DeviceExit
end

table KConsoleDigits
	'0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'
endtable

procedure Gets (* s max -- *)
	auto max
	max!

	auto s
	s!

	auto len
	0 len!

	while (1)
		auto c
		ERR c!
		while (c@ ERR ==)
			Getc c!
		end

		if (c@ '\n' ==)
			'\n' Putc
			break
		end

		if (c@ '\b' ==)
			if (len@ 0 >)
				len@ 1 - len!
				0 s@ len@ + sb
				'\b' Putc
				' ' Putc
				'\b' Putc
			end
		end else if (len@ max@ <)
			c@ s@ len@ + sb

			len@ 1 + len!
			c@ Putc
		end end
	end

	0 s@ len@ + sb
end

procedure Puts (* s -- *)
	auto s
	s!

	while (s@ gb 0 ~=)
		s@ gb Putc
		s@ 1 + s!
	end
end

procedure Putx (* nx -- *)
	auto nx
	nx!

	if (nx@ 15 >)
		auto a
		nx@ 16 / a!

		nx@ 16 a@ * - nx!
		a@ Putx
	end

	[nx@]KConsoleDigits@ Putc
end

procedure Putn (* n -- *)
	auto n
	n!

	if (n@ 9 >)
		auto a
		n@ 10 / a!

		n@ 10 a@ * - n!
		a@ Putn
	end

	[n@]KConsoleDigits@ Putc
end

procedure Printf (* ... fmt -- *)
	auto f
	f!
	auto i
	0 i!
	auto sl
	f@ strlen sl!
	while (i@ sl@ <)
		auto char
		f@ i@ + gb char!
		if (char@ '%' ~=)
			char@ Putc
		end else
			i@ 1 + i!
			if (i@ sl@ >=)
				return
			end

			f@ i@ + gb char!

			if (char@ 'd' ==)
				Putn
			end else

			if (char@ 'x' ==)
				Putx
			end else

			if (char@ 's' ==)
				Puts
			end else

			if (char@ '%' ==)
				'%' Putc
			end else

			if (char@ 'l' ==)
				Putc
			end

			end

			end

			end

			end
		end

		i@ 1 + i!
	end
end

procedure ConsoleInit (* -- *)
	if (ConsoleOut@ 0 ==) (* nobody asserted themselves as stdout, try setting default *)
		"console-stdout" NVRAMGetVar dup if (0 ==)
			drop "/serial" "console-stdout" NVRAMSetVar
			"/serial"
		end

		DevTreeWalk ConsoleOut!

		if (ConsoleOut@ 0 ==)
			"/serial" DevTreeWalk ConsoleOut!
		end
	end
	if (ConsoleIn@ 0 ==) (* nobody asserted stdin *)
		"console-stdin" NVRAMGetVar dup if (0 ==)
			drop "/serial" "console-stdin" NVRAMSetVar
			"/serial"
		end

		DevTreeWalk ConsoleIn!

		if (ConsoleIn@ 0 ==)
			"/serial" DevTreeWalk ConsoleIn!
		end
	end
end