var InterruptsVT 0

procedure InterruptsInit (* -- *)
	1024 Calloc InterruptsVT!

	InterruptsVT@ asm "
		call _POP
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

procedure FaultsHandler (* num loc -- *)
	auto rs
	InterruptDisable rs!

	swap "!!!FAULT!!! %d at %x, halting\n" Printf

	while (1) end
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