var InterruptsVT 0

procedure InterruptsInit (* -- *)
	auto oivt

	asm "

	pushv r5, ivt

	" oivt!

	1024 Calloc InterruptsVT!

	oivt@ FaultsCopy

	InterruptsVT@ asm "
		popv r5, r0
		cli
		mov ivt, r0
	"

	InterruptEnable
end

procedure FaultsCopy (* oivt -- *)
	auto oivt
	oivt!

	auto i
	0 i!
	while (i@ 10 <)
		oivt@ @ i@ InterruptRegister
		i@ 1 + i!
		oivt@ 4 + oivt!
	end
end

procedure FaultsRegister (* -- *)
	auto i
	0 i!
	while (i@ 10 <)
		pointerof FaultsHandlerASM i@ InterruptRegister
		i@ 1 + i!
	end
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

	if (ConsoleInMethod@ 0 ~=)
		loc@ [num@]FaultsNames@ "\n!!!FAULT!!! %s at %x, resetting on console input.\nPress 'c' to clear NVRAM.\n" Printf

		auto c
		ERR c!
		while (c@ ERR ==)
			Getc c!
		end

		if (c@ 'c' ==)
			NVRAMFormat
		end

		LateReset
	end else
		loc@ [num@]FaultsNames@ "\n!!!FAULT!!! %s at %x, resetting.\n" Printf

		LateReset
	end
end

asm "

FaultsHandlerASM:
	pop r1
	pop r1
	pop r1

	li sp, 0x1FFF ;put stack in known location
	li r5, 0x0FFF ;this too

	pushv r5, r0

	mov r0, r1
	pushv r5, r0

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
	pushv r5, r0

	"
end

procedure InterruptRestore (* rs -- *)
	asm "

	popv r5, r0
	mov rs, r0

	"
end