;string operations

;r0 - pointer to string
;zero out a string
StringZero:
	push r1

.loop:
	lrr.b r1, r0
	cmpi r1, 0 ;end of string
	be .out

	sri.b r0, 0
	addi r0, r0, 1
	b .loop
	
.out:
	pop r1
	ret

;r0 - pointer to dest
;r1 - pointer to src
;copy string from src to dest, including \0
StringCopy:
	push r2

.loop:
	lrr.b r2, r1
	cmpi r2, 0
	be .out

	srr.b r0, r2

	addi r0, r0, 1
	addi r1, r1, 1
	b .loop

.out:
	addi r0, r0, 1
	sri.b r0, 0 ;store zero terminator

	pop r2
	ret

;r0 - pointer to string
;outputs:
;r0 - string length
StringLength:
	push r1
	push r2

.loop:
	lrr.b r1, r0
	cmpi r1, 0
	be .out

	addi r2, r2, 1
	b .loop

.out:
	mov r0, r2
	pop r2
	pop r1
	ret

;r0 - pointer to array
;outputs:
;r0 - integer

;converts a ascii form of a number into the number, e.g. "1234" > 1234
;performs NO checking on to see if its actually a number
;so if its something else you'll get garbage
StringToInteger:
	push r1
	push r2
	li r1, 0

.loop:
	lrr.b r2, r0
	cmpi r2, 0
	be .out

	muli r1, r1, 10
	subi r2, r2, "0"
	add r1, r1, r2

	addi r0, r0, 1
	b .loop

.out:
	mov r0, r1

	pop r2
	pop r1
	ret


;r0 - string
;r1 - buffer
;r2 - delimiter
;outputs:
;r0 - next token (or 0 if none)
StringTokenize:
	push r3

	lrr.b r3, r0
	cmpi r3, 0
	be .zero

.dloop:
	lrr.b r3, r0
	cmp r3, r2
	bne .loop

	addi r0, r0, 1
	b .dloop

.loop:
	lrr.b r3, r0

	cmp r3, r2
	be .out

	cmpi r3, 0
	be .zero

	srr.b r1, r3

	addi r1, r1, 1
	addi r0, r0, 1
	b .loop

.zero:
	li r0, 0

.out:
	pop r3
	ret

;r0 - string one
;r1 - string two
;outputs:
;r0 - are they the same?
StringCompare:
	push r3
	push r2

.loop:
	lrr.b r2, r0
	lrr.b r3, r1

	cmp r2, r3
	bne .false

	cmpi r2, 0
	be .true

	addi r0, r0, 1
	addi r1, r1, 1
	b .loop

.true:
	li r1, 1

.out:
	pop r2
	pop r3
	ret

.false:
	li r0, 0
	b .out














