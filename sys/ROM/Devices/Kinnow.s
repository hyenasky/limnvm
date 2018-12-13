;driver for variable resolution 8-bit color display

;depends on routines from Blitter.s

;constants
GraphicsPixelsPerByte === 1
GraphicsBitsPerPixel === 8

GraphicsGPUCmdPort === 0x12
GraphicsGPUPortA === 0x13
GraphicsGPUPortB === 0x14
GraphicsGPUPortC === 0x15

GraphicsGPUInfo === 0x1
GraphicsGPURectangle === 0x2
GraphicsGPUVSync === 0x3
GraphicsGPUScroll === 0x4
GraphicsGPUPresent === 0x5

GraphicsInt === 0x35

GraphicsVSyncInterrupt:
	iret

GraphicsInit:
	push r0
	push r1

	li r0, GraphicsInt
	li r1, GraphicsVSyncInterrupt
	call InterruptRegister

	;request info from gpu
	push rs
	bclri rs, rs, 1

	li r0, GraphicsGPUCmdPort
	li r1, GraphicsGPUInfo
	call BusCommand

	li r0, GraphicsGPUPortA
	call BusReadInt
	sir.i GraphicsWidth, r0

	li r0, GraphicsGPUPortB
	call BusReadInt
	sir.i GraphicsHeight, r0

	pop rs

	lri.i r1, GraphicsWidth

	;cache some information

	;r1xr0

	mul r0, r1, r0
	addi r0, r0, GraphicsFBStart
	sir.l GraphicsFBEnd, r0

	sir.i GraphicsBytesPerRow, r1

	pop r1
	pop r0
	ret

;r0 - pointer to 8-bit image to blit
GraphicsBlitScreen:
	push r1
	push r2
	push r3
	push r4

	mov r1, r0 ;from
	li r2, GraphicsFBStart ;dest
	lri.i r3, GraphicsWidth
	lri.i r4, GraphicsHeight
	lshi r4, r4, 16
	ior r3, r3, r4 ;dim
	li r4, 0 ;modulo
	li r0, 1 ;COPY
	call BlitterOperation

	pop r4
	pop r3
	pop r2
	pop r1
	ret

;r1 - color
;r1 is trashed.
GraphicsFillScreen:
	push r0
	push r2
	push r3
	push r4

	mov r4, r1

	li r0, 0
	li r1, 0

	lri.i r2, GraphicsWidth
	lri.i r3, GraphicsHeight

	call GraphicsFilledRectangle

	pop r4
	pop r3
	pop r2
	pop r0
	ret

;r0 - x
;r1 - y
;r2 - color
;trashes r0, r1, r2
GraphicsPutPixel:
	push r10

	lri.i r10, GraphicsBytesPerRow
	mul r1, r1, r10
	addi r1, r1, GraphicsFBStart

	add r1, r1, r0

	srr.b r1, r2

	pop r10
	ret

;r0 - x
;r1 - y
;r2 - width
;r3 - height
;r4 - color
GraphicsFilledRectangle:
	push rs
	bclri rs, rs, 1

	lshi r0, r0, 16
	ior r0, r0, r1

	mov r1, r0
	li r0, GraphicsGPUPortB
	call BusWriteLong

	lshi r2, r2, 16
	ior r2, r2, r3

	mov r1, r2
	li r0, GraphicsGPUPortA
	call BusWriteLong

	mov r1, r4
	li r0, GraphicsGPUPortC
	call BusWriteByte

	li r0, GraphicsGPUCmdPort
	li r1, GraphicsGPURectangle
	call BusCommand

	pop rs

	ret

;r0 - rows
;r1 - fill
GraphicsScrollScreen:
	push rs
	bclri rs, rs, 1

	push r1
	mov r1, r0
	li r0, GraphicsGPUPortA
	call BusWriteLong
	pop r1

	li r0, GraphicsGPUPortB
	call BusWriteLong

	li r0, GraphicsGPUCmdPort
	li r1, GraphicsGPUScroll
	call BusCommand

	pop rs

	ret

;r0 - rows
;r1 - fill
_SoftwareGraphicsScrollScreen:
	;algo works like this:
	;keep two counters:
	;the first starts at row 0+r0, or byte r0*GraphicsBytesPerRow + GraphicsFBStart
	;the second starts at row 0, or 0 + GraphicsFBStart

	;loop the following until the first counter reaches GraphicsFBEnd:
	;get long pointed to by counter 1
	;put at location pointed to by counter 2
	;increment counter 1 and 2 by 4

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






