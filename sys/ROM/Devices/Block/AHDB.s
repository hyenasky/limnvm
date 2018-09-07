;AISA Hard Disk Bus driver

;AHDB supports 8 hot-pluggable drives, but we only statically register them at boot here.
;so if someone attaches a disk they want to boot from, they need to reboot the machine.
;we will print a warning message about it

;this is firmware so we get to be very lazy.
;our IO is blocking, once its initiated, it spins until we receive interrupt 0x31 with
;proper details

AHDBCmdPort === 0x18
AHDBPortA === 0x19
AHDBPortB === 0x1A

AHDBCmdSelect === 0x1
AHDBCmdRead === 0x2
AHDBCmdWrite === 0x3
AHDBCmdInfo === 0x4
AHDBCmdPoll === 0x5

AHDBInfoDMA === 0x0
AHDBInfoAttach === 0x1
AHDBInfoRemove === 0x2

AHDBInt === 0x31

AHDSpin:
	push r0

.spin:
	lri.b r0, AHDSpinning
	cmpi r0, 0
	bne .spin

	pop r0
	ret

AHDInterrupt:
	pusha

	li r0, AHDBCmdPort
	li r1, AHDBCmdInfo
	call BusCommand

	li r0, AHDBPortA
	call BusReadByte

	cmpi r0, AHDBInfoDMA
	be .dma

	cmpi r0, AHDBInfoAttach
	be .hotplug

	cmpi r0, AHDBInfoRemove
	be .hotplug

	b .out

.hotplug:
	li r0, AHDBWarningString
	call PutString

	b .out

.dma:
	sii.b AHDSpinning, 0

.out:
	popa
	iret

AHDBWarningString:
	.ds Do not hotplug disks in Antecedent!
	.db 0xA
	.ds Please restart or you may brutally mess something up.
	.db 0xA, 0x0

;r0 - drive number
AHDRegister:
	push r1

	lri.b r2, AHDLastMin
	addi r1, r2, AHDBDevTab
	srr.b r1, r0

	addi r2, r2, 1
	sir.b AHDLastMin, r2

	pop r1
	ret

AHDBInit:
	sii.b AHDSpinning, 0

	li r0, AHDBInt
	li r1, AHDInterrupt
	call InterruptRegister

	ret

;r0 - drive
;outputs:
;r0 - exists?
;r1 - size
AHDPoll:
	mov r1, r0
	li r0, AHDBPortA
	call BusWriteByte

	li r0, AHDBCmdPort
	li r1, AHDBCmdPoll
	call BusCommand

	li r0, AHDBPortB
	call BusReadByte

	mov r1, r0

	li r0, AHDBPortA
	call BusReadByte

	ret

;r0 - drive
AHDSelect:
	push r1

	mov r1, r0
	li r0, AHDBPortA
	call BusWriteLong

	li r0, AHDBCmdPort
	li r1, AHDBCmdSelect
	call BusCommand

	pop r1
	ret

;r0 - minor
;r1 - block num
;r2 - buf ptr
AHDReadBlock:
	call AHDSelect

	li r0, AHDBPortA
	call BusWriteLong

	li r0, AHDBPortB
	mov r1, r2
	call BusWriteLong

	sii.b AHDSpinning, 1

	li r0, AHDBCmdPort
	li r1, AHDBCmdRead
	call BusCommand

	call AHDSpin
	ret

;r0 - minor
;r1 - block num
;r2 - buf ptr
AHDWriteBlock:
	call AHDSelect

	li r0, AHDBPortA
	call BusWriteLong

	li r0, AHDBPortB
	mov r1, r2
	call BusWriteLong

	sii.b AHDSpinning, 1

	li r0, AHDBCmdPort
	li r1, AHDBCmdWrite
	call BusCommand

	call AHDSpin
	ret