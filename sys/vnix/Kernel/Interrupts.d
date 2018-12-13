buffer InterruptsVT 1024

procedure InterruptsInit (* -- *)
	"Interrupts: init\n" KPrintf

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

	InterruptsVT oivt@ "Interrupts: old IVT at 0x%x, new IVT at 0x%x\n" KPrintf

	"Interrupts: init done\n" KPrintf
end

procedure InterruptRegister (* rsmask handler num -- *)
	4 * InterruptsVT + !
end

procedure InterruptDisable (* -- rs *)
	asm "

	li r0, rs
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