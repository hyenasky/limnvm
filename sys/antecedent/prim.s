asm "

_STACK_PTR:
	.dl 0

;128 cells deep
_STACK:
	.bytes 512 0

;safe prims

_POP:
	push rs
	bclri rs, rs, 1

	lri.l r0, _STACK_PTR
	cmpi r0, 0
	be _UNDERFLOW

	subi r0, r0, 4
	sir.l _STACK_PTR, r0

	addi r0, r0, _STACK
	lrr.l r0, r0

	pop rs
	ret

_PUSH:
	push rs
	bclri rs, rs, 1

	push r1
	lri.l r1, _STACK_PTR

	push r2
	addi r2, r1, 4
	sir.l _STACK_PTR, r2
	pop r2

	addi r1, r1, _STACK
	srr.l r1, r0

	pop r1

	pop rs
	ret

"