asm "

_STACK_PTR:
	.dl 0

;128 cells deep
_STACK:
	.dl 0

;safe prims

_POP:
	push rs
	bclri rs, rs, 1

	push r2
	push r1

	lri.l r0, _STACK_PTR
	lrr.l r1, r0
	lri.l r2, _STACK

	cmpi r1, 0
	be _UNDERFLOW

	subi r1, r1, 4
	srr.l r0, r1

	add r2, r1, r2
	lrr.l r0, r2

	pop r1
	pop r2

	pop rs
	ret

_PUSH:
	push rs
	bclri rs, rs, 1

	push r4

	mov r4, r0

	push r2
	push r1

	lri.l r0, _STACK_PTR
	lrr.l r1, r0
	lri.l r2, _STACK

	push r3
	addi r3, r1, 4
	srr.l r0, r3
	pop r3

	add r2, r2, r1
	srr.l r2, r4

	pop r1
	pop r2

	pop r4

	pop rs
	ret

"