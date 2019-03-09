var InterruptsVT 0

procedure InterruptsInit (* -- *)
	1024 Calloc InterruptsVT!

	InterruptsVT@ asm "
		call _POP
		cli
		mov ivt, r0
	"

	auto i
	0 i!
	while (i@ 10 <)
		pointerof FaultsHandlerASM i@ InterruptRegister
		i@ 1 + i!
	end

	InterruptEnable
end

table FaultsNames
	"Division by zero"
	"Invalid opcode"
	"Page fault"
	"Privilege violation"
	"General fault"
	"Fatal fault"
	"Double fault"
	"Bus error"
	"I/O error"
	"Spurious interrupt"
endtable

procedure FaultsHandler (* num loc -- *)
	auto rs
	InterruptDisable rs!

	auto loc
	loc!

	auto num
	num!

	ConsoleUserOut

	if (ConsoleIn@ 0 ~=)
		loc@ [num@]FaultsNames@ "!!!FAULT!!! %s at %x, resetting on console input\n" Printf

		while (Getc ERR ==) end

		Reset
	end else
		loc@ [num@]FaultsNames@ "!!!FAULT!!! %s at %x, resetting\n" Printf

		Reset
	end
end

asm "

FaultsHandlerASM:
	pop r1
	pop r1
	pop r1

	call _PUSH

	mov r0, r1
	call _PUSH

	call FaultsHandler

"

procedure InterruptRegister (* handler num -- *)
	4 * InterruptsVT@ + !
end

procedure InterruptEnable (* -- *)
	asm "

	bseti rs, rs, 1

	"
end

procedure InterruptDisable (* -- rs *)
	asm "

	mov r0, rs
	bclri rs, rs, 1
	call _PUSH

	"
end

procedure InterruptRestore (* rs -- *)
	asm "

	call _POP
	mov rs, r0

	"
end