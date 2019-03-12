;r0 - message
;r1 - number
LLFWError:
	li sp, 0x1FFF

	push r0
	push r1

	push r0
	li r0, LLFWErrorString
	call LLFWSerialPuts
	pop r0
	call LLFWSerialPuts
	li r0, LLFWErrorStringB
	call LLFWSerialPuts
	mov r0, r1
	call LLFWSerialPutInteger
	li r0, 0xA
	call LLFWSerialWrite

	pop r1
	pop r0
	call LLFWErrorGraphical
	b Hang

;r0 - message
;r1 - number (only thing displayed right now)
LLFWErrorGraphical:
	push r0
	call LLFWK2Find
	cmpi r0, 0
	be .out
	mov r2, r0

	li r1, 0x67
	call LLFWK2Fill

	mov r3, r2
	li r0, 213
	li r1, 69
	li r2, LLFWErrorBMP
	call LLFWK2BlitIcon

.out:
	pop r0
	ret

LLFWErrorString:
	.db 0xA
	.ds FATAL ERROR! Cannot continue initialization:
	.db 0xA, 0x9, 0x0

LLFWErrorStringB:
	.db 0x9
	.ds EC: 
	.db 0x0

LLFWErrorFont:
	.static llfw/llfwerrorfnt.bmp

LLFWErrorBMP:
	.static llfw/llfwerror.bmp