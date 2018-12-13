

.org 0x100000

.ds DTOO

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH
b Main


_STACK_PTR:
	.dl 0

;68 cells deep
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
Call:

		call _POP
		call .e
		ret

		.e:
			br r0
	
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


BuildPT:
li r0, 0
mov r5, r0
li r0, 1179648
call _PUSH
li r0, 16
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
li r0, 0
mov r7, r0
_dc_o_4:
mov r0, r5
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
be _dc_o_5
mov r0, r6
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
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_7
_dc_o_6:
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_9
_dc_o_8:
mov r0, r7
call _PUSH
li r0, 2
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
_dc_o_9:
mov r0, r7
call _PUSH
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionTable
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r6
call _PUSH
li r0, 8
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
mov r7, r0
b _dc_o_10
_dc_o_7:
li r0, 4294967295
call _PUSH
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionTable
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_10:
mov r0, r6
call _PUSH
li r0, 16
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
b _dc_o_4
_dc_o_5:
ret
SaveVDB:
li r0, _dc_o_11
call _PUSH
call PutString
li r0, 0
call _PUSH
li r0, 1179648
call _PUSH
li r0, SelectedBlockDev
lrr.l r0, r0
call _PUSH
call WriteBlock
ret
SelectDev:
call _POP
mov r5, r0
push r5
call SaveVDB
pop r5
li r0, _dc_o_13
call _PUSH
push r5
call PutString
pop r5
li r0, 0
call _PUSH
li r0, 1179648
call _PUSH
mov r0, r5
call _PUSH
push r5
call ReadBlock
pop r5
mov r0, r5
call _PUSH
li r0, SelectedBlockDev
mov r1, r0
call _POP
srr.l r1, r0
push r5
call BuildPT
pop r5
ret
CommandLine:
call CLInit
li r0, _dc_o_15
call _PUSH
call PutString
li r0, 1
call _PUSH
li r0, Running
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_17:
li r0, Running
lrr.l r0, r0
cmpi r0, 0
be _dc_o_18
call CLPrompt
b _dc_o_17
_dc_o_18:
ret
CLNotACommand:
call _POP
li r0, _dc_o_19
call _PUSH
call PutString
ret
CLRegisterCommand:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, CommandTable
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
ret
CLInit:
li r0, BootDevice
lrr.l r0, r0
call _PUSH
li r0, SelectedBlockDev
mov r1, r0
call _POP
srr.l r1, r0
li r0, 0
call _PUSH
li r0, 1179648
call _PUSH
li r0, BootDevice
lrr.l r0, r0
call _PUSH
call ReadBlock
call BuildPT
li r0, 0
mov r5, r0
_dc_o_21:
mov r0, r5
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
be _dc_o_22
li r0, CLNotACommand
call _PUSH
mov r0, r5
call _PUSH
push r5
call CLRegisterCommand
pop r5
mov r0, r5
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
b _dc_o_21
_dc_o_22:
li r0, CmdHelpText
call _PUSH
li r0, 104
call _PUSH
push r5
call CLRegisterCommand
pop r5
li r0, CmdQuit
call _PUSH
li r0, 113
call _PUSH
push r5
call CLRegisterCommand
pop r5
li r0, CmdChangeDev
call _PUSH
li r0, 99
call _PUSH
push r5
call CLRegisterCommand
pop r5
li r0, CmdSave
call _PUSH
li r0, 115
call _PUSH
push r5
call CLRegisterCommand
pop r5
li r0, CmdInfo
call _PUSH
li r0, 105
call _PUSH
push r5
call CLRegisterCommand
pop r5
li r0, CmdFormat
call _PUSH
li r0, 102
call _PUSH
push r5
call CLRegisterCommand
pop r5
li r0, CmdPartition
call _PUSH
li r0, 112
call _PUSH
push r5
call CLRegisterCommand
pop r5
ret
CLPrompt:
li r0, PromptLine
call _PUSH
call StringZero
li r0, SelectedBlockDev
lrr.l r0, r0
call _PUSH
call PutIntegerD
li r0, _dc_o_23
call _PUSH
call PutString
li r0, PromptLine
call _PUSH
li r0, 127
call _PUSH
call GetString
li r0, PromptLine
lrr.b r0, r0
call _PUSH
call _PUSH
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_26
_dc_o_25:
ret
_dc_o_26:
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, CommandTable
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
li r0, PromptLine
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
xch r0, r1
call _PUSH
mov r0, r1
call _PUSH
call Call
ret
CmdHelpText:
call _POP
li r0, _dc_o_27
call _PUSH
call PutString
ret
CmdPartition:
call _POP
li r0, 0
mov r6, r0
_dc_o_29:
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
be _dc_o_30
li r0, 1179648
call _PUSH
li r0, 16
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, 16
call _PUSH
mov r0, r6
mov r1, r0
call _POP
mul r0, r1, r0
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
mov r0, r5
call _PUSH
push r5
push r6
call PutIntegerD
pop r6
pop r5
push r5
push r6
call CR
pop r6
pop r5
li r0, _dc_o_31
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
mov r0, r6
call _PUSH
push r5
push r6
call PutIntegerD
pop r6
pop r5
li r0, _dc_o_33
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
li r0, _dc_o_35
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
li r0, PromptLine
call _PUSH
push r5
push r6
call StringZero
pop r6
pop r5
li r0, PromptLine
call _PUSH
li r0, 1
call _PUSH
push r5
push r6
call GetString
pop r6
pop r5
li r0, PromptLine
call _PUSH
push r5
push r6
call StringToInteger
pop r6
pop r5
call _PUSH
mov r0, r5
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.b r1, r0
li r0, 0
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_38
_dc_o_37:
li r0, _dc_o_39
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
li r0, PromptLine
call _PUSH
push r5
push r6
call StringZero
pop r6
pop r5
li r0, PromptLine
call _PUSH
li r0, 7
call _PUSH
push r5
push r6
call GetString
pop r6
pop r5
mov r0, r5
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
li r0, PromptLine
call _PUSH
push r5
push r6
call StringCopy
pop r6
pop r5
li r0, _dc_o_41
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
li r0, PromptLine
call _PUSH
push r5
push r6
call StringZero
pop r6
pop r5
li r0, PromptLine
call _PUSH
li r0, 10
call _PUSH
push r5
push r6
call GetString
pop r6
pop r5
li r0, PromptLine
call _PUSH
push r5
push r6
call StringToInteger
pop r6
pop r5
mov r0, r5
call _PUSH
li r0, 8
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
_dc_o_38:
mov r0, r6
call _PUSH
li r0, 1
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
b _dc_o_29
_dc_o_30:
push r5
push r6
call BuildPT
pop r6
pop r5
ret
CmdFormat:
li r0, 1179648
mov r5, r0
li r0, 1179648
call _PUSH
li r0, 4096
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
_dc_o_43:
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
be _dc_o_44
li r0, 0
call _PUSH
mov r0, r5
mov r1, r0
call _POP
srr.l r1, r0
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
add r0, r1, r0
mov r5, r0
b _dc_o_43
_dc_o_44:
li r0, 1179648
mov r1, r0
call _POP
xch r0, r1
call _PUSH
mov r0, r1
call _PUSH
push r5
push r6
call StringCopy
pop r6
pop r5
li r0, 1313687884
call _PUSH
li r0, 1179648
call _PUSH
li r0, 144
mov r1, r0
call _POP
add r0, r1, r0
mov r1, r0
call _POP
srr.l r1, r0
ret
CmdQuit:
call _POP
li r0, _dc_o_45
call _PUSH
call PutString
li r0, 0
call _PUSH
li r0, Running
mov r1, r0
call _POP
srr.l r1, r0
ret
CmdChangeDev:
call StringToInteger
call _PUSH
li r0, _dc_o_47
call _PUSH
call PutString
call PutIntegerD
call CR
call SelectDev
ret
CmdSave:
call _POP
call SaveVDB
ret
BReadBlock:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionTable
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r6
call _PUSH
li r0, SelectedBlockDev
lrr.l r0, r0
call _PUSH
push r5
push r6
push r7
call ReadBlock
pop r7
pop r6
pop r5
ret
BWriteBlock:
call _POP
mov r5, r0
call _POP
mov r6, r0
call _POP
mov r7, r0
mov r0, r5
call _PUSH
li r0, 4
mov r1, r0
call _POP
mul r0, r1, r0
call _PUSH
li r0, PartitionTable
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
mov r0, r7
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
mov r0, r6
call _PUSH
li r0, SelectedBlockDev
lrr.l r0, r0
call _PUSH
push r5
push r6
push r7
call WriteBlock
pop r7
pop r6
pop r5
ret
CmdInfo:
call _POP
li r0, _dc_o_49
call _PUSH
call PutString
li r0, _dc_o_51
call _PUSH
call PutString
li r0, 1179648
call _PUSH
li r0, 144
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
call _PUSH
call PutString
call CR
call _POP
lrr.l r0, r0
call _PUSH
li r0, 1313687884
mov r1, r0
call _POP
cmp r0, r1
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_54
_dc_o_53:
li r0, _dc_o_55
call _PUSH
call PutString
ret
_dc_o_54:
li r0, _dc_o_57
call _PUSH
call PutString
li r0, 1179648
call _PUSH
li r0, 0
mov r1, r0
call _POP
add r0, r1, r0
call _PUSH
call PutString
li r0, _dc_o_59
call _PUSH
call PutString
li r0, 0
mov r5, r0
li r0, 1179648
call _PUSH
li r0, 16
mov r1, r0
call _POP
add r0, r1, r0
mov r6, r0
_dc_o_61:
mov r0, r5
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
be _dc_o_62
mov r0, r6
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
not rf, rf
andi r0, rf, 0x1
cmpi r0, 0
be _dc_o_64
_dc_o_63:
li r0, 9
call _PUSH
push r5
push r6
call StdPutChar
pop r6
pop r5
mov r0, r5
call _PUSH
push r5
push r6
call PutIntegerD
pop r6
pop r5
li r0, _dc_o_65
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
mov r0, r6
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
push r5
push r6
call CR
pop r6
pop r5
li r0, _dc_o_67
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
mov r0, r6
call _PUSH
li r0, 12
mov r1, r0
call _POP
add r0, r1, r0
lrr.b r0, r0
call _PUSH
push r5
push r6
call PutIntegerD
pop r6
pop r5
push r5
push r6
call CR
pop r6
pop r5
li r0, _dc_o_69
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
mov r0, r6
call _PUSH
li r0, 8
mov r1, r0
call _POP
add r0, r1, r0
lrr.l r0, r0
call _PUSH
push r5
push r6
call PutIntegerD
pop r6
pop r5
li r0, _dc_o_71
call _PUSH
push r5
push r6
call PutString
pop r6
pop r5
_dc_o_64:
mov r0, r6
call _PUSH
li r0, 16
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
b _dc_o_61
_dc_o_62:
ret
Main:
li r0, BootDevice
mov r1, r0
call _POP
srr.l r1, r0
li r0, CIPtr
mov r1, r0
call _POP
srr.l r1, r0
li r0, _dc_o_73
call _PUSH
call PutString
call CommandLine
ret
FatalError:
li r0, _dc_o_75
call _PUSH
call PutString
call PutString
_dc_o_77:
li r0, 1
cmpi r0, 0
be _dc_o_78
b _dc_o_77
_dc_o_78:
ret

