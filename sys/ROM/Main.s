.include "Includes.s"

ResetFault === 1

;r0 - reset reason
;will be 0 if ok
;anything else means theres a reason, and a message will be printed from ScratchBuffer
Reset:
	bclri rs, rs, 1 ;make sure interrupts are off
	li sp, StackTop

	sir.b ResetReason, r0

	call InterruptInit
	call GraphicsInit
	call CharDevInit
	call BlockInit

	li r0, 0x11
	call StdPutChar

	;was there a reason for our reset?
	lri.b r0, ResetReason
	cmpi r0, 0
	be .normal ;nope, complete thinger

	;yep, print info string
	li r0, ScratchBuffer
	call PutString

.normal:
	call NVRAMInit
	call MmuInit
	call AHDBInit
	call BlitterInit

	call Monitor

	b Halt

BuildNum === #build

Halt:
	bclri rs, rs, 1 ;disable interrupts

.idle:
	b .idle