;AISA Hard Disk Bus driver

;AHDB supports 8 hot-pluggable drives, but we only statically register them at boot here.
;so if someone attaches a disk they want to boot from, they need to reboot the machine.
;we will print a warning message about it

;this is firmware so we get to be very lazy.
;our IO is blocking, once its initiated, it spins until we receive interrupt 0x31 with
;proper details

AHDBCmdPort === 0x19
AHDBPortA === 0x1A
AHDBPortB === 0x1B

AHDBCmdSelect === 0x1
AHDBCmdRead === 0x2
AHDBCmdWrite === 0x3
AHDBCmdInfo === 0x4
AHDBCmdPoll === 0x5

AHDBInfoDMA === 0x0
AHDBInfoAttach === 0x1
AHDBInfoRemove === 0x2

AHDBInt === 0x31

AHDBSpinTimeout === 0x100000

AHDSpin:
	push r0
	push r1
	li r1, 0

.spin:
	cmpi r1, AHDBSpinTimeout
	bge .timeout

	addi r1, r1, 1

	lri.b r0, AHDSpinning
	cmpi r0, 0
	bne .spin

.out:
	pop r1
	pop r0
	ret

.timeout:
	li r0, AHDBStringTimeout
	call PutString

	sii.b AHDSpinning, 0
	b .out

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
	li r0, AHDBConnectedString
	call PutString

	li r0, AHDBPortB
	call BusReadByte
	call PutIntegerD

	li r0, 0xA
	call StdPutChar

	b .out

.dma:
	sii.b AHDSpinning, 0

.out:
	popa
	iret

AHDBConnectedString:
	.ds AHDB: connected ahd
	.db 0x0

;just polls all drives and displays info to the user
AHDBPollAll:
	push r0
	push r1

	li r0, AHDBStringPoll
	call PutString

	li r0, 0

.loop:
	cmpi r0, 8
	be .out

	push r0
	call AHDPoll
	cmpi r0, 1
	be .ddec
	pop r0

.cont:
	addi r0, r0, 1
	b .loop

.ddec:
	li r0, AHDBStringA
	call PutString

	pop r0
	push r0
	call PutInteger

	li r0, AHDBStringB
	call PutString

	mov r0, r1
	call PutIntegerD

	li r0, AHDBStringC
	call PutString

	muli r0, r1, 4096
	call PutIntegerD

	li r0, AHDBStringD
	call PutString

	pop r0
	b .cont

.out:
	li r0, AHDBStringNM
	call PutString

	pop r1
	pop r0
	ret


AHDBStringTimeout:
	.ds AHDB ERROR: DMA timed out.
	.db 0xA, 0x0

AHDBStringPoll:
	.ds Polling AHDB...
	.db 0xA
	.ds drives:
	.db 0xA, 0x0

AHDBStringA:
	.db 0x9
	.ds ahd
	.db 0

AHDBStringB:
	.ds : 
	.db 0

AHDBStringC:
	.ds  blocks, 
	.db 0

AHDBStringD:
	.ds  bytes.
	.db 0xA, 0x0

AHDBStringNM:
	.db 0x9
	.ds none more.
	.db 0xA, 0x0

AHDBDName:
	.ds ahd
	.db 0x0

AHDBInit:
	sii.b AHDSpinning, 0

	li r0, AHDBInt
	li r1, AHDInterrupt
	call InterruptRegister

	li r0, AHDBDName
	li r1, AHDReadBlock
	li r2, AHDWriteBlock
	li r3, AHDBPollAll
	call BlockDriverRegister

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