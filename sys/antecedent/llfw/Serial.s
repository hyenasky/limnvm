LLFWSerialPortA === 0xF8000040
LLFWSerialPortB === 0xF8000044

;r0 - char
LLFWSerialWrite:
	push r1

	;wait for serial port to become available
.wait:
	lri.b r1, LLFWSerialPortA
	cmpi r1, 0
	bne .wait

	sir.b LLFWSerialPortB, r0
	sii.b LLFWSerialPortA, 1

	pop r1
	ret

;r0 - ptr to string
LLFWSerialPuts:
	push r1
	mov r1, r0

.loop:
	lrr.b r0, r1
	cmpi r0, 0
	be .out

	call LLFWSerialWrite

	addi r1, r1, 1
	b .loop

.out:
	pop r1
	ret

LLFWSerialIntegerChars:
	.ds 0123456789ABCDEF

;r0 - number
;recursive but there shouldnt be risk of stack overflow
;since 32 bit numbers cant get big enough to do that easily.
;hexadecimal
LLFWSerialPutInteger:
	push r0
	push r1
	push r2

	mov r2, r0
	divi r0, r0, 16
	modi r1, r2, 16
	cmpi r0, 0
	be .ldigit

	call LLFWSerialPutInteger

.ldigit:
	addi r1, r1, LLFWSerialIntegerChars
	lrr.b r0, r1

	call LLFWSerialWrite

	pop r2
	pop r1
	pop r0
	ret