;very low-level reset code for limn cpu, reset vector specified in ROMHeader.s points to Reset routine
;special purpose registers are reset, the ROM is copied into RAM, and the main firmware procedure is called

Reset:
	li rs, 0x80000000 ;reset ebus
	cli
	li ivt, 0
	li sp, 0x1FFF
	call LLFWShadow
	call AntecedentEntry
	b Hang

Hang:
	b Hang

LLFWShadow:
	li r0, AntecedentBase
	li r1, 0x2000
	addi r2, r0, AntecedentEnd

.loop:
	cmp r0, r2
	bge .done

	lrr.l r3, r0
	srr.l r1, r3

	addi r0, r0, 4
	addi r1, r1, 4
	b .loop

.done:
	ret