

.org 0x200000

.ds VNIX

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH

;r2 contains boot partition
mov r0, r2
call _PUSH

;r3 contains partition table ptr
mov r0, r3
call _PUSH

sir.l AnteSP, sp
li sp, VNIXStack

b Main

	.bytes 4096 0
VNIXStack:


_STACK_PTR:
	.dl 0

;128 cells deep
_STACK:
	.bytes 512 0

_POP:
	lri.l r0, _STACK_PTR
	cmpi r0, 0
	be _UNDERFLOW

	subi r0, r0, 4
	sir.l _STACK_PTR, r0

	addi r0, r0, _STACK
	lrr.l r0, r0

	ret

_PUSH:
	push r1
	lri.l r1, _STACK_PTR

	push r2
	addi r2, r1, 4
	sir.l _STACK_PTR, r2
	pop r2

	addi r1, r1, _STACK
	srr.l r1, r0

	pop r1
	ret
_UNDERFLOW:
li r0, _dc_o_0
call _PUSH
call KPanic
ret
CR:
li r0, 10
call _PUSH
call KPutc
ret
Call:

		call _POP
		call .e
		ret

		.e:
			br r0
	
ret
_DumpStack:


	li r0, 0
	lri.l r1, _STACK_PTR
	li r2, _STACK

.loop:
	cmp r0, r1
	be .out

	lrr.l r3, r2
	push r0
	mov r0, r3
	call _PUSH
	call KPutx

	li r0, 0xA
	call _PUSH
	call KPutc
	pop r0

	addi r0, r0, 4
	addi r2, r2, 4
	b .loop

.out:

	
ret
memset:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
mov r0, r7
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
_dc_o_2:
mov r0, r7
call _PUSH
mov r0, r8
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_3
mov r0, r5
call _PUSH
mov r0, r7
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r7
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_2
_dc_o_3:
ret
strcmp:
call _POP
mov r5, r0
call _POP
mov r6, r0
li r0, 0
mov r7, r0
_dc_o_4:
mov r0, r5
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
mov r0, r6
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_5
mov r0, r5
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_7
_dc_o_6:
li r0, 1
call _PUSH
ret
_dc_o_7:
mov r0, r7
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_4
_dc_o_5:
li r0, 0
call _PUSH
ret
ret
strlen:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
_dc_o_8:
mov r0, r5
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_9
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
mov r0, r5
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
b _dc_o_8
_dc_o_9:
mov r0, r6
call _PUSH
ret
ret
strtok:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
li r0, 0
mov r8, r0
mov r0, r7
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_11
_dc_o_10:
li r0, 0
call _PUSH
ret
_dc_o_11:
_dc_o_12:
mov r0, r7
lrr.b r0, r0
call _PUSH
mov r0, r5
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_13
mov r0, r7
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_12
_dc_o_13:
_dc_o_14:
mov r0, r7
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
mov r0, r5
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_15
mov r0, r7
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r9, r0
mov r0, r9
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_17
_dc_o_16:
li r0, 0
call _PUSH
ret
_dc_o_17:
mov r0, r9
call _PUSH
mov r0, r6
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r8
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
b _dc_o_14
_dc_o_15:
mov r0, r7
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
ret
strzero:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
_dc_o_18:
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_19
li r0, 0
call _PUSH
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_18
_dc_o_19:
ret
strntok:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
call _POP
mov r8, r0
li r0, 0
mov r9, r0
mov r0, r8
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_21
_dc_o_20:
li r0, 0
call _PUSH
ret
_dc_o_21:
_dc_o_22:
mov r0, r8
lrr.b r0, r0
call _PUSH
mov r0, r6
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_23
mov r0, r8
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
b _dc_o_22
_dc_o_23:
_dc_o_24:
mov r0, r8
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
mov r0, r6
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_25
mov r0, r9
call _PUSH
mov r0, r5
mov r1, r0
call _POP
cmp r0, r1
rshi r0, rf, 0x1
andi r0, r0, 1
cmpi r0, 0
be _dc_o_27
_dc_o_26:
b _dc_o_25
_dc_o_27:
mov r0, r8
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r10, r0
mov r0, r10
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_29
_dc_o_28:
li r0, 0
call _PUSH
ret
_dc_o_29:
mov r0, r10
call _PUSH
mov r0, r7
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r9
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r9, r0
b _dc_o_24
_dc_o_25:
mov r0, r8
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
ret
atoi:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
li r0, 0
mov r7, r0
_dc_o_30:
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_31
mov r0, r7
call _PUSH
li r0, 10
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 48
mov r1, r0
call _POP
sub r0, r0, r1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_30
_dc_o_31:
mov r0, r7
call _PUSH
ret
ret


SaveFirmwareInterrupts:
	sir.l AnteIVT, ivt
	ret

RestoreFirmwareInterrupts:
	lri.l ivt, AnteIVT
	ret

AnteIVT:
	.dl 0

ReturnToFirmware:
	call RestoreFirmwareInterrupts

	lri.l sp, AnteSP
	ret

AnteSP:
	.dl 0

;r30 - call num
_CIC_Call:
	push r29
	lri.l r29, CIPtr
	muli r30, r30, 4
	add r30, r30, r29
	lrr.l r30, r30

	call .e
	pop r29
	ret

