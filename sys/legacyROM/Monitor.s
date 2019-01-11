Monitor:
	li r0, himsg
	call PutString

	lri.b r0, NVRAM_AutorunBuffer
	cmpi r0, 0
	be .cont

	;autorun

	li r0, MonitorStringRWC
	call PutString
	li r0, NVRAM_AutorunBuffer
	call PutString
	li r0, 0xA
	call StdPutChar
	li r0, 0xA
	call StdPutChar

	li r0, MonitorBuffer
	call StringZero

	li r0, MonitorBuffer
	li r1, NVRAM_AutorunBuffer
	call StringCopy

	sii.b NVRAM_AutorunBuffer, 0

	li r0, MonitorBuffer
	call MonitorDoLine

.cont:
	li r0, MonitorHi
	call PutString

.loop:
	call MonitorGetLine
	b .loop

MonitorGetLine:
	li r0, MonitorPrompt
	call PutString

	li r0, MonitorBuffer
	call StringZero

	li r0, MonitorBuffer
	li r1, 256
	call GetString

	li r0, MonitorBuffer
	call MonitorDoLine
	ret

;r0 - line
MonitorDoLine:
	push r1

	lrr.b r1, r0

	cmpi r1, 0 ;empty
	be .out

	cmpi r1, "h"
	be .cmdh

	cmpi r1, "c"
	be .cmdc

	cmpi r1, "o"
	be .cmdo

	cmpi r1, "i"
	be .cmdi

	cmpi r1, "b"
	be .cmdb

	cmpi r1, "p"
	be .cmdp

	cmpi r1, "r"
	be .cmdr

	cmpi r1, "d"
	be .cmdd

	cmpi r1, "z"
	be .cmdz

	cmpi r1, "x"
	be .cmdx

	cmpi r1, "s"
	be .cmds

	cmpi r1, "g"
	be .cmdg

	cmpi r1, "t"
	be .cmdt

	b .notcmd

.cmdt:
	push r0
	li r0, MonitorStringT
	call PutString
	pop r0
	b .out

.cmdg:
	push r0
	li r0, MonitorStringG
	call PutString
	pop r0
	b .out

.cmds:
	push r0
	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	addi r0, r0, 1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r2

	push r0
	li r0, MonitorWordBuffer
	call StringToInteger

	mov r1, r0

	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	push r1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r1
	pop r2

	li r0, MonitorWordBuffer
	call StringToInteger

	xch r0, r1

	srr.l r0, r1

	b .out

.cmdx:
	push r0
	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	addi r0, r0, 1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r2

	li r0, MonitorWordBuffer
	call StringToInteger

	call GraphicsBlitScreen
	pop r0

	b .out

.cmdb:
	push r3

	push r0
	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	addi r0, r0, 1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r2

	push r0
	li r0, MonitorWordBuffer
	call StringToInteger

	mov r1, r0

	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	push r1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r1
	pop r2

	mov r3, r0

	li r0, MonitorWordBuffer
	call StringToInteger

	xch r0, r1

	push r0
	li r0, MonitorBString
	call PutString

	pop r0
	push r0
	call PutInteger

	li r0, ","
	call StdPutChar

	mov r0, r1
	call PutInteger

	li r0, 0xA
	call StdPutChar

	pop r0

	lshi r0, r0, 8
	ior r0, r0, r1

	mov r1, r3

	call GoClient

	cmpi r0, EBootSignature
	be .bfail

	pop r3
	b .out

.bfail:
	li r0, MonitorNBString
	call PutString

	pop r3
	b .out

.cmdz:
	li r1, 0x0 

	push r2
	push r3
	push r4
	push r5
	lri.b r2, ConsoleBGColor
	lri.b r3, ConsoleFGColor

	li r5, 0

.cmdzloop:
	cmpi r1, 0x100
	be .cmdzloopd

	sir.b ConsoleBGColor, r1

	li r4, 0xFF
	sub r0, r4, r1
	sir.b ConsoleFGColor, r0

	cmpi r5, 0x11
	be .cmdzno ;don't clear the screen
	
	mov r0, r5
	call StdPutChar

.cmdzno:
	addi r5, r5, 1
	addi r1, r1, 1
	b .cmdzloop

