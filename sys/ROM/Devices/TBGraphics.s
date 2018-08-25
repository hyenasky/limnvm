;DEPRECATED
;here for posterity

;driver for 640x480 2-bit monochrome display

;constants
GraphicsPixelsPerByte === 4
GraphicsBitsPerPixel === 2

GraphicsGPUCmdPort === 0x12
GraphicsGPUPortA === 0x13
GraphicsGPUPortB === 0x14

GraphicsGPUInfo === 0x1

GraphicsInit:
	push r0
	push r1

	;request info from gpu
	li r0, GraphicsGPUCmdPort
	li r1, GraphicsGPUInfo
	call BusCommand

	li r0, GraphicsGPUPortA
	call BusReadInt
	sir.i GraphicsWidth, r0

	li r0, GraphicsGPUPortB
	call BusReadInt
	sir.i GraphicsHeight, r0

	lri.i r1, GraphicsWidth

	;cache some information

	;r1xr0

	mul r0, r1, r0
	divi r0, r0, 4
	addi r0, r0, GraphicsFBStart
	sir.l GraphicsFBEnd, r0

	divi r1, r1, 4
	sir.i GraphicsBytesPerRow, r1

	pop r1
	pop r0
	ret

;r0 - pointer to 2-bit grayscale image to blit
GraphicsBlitScreen:
	push r1
	push r2

	li r1, GraphicsFBStart
	lri.l r2, GraphicsFBEnd

.loop:
	cmp r1, r2
	bge .end

	lrr.l r3, r0
	srr.l r1, r3

	addi r1, r1, 4
	addi r0, r0, 4
	b .loop

.end:

	pop r2
	pop r1
	ret

;r1 - color pattern
;r1 is trashed.
GraphicsFillScreen:
	push r0
	push r2

	li r0, GraphicsFBStart

	lri.l r2, GraphicsFBEnd
.loop:
	cmp r0, r2
	bge .out

	srr.l r0, r1

	addi r0, r0, 4
	b .loop

.out:
	pop r2
	pop r0
	ret

;r0 - x
;r1 - y
;r2 - color
;trashes r0, r1, r2
GraphicsPutPixel:
	push r3
	push r4
	push r10

	lri.i r10, GraphicsBytesPerRow
	mul r1, r1, r10
	divi r3, r0, GraphicsPixelsPerByte
	add r1, r1, r3
	addi r1, r1, GraphicsFBStart
	;r1 now contains the address of the byte containing the pixel

	modi r3, r0, GraphicsPixelsPerByte
	muli r3, r3, GraphicsBitsPerPixel
	;r3 now contains the bit where the pixel starts within the byte

	lsh r2, r2, r3

	li r4, 3
	lsh r4, r4, r3
	not r4, r4
	;r4 now contains a maskyboi

	lrr.b r3, r1
	;r3 now contains the byte containing the pixel

	and r3, r3, r4
	;mask off r3

	ior r3, r3, r2
	;now contains byte with our new color

	srr.b r1, r3
	;store bacc

	pop r10
	pop r4
	pop r3
	ret

;r0 - x
;r1 - y
;r2 - width
;r3 - height
;r4 - color
GraphicsFilledRectangle:
	add r2, r2, r0 ;furthest reaches of xloop
	add r3, r3, r1 ;furthest reaches of yloop

	push r5 ;yloop iterator
	push r6 ;xloop iterator

	mov r5, r1
.yloop:
	cmp r5, r3
	bge .end

	mov r6, r0
	.xloop:
		cmp r6, r2
		bge .next

		push r2
		push r1
		push r0

		mov r0, r6
		mov r1, r5
		mov r2, r4
		call GraphicsPutPixel
		pop r0
		pop r1
		pop r2

		addi r6, r6, 1
		b .xloop

.next:
	addi r5, r5, 1
	b .yloop

.end:
	pop r6
	pop r5
	ret

;r0 - rows
;r1 - fill
GraphicsScrollScreen:
	;algo works like this:
	;keep two counters:
	;the first starts at row 0+r0, or byte r0*GraphicsBytesPerRow + GraphicsFBStart
	;the second starts at row 0, or 0 + GraphicsFBStart

	;loop the following until the first counter reaches GraphicsFBEnd:
	;get long pointed to by counter 1
	;put at location pointed to by counter 2
	;increment counter 1 + 2 by 4

	;then, set a counter to GraphicsFBEnd - r0*GraphicsBytesPerRow
	;loop the following until the counter reaches GraphicsFBEnd:
	;put long r1 (fill) at the location pointer to by the counter

	;use r2, and r3 for the first and second counter respectively
	;then, use r2 for the backfill counter

	;cache GraphicsFBEnd in r4
	;cache GraphicsBytesPerRow in r5

	;any extra scratch is r6 and beyond

	;godspeed, me

	push r2
	push r3
	push r4
	push r5
	push r6
	push r7

	lri.l r4, GraphicsFBEnd
	lri.i r5, GraphicsBytesPerRow

	mul r7, r0, r5
	mov r2, r7
	addi r2, r2, GraphicsFBStart

	li r3, GraphicsFBStart

.scroll:
	cmp r2, r4
	bge .backfill

	lrr.l r6, r2
	srr.l r3, r6

	addi r2, r2, 4
	addi r3, r3, 4
	b .scroll

.backfill:
	
	sub r2, r4, r7
.loop:
	cmp r2, r4
	bge .end

	srr.l r2, r1

	addi r2, r2, 4
	b .loop

.end:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	ret

;r0 - x1
;r1 - y1
;r2 - x2
;r3 - y2
;r4 - rows
;r5 - fill

;x coordinates MUST be divisible by 16. this is a
;optimized boi who uses longs at a time, each byte
;can hold 4 pixels and so 4 bytes can hold 16
GraphicsScrollAreaFast:
	;we're memory oriented so convert this to
	;something immediately usable in pointer math
	divi r0, r0, 4
	divi r2, r2, 4

	;TODO

	ret







