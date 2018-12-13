

.org 0x100000

.dl 0x0C001CA7

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

b Main


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


IDiskInit:
call _POP
mov r1, r0
call _POP
xch r0, r1
call _PUSH
mov r0, r1
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, IDiskBase
mov r1, r0
call _POP
srr.l r1, r0
li r0, IDiskBD
mov r1, r0
call _POP
srr.l r1, r0
ret
IReadBlock:
call _POP
mov r1, r0
call _POP
xch r0, r1
call _PUSH
mov r0, r1
call _PUSH
li r0, IDiskBase
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
xch r0, r1
call _PUSH
mov r0, r1
call _PUSH
li r0, IDiskBD
lrr.l r0, r0
call _PUSH
call ReadBlock
ret
VFSInit:
li r0, _dc_o_4
call _PUSH
call PutString
li r0, 0
call _PUSH
li r0, 1114112
call _PUSH
call IReadBlock
li r0, 1114112
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 2948313019
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_7
_dc_o_6:
li r0, _dc_o_8
call _PUSH
call Panic
_dc_o_10:
li r0, 1
cmpi r0, 0
be _dc_o_11
b _dc_o_10
_dc_o_11:
_dc_o_7:
li r0, 1114112
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
li r0, 4
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_13
_dc_o_12:
li r0, _dc_o_14
call _PUSH
call Panic
_dc_o_16:
li r0, 1
cmpi r0, 0
be _dc_o_17
b _dc_o_16
_dc_o_17:
_dc_o_13:
li r0, 1114112
call _PUSH
li r0, 34
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, 1245184
call _PUSH
call IReadBlock
ret
VFSLoadFile:
call _POP
mov r5, r0
push r5
call VFSFileByName
pop r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_19
_dc_o_18:
ret
_dc_o_19:
call _POP
mov r6, r0
mov r0, r6
call _PUSH
li r0, 14
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r7, r0
mov r0, r6
call _PUSH
li r0, 18
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r8, r0
li r0, 0
mov r9, r0
_dc_o_20:
mov r0, r9
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
be _dc_o_21
mov r0, r7
call _PUSH
mov r0, r5
call _PUSH
push r5
push r6
push r7
push r8
push r9
call IReadBlock
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
call VFSBlockStatus
pop r9
pop r8
pop r7
pop r6
pop r5
call _POP
mov r7, r0
mov r0, r5
call _PUSH
li r0, 4096
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
mov r0, r9
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r9, r0
b _dc_o_20
_dc_o_21:
li r0, 1
call _PUSH
ret
VFSFileByName:
call _POP
mov r5, r0
li r0, 0
mov r6, r0
_dc_o_22:
mov r0, r6
call _PUSH
li r0, 64
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
be _dc_o_23
mov r0, r6
call _PUSH
li r0, 64
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 1245184
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, 26
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r5
call _PUSH
push r5
push r6
call StringCompare
pop r6
pop r5
call _POP
cmpi r0, 0
be _dc_o_25
_dc_o_24:
mov r0, r6
call _PUSH
li r0, 64
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 1245184
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
ret
_dc_o_25:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_22
_dc_o_23:
li r0, 0
call _PUSH
ret
VFSReadFATBlock:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, VFSFatCached
lrr.l r0, r0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_27
_dc_o_26:
mov r0, r5
call _PUSH
li r0, 1114112
call _PUSH
li r0, 26
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, 1179648
call _PUSH
push r5
call IReadBlock
pop r5
mov r0, r5
call _PUSH
li r0, VFSFatCached
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_27:
ret
VFSBlockStatus:
call _POP
mov r5, r0
mov r0, r5
call _PUSH
li r0, 4096
mov r1, r0
call _POP
div r0, r0, r1
mov r6, r0
mov r0, r5
call _PUSH
li r0, 4096
mov r1, r0
call _POP
mod r0, r0, r1
mov r7, r0
mov r0, r6
call _PUSH
push r5
push r6
push r7
call VFSReadFATBlock
pop r7
pop r6
pop r5
mov r0, r7
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, 1179648
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
ret
Main:
call _POP
mov r7, r0
call _POP
mov r6, r0
call _POP
mov r5, r0
li r0, CIPtr
mov r1, r0
call _POP
srr.l r1, r0
li r0, _dc_o_28
call _PUSH
push r5
push r6
push r7
call PutString
pop r7
pop r6
pop r5
mov r0, r5
call _PUSH
push r5
push r6
push r7
call PutInteger
pop r7
pop r6
pop r5
li r0, 58
call _PUSH
push r5
push r6
push r7
call StdPutChar
pop r7
pop r6
pop r5
mov r0, r6
call _PUSH
push r5
push r6
push r7
call PutInteger
pop r7
pop r6
pop r5
push r5
push r6
push r7
call CR
pop r7
pop r6
pop r5
mov r0, r5
call _PUSH
mov r0, r6
call _PUSH
mov r0, r7
call _PUSH
push r5
push r6
push r7
call IDiskInit
pop r7
pop r6
pop r5
push r5
push r6
push r7
call VFSInit
pop r7
pop r6
pop r5
li r0, _dc_o_30
call _PUSH
push r5
push r6
push r7
call PutString
pop r7
pop r6
pop r5
li r0, _dc_o_32
call _PUSH
li r0, 2097152
call _PUSH
push r5
push r6
push r7
call VFSLoadFile
pop r7
pop r6
pop r5
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_35
_dc_o_34:
li r0, _dc_o_36
call _PUSH
push r5
push r6
push r7
call Panic
pop r7
pop r6
pop r5
ret
_dc_o_35:
li r0, 2097152
lrr.l r0, r0
call _PUSH
li r0, 1481199190
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_39
_dc_o_38:
li r0, _dc_o_40
call _PUSH
push r5
push r6
push r7
call Panic
pop r7
pop r6
pop r5
ret
_dc_o_39:
li r0, CIPtr
lrr.l r0, r0
call _PUSH
mov r0, r5
call _PUSH
mov r0, r6
call _PUSH
mov r0, r7
call _PUSH

		call _POP
		mov r3, r0
		call _POP
		mov r2, r0
		call _POP
		mov r1, r0
		call _POP
		b 0x200004
	
ret
Panic:
li r0, _dc_o_42
call _PUSH
call PutString
call PutString
ret

CIPtr:
	.dl 0
_dc_o_0:
	.ds Runtime error: Stack underflow.
	.db 0xA
	.ds 
	.db 0x0
IDiskBD:
	.dl 0
IDiskBase:
	.dl 0
_dc_o_4:
	.ds VnF: Mounting filesystem
	.db 0xA
	.ds 
	.db 0x0
_dc_o_8:
	.ds VnF: Invalid superblock
	.db 0xA
	.ds 
	.db 0x0
_dc_o_14:
	.ds VnF: Bad version on superblock
	.db 0xA
	.ds 
	.db 0x0
VFSFatCached:
	.dl 4294967295
_dc_o_28:
	.ds Boot1 on 
	.db 0x0
_dc_o_30:
	.ds Loading kernel image
	.db 0xA
	.ds 
	.db 0x0
_dc_o_32:
	.ds vnix
	.db 0x0
_dc_o_36:
	.ds Failed to load kernel image
	.db 0xA
	.ds 
	.db 0x0
_dc_o_40:
	.ds Invalid kernel image
	.db 0xA
	.ds 
	.db 0x0
_dc_o_42:
	.ds Panic: 
	.db 0x0

