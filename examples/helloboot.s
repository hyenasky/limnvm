;bootable minimal "hello world" disk stub for Antecedent






;=========== FILLER (partition table usually here) =============
.fill 4096 0 ;fill block 0 with zeroes














;boot record is block 1 on disk, gives information about what antecedent should load
;=========== BOOT RECORD ==========

;magic number so antecedent knows its valid
.ds ANTE
ret ;compatibility, so <3.0 antecedent versions will just return to ROM if they try to boot this disk

;OS name, 16 bytes
;ours is only 11 bytes so...
.ds Hello World
.bytes 5 0 ;...we have to pad it with zeroes

;boot program info
.dl 2 ;starts at block 2
.dl 1 ;1 block long

.fill 8192 0 ;fill up to block 2











;block 2 as specified by boot record
;=========== BOOT PROGRAM ============

;boot blocks are loaded here by antecedent
.org 0x100000

;magic string
.ds ANTE

;entry pointer so antecedent knows where to jump
.dl Start

;hi string
HiMsg:
	.ds panther/cryptid person whatever idk is really super cool
	.db 0xA
	.ds also here's some args for u: 
	.db 0x0

;just a newline
Newline:
	.db 0xA, 0x0

;api pointer
API:
	.dl 0

;put string
;r0 - string pointer
Puts:
	push r1

	lri.l r1, API ;get saved API pointer
	addi r1, r1, 12 ;add 12 to get offset for Puts firmware call
	lrr.l r1, r1 ;load Puts firmware call pointer

	;do a weird thing so when antecedent returns back to us it goes here since we can't "call" a register
	pusha ;antecedent calls dont care about trashing registers
	call .cstub
	popa

	pop r1
	ret

.cstub:
	br r1

;antecedent jumps here with these arguments:
;r0 - calls table
;r1 - boot node
;r2 - args
Start:
	sir.l API, r0 ;store api pointer

	li r0, HiMsg
	call Puts ;print hello world

	mov r0, r2
	call Puts ;print arguments

	li r0, Newline
	call Puts ;print a string thats just a newline character for simplicity

	ret ;return back to ROM

.fill 12288 0 ;fill remainder of disk block