;r0 - num
;r1 - handler
;trashes r0
InterruptRegister:
	muli r0, r0, 4
	addi r0, r0, InterruptVectorTable

	srr.l r0, r1
	ret

InterruptInit:

	;zero out vector table
	push r0
	li r0, InterruptVectorTable
.loop:
	cmpi r0, InterruptVectorTableEnd
	bge .end

	sri.l r0, 0

	addi r0, r0, 4
	b .loop

.end:
	pop r0

	call FaultsInit

	li ivt, InterruptVectorTable
	bseti rs, rs, 1 ;enable interrupts

	ret