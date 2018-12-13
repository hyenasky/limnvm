SerialCmdPort === 0x10
SerialDataPort === 0x11

SerialCmdWrite === 1
SerialCmdRead === 2

SerialInit:
	
	li r0, SerialWrite
	li r1, SerialRead
	call CharDevRegister

	ret

;outputs:
;r0 - byte
SerialRead:
	push r1

	push rs
	bclri rs, rs, 1

	li r0, SerialCmdPort
	li r1, SerialCmdRead
	call BusCommand

	li r0, SerialDataPort
	call BusReadInt

	pop rs

	pop r1
	ret

;r0 - byte
SerialWrite:
	push r1

	push rs
	bclri rs, rs, 1

	mov r1, r0
	li r0, SerialDataPort
	call BusWriteByte

	li r0, SerialCmdPort
	li r1, SerialCmdWrite
	call BusCommand

	pop rs

	pop r1
	ret