CIPtr:
	.dl 0
_dc_o_0:
	.ds Runtime error: Stack underflow.
	.db 0xA
	.ds 
	.db 0x0
BootDevice:
	.dl 0
Running:
	.dl 0
SelectedBlockDev:
	.dl 0
PromptLine:
	.bytes 128 0x0
CommandTable:
	.bytes 512 0x0
PartitionTable:
	.bytes 32 0x0
_dc_o_11:
	.ds Writing VDB...
	.db 0xA
	.ds 
	.db 0x0
_dc_o_13:
	.ds Reading new VDB...
	.db 0xA
	.ds 
	.db 0x0
_dc_o_15:
	.ds Type h for a list of commands.
	.db 0xA
	.ds 
	.db 0x0
_dc_o_19:
	.ds Not a valid command.
	.db 0xA
	.ds 
	.db 0x0
_dc_o_23:
	.ds > 
	.db 0x0
_dc_o_27:
	.ds h - help
	.db 0xA
	.ds q - quit
	.db 0xA
	.ds s - save changes
	.db 0xA
	.ds i - print disk info
	.db 0xA
	.ds p - partition
	.db 0xA
	.ds f<name> - format (will overwrite VDB, partition table wiped out)
	.db 0xA
	.ds c<dev> - change to dev
	.db 0xA
	.ds 
	.db 0x0
