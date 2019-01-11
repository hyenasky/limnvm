FaultDivByZero === 0
FaultInvalidOp === 1
FaultPageFault === 2
FaultPrivilege === 3
FaultGeneral === 4
FaultFatal === 5
FaultDouble === 6

;register faults handler
FaultsInit:
	push r0
	push r1

	li r0, 0
.loop:
	cmpi r0, 10
	bge .end

	muli r1, r0, 4
	addi r1, r1, InterruptVectorTable

	sri.l r1, FaultsHandler

	addi r0, r0, 1
	b .loop

.end:
	pop r1
	pop r0
	ret

FaultsHandler:
	pusha

	mov r1, r0

	cmpi r1, FaultFatal
	be .abort

	b .r

.abort:
	muli r0, r1, 4
	addi r0, r0, FaultsStringsTab
	lrr.l r0, r0
	call PutString

	b Halt

.r:
	;reset
	mov r2, r1

	li r0, ScratchBuffer
	call StringZero

	li r0, ScratchBuffer
	li r1, FaultsMsg
	call StringCopy

	muli r1, r2, 4
	addi r1, r1, FaultsStringsTab
	lrr.l r1, r1

	li r0, ScratchBuffer
	addi r0, r0, 11 ;length of FaultsMsg string
	call StringCopy

	li r0, 1
	b Reset

FaultsMsg:
	.ds Exception: 
	.db 0

FaultsStrings:
	FaultsString0:
		.ds Division by zero
		.db 0xA, 0
	FaultsString1:
		.ds Invalid opcode
		.db 0xA, 0
	FaultsString2:
		.ds Page fault
		.db 0xA, 0
	FaultsString3:
		.ds Privilege violation
		.db 0xA, 0
	FaultsString4:
		.ds General fault
		.db 0xA, 0
	FaultsString5:
		.ds Fatal fault
		.db 0xA, 0
	FaultsString6:
		.ds Double fault
		.db 0xA, 0
	FaultsString7:
		.ds Bus error
		.db 0xA, 0
	FaultsString8:
		.ds I/O error
		.db 0xA, 0
	FaultsStringUnknown:
		.ds Unknown fault
		.db 0xA, 0

FaultsStringsTab:
	.dl FaultsString0
	.dl FaultsString1
	.dl FaultsString2
	.dl FaultsString3
	.dl FaultsString4
	.dl FaultsString5
	.dl FaultsString6
	.dl FaultsString7
	.dl FaultsString8
	.dl FaultsStringUnknown