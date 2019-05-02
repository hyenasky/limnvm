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
	li r0, LLFWErrorStringC
	call LLFWSerialPuts

	pop r1
	pop r0
	call LLFWErrorGraphical

.wloop:
	call LLFWSerialRead
	cmpi r0, 0xFFFF
	bne .reset
	b .wloop

.reset:
	cmpi r0, "c"
	be .clear
	b .ro

.clear:
	andi r1, r1, 0xFFFF0000
	cmpi r1, 0x01000000 ;was it insufficient RAM that caused this error?
	be .ro ;then just reset

	li r0, 0
.cloop:
	cmpi r0, 1048576
	bge .ro

	sri.l r0, 0

	addi r0, r0, 4
	b .cloop

.ro:
	li r0, LLFWTermClear
	call LLFWSerialPuts

	b Reset

;r0 - message
;r1 - number (only thing displayed right now)
LLFWErrorGraphical:
	push r1
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
	pop r1
	ret

LLFWTermClear:
	.db 0x1B
	.ds [c
	.db 0x0

LLFWErrorString:
	.db 0xA
	.ds FATAL ERROR! Cannot continue initialization:
	.db 0xA, 0x9, 0x0

LLFWErrorStringB:
	.db 0x9
	.ds EC: 
	.db 0x0

LLFWErrorStringC:
	.ds Resetting on console input.
	.db 0xA
	.ds Press 'c' to clear bottom 1M of RAM.
	.db 0xA, 0x0

LLFWErrorBMP:
	.static llfw/llfwerror.bmp