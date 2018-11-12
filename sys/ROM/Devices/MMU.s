MmuAreaBase === 0xFFF20000
MmuRegisterPMS === 0

;r0 - register
;outputs:
;r0 - contents
MmuReadRegister:
	muli r0, r0, 4
	addi r0, r0, MmuAreaBase

	lrr.l r0, r0
	ret

;r0 - register
;r1 - new contents
MmuWriteRegister:
	muli r0, r0, 4
	addi r0, r0, MmuAreaBase

	srr.l r0, r1
	ret

MmuInit:
	li r0, MmuStringA
	call PutString

	li r0, MmuRegisterPMS
	call MmuReadRegister

	sir.l TotalMemory, r0

	divi r0, r0, 1048576
	call PutIntegerD

	li r0, MmuStringB
	call PutString

	ret

;outputs:
;r0 - RAM
MmuGetRAM:
	lri.l r0, TotalMemory
	ret

MmuStringA:
	.ds RAM: 
	.db 0x0

MmuStringB:
	.ds MB
	.db 0xA, 0x0