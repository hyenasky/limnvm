;turn the serial port into a block device in order to boot from it
;will read 4096 bytes from serial port into a buffer and then return

;this is read-only, writes are no-ops

;the byte 0x4E will be written to initiate the read
;followed by the block number (may or may not be discarded)
;which is written as 4 subsequent bytes, most significant first
;we spin until we get 0x4E back, which signals the start of the read.
;then, 4096 bytes will be read into the buffer.

;only supports 1 port, minor #0

;r0 - minor
;r1 - block num
;r2 - buf ptr
SerialReadBlock:
	;ayo we startin
	li r0, 0x4E
	call SerialWrite

	;write sector number
	rshi r0, r1, 24
	andi r0, r0, 0xFF
	call SerialWrite

	rshi r0, r1, 16
	andi r0, r0, 0xFF
	call SerialWrite

	rshi r0, r1, 8
	andi r0, r0, 0xFF
	call SerialWrite

	andi r0, r1, 0xFF
	call SerialWrite

	;spin til ACK
.spin:
	call SerialRead
	cmpi r0, 0x4E
	bne .spin

	;read block
	push r3
	li r3, 0
.read:
	cmpi r3, 4096
	be .out

.rspin:
	call SerialRead
	cmpi r0, 0xFFFF
	be .rspin

	srr.b r2, r0

	addi r3, r3, 1
	addi r2, r2, 1
	b .read

.out:
	pop r3
	ret

SerialWriteBlock:
	ret