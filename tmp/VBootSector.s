

.org 0xA0000 ;loaded here by auntie antecedent

.ds ANTE

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH
b Main

;if main returns, itll go back into the ROM


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
call PutString
_dc_o_2:
li r0, 1
cmpi r0, 0
be _dc_o_3
b _dc_o_2
_dc_o_3:
ret
CR:
li r0, 10
call _PUSH
call StdPutChar
ret


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

; string --
PutString:
	push r30

	call _POP

	li r30, _CIC_PutString
	call _CIC_Call

	pop r30
	ret

; buffer maxchars --
GetString:
	push r30

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_GetString
	call _CIC_Call

	pop r30
	ret

; char -- 
StdPutChar:
	push r30

	call _POP

	li r30, _CIC_StdPutChar
	call _CIC_Call

	pop r30
	ret

; -- char
StdGetChar:
	push r30

	call _POP

	li r30, _CIC_StdGetChar
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; char dev --
PutChar:
	push r30

	call _POP
	mov r0, r1

	call _POP

	li r30, _CIC_PutChar
	call _CIC_Call

	pop r30
	ret

; dev -- char
GetChar:
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
PutInteger:
	push r30

	call _POP

	li r30, _CIC_PutInteger
	call _CIC_Call

	pop r30
	ret

; integer --
PutIntegerD:
	push r30

	call _POP

	li r30, _CIC_PutIntegerD
	call _CIC_Call

	pop r30
	ret

; major --
ListBDevs:
	push r30

	call _POP

	li r30, _CIC_ListBDevs
	call _CIC_Call

	pop r30
	ret

; --
BlockDriverList:
	push r30

	li r30, _CIC_BlockDriverList
	call _CIC_Call

	pop r30
	ret

; name ReadBlock WriteBlock List -- major
BlockDriverRegister:
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
ReadBlock:
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
WriteBlock:
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
StringZero:
	push r30

	call _POP

	li r30, _CIC_StringZero
	call _CIC_Call

	pop r30
	ret

; dest src --
StringCopy:
	push r30

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_StringCopy
	call _CIC_Call

	pop r30
	ret

; string -- length
StringLength:
	push r30

	call _POP

	li r30, _CIC_StringLength
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; string -- length
StringToInteger:
	push r30

	call _POP

	li r30, _CIC_StringToInteger
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; string buffer delimiter -- next
StringTokenize:
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
Reset:
	push r30

	li r30, _CIC_Reset
	call _CIC_Call

	pop r30
	ret

; handler interrupt --
InterruptRegister:
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
StringCompare:
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


