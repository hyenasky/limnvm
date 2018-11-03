.include Includes.s

ResetFault === 1

;r0 - reset reason
;will be 0 if ok
;anything else means theres a reason, and a message will be printed from ScratchBuffer
Reset:
	bclri rs, rs, 1 ;make sure interrupts are off
	li sp, StackTop

	sir.b ResetReason, r0

	call InterruptInit
	call CharDevInit
	call GraphicsInit
	call ConsoleInit
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
	call MmuInit

	li r0, himsg
	call PutString

	call AHDBInit

	call Monitor

	b Halt

BuildNum === #build

himsg:
	.ds   ___  _   _ _____ _____ _____ ___________ _____ _   _ _____ 
	.db 0xA
	.ds  / _ \| \ | |_   _|  ___/  __ |  ___|  _  |  ___| \ | |_   _|
	.db 0xA
	.ds / /_\ |  \| | | | | |__ | /  \| |__ | | | | |__ |  \| | | |  
	.db 0xA
	.ds |  _  | . ` | | | |  __|| |   |  __|| | | |  __|| . ` | | |  
	.db 0xA
	.ds | | | | |\  | | | | |___| \__/| |___| |/ /| |___| |\  | | |  
	.db 0xA
	.ds \_| |_\_| \_/ \_/ \____/ \____\____/|___/ \____/\_| \_/ \_/  
	.db 0xA
	.db 0xA
	.ds Version 1.1 (build 
	.ds$ BuildNum
	.ds )
	.db 0xA
	.ds Built on 
	.ds$ __DATE
	.db 0xA
	.ds Boot firmware for AISAv2 Lemon
	.db 0xA
	.ds Written by Will
	.db 0xA, 0xA, 0xA, 0xA, 0x0

Halt:
	bclri rs, rs, 1 ;disable interrupts

.idle:
	b .idle