.e:
	br r30

_CIC_PutString === 0
_CIC_GetString === 1
_CIC_StdPutChar === 2
_CIC_StdGetChar === 3
_CIC_PutChar === 4
_CIC_GetChar === 5
_CIC_PutInteger === 6
_CIC_PutIntegerD === 7
_CIC_ListBDevs === 8
_CIC_BlockDriverList === 9
_CIC_BlockDriverRegister === 10
_CIC_ReadBlock === 11
_CIC_WriteBlock === 12
_CIC_StringZero === 13
_CIC_StringCopy === 14
_CIC_StringLength === 15
_CIC_StringToInteger === 16
_CIC_StringTokenize === 17
_CIC_Reset === 18
_CIC_InterruptRegister === 19
_CIC_StringCompare === 20
_CIC_BlitterOperation === 21
_CIC_GetMem === 22

; string --
ACIPutString:
	push r30

	call _POP

	li r30, _CIC_PutString
	call _CIC_Call

	pop r30
	ret

; buffer maxchars --
ACIGetString:
	push r30

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_GetString
	call _CIC_Call

	pop r30
	ret

; char -- 
ACIStdPutChar:
	push r30

	call _POP

	li r30, _CIC_StdPutChar
	call _CIC_Call

	pop r30
	ret

; -- char
ACIStdGetChar:
	push r30

	li r30, _CIC_StdGetChar
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; char dev --
ACIPutChar:
	push r30

	call _POP
	mov r0, r1

	call _POP

	li r30, _CIC_PutChar
	call _CIC_Call

	pop r30
	ret

; dev -- char
ACIGetChar:
	push r30

	call _POP
	mov r0, r1

	call _POP

	li r30, _CIC_StdGetChar
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; integer --
ACIPutInteger:
	push r30

	call _POP

	li r30, _CIC_PutInteger
	call _CIC_Call

	pop r30
	ret

; integer --
ACIPutIntegerD:
	push r30

	call _POP

	li r30, _CIC_PutIntegerD
	call _CIC_Call

	pop r30
	ret

; major --
ACIListBDevs:
	push r30

	call _POP

	li r30, _CIC_ListBDevs
	call _CIC_Call

	pop r30
	ret

; --
ACIBlockDriverList:
	push r30

	li r30, _CIC_BlockDriverList
	call _CIC_Call

	pop r30
	ret

; name ReadBlock WriteBlock List -- major
ACIBlockDriverRegister:
	push r30

	call _POP
	mov r3, r0

	call _POP
	mov r2, r0

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_BlockDriverRegister
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; blocknum buffer dev --
ACIReadBlock:
	push r30

	call _POP
	mov r3, r0

	call _POP
	mov r2, r0

	call _POP
	mov r1, r0

	mov r0, r3

	li r30, _CIC_ReadBlock
	call _CIC_Call

	pop r30
	ret

; blocknum buffer dev --
ACIWriteBlock:
	push r30

	call _POP
	mov r3, r0

	call _POP
	mov r2, r0

	call _POP
	mov r1, r0

	mov r0, r3

	li r30, _CIC_WriteBlock
	call _CIC_Call

	pop r30
	ret

; string --
ACIStringZero:
	push r30

	call _POP

	li r30, _CIC_StringZero
	call _CIC_Call

	pop r30
	ret

; dest src --
ACIStringCopy:
	push r30

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_StringCopy
	call _CIC_Call

	pop r30
	ret

; string -- length
ACIStringLength:
	push r30

	call _POP

	li r30, _CIC_StringLength
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; string -- length
ACIStringToInteger:
	push r30

	call _POP

	li r30, _CIC_StringToInteger
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; string buffer delimiter -- next
ACIStringTokenize:
	push r30

	call _POP
	mov r2, r0

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_StringTokenize
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; --
ACIReset:
	push r30

	li r30, _CIC_Reset
	call _CIC_Call

	pop r30
	ret

; handler interrupt --
ACIInterruptRegister:
	push r30

	call _POP
	mov r1, r0

	call _POP

	xch r1, r0

	li r30, _CIC_InterruptRegister
	call _CIC_Call

	pop r30
	ret

; str1 str2 -- result
ACIStringCompare:
	push r30

	call _POP
	mov r1, r0

	call _POP

	xch r1, r0

	li r30, _CIC_StringCompare
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; modulo dim dest from cmd --
ACIBlitterOperation:
	push r30

	call _POP ;cmd
	push r0

	call _POP
	mov r1, r0 ;from

	call _POP
	mov r2, r0 ;dest

	call _POP
	mov r3, r0 ;dim

	call _POP
	mov r4, r0 ;modulo

	pop r0

	li r30, _CIC_BlitterOperation
	call _CIC_Call

	pop r30
	ret

; -- mem
ACIGetMem:
	push r30

	li r30, _CIC_GetMem
	call _CIC_Call

	call _PUSH

	pop r30
	ret


