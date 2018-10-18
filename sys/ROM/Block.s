;block device interface

;the block driver interface consists of
;registering a driver, with a given 8-bit
;"major" number.
;this major number has a structure associated
;with it which contains pointers to interface
;functions. this interface is detailed below

;works in blocks of 4kb

;+-------------------------------------------------------------
;|ReadBlock  | r0 - minor, r1 - block number, r2 - buffer
;+-------------------------------------------------------------
;|WriteBlock | r0 - minor, r1 - block number, r2 - buffer
;+-------------------------------------------------------------
;|List       |
;+-------------------------------------------------------------

;each individual device has a "minor" number
;associated with it. it is up to the driver to
;maintain internal bookkeeping on every
;individual device.

;a block device is identified with a 16-bit number.
;the least significant 8 bits are the minor number,
;the most significant 8 bits are the major number.

;the outward-facing block I/O interface is
;detailed below

;+-----------------------------------------------------------------------------------------------
;|ReadBlock     | r0 - device num, r1 - block number, r2 - buffer. outputs: r0 - error code (0 for success)
;+-----------------------------------------------------------------------------------------------
;|WriteBlock    | r0 - dev, r1 - block, r2 - buffer. outputs: r0 - error code (0 for success)
;+-----------------------------------------------------------------------------------------------
;|ListBDevs     | r0 - major
;+-----------------------------------------------------------------------------------------------

;and the control interface is here

;+----------------------------------------------------------------------------------------------
;|BlockDriverRegister | r0 - name, r1 - ReadBlock, r2 - WriteBlock. outputs: r0 - major number
;+----------------------------------------------------------------------------------------------

.struct BlockDriver
	ReadBlock 4
	WriteBlock 4
	NamePtr 4
	List 4
end-struct

BlockInit:
	sii.b BlockLastMajor, 0
	ret

BlockDriverString:
	.ds Block Devices:
	.db 0xA, 0x0

;r0 - dev num
;r1 - block num
;r2 - buffer
ReadBlock:
	push r3

	;get major in r3, minor in r0
	rshi r3, r0, 8
	andi r0, r0, 0xFF

	cmpi r3, 255 ;can't have more than 256 block drivers
	bge .no

	;put readblock ptr in r3
	muli r3, r3, BlockDriver_sizeof
	addi r3, r3, BlockDevTable
	addi r3, r3, BlockDriver_ReadBlock
	lrr.l r3, r3
	cmpi r3, 0 ;no block dev or not supported
	be .no

	call .e
	b .no

.e:
	br r3

.no:
	pop r3
	ret

;r0 - dev num
;r1 - block num
;r2 - buffer
WriteBlock:
	push r3

	;get major in r3, minor in r0
	rshi r3, r0, 8
	andi r0, r0, 0xFF

	cmpi r3, 255 ;can't have more than 256 block drivers
	bge .no

	;put readblock ptr in r3
	muli r3, r3, BlockDriver_sizeof
	addi r3, r3, BlockDevTable
	addi r3, r3, BlockDriver_WriteBlock
	lrr.l r3, r3
	cmpi r3, 0 ;no block dev or not supported
	be .no

	call .e
	b .no

.e:
	br r3

.no:
	pop r3
	ret

;r0 - major
ListBDevs:
	cmpi r0, 255
	bge .no

	muli r0, r0, BlockDriver_sizeof
	addi r0, r0, BlockDevTable
	addi r0, r0, BlockDriver_List
	lrr.l r0, r0
	cmpi r0, 0
	be .no

	call .e
	ret

.e:
	br r0

.no:
	ret

BlockDriverList:
	push r0
	push r3
	push r4
	push r5
	push r6

	li r0, BlockDriverString
	call PutString

	li r3, BlockDevTable
	li r4, 0
	lri.b r6, BlockLastMajor

.loop:
	cmp r4, r6
	be .out

	li r0, 0x9
	call StdPutChar

	mov r0, r4
	call PutIntegerD

	li r0, 0x20
	call StdPutChar

	addi r5, r3, BlockDriver_NamePtr
	lrr.l r0, r5
	call PutString

	li r0, 0xA
	call StdPutChar

	mov r0, r4
	call ListBDevs

	addi r4, r4, 1
	addi r3, r3, BlockDriver_sizeof
	b .loop

.out:
	pop r6
	pop r5
	pop r4
	pop r3
	pop r0

	ret

;r0 - name
;r1 - ReadBlock
;r2 - WriteBlock
;r3 - List
;outputs:
;r0 - major
BlockDriverRegister:
	push r3
	push r4
	push r5
	push r6

	mov r6, r3

	lri.b r3, BlockLastMajor

	muli r4, r3, BlockDriver_sizeof
	addi r4, r4, BlockDevTable

	addi r5, r4, BlockDriver_NamePtr
	srr.l r5, r0

	addi r5, r4, BlockDriver_ReadBlock
	srr.l r5, r1

	addi r5, r4, BlockDriver_WriteBlock
	srr.l r5, r2

	addi r5, r4, BlockDriver_List
	srr.l r5, r6

	addi r3, r3, 1
	sir.b BlockLastMajor, r3

	subi r0, r3, 1

	pop r6
	pop r5
	pop r4
	pop r3
	ret





























