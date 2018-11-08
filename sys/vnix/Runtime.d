(* barebones runtime lib for vnix, depends on antecedent *)

var CIPtr 0

procedure _UNDERFLOW (* -- *)
	"Runtime error: Stack underflow.\n" PutString
	while (1) end
end

procedure CR (* -- *)
	'\n' StdPutChar
end

asm "

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

"