KPrintf:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
mov r0, r5
call _PUSH
push r5
push r6
push r7
call strlen
pop r7
pop r6
pop r5
call _POP
mov r7, r0
_dc_o_32:
mov r0, r6
call _PUSH
mov r0, r7
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_33
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, 37
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_35
_dc_o_34:
mov r0, r8
call _PUSH
push r5
push r6
push r7
push r8
call KPutc
pop r8
pop r7
pop r6
pop r5
b _dc_o_36
_dc_o_35:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
mov r0, r6
call _PUSH
mov r0, r7
mov r1, r0
call _POP
cmp r0, r1
mov r0, rf
rshi rf, rf, 1
ior r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_38
_dc_o_37:
ret
_dc_o_38:
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, 100
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_40
_dc_o_39:
push r5
push r6
push r7
push r8
call KPutn
pop r8
pop r7
pop r6
pop r5
b _dc_o_41
_dc_o_40:
mov r0, r8
call _PUSH
li r0, 120
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_43
_dc_o_42:
push r5
push r6
push r7
push r8
call KPutx
pop r8
pop r7
pop r6
pop r5
b _dc_o_44
_dc_o_43:
mov r0, r8
call _PUSH
li r0, 115
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_46
_dc_o_45:
push r5
push r6
push r7
push r8
call KPuts
pop r8
pop r7
pop r6
pop r5
b _dc_o_47
_dc_o_46:
mov r0, r8
call _PUSH
li r0, 37
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_49
_dc_o_48:
li r0, 37
call _PUSH
push r5
push r6
push r7
push r8
call KPutc
pop r8
pop r7
pop r6
pop r5
b _dc_o_50
_dc_o_49:
mov r0, r8
call _PUSH
li r0, 108
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_52
_dc_o_51:
push r5
push r6
push r7
push r8
call KPutc
pop r8
pop r7
pop r6
pop r5
_dc_o_52:
_dc_o_50:
_dc_o_47:
_dc_o_44:
_dc_o_41:
_dc_o_36:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_32
_dc_o_33:
ret
KPanic:
li r0, _dc_o_53
call _PUSH
call KPrintf
call KPrintf
li r0, _dc_o_55
call _PUSH
call KPrintf
call ReturnToFirmware
ret
PMMInit:
li r0, _dc_o_57
call _PUSH
call KPrintf
call ACIGetMem
call _PUSH
li r0, PMMTotalMemory
mov r1, r0
call _POP
srr.l r1, r0
li r0, 4096
mov r1, r0
call _POP
div r0, r0, r1
call _PUSH
li r0, PMMTotalPages
mov r1, r0
call _POP
srr.l r1, r0
li r0, PMMTotalPages
lrr.l r0, r0
call _PUSH
li r0, _dc_o_59
call _PUSH
call KPrintf
li r0, PMMTotalPages
lrr.l r0, r0
call _PUSH
li r0, 32768
mov r1, r0
call _POP
cmp r0, r1
rshi r0, rf, 0x1
andi r0, r0, 1
cmpi r0, 0
be _dc_o_62
_dc_o_61:
li r0, _dc_o_63
call _PUSH
call KPanic
_dc_o_62:
li r0, _dc_o_65
call _PUSH
call KPrintf
ret
PMMBMSet:
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r6
call _PUSH
li r0, 8
mov r1, r0
call _POP
div r0, r0, r1
mov r7, r0
mov r0, r6
call _PUSH
li r0, 8
mov r1, r0
call _POP
mod r0, r0, r1
mov r8, r0
mov r0, r7
call _PUSH
li r0, PMMBitmap
mov r1, r0
call _POP
add r0, r1, r0
mov r9, r0
mov r0, r9
lrr.b r0, r0
mov r10, r0
mov r0, r5
call _PUSH
li r0, 1
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_68
_dc_o_67:
mov r0, r5
call _PUSH
mov r0, r8
mov r1, r0
call _POP
lsh r0, r0, r1
mov r12, r0
mov r0, r10
call _PUSH
mov r0, r12
mov r1, r0
call _POP
ior r0, r0, r1
mov r11, r0
b _dc_o_69
_dc_o_68:
mov r0, r8
muli r0, r0, 4
addi r0, r0, PMMBitmasks
lrr.l r0, r0
call _PUSH
mov r0, r10
mov r1, r0
call _POP
and r0, r0, r1
mov r11, r0
_dc_o_69:
mov r0, r11
call _PUSH
mov r0, r9
mov r1, r0
call _POP
srr.b r1, r0
ret
PMMBMGet:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 8
mov r1, r0
call _POP
div r0, r0, r1
mov r6, r0
mov r0, r5
call _PUSH
li r0, 8
mov r1, r0
call _POP
mod r0, r0, r1
mov r7, r0
mov r0, r6
call _PUSH
li r0, PMMBitmap
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r8, r0
mov r0, r8
call _PUSH
mov r0, r7
mov r1, r0
call _POP
rsh r0, r0, r1
call _PUSH
li r0, 1
mov r1, r0
call _POP
and r0, r0, r1
call _PUSH
ret
ret
PMMFree:
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r6
mov r7, r0
mov r0, r6
call _PUSH
mov r0, r5
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
_dc_o_70:
mov r0, r7
call _PUSH
mov r0, r8
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_71
mov r0, r7
call _PUSH
li r0, 0
call _PUSH
push r5
push r6
push r7
push r8
call PMMBMSet
pop r8
pop r7
pop r6
pop r5
mov r0, r7
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_70
_dc_o_71:
ret
PMMAllocate:
call _POP
mov r5, r0
li r0, 768
mov r6, r0
li r0, 0
mov r7, r0
li r0, PMMTotalPages
lrr.l r0, r0
mov r8, r0
_dc_o_72:
mov r0, r6
call _PUSH
mov r0, r8
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_73
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
push r9
call PMMBMGet
pop r9
pop r8
pop r7
pop r6
pop r5
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_75
_dc_o_74:
mov r0, r7
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_76
_dc_o_75:
li r0, 0
mov r7, r0
_dc_o_76:
mov r0, r7
call _PUSH
mov r0, r5
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_78
_dc_o_77:
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
li r0, 1
mov r1, r0
call _POP
sub r0, r0, r1
mov r1, r0
call _POP
sub r0, r0, r1
mov r9, r0
mov r0, r9
mov r10, r0
mov r0, r9
call _PUSH
mov r0, r5
mov r1, r0
call _POP
add r0, r1, r0
mov r11, r0
_dc_o_79:
mov r0, r10
call _PUSH
mov r0, r11
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_80
mov r0, r10
call _PUSH
li r0, 1
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call PMMBMSet
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r10
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r10, r0
b _dc_o_79
_dc_o_80:
mov r0, r9
call _PUSH
ret
_dc_o_78:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_72
_dc_o_73:
li r0, 4294967295
call _PUSH
ret
ret
KHeapInit:
li r0, _dc_o_81
call _PUSH
call KPrintf
li r0, KHeapSize
lrr.l r0, r0
call _PUSH
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
li r0, 0
call _PUSH
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
li r0, 0
call _PUSH
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, KHeapSize
lrr.l r0, r0
call _PUSH
li r0, _dc_o_83
call _PUSH
call KPrintf
li r0, _dc_o_85
call _PUSH
call KPrintf
ret
KHeapDump:
li r0, KHeapStart
lrr.l r0, r0
mov r5, r0
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, KHeapSize
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
li r0, 0
mov r7, r0
li r0, 0
mov r8, r0
_dc_o_87:
mov r0, r5
call _PUSH
mov r0, r6
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_88
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r9, r0
mov r0, r5
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
mov r10, r0
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r11, r0
mov r0, r7
call _PUSH
li r0, _dc_o_89
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call KPrintf
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r5
call _PUSH
li r0, _dc_o_91
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call KPrintf
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r9
call _PUSH
li r0, _dc_o_93
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call KPrintf
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r11
call _PUSH
li r0, _dc_o_95
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call KPrintf
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r10
call _PUSH
li r0, _dc_o_97
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call KPrintf
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r8
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
mov r0, r5
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
mov r0, r7
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_87
_dc_o_88:
mov r0, r8
call _PUSH
li r0, _dc_o_99
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
push r11
call KPrintf
pop r11
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
ret
KMalloc:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_102
_dc_o_101:
li r0, 0
call _PUSH
ret
_dc_o_102:
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, 1
mov r1, r0
call _POP
sub r0, r0, r1
mov r6, r0
li r0, KHeapStart
lrr.l r0, r0
mov r7, r0
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, KHeapSize
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
_dc_o_103:
mov r0, r7
call _PUSH
mov r0, r8
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_104
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r9, r0
mov r0, r7
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_106
_dc_o_105:
mov r0, r9
call _PUSH
mov r0, r6
mov r1, r0
call _POP
cmp r0, r1
rshi r0, rf, 0x1
andi r0, r0, 1
cmpi r0, 0
be _dc_o_108
_dc_o_107:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r9
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_110
_dc_o_109:
mov r0, r7
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, 1
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r7
call _PUSH
li r0, 13
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
ret
_dc_o_110:
mov r0, r9
call _PUSH
mov r0, r5
call _PUSH
li r0, 13
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
sub r0, r0, r1
mov r10, r0
mov r0, r10
call _PUSH
li r0, 13
mov r1, r0
call _POP
cmp r0, r1
rshi r0, rf, 0x1
andi r0, r0, 1
cmpi r0, 0
be _dc_o_112
_dc_o_111:
mov r0, r5
call _PUSH
li r0, 13
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
mov r11, r0
mov r0, r10
call _PUSH
mov r0, r11
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r7
call _PUSH
mov r0, r11
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
li r0, 0
call _PUSH
mov r0, r11
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r5
call _PUSH
li r0, 13
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_112:
li r0, 1
call _PUSH
mov r0, r7
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r7
call _PUSH
li r0, 13
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
ret
_dc_o_108:
_dc_o_106:
mov r0, r7
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_103
_dc_o_104:
li r0, 4294967295
call _PUSH
ret
ret
KCalloc:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
push r5
push r6
call KMalloc
pop r6
pop r5
call _POP
mov r6, r0
mov r0, r6
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_114
_dc_o_113:
li r0, 0
call _PUSH
ret
_dc_o_114:
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
li r0, 0
call _PUSH
push r5
push r6
call memset
pop r6
pop r5
mov r0, r6
call _PUSH
ret
KHeapMerge:
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r6
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_116
_dc_o_115:
mov r0, r7
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_118
_dc_o_117:
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r10, r0
mov r0, r10
call _PUSH
mov r0, r5
mov r1, r0
call _POP
add r0, r1, r0
mov r9, r0
mov r0, r9
call _PUSH
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r7
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, KHeapSize
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_120
_dc_o_119:
mov r0, r7
call _PUSH
mov r0, r8
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_120:
mov r0, r7
call _PUSH
mov r0, r9
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call KHeapMerge
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
ret
_dc_o_118:
_dc_o_116:
mov r0, r6
call _PUSH
mov r0, r5
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, KHeapSize
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_122
_dc_o_121:
mov r0, r8
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_124
_dc_o_123:
mov r0, r8
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r10, r0
mov r0, r10
call _PUSH
mov r0, r5
mov r1, r0
call _POP
add r0, r1, r0
mov r9, r0
mov r0, r6
call _PUSH
mov r0, r9
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, KHeapStart
lrr.l r0, r0
call _PUSH
li r0, KHeapSize
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_126
_dc_o_125:
mov r0, r6
call _PUSH
mov r0, r8
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_126:
mov r0, r9
call _PUSH
mov r0, r6
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r6
call _PUSH
mov r0, r9
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call KHeapMerge
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
_dc_o_124:
_dc_o_122:
ret
KFree:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 13
mov r1, r0
call _POP
sub r0, r0, r1
mov r6, r0
li r0, 0
call _PUSH
mov r0, r6
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
mov r0, r6
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r6
call _PUSH
mov r0, r7
call _PUSH
push r5
push r6
push r7
call KHeapMerge
pop r7
pop r6
pop r5
ret
InterruptsInit:
li r0, _dc_o_127
call _PUSH
call KPrintf
call SaveFirmwareInterrupts


	mov r0, ivt
	call _PUSH

	