Error:
li r0, _dc_o_4
call _PUSH
call PutString
call PutString
ret
Prompt:
li r0, _dc_o_6
call _PUSH
call PutString
li r0, PromptLine
call _PUSH
call _PUSH
call StringZero
li r0, 5
call _PUSH
call GetString
ret
Main:
call _POP
mov r5, r0
li r0, CIPtr
mov r1, r0
call _POP
srr.l r1, r0
li r0, _dc_o_8
call _PUSH
push r5
call PutString
pop r5
li r0, _dc_o_10
call _PUSH
push r5
call PutString
pop r5
mov r0, r5
call _PUSH
push r5
call PutInteger
pop r5
push r5
call CR
pop r5
push r5
call Prompt
pop r5
li r0, PromptLine
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_13
_dc_o_12:
li r0, PromptLine
call _PUSH
push r5
call StringToInteger
pop r5
call _POP
mov r5, r0
_dc_o_13:
li r0, _dc_o_14
call _PUSH
push r5
call PutString
pop r5
mov r0, r5
call _PUSH
push r5
call PutInteger
pop r5
push r5
call CR
pop r5
li r0, _dc_o_16
call _PUSH
push r5
call PutString
pop r5
li r0, 0
call _PUSH
li r0, 1048576
call _PUSH
mov r0, r5
call _PUSH
push r5
call ReadBlock
pop r5
li r0, _dc_o_18
call _PUSH
push r5
call PutString
pop r5
li r0, 1048576
call _PUSH
li r0, 144
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 1313687884
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_21
_dc_o_20:
li r0, _dc_o_22
call _PUSH
push r5
call Error
pop r5
ret
_dc_o_21:
li r0, _dc_o_24
call _PUSH
push r5
call PutString
pop r5
li r0, 1048576
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
push r5
call PutString
pop r5
li r0, _dc_o_26
call _PUSH
push r5
call PutString
pop r5
li r0, 0
mov r6, r0
li r0, 1048576
call _PUSH
li r0, 16
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
li r0, 0
mov r8, r0
li r0, 0
mov r9, r0
li r0, 0
mov r10, r0
_dc_o_28:
mov r0, r6
call _PUSH
li r0, 8
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
be _dc_o_29
mov r0, r7
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 1
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_31
_dc_o_30:
li r0, 9
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call StdPutChar
pop r10
pop r9
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
push r9
push r10
call PutIntegerD
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
li r0, _dc_o_32
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutString
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r7
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutString
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
push r5
push r6
push r7
push r8
push r9
push r10
call CR
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r6
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_35
_dc_o_34:
mov r0, r8
call _PUSH
li r0, 2
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
_dc_o_35:
mov r0, r8
call _PUSH
mov r0, r6
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionStart
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r7
call _PUSH
li r0, 8
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
mov r0, r8
mov r1, r0
call _POP
add r0, r1, r0
mov r8, r0
mov r0, r6
mov r9, r0
mov r0, r10
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r10, r0
b _dc_o_36
_dc_o_31:
li r0, 4294967295
call _PUSH
mov r0, r6
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionStart
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_36:
mov r0, r7
call _PUSH
li r0, 16
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
b _dc_o_28
_dc_o_29:
mov r0, r10
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_38
_dc_o_37:
li r0, _dc_o_39
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call Error
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
ret
_dc_o_38:
mov r0, r10
call _PUSH
li r0, 1
mov r1, r0
call _POP
cmp r0, r1
rshi r0, rf, 0x1
andi r0, r0, 1
cmpi r0, 0
be _dc_o_42
_dc_o_41:
li r0, _dc_o_43
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutString
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r9
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutInteger
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
push r5
push r6
push r7
push r8
push r9
push r10
call CR
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
push r5
push r6
push r7
push r8
push r9
push r10
call Prompt
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
li r0, PromptLine
lrr.b r0, r0
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_46
_dc_o_45:
li r0, PromptLine
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call StringToInteger
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
call _POP
mov r9, r0
_dc_o_46:
_dc_o_42:
li r0, _dc_o_47
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutString
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r5
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutInteger
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
li r0, 58
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call StdPutChar
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r9
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call PutIntegerD
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
push r5
push r6
push r7
push r8
push r9
push r10
call CR
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r9
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionStart
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r8, r0
mov r0, r8
call _PUSH
li r0, 4294967295
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_50
_dc_o_49:
li r0, _dc_o_51
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call Error
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
ret
_dc_o_50:
li r0, 1048576
mov r7, r0
li r0, 1
mov r6, r0
_dc_o_53:
mov r0, r6
call _PUSH
li r0, 16
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
be _dc_o_54
mov r0, r8
call _PUSH
mov r0, r6
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r7
call _PUSH
mov r0, r5
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call ReadBlock
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
mov r0, r7
call _PUSH
li r0, 4096
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
b _dc_o_53
_dc_o_54:
li r0, 1048576
lrr.l r0, r0
call _PUSH
li r0, 201333927
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_56
_dc_o_55:
li r0, _dc_o_57
call _PUSH
push r5
push r6
push r7
push r8
push r9
push r10
call Error
pop r10
pop r9
pop r8
pop r7
pop r6
pop r5
ret
_dc_o_56:
li r0, CIPtr
lrr.l r0, r0
call _PUSH
mov r0, r5
call _PUSH
mov r0, r9
call _PUSH
li r0, PartitionStart
call _PUSH

		call _POP
		mov r3, r0
		call _POP
		mov r2, r0
		call _POP
		mov r1, r0
		call _POP
		call 0x100004
	
ret

CIPtr:
	.dl 0
_dc_o_0:
	.ds Runtime error: Stack underflow.
	.db 0xA
	.ds 
	.db 0x0
PromptLine:
	.bytes 6 0x0
PartitionStart:
	.bytes 32 0x0
_dc_o_4:
	.ds Panic: 
	.db 0x0
_dc_o_6:
	.ds @
	.db 0x0
_dc_o_8:
	.ds ==== Bootloader ====
	.db 0xA
	.ds 
	.db 0x0
_dc_o_10:
	.ds Bootdev? Default:
	.db 0x0
_dc_o_14:
	.ds Boot0 on blockdev
	.db 0x0
_dc_o_16:
	.ds Loading volume descriptor block
	.db 0xA
	.ds 
	.db 0x0
_dc_o_18:
	.ds Disk Info:
	.db 0xA
	.ds 
	.db 0x0
_dc_o_22:
	.ds at the disc.
	.db 0xA
	.ds 
	.db 0x0
_dc_o_24:
	.ds 	Disk Label: 
	.db 0x0
_dc_o_26:
	.ds 
	.db 0xA
	.ds Bootable partitions:
	.db 0xA
	.ds 
	.db 0x0
_dc_o_32:
	.ds : 
	.db 0x0
_dc_o_39:
	.ds No bootable partitions.
	.db 0xA
	.ds 
	.db 0x0
_dc_o_43:
	.ds boot partition? default:
	.db 0x0
_dc_o_47:
	.ds Selected 
	.db 0x0
_dc_o_51:
	.ds Bad partition
	.db 0xA
	.ds 
	.db 0x0
_dc_o_57:
	.ds Invalid boot1
	.db 0xA
	.ds 
	.db 0x0

