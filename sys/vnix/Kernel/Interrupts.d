buffer InterruptsVT 1024

procedure InterruptsInit (* -- *)
	"init interrupts\n" KPrintf

	SaveFirmwareInterrupts

	asm "

	mov r0, ivt
	call _PUSH

	"

	auto oivt
	oivt!

	(* copy firmware IVT into our IVT *)
	auto i
	0 i!
	while (i@ 1024 <)
		i@ oivt@ + @ i@ InterruptsVT + !
		i@ 4 + i!
	end

	(* set IVT *)
	InterruptsVT
	asm "

	call _POP
	mov ivt, r0

	"

	InterruptsVT oivt@ "old IVT at 0x%x, new IVT at 0x%x\n" KPrintf
end

procedure InterruptRegister (* handler num -- *)
	4 * InterruptsVT + !
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