call _POP
mov r5, r0
li r0, 0
mov r6, r0
_dc_o_129:
mov r0, r6
call _PUSH
li r0, 1024
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_130
mov r0, r6
call _PUSH
mov r0, r5
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
mov r0, r6
call _PUSH
li r0, InterruptsVT
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r6
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_129
_dc_o_130:
li r0, InterruptsVT
call _PUSH


	call _POP
	mov ivt, r0

	
li r0, InterruptsVT
call _PUSH
mov r0, r5
call _PUSH
li r0, _dc_o_131
call _PUSH
push r5
push r6
call KPrintf
pop r6
pop r5
li r0, _dc_o_133
call _PUSH
push r5
push r6
call KPrintf
pop r6
pop r5
ret
InterruptRegister:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, InterruptsVT
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
ret
InterruptDisable:


	li r0, rs
	bclri rs, rs, 1
	call _PUSH

	
ret
InterruptRestore:


	call _POP
	mov rs, r0

	
ret
DCitronInb:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
ret
DCitronIni:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
lrr.i r0, r0
call _PUSH
ret
DCitronInl:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
DCitronOutb:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
ret
DCitronOuti:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.i r1, r0
ret
DCitronOutl:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
ret
DCitronCommand:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294705152
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
call _POP
mov r6, r0
mov r0, r6
call _PUSH
mov r0, r5
mov r1, r0
call _POP
srr.b r1, r0
_dc_o_135:
mov r0, r5
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_136
b _dc_o_135
_dc_o_136:
ret
MmuReadRegister:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294049792
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
MmuWriteRegister:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 4294049792
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
ret
KPutx:
call ACIPutInteger
ret
KPutn:
call ACIPutIntegerD
ret
KPutc:
call ACIStdPutChar
ret
KGetc:
call ACIStdGetChar
call _PUSH
li r0, 65535
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_138
_dc_o_137:
call _POP
li r0, 4294967295
call _PUSH
ret
_dc_o_138:
ret
KPuts:
call ACIPutString
ret
DTTYInit:
li r0, DTTYDriver
call _PUSH
call DevAddDriver
ret
DTTYPut:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_142
_dc_o_141:
push r5
call KPutc
pop r5
li r0, 1
call _PUSH
ret
_dc_o_142:
li r0, 4294967295
call _PUSH
ret
ret
DTTYGet:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_144
_dc_o_143:
push r5
call KGetc
pop r5
ret
_dc_o_144:
li r0, 4294967295
call _PUSH
ret
ret
DTTYIOCtl:
li r0, 1
call _PUSH
ret
ret
DTTYNumMinor:
li r0, 1
call _PUSH
ret
ret
DriversInit:
call DTTYInit
ret
DevInit:
li r0, _dc_o_145
call _PUSH
call KPrintf
li r0, 128
call _PUSH
li r0, 24
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
call KCalloc
call _PUSH
li r0, DevDriverList
mov r1, r0
call _POP
srr.l r1, r0
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_148
_dc_o_147:
li r0, _dc_o_149
call _PUSH
call KPanic
_dc_o_148:
call DriversInit
li r0, _dc_o_151
call _PUSH
call KPrintf
ret
DevIsBlock:
push r5
push r6
call DevSplitNum
pop r6
pop r5
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r5
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_154
_dc_o_153:
li r0, 4294967295
call _PUSH
ret
_dc_o_154:
mov r0, r5
call _PUSH
li r0, 20
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
DevNumMinors:
push r5
push r6
call DevSplitNum
pop r6
pop r5
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r5
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_156
_dc_o_155:
li r0, 4294967295
call _PUSH
ret
_dc_o_156:
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
li r0, 16
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_158
_dc_o_157:
li r0, 4294967295
call _PUSH
ret
_dc_o_158:
mov r0, r7
call _PUSH
push r5
push r6
push r7
call Call
pop r7
pop r6
pop r5
ret
DevIOCtl:
push r5
push r6
call DevSplitNum
pop r6
pop r5
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r5
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_160
_dc_o_159:
li r0, 4294967295
call _PUSH
ret
_dc_o_160:
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_162
_dc_o_161:
li r0, 4294967295
call _PUSH
ret
_dc_o_162:
mov r0, r7
call _PUSH
push r5
push r6
push r7
call Call
pop r7
pop r6
pop r5
ret
DevPut:
push r5
push r6
call DevSplitNum
pop r6
pop r5
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r5
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_164
_dc_o_163:
li r0, 4294967295
call _PUSH
ret
_dc_o_164:
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_166
_dc_o_165:
li r0, 4294967295
call _PUSH
ret
_dc_o_166:
mov r0, r7
call _PUSH
push r5
push r6
push r7
call Call
pop r7
pop r6
pop r5
ret
DevGet:
push r5
push r6
call DevSplitNum
pop r6
pop r5
call _POP
mov r5, r0
call _POP
mov r6, r0
mov r0, r5
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_168
_dc_o_167:
li r0, 4294967295
call _PUSH
ret
_dc_o_168:
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
li r0, 8
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_170
_dc_o_169:
li r0, 4294967295
call _PUSH
ret
_dc_o_170:
mov r0, r7
call _PUSH
push r5
push r6
push r7
call Call
pop r7
pop r6
pop r5
ret
DevResolvePath:
call _POP
mov r5, r0
li r0, 32
call _PUSH
push r5
push r6
call KCalloc
pop r6
pop r5
call _POP
mov r6, r0
mov r0, r5
call _PUSH
mov r0, r6
call _PUSH
li r0, 47
call _PUSH
li r0, 31
call _PUSH
push r5
push r6
push r7
push r8
call strntok
pop r8
pop r7
pop r6
pop r5
call _POP
mov r5, r0
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call DevDriverByName
pop r8
pop r7
pop r6
pop r5
call _POP
mov r7, r0
mov r0, r7
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_172
_dc_o_171:
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call KFree
pop r8
pop r7
pop r6
pop r5
li r0, 4294967295
call _PUSH
ret
_dc_o_172:
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call strzero
pop r8
pop r7
pop r6
pop r5
mov r0, r5
call _PUSH
mov r0, r6
call _PUSH
li r0, 47
call _PUSH
li r0, 31
call _PUSH
push r5
push r6
push r7
push r8
call strntok
pop r8
pop r7
pop r6
pop r5
call _POP
mov r5, r0
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call atoi
pop r8
pop r7
pop r6
pop r5
call _POP
mov r8, r0
mov r0, r8
call _PUSH
li r0, 65535
mov r1, r0
call _POP
cmp r0, r1
rshi r0, rf, 0x1
andi r0, r0, 1
cmpi r0, 0
be _dc_o_174
_dc_o_173:
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call KFree
pop r8
pop r7
pop r6
pop r5
li r0, 4294967295
call _PUSH
ret
_dc_o_174:
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call KFree
pop r8
pop r7
pop r6
pop r5
mov r0, r7
call _PUSH
li r0, 16
mov r1, r0
call _POP
lsh r0, r0, r1
call _PUSH
mov r0, r8
mov r1, r0
call _POP
ior r0, r0, r1
call _PUSH
ret
DevSplitNum:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 16
mov r1, r0
call _POP
rsh r0, r0, r1
call _PUSH
push r5
push r6
call DevDriverByMajor
pop r6
pop r5
call _POP
mov r6, r0
mov r0, r5
call _PUSH
li r0, 65535
mov r1, r0
call _POP
and r0, r0, r1
mov r7, r0
mov r0, r7
call _PUSH
mov r0, r6
call _PUSH
ret
DevDriverByMajor:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, DevDriverPtr
lrr.l r0, r0
mov r1, r0
call _POP
cmp r0, r1
mov r0, rf
rshi rf, rf, 1
ior r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_176
_dc_o_175:
li r0, 4294967295
call _PUSH
ret
_dc_o_176:
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, DevDriverList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
DevDriverByName:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
li r0, DevDriverPtr
lrr.l r0, r0
mov r7, r0
_dc_o_177:
mov r0, r6
call _PUSH
mov r0, r7
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_178
mov r0, r6
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, DevDriverList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_180
_dc_o_179:
mov r0, r8
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
mov r0, r5
call _PUSH
push r5
push r6
push r7
push r8
call strcmp
pop r8
pop r7
pop r6
pop r5
call _POP
cmpi r0, 0
be _dc_o_182
_dc_o_181:
mov r0, r6
call _PUSH
ret
_dc_o_182:
_dc_o_180:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_177
_dc_o_178:
li r0, 4294967295
call _PUSH
ret
ret
DevAddDriver:
call _POP
mov r5, r0
li r0, DevDriverPtr
lrr.l r0, r0
call _PUSH
mov r0, r5
call _PUSH
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, _dc_o_183
call _PUSH
push r5
call KPrintf
pop r5
li r0, DevDriverPtr
lrr.l r0, r0
call _PUSH
li r0, 128
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_186
_dc_o_185:
li r0, _dc_o_187
call _PUSH
push r5
call KPanic
pop r5
_dc_o_186:
mov r0, r5
call _PUSH
li r0, DevDriverPtr
lrr.l r0, r0
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, DevDriverList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
li r0, DevDriverPtr
lrr.l r0, r0
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, DevDriverPtr
mov r1, r0
call _POP
srr.l r1, r0
ret
TaskInit:
li r0, _dc_o_189
call _PUSH
call KPrintf
li r0, 128
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
call KCalloc
call _PUSH
li r0, TaskList
mov r1, r0
call _POP
srr.l r1, r0
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_192
_dc_o_191:
li r0, _dc_o_193
call _PUSH
call KPanic
_dc_o_192:
li r0, _dc_o_195
call _PUSH
call KPrintf
ret
TaskName:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 144
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
TaskHTTA:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
ret
TaskPStart:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 148
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
TaskPSize:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 152
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
TaskSCreate:
call _POP
mov r5, r0
call _POP
mov r6, r0
li r0, 156
call _PUSH
push r5
push r6
push r7
call KCalloc
pop r7
pop r6
pop r5
call _POP
mov r7, r0
mov r0, r7
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_198
_dc_o_197:
li r0, 4294967295
call _PUSH
ret
_dc_o_198:
mov r0, r5
call _PUSH
mov r0, r7
call _PUSH
li r0, 144
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r6
call _PUSH
li r0, 4096
mov r1, r0
call _POP
div r0, r0, r1
call _PUSH
li r0, 2
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
mov r0, r8
call _PUSH
push r5
push r6
push r7
push r8
push r9
call PMMAllocate
pop r9
pop r8
pop r7
pop r6
pop r5
call _POP
mov r9, r0
mov r0, r9
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_200
_dc_o_199:
mov r0, r7
call _PUSH
push r5
push r6
push r7
push r8
push r9
call KFree
pop r9
pop r8
pop r7
pop r6
pop r5
li r0, 4294967295
call _PUSH
ret
_dc_o_200:
mov r0, r9
call _PUSH
mov r0, r7
call _PUSH
li r0, 148
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r8
call _PUSH
mov r0, r7
call _PUSH
li r0, 152
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r7
call _PUSH
ret
TaskDestroy:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r6, r0
mov r0, r6
call _PUSH
li r0, 148
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r6
call _PUSH
li r0, 152
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r8, r0
mov r0, r7
call _PUSH
mov r0, r8
call _PUSH
push r5
push r6
push r7
push r8
call PMMFree
pop r8
pop r7
pop r6
pop r5
mov r0, r6
call _PUSH
push r5
push r6
push r7
push r8
call KFree
pop r8
pop r7
pop r6
pop r5
li r0, 0
call _PUSH
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
ret
TaskNewPID:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
_dc_o_201:
mov r0, r6
call _PUSH
li r0, 128
mov r1, r0
call _POP
cmp r0, r1
not r1, rf
rshi r0, r1, 0x1
andi r0, r0, 1
not rf, rf
and r0, r0, rf
andi r0, r0, 1
cmpi r0, 0
be _dc_o_202
mov r0, r6
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, TaskList
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
mov r0, r7
lrr.l r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_204
_dc_o_203:
mov r0, r5
call _PUSH
mov r0, r7
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r6
call _PUSH
ret
_dc_o_204:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_201
_dc_o_202:
li r0, 4294967295
call _PUSH
ret
TaskCreate:
call TaskSCreate
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_206
_dc_o_205:
li r0, 4294967295
call _PUSH
ret
_dc_o_206:
call TaskNewPID
ret
GraphicsXYDim:
li r0, 16
mov r1, r0
call _POP
lsh r0, r0, r1
mov r1, r0
call _POP
ior r0, r0, r1
call _PUSH
ret
GraphicsFillScreen:
call _POP
mov r5, r0
li r0, 0
call _PUSH
li r0, 1120
call _PUSH
li r0, 832
call _PUSH
push r5
call GraphicsXYDim
pop r5
li r0, 4093640704
call _PUSH
mov r0, r5
call _PUSH
li r0, 2
call _PUSH
push r5
call ACIBlitterOperation
pop r5
ret
GraphicsCopyImage:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
call _POP
mov r8, r0
call _POP
mov r9, r0
li r0, 1120
call _PUSH
mov r0, r6
mov r1, r0
call _POP
sub r0, r0, r1
call _PUSH
li r0, 16
mov r1, r0
call _POP
lsh r0, r0, r1
call _PUSH
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
push r5
push r6
push r7
push r8
push r9
call GraphicsXYDim
pop r9
pop r8
pop r7
pop r6
pop r5
li r0, 4093640704
call _PUSH
mov r0, r7
call _PUSH
li r0, 1120
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r9
call _PUSH
li r0, 1
call _PUSH
push r5
push r6
push r7
push r8
push r9
call ACIBlitterOperation
pop r9
pop r8
pop r7
pop r6
pop r5
ret
GraphicsCopyFromScreen:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
call _POP
mov r8, r0
call _POP
mov r9, r0
li r0, 1120
call _PUSH
mov r0, r6
mov r1, r0
call _POP
sub r0, r0, r1
call _PUSH
mov r0, r6
call _PUSH
mov r0, r5
call _PUSH
push r5
push r6
push r7
push r8
push r9
call GraphicsXYDim
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r9
call _PUSH
li r0, 4093640704
call _PUSH
mov r0, r7
call _PUSH
li r0, 1120
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, 1
call _PUSH
push r5
push r6
push r7
push r8
push r9
call ACIBlitterOperation
pop r9
pop r8
pop r7
pop r6
pop r5
ret
Main:
li r0, PartitionTable
mov r1, r0
call _POP
srr.l r1, r0
li r0, BootPartition
mov r1, r0
call _POP
srr.l r1, r0
li r0, BootDevice
mov r1, r0
call _POP
srr.l r1, r0
li r0, CIPtr
mov r1, r0
call _POP
srr.l r1, r0
li r0, _dc_o_207
call _PUSH
call KPrintf
call InterruptsInit
call PMMInit
call KHeapInit
call DevInit
call TaskInit
call ReturnToFirmware
ret