.cmdzloopd:
	sir.b ConsoleBGColor, r2
	sir.b ConsoleFGColor, r3
	pop r5
	pop r4
	pop r3
	pop r2

	li r0, 0xA
	call StdPutChar

	b .out

.cmdd:
	call BlockDriverList

	b .out

.cmdr:
	li r0, 0
	b Reset

.cmdp:
	li r0, MonitorPString1
	call PutString

	lri.b r0, IOStdOut
	call PutInteger

	li r0, MonitorPString2
	call PutString

	lri.b r0, IOStdIn
	call PutInteger

	li r0, MonitorPString3
	call PutString

	lri.l r0, TotalMemory
	call PutIntegerD

	li r0, MonitorPString4
	call PutString

	li r0, 0xA
	call StdPutChar

	b .out

.cmdi:
	push r0
	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	addi r0, r0, 1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r2

	li r0, MonitorWordBuffer
	call StringToInteger

	mov r1, r0

	li r0, MonitorIString
	call PutString

	mov r0, r1
	call PutInteger

	li r0, 0xA
	call StdPutChar

	sir.b IOStdIn, r1

	b .out

.cmdo:
	push r0
	li r0, MonitorWordBuffer
	call StringZero
	pop r0

	push r2
	addi r0, r0, 1
	li r1, MonitorWordBuffer
	li r2, 0x20 ;space
	call StringTokenize
	pop r2

	li r0, MonitorWordBuffer
	call StringToInteger

	mov r1, r0

	li r0, MonitorOString
	call PutString

	mov r0, r1
	call PutInteger

	li r0, 0xA
	call StdPutChar

	sir.b IOStdOut, r1

	b .out

.cmdc:
	li r0, 0x11
	call StdPutChar

	b .out

.cmdh:
	li r0, MonitorHelpString
	call PutString

	b .out

.notcmd:
	li r0, MonitorNotCommand
	call PutString

.out:
	pop r1
	ret

MonitorHi:
	.ds ROM Monitor v0.5
	.db 0xA
	.ds Type 'h' for help.
	.db 0xA, 0x0

MonitorPrompt:
	.ds ] 
	.db 0x0

MonitorNotCommand:
	.ds Not a command.
	.db 0xA, 0x0

MonitorHelpString:
	.ds 'h' - display help
	.db 0xA
	.ds 'o <char>' - set stdout to chardev
	.db 0xA
	.ds 'i <char>' - set stdin to chardev
	.db 0xA
	.ds 'b <major> <minor>' - boot from blkdev
	.db 0xA
	.ds 'c' - clear console
	.db 0xA
	.ds 'p' - print info
	.db 0xA
	.ds 'r' - reset
	.db 0xA
	.ds 'd' - print devices
	.db 0xA
	.ds 'z' - colors
	.db 0xA
	.ds 's <addr> <value>' - write long to addr
	.db 0xA, 0x0

MonitorOString:
	.ds Setting stdout to chardev 
	.db 0x0

MonitorIString:
	.ds Setting stdin to chardev 
	.db 0x0

MonitorBString:
	.ds Running client from blockdev 
	.db 0x0

MonitorNBString:
	.ds Not a bootable device.
	.db 0xA, 0x0

MonitorPString1:
	.ds I/O Info:
	.db 0xA
	.ds 	stdout: 
	.db 0x0

MonitorPString2:
	.db 0xA
	.ds 	stdin: 
	.db 0x0

MonitorPString3:
	.db 0xA
	.ds Memory Info:
	.db 0xA
	.ds 	Total memory: 
	.db 0x0

MonitorPString4:
	.ds  bytes
	.db 0x0

MonitorStringRWC:
	.ds Reset with command 
	.db 0x0

MonitorStringG:
	.ds he really does
	.db 0xA, 0x0

MonitorStringT:
	.ds FUCKIN RADICAL IS WHAT
	.db 0xA, 0x0

himsg:
	.db 0x11, 0xA
	.ds 	Welcome to ANTECEDENT
	.db 0xA
	.db 0xA
	.ds 	Version 1.1 (build 
	.ds$ BuildNum
	.ds )
	.db 0xA
	.ds 	Built on 
	.ds$ __DATE
	.db 0xA
	.ds 	Boot firmware for AISAv2 Lemon
	.db 0xA
	.ds 	Written by Will
	.db 0xA, 0xA, 0x0




