;amanatsu bus

AmanatsuPortSDev === 0x30
AmanatsuPortMID === 0x31
AmanatsuPortCMD === 0x32
AmanatsuPortA === 0x33
AmanatsuPortB === 0x34

;r0 - dev
;r1 - num
;trashes the currently selected device!
AmanatsuSetInterrupt:
	push r2
	push r3

	mov r2, r0
	mov r3, r1

	li r0, 0
	call AmanatsuSelectDev

	mov r0, r3
	call AmanatsuWritePortA
	mov r0, r2
	call AmanatsuWritePortB
	li r0, 1
	call AmanatsuCommand

	pop r3
	pop r2
	ret

;r0 - dev
AmanatsuSelectDev:
	push r1

	mov r1, r0
	li r0, AmanatsuPortSDev
	call BusWriteByte

	pop r1
	ret

;r0 - command
AmanatsuCommand:
	push r1

	mov r1, r0
	li r0, AmanatsuPortCMD
	call BusWriteByte

.spin:
	li r0, AmanatsuPortCMD
	call BusReadByte
	cmpi r0, 0
	bne .spin

	pop r1
	ret

;outputs:
;r0 - MID
AmanatsuReadMID:
	li r0, AmanatsuPortMID
	call BusReadLong
	ret

;outputs:
;r0 - portA
AmanatsuReadPortA:
	li r0, AmanatsuPortA
	call BusReadLong
	ret

;outputs:
;r0 - portB
AmanatsuReadPortB:
	li r0, AmanatsuPortB
	call BusReadLong
	ret

;r0 - v
AmanatsuWritePortA:
	push r1

	mov r1, r0
	li r0, AmanatsuPortA
	call BusWriteLong

	pop r1
	ret

;r0 - v
AmanatsuWritePortB:
	push r1

	mov r1, r0
	li r0, AmanatsuPortB
	call BusWriteLong

	pop r1
	ret