_dc_o_0:
	.ds Runtime error: Stack underflow.
	.db 0xA
	.ds 
	.db 0x0
CIPtr:
	.dl 0
_dc_o_53:
	.ds 
	.db 0xA
	.ds vnix PANIC: 
	.db 0x0
_dc_o_55:
	.ds returning to firmware!
	.db 0xA
	.ds 
	.db 0xA
	.ds 
	.db 0x0
PMMTotalMemory:
	.dl 0
PMMTotalPages:
	.dl 0
_dc_o_57:
	.ds PMM: init
	.db 0xA
	.ds 
	.db 0x0
_dc_o_59:
	.ds PMM: managing %d pages.
	.db 0xA
	.ds 
	.db 0x0
_dc_o_63:
	.ds can't manage more than 32768 pages (128MB of memory)
	.db 0xA
	.ds 
	.db 0x0
_dc_o_65:
	.ds PMM: init done
	.db 0xA
	.ds 
	.db 0x0
PMMBitmap:
	.bytes 4096 0x0
PMMBitmasks:
	.dl 254
	.dl 253
	.dl 251
	.dl 247
	.dl 239
	.dl 223
	.dl 191
	.dl 127

KHeapStart:
	.dl 1048576
KHeapSize:
	.dl 1048575
_dc_o_81:
	.ds KHeap: init
	.db 0xA
	.ds 
	.db 0x0
