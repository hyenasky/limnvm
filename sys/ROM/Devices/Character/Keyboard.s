;keyboard driver

KeyboardINum === 0x30

KeyboardCmdPort === 0x17
KeyboardDataPort === 0x18

KeyboardCmdPop === 0x1
KeyboardCmdReset === 0x2

KeyboardBufferSize === 256

KeyboardSpecial === 50

KeyboardInit:
	sii.b KeyboardWritePointer, 0
	sii.b KeyboardReadPointer, 0

	li r0, KeyboardINum
	li r1, KeyboardInterrupt
	call InterruptRegister

	li r0, KeyboardCmdPort
	li r1, KeyboardCmdReset
	call BusCommand

	ret

;returns:
;r0 - scancode
KeyboardPopScan:
	push r1
	li r0, KeyboardCmdPort
	li r1, KeyboardCmdPop
	call BusCommand
	pop r1

	li r0, KeyboardDataPort
	call BusReadInt

	ret

;r0 - char
;puts a char in the circular buffer.
;if full, it just loops back around.
KeyboardPutBuffer:
	push r1

	bclri rs, rs, 1 ;disable interrupts

	lri.b r1, KeyboardWritePointer
	addi r1, r1, KeyboardBuffer
	srr.b r1, r0

	lri.b r1, KeyboardWritePointer
	addi r1, r1, 1
	cmpi r1, KeyboardBufferSize
	be .full

	sir.b KeyboardWritePointer, r1

	b .out

.full:
	sii.b KeyboardWritePointer, 0

.out:

	bseti rs, rs, 1 ;enable interrupts

	pop r1
	ret

;returns:
;r0 - char (or 0xFFFF if empty (read pointer = write pointer))
KeyboardPopBuffer:
	push r1
	push r2

	bclri rs, rs, 1 ;disable interrupts

	lri.b r1, KeyboardWritePointer
	lri.b r2, KeyboardReadPointer

	cmp r1, r2
	be .empty

	cmpi r2, KeyboardBufferSize
	be .edge

	addi r2, r2, KeyboardBuffer
	lrr.b r0, r2

	lri.b r2, KeyboardReadPointer
	addi r2, r2, 1

	sir.b KeyboardReadPointer, r2

	b .out

.edge:
	sii.b KeyboardReadPointer, 0
	
	lri.b r0, KeyboardBuffer

	b .out

.empty:
	li r0, 0xFFFF

.out:

	bseti rs, rs, r1 ;enable interrupts

	pop r2
	pop r1
	ret

KeyboardInterrupt:
	pusha

	call KeyboardPopScan

.cont:
	;are we shift or ctrl'd?
	cmpi r0, 0xF0
	be .shift

	cmpi r0, 0xF1
	be .ctrl

	;no, normal scancode

	cmpi r0, KeyboardSpecial ;are we a special key?
	bge .special ;yus

	;nope, char

	addi r0, r0, KeyboardLayout
	lrr.b r0, r0 ;get char

	;do stuff with char
	b .char

.shift:
	call KeyboardPopScan

	cmpi r0, KeyboardSpecial
	bge .special

	addi r0, r0, KeyboardLayoutShift
	lrr.b r0, r0 ;get char

	b .char

.ctrl:
	call KeyboardPopScan

	cmpi r0, KeyboardSpecial
	bge .special

	addi r0, r0, KeyboardLayoutCtrl
	lrr.b r0, r0 ;get char

	cmpi r0, "c" ;reset if ctrl-C
	be Reset

	b .char

.special:
	cmpi r0, 50 ;return
	be .return

	cmpi r0, 51 ;backspace
	be .backspace

	b .out

.return:
	li r0, 0xA
	call KeyboardPutBuffer

	b .out

.backspace:
	li r0, 0x7F
	call KeyboardPutBuffer

	b .out

.char:
	;at this point, r0 contains the ascii translation of the scancode

	;put in buffer
	call KeyboardPutBuffer

.out:
	popa
	iret



KeyboardRead:
	call KeyboardPopBuffer
	ret

KeyboardWrite:
	ret

; keyboard layout maps

KeyboardLayout:
	.db "a"
	.db "b", "c", "d"
	.db "e", "f", "g"
	.db "h", "i", "j"
	.db "k", "l", "m"
	.db "n", "o", "p"
	.db "q", "r", "s"
	.db "t", "u", "v"
	.db "w", "x", "y"
	.db "z"
	.db "0", "1", "2"
	.db "3", "4", "5"
	.db "6", "7", "8"
	.db "9"
	.db ";"
	.db 0x20
	.db 0x20
	.db "-"
	.db "="
	.db "["
	.db "]"
	.db "\"
	.db ";"
	.db "/"
	.db "."
	.db "'"
	.db ","

KeyboardLayoutCtrl:
	.db "a"
	.db "b", "c", "d"
	.db "e", "f", "g"
	.db "h", "i", "j"
	.db "k", "l", "m"
	.db "n", "o", "p"
	.db "q", "r", "s"
	.db "t", "u", "v"
	.db "w", "x", "y"
	.db "z"
	.db "0", "1", "2"
	.db "3", "4", "5"
	.db "6", "7", "8"
	.db "9"
	.db ";"
	.db 0x20
	.db 0x20
	.db "-"
	.db "="
	.db "["
	.db "]"
	.db "\"
	.db ";"
	.db "/"
	.db "."
	.db "'"
	.db ","

KeyboardLayoutShift:
	.db "A"
	.db "B", "C", "D"
	.db "E", "F", "G"
	.db "H", "I", "J"
	.db "K", "L", "M"
	.db "N", "O", "P"
	.db "Q", "R", "S"
	.db "T", "U", "V"
	.db "W", "X", "Y"
	.db "Z"
	.db ")", "!", "@"
	.db "#", "$", "%"
	.db "^", "&", "*"
	.db "("
	.db ":"
	.db 0x20
	.db 0x20
	.db "_"
	.db "+"
	.db "{"
	.db "}"
	.db "|"
	.db ":"
	.db "?"
	.db ">"
	.db """
	.db "<"