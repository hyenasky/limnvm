ConsoleFont:
	.static Assets/font-terminus.bmp

;constants

ConsoleFontWidth === 8
ConsoleFontWidthA === 7 ;ConsoleFontWidth - 1
ConsoleFontBytesPerRow === 1
ConsoleFontHeight === 16
ConsoleOffsetX === 0
ConsoleOffsetY === 0
ConsoleBorderTotalX === 0
ConsoleBorderTotalY === 0

ConsoleCursorYOffset === 0
ConsoleCursorHeight === 16
ConsoleCursorWidth === 8

ConsoleBGDefault === 0x00
ConsoleFGDefault === 0x0F

ConsoleInit:
	push r0
	push r1

	sii.i ConsoleX, 0
	sii.i ConsoleY, 0

	sii.i ConsoleLastX, 0
	sii.i ConsoleLastY, 0

	sii.b ConsoleBGColor, ConsoleBGDefault
	sii.b ConsoleFGColor, ConsoleFGDefault

	lri.i r0, GraphicsWidth
	subi r0, r0, ConsoleBorderTotalX
	divi r0, r0, ConsoleFontWidth
	sir.b ConsoleWidth, r0

	mov r1, r0

	subi r0, r0, 1
	sir.b ConsoleWM, r0

	lri.i r0, GraphicsHeight
	subi r0, r0, ConsoleBorderTotalY
	divi r0, r0, ConsoleFontHeight
	sir.b ConsoleHeight, r0

	subi r0, r0, 1
	sir.b ConsoleHM, r0

	li r0, ConsolePutChar
	li r1, CharDevNull
	call CharDevRegister

	lri.i r0, GraphicsHeight
	cmpi r0, 0
	be .out

.out:
	pop r1
	pop r0
	ret

ConsoleClear:
	push r0

	push r1
	lri.b r1, ConsoleBGColor
	call GraphicsFillScreen
	pop r1

	sii.i ConsoleX, 0
	sii.i ConsoleY, 0

	sii.i ConsoleLastX, 0
	sii.i ConsoleLastY, 0

	pop r0
	ret

ConsoleNewline:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	sii.i ConsoleX, 0

	lri.i r0, ConsoleY
	addi r0, r0, 1

	sir.i ConsoleY, r0

	lri.b r1, ConsoleHM
	cmp r0, r1
	bl .out

	li r0, ConsoleFontHeight
	lri.b r1, ConsoleBGColor
	call GraphicsScrollScreen

	lri.b r1, ConsoleHM
	sir.i ConsoleY, r1

.out:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret

ConsoleClearCursor:
	push r0
	push r1
	push r2

	lri.i r1, ConsoleLastX
	lri.i r2, ConsoleLastY

	;now we clear the cursor for realsies
	li r0, 0x20
	call ConsolePlotChar

	pop r2
	pop r1
	pop r0
	ret

ConsoleDrawCursor:
	push r0
	push r1
	push r2
	push r3
	push r4

	lri.i r1, ConsoleX
	lri.i r2, ConsoleY

	sir.i ConsoleLastX, r1
	sir.i ConsoleLastY, r2

	muli r1, r1, ConsoleFontWidth
	muli r2, r2, ConsoleFontHeight

	addi r1, r1, ConsoleOffsetX
	addi r2, r2, ConsoleOffsetY

	addi r2, r2, ConsoleCursorYOffset

	;draw cursor
	lri.b r4, ConsoleFGColor
	
	;thunk over to GraphicsFilledRectangle
	mov r0, r1
	mov r1, r2
	li r2, ConsoleCursorWidth
	li r3, ConsoleCursorHeight

	call GraphicsFilledRectangle

	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret

;r0 - char
;r1 - x
;r2 - y
ConsolePlotChar:
	push r3
	push r4

	muli r1, r1, ConsoleFontWidth
	muli r2, r2, ConsoleFontHeight

	addi r1, r1, ConsoleOffsetX
	addi r2, r2, ConsoleOffsetY

	;draw background
	lri.b r4, ConsoleBGColor
	
	;thunk over to GraphicsFilledRectangle
	push r0
	push r1
	push r2

	mov r0, r1
	mov r1, r2
	li r2, ConsoleFontWidth
	li r3, ConsoleFontHeight

	call GraphicsFilledRectangle

	pop r2
	pop r1
	pop r0

	lri.b r3, ConsoleFGColor
	call ConsoleDrawChar

	pop r4
	pop r3
	ret

