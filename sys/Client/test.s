.org 0xA0000

.ds ANTE

.include ../ROM/Globals.s

CIPtr:
	.dl 0

_CIC_PutString === 0

main:
	sir.l CIPtr, r0

.loop:
	li r0, coolstring
	call PutString

	lri.b r0, ConsoleBGColor
	addi r0, r0, 1
	andi r0, r0, 0xFF
	sir.b ConsoleBGColor, r0

	li r1, 0xFF
	sub r0, r1, r0
	sir.b ConsoleFGColor, r0

	b .loop

	ret

coolstring:
	.ds LuaJIT is a decent language for virtual machines. 
	.db 0x0

PutString:
	push r1

	lri.l r1, CIPtr
	addi r1, r1, _CIC_PutString
	lrr.l r1, r1

	call .stupidhack

	b .out

.stupidhack:
	br r1

.out:
	pop r1
	ret

.fill 0x1000 0x0