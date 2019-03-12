;outputs:
;r0 - 0 if no kinnow2 board detected, or ptr to base of slotspace
LLFWK2Find:
	;we have to find the ebus slot containing the kinnow2 card (if one exists)
	;start at slot 0
	li r0, 0xC0000000

	push r1

.kfind:
	cmpi r0, 0xF8000000
	bge .out

	lrr.l r1, r0
	cmpi r1, 0x0C007CA1 ;valid board
	bne .kfnext ;no, next

	push r0
	addi r0, r0, 4
	lrr.l r1, r0
	pop r0
	cmpi r1, 0x4B494E57 ;kinnow2?
	be .kfound ;yes

.kfnext:
	addi r0, r0, 0x8000000
	b .kfind

.kfound:
	pop r1
	ret

.out:
	li r0, 0
	pop r1
	ret

;r0 - slotspace base
;r1 - new value
LLFWK2WPortA:
	addi r0, r0, 0x4004
	srr.l r0, r1
	ret

;r0 - slotspace base
;r1 - new value
LLFWK2WPortB:
	addi r0, r0, 0x4008
	srr.l r0, r1
	ret

;r0 - slotspace base
;r1 - new value
LLFWK2WPortC:
	addi r0, r0, 0x400C
	srr.l r0, r1
	ret

;r0 - slotspace base
;outputs:
;r0 - portA
LLFWK2PortA:
	addi r0, r0, 0x4004
	lrr.l r0, r0
	ret

;r0 - slotspace base
;outputs:
;r0 - portB
LLFWK2PortB:
	addi r0, r0, 0x4008
	lrr.l r0, r0
	ret

;r0 - slotspace base
;outputs:
;r0 - portC
LLFWK2PortC:
	addi r0, r0, 0x400C
	lrr.l r0, r0
	ret

;r0 - slotspace base
;r1 - command
LLFWK2Command:
	push r3
	push r2

	addi r3, r0, 0x4000

	;wait for board to become available
.wait:
	lrr.b r2, r3
	cmpi r2, 0
	bne .wait

	srr.b r3, r1

	;wait for board to complete command
.waitb:
	lrr.b r2, r3
	cmpi r2, 0
	bne .waitb

	pop r2
	pop r3
	ret

;r0 - slotspace base
;outputs:
;r0 - width
;r1 - height
LLFWK2Size:
	li r1, 1
	call LLFWK2Command

	push r0
	call LLFWK2PortB
	mov r1, r0
	pop r0

	call LLFWK2PortA

	ret

;r0 - slotspace base
;outputs:
;r0 - fb
LLFWK2FB:
	addi r0, r0, 0x100000
	ret

;r0 - slotspace base
;r1 - color
LLFWK2Fill:
	push r2
	push r1
	push r0
	call LLFWK2Size
	lshi r2, r0, 16
	ior r2, r2, r1
	pop r0
	push r0
	mov r1, r2
	call LLFWK2WPortA
	li r1, 0
	pop r0
	push r0
	call LLFWK2WPortB
	pop r0
	pop r1
	push r0
	call LLFWK2WPortC
	pop r0
	li r1, 2
	call LLFWK2Command
	pop r2
	ret

;r0 - width
;r1 - height
;r2 - ptr
;r3 - slotspace base
LLFWK2BlitIcon:
	push r4
	push r5
	push r6
	push r7
	push r8

	mov r7, r0
	mov r8, r1

	mov r0, r3
	call LLFWK2Size
	mov r6, r0

	mov r0, r3
	call LLFWK2FB
	mov r3, r0

	push r9
	push r10
	push r11
	push r12
	divi r9, r7, 2 ;r9 has half of icon width
	divi r10, r8, 2 ;r10 has half of icon height
	divi r11, r6, 2 ;r11 has half of screen width
	divi r12, r1, 2 ;r12 has half of screen height
	sub r11, r11, r9
	sub r12, r12, r10
	mul r12, r12, r6
	add r12, r12, r11
	add r3, r3, r12
	pop r12
	pop r11
	pop r10
	pop r9

	mov r4, r2

	;scratch: r2, r5

	;menugwidth - r6
	;ptr - r4
	;fbp - r3

	;row - r0
	;col - r1

	li r0, 0

	.rowloop:
		cmp r0, r8
		bge .rlo

		li r1, 0

		.colloop:
			cmp r1, r7
			bge .clo

			add r5, r3, r1
			lrr.b r2, r4
			srr.b r5, r2

			addi r4, r4, 1
			addi r1, r1, 1
			b .colloop

		.clo:

		add r3, r3, r6
		addi r0, r0, 1
		b .rowloop

	.rlo:

	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	ret