ConsoleBackspace === 0x7F
ConsoleClearScreen === 0x11

;r0 - char
ConsolePutChar:
	call ConsoleClearCursor

	;is it a newline?
	cmpi r0, 0xA
	bne .tabtest
	call ConsoleNewline
	b .r

.tabtest:
	;is it a tab?
	cmpi r0, 0x9
	bne .backtest

	;yes, put 2 spaces
	li r0, 0x20
	call ConsolePutChar

	li r0, 0x20
	call ConsolePutChar

	b .r

.backtest:
	;is it a backspace?
	cmpi r0, ConsoleBackspace
	bne .cleartest

	;yes, decrement ConsoleX or ConsoleY if necessary

	push r0

	lri.i r0, ConsoleX
	cmpi r0, 0 ;is it already 0?
	be .decY ;ye, decrement Y

	;nope, decrement X
	subi r0, r0, 1
	sir.i ConsoleX, r0
	b .goBackoutMoash

.decY:
	lri.i r0, ConsoleY
	cmpi r0, 0 ;is it already 0?
	be .goBackoutMoash ;yes, do nuffin then

	subi r0, r0, 1
	sir.i ConsoleY, r0

	lri.b r0, ConsoleWM
	sir.i ConsoleX, r0 ;set x to rightmost edge

.goBackoutMoash:
	pop r0
	b .r

.cleartest:
	;are we clearing the screen?
	cmpi r0, ConsoleClearScreen
	bne .cont

	call ConsoleClear
	b .r

.cont:
	push r1
	push r2
	push r3
	push r4
	push r5

	;store in buffer real fast
	lri.i r1, ConsoleX
	lri.i r2, ConsoleY

	call ConsolePlotChar

	lri.i r1, ConsoleX
	addi r1, r1, 1

	lri.b r5, ConsoleWM
	cmp r1, r5
	bl .nn

	call ConsoleNewline
	b .o
.nn:
	sir.i ConsoleX, r1

.o:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1

.r:
	call ConsoleDrawCursor

	ret

;r0 - char
;r1 - x
;r2 - y
;r3 - color
;draw bitmap character at specified location on screen
ConsoleDrawChar:
	;push r3 ;use r3 as y iterator
	push r4 ;use r4 as x iterator
	push r5 ;use r5 to store ptr to current byte in font to look at
	push r6 ;use r6 to store current byte
	push r7 ;use r7 for scratch in xloop
	push r8 ;use r8 to cache 0x7
	push r9 ;use r9 for more scratch in xloop
	push r10 ;use r10 to store color

	mov r10, r3

	muli r5, r0, ConsoleFontBytesPerRow
	muli r5, r5, ConsoleFontHeight
	addi r5, r5, ConsoleFont
	li r3, 0
.yloop:
	cmpi r3, ConsoleFontHeight
	bge .yend

	;body of y loop

	lrr.l r6, r5

	li r4, 0 ;ctr
	li r8, ConsoleFontWidthA ;reverse ctr
.xloop:
	cmpi r4, ConsoleFontWidth
	bge .ynext

	rsh r7, r6, r8
	andi r7, r7, 1
	cmpi r7, 1
	bne .xnext

	;thunk over to GraphicsPutPixel.
	;it expects x,y in r0,r1
	;and color in r2.
	;all of these get trashed so we
	;have to push them first.

	push r0
	push r1
	push r2

	add r0, r1, r4 ;add bx and x iterator
	add r1, r2, r3 ;add by and y iterator
	mov r2, r10 ;get color

	call GraphicsPutPixel

	pop r2
	pop r1
	pop r0

.xnext:
	addi r4, r4, 1
	subi r8, r8, 1
	b .xloop

.ynext:
	addi r5, r5, ConsoleFontBytesPerRow
	addi r3, r3, 1
	b .yloop

.yend:
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	ret






















