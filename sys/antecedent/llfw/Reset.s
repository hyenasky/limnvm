Reset:
	li rs, 0
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