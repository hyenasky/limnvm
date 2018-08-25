Monitor:
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

	cmpi r1, "m"
	be .cmdm
	
	b .notcmd

.cmdm:
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

	add r2, r1, r0

	li r3, 1

.mloop:
	cmp r1, r2
	bg .mlout

	modi r0, r3, 21
	cmpi r0, 0
	be .mlnl

	b .mlc

.mlnl:
	li r0, 0xA
	call StdPutChar

	mov r0, r1
	call PutInteger

	li r0, "]"
	call StdPutChar

	li r0, 0x09
	call StdPutChar

.mlc:
	lrr.b r0, r1
	call PutInteger

	li r0, 0x09
	call StdPutChar

	addi r1, r1, 1
	addi r3, r3, 1
	b .mloop

.mlout:
	li r0, 0xA
	call StdPutChar

	b .out

.cmdz:
	li r1, 0x0 

	push r2
	push r3
	push r4
	lri.b r2, ConsoleBGColor
	lri.b r3, ConsoleFGColor

.cmdzloop:
	cmpi r1, 0x100
	be .cmdzloopd

	sir.b ConsoleBGColor, r1

	li r4, 0xFF
	sub r0, r4, r1
	sir.b ConsoleFGColor, r0

	li r0, MonitorZString
	call PutString

	addi r1, r1, 1
	b .cmdzloop

.cmdzloopd:
	sir.b ConsoleBGColor, r2
	sir.b ConsoleFGColor, r3
	pop r4
	pop r3
	pop r2

	li r0, 0xA
	call StdPutChar

	b .out

.cmdd:
	li r0, MonitorDString
	call PutString

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

.cmdb:
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

	li r0, MonitorBString
	call PutString

	mov r0, r1
	call PutInteger

	li r0, 0xA
	call StdPutChar

	mov r0, r1
	call GoClient

	cmpi r0, EBootSignature
	be .bfail

	b .out

.bfail:
	li r0, MonitorNBString
	call PutString

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
	.ds Monitor v0.3
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
	.ds 'b <block>' - boot from blkdev
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
	.ds 'm <start> <size>' - hex dump from address start to start+size
	.db 0xA, 0x0

MonitorDString:
	.ds Devices:
	.db 0xA
	.ds 	Char:
	.db 0xA
	.ds 		0 - serial
	.db 0xA
	.ds 		1 - graphical console
	.db 0xA
	.ds 		2 - keyboard
	.db 0xA
	.ds 	Block:
	.db 0xA
	.ds 		0 - SDisk
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

MonitorZString:
	.ds Colors! 
	.db 0x0