_dc_o_83:
	.ds KHeap: heap is %d bytes starting at 0x%x
	.db 0xA
	.ds 
	.db 0x0
_dc_o_85:
	.ds KHeap: init done
	.db 0xA
	.ds 
	.db 0x0
_dc_o_89:
	.ds block %d:
	.db 0xA
	.ds 
	.db 0x0
_dc_o_91:
	.ds 	ptr: 0x%x
	.db 0xA
	.ds 
	.db 0x0
_dc_o_93:
	.ds 	size: %d bytes
	.db 0xA
	.ds 
	.db 0x0
_dc_o_95:
	.ds 	last: 0x%x
	.db 0xA
	.ds 
	.db 0x0
_dc_o_97:
	.ds 	allocated: %d
	.db 0xA
	.ds 
	.db 0x0
_dc_o_99:
	.ds heap size: 0x%x bytes.
	.db 0xA
	.ds 
	.db 0x0
InterruptsVT:
	.bytes 1024 0x0
_dc_o_127:
	.ds Interrupts: init
	.db 0xA
	.ds 
	.db 0x0
_dc_o_131:
	.ds Interrupts: old IVT at 0x%x, new IVT at 0x%x
	.db 0xA
	.ds 
	.db 0x0
_dc_o_133:
	.ds Interrupts: init done
	.db 0xA
	.ds 
	.db 0x0
