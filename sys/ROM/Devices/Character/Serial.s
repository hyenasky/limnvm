SerialCmdPort === 0x10
SerialDataPort === 0x11

SerialCmdWrite === 1
SerialCmdRead === 2

;outputs:
;r0 - byte
SerialRead:
	push r1

	li r0, SerialCmdPort
	li r1, SerialCmdRead
	call BusCommand

	li r0, SerialDataPort
	call BusReadInt

	pop r1
	ret

;r0 - byte
SerialWrite:
	push r1

	mov r1, r0
	li r0, SerialDataPort
	call BusWriteByte

	li r0, SerialCmdPort
	li r1, SerialCmdWrite
	call BusCommand

	pop r1
	ret