_dc_o_31:
	.ds partition 
	.db 0x0
_dc_o_33:
	.ds : 
	.db 0xA
	.ds 
	.db 0x0
_dc_o_35:
	.ds 	status (0 unused, 1 boot, 2 used): 
	.db 0x0
_dc_o_39:
	.ds 	label: 
	.db 0x0
_dc_o_41:
	.ds 	blocks: 
	.db 0x0
_dc_o_45:
	.ds Bye!
	.db 0xA
	.ds 
	.db 0x0
_dc_o_47:
	.ds Switching to blk
	.db 0x0
_dc_o_49:
	.ds Disk Info:
	.db 0xA
	.ds 
	.db 0x0
_dc_o_51:
	.ds 	Magic: 
	.db 0x0
_dc_o_55:
	.ds Invalid volume descriptor. Type 'f<name>' to format.
	.db 0xA
	.ds 
	.db 0x0
_dc_o_57:
	.ds 	Disk Label: 
	.db 0x0
_dc_o_59:
	.ds 
	.db 0xA
	.ds Partitions:
	.db 0xA
	.ds 
	.db 0x0
_dc_o_65:
	.ds : 
	.db 0x0
_dc_o_67:
	.ds 		Status: 
	.db 0x0
_dc_o_69:
	.ds 		Size: 
	.db 0x0
_dc_o_71:
	.ds  blocks
	.db 0xA
	.ds 
	.db 0x0
_dc_o_73:
	.ds ==== Disktools ====
	.db 0xA
	.ds 
	.db 0x0
_dc_o_75:
	.ds 
	.db 0xA
	.ds Fatal Error: 
	.db 0x0