_dc_o_139:
	.ds tty
	.db 0x0
DTTYDriver:
	.dl _dc_o_139
	.dl DTTYPut
	.dl DTTYGet
	.dl DTTYIOCtl
	.dl DTTYNumMinor
	.dl 0

DevDriverList:
	.dl 0
DevDriverPtr:
	.dl 0
_dc_o_145:
	.ds Dev: init
	.db 0xA
	.ds 
	.db 0x0
_dc_o_149:
	.ds couldn't allocate driver list: not enough heap
	.db 0xA
	.ds 
	.db 0x0
_dc_o_151:
	.ds Dev: init done
	.db 0xA
	.ds 
	.db 0x0
_dc_o_183:
	.ds Dev: adding driver %s@0x%x@%d
	.db 0xA
	.ds 
	.db 0x0
_dc_o_187:
	.ds can't add driver: max reached
	.db 0xA
	.ds 
	.db 0x0
TaskList:
	.dl 0
TaskCurrent:
	.dl 0
_dc_o_189:
	.ds Task: init
	.db 0xA
	.ds 
	.db 0x0
_dc_o_193:
	.ds couldn't allocate task list: not enough heap
	.db 0xA
	.ds 
	.db 0x0
_dc_o_195:
	.ds Task: init done
	.db 0xA
	.ds 
	.db 0x0
BootDevice:
	.dl 0
BootPartition:
	.dl 0
PartitionTable:
	.dl 0
_dc_o_207:
	.ds 
	.db 0xA
	.ds vnix - ball rolling
	.db 0xA
	.ds 
	.db 0x0

