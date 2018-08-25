IntegerChars:
	.ds 0123456789abcdef

;r0 - number
;recursive but there shouldnt be risk of stack overflow
;since 32 bit numbers cant get big enough to do that easily.
;hexadecimal
PutInteger:
	push r0
	push r1
	push r2

	mov r2, r0
	divi r0, r0, 16
	modi r1, r2, 16
	cmpi r0, 0
	be .ldigit

	call PutInteger

.ldigit:
	addi r1, r1, IntegerChars
	lrr.b r0, r1

	call StdPutChar

	pop r2
	pop r1
	pop r0
	ret

;r0 - number
;recursive but there shouldnt be risk of stack overflow
;since 32 bit numbers cant get big enough to do that easily.
;decimal
PutIntegerD:
	push r0
	push r1
	push r2

	mov r2, r0
	divi r0, r0, 10
	modi r1, r2, 10
	cmpi r0, 0
	be .ldigit

	call PutIntegerD

.ldigit:
	addi r1, r1, IntegerChars
	lrr.b r0, r1

	call StdPutChar

	pop r2
	pop r1
	pop r0
	ret

;r0 - pointer to zero-terminated string
;r0 is trashed
PutString:
	push r1
	mov r1, r0

.loop:
	lrr.b r0, r1
	cmpi r0, 0
	be .out

	call StdPutChar

	addi r1, r1, 1
	b .loop

.out:
	pop r1
	ret

CharNone === 0xFFFF
CharBackspace === 0x7F
CharReturn === 0xA

;r0 - pointer to buffer
;r1 - max chars
GetString:
	push r2 ;char counter
	push r3

	mov r3, r0
	li r2, 0
.loop:
	call StdGetChar
	cmpi r0, CharNone ;no char (non-blocking)
	be .loop

	cmpi r0, CharBackspace
	be .backspace

	cmpi r0, CharReturn
	be .return

	b .char

.return: ;done
	call StdPutChar ;put newline
	b .out

.backspace:
	;backspace

	cmpi r2, 0 ;is the buffer empty already?
	be .loop ;yes, loop

	;no, continue backspace

	call StdPutChar ;put backspace

	subi r3, r3, 1
	sri.b r3, 0 ;erase char from buf
	subi r2, r2, 1 ;decrement char counter and buf ptr

	b .loop ;loop

.char:
	cmp r2, r1 ;is the buffer full?
	be .loop ;ye, go back to the start

	;nope: store, echo, and increment stuff

	srr.b r3, r0 ;store

	call StdPutChar ;echo

	addi r2, r2, 1 ;increment
	addi r3, r3, 1
	b .loop

.out:
	pop r3
	pop r2
	ret