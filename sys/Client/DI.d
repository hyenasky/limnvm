asm preamble "

.org 0xA0000 ;loaded here by auntie antecedent

.ds ANTE

;r0 contains pointer to client interface
call _PUSH
call CIInit

;r1 contains blockdev number

mov r0, r1
call _PUSH
b Main

;if main returns, itll go back into the ROM
;which should reset.

;consts: offsets into CI
_CIC_PutString === 0x0
_CIC_GetString === 0x4
_CIC_StdPutChar === 0x8
_CIC_StdGetChar === 0xC
_CIC_PutChar === 0x10
_CIC_GetChar === 0x14
_CIC_PutInteger === 0x18

"

var CIPtr 0

procedure CIInit (* ptr -- *)
	(* store CIPtr *)
	CIPtr!
end

procedure _UNDERFLOW (* -- *)
	"Runtime error: Stack underflow.\n" PutString
	while (1) end
end

procedure _OVERFLOW (* -- *)
	"Runtime error: Stack overflow.\n" PutString
	while (1) end
end

(* lots of thunks *)

procedure PutString (* str -- *)
	asm "

	call _POP

	lri.l r1, CIPtr
	addi r1, r1, _CIC_PutString
	lrr.l r1, r1

	call .stupidhack

	b .out

.stupidhack:
	br r1

.out:

	"
end

procedure GetString (* buf max -- *)
	asm "

	call _POP
	mov r1, r0

	call _POP

	lri.l r2, CIPtr
	addi r2, r2, _CIC_PutString
	lrr.l r2, r2

	call .stupidhack

	b .out

.stupidhack:
	br r2

.out:

	"
end

procedure StdPutChar (* char -- *)
	asm "

	call _POP

	lri.l r1, CIPtr
	addi r1, r1, _CIC_StdPutChar
	lrr.l r1, r1

	call .stupidhack

	b .out

.stupidhack:
	br r1

.out:

	"
end

procedure StdGetChar (* -- char *)
	asm "

	lri.l r0, CIPtr
	addi r0, r0, _CIC_StdGetChar
	lrr.l r0, r0

	call .stupidhack

	b .out

.stupidhack:
	br r0

.out:
	call _PUSH

	"
end

procedure PutChar (* char chardev -- *)
	asm "

	call _POP
	mov r1, r0

	call _POP

	lri.l r2, CIPtr
	addi r2, r2, _CIC_PutChar
	lrr.l r2, r2

	call .stupidhack

	b .out

.stupidhack:
	br r2

.out:

	"
end

procedure GetChar (* chardev -- char *)
	asm "

	call _POP

	lri.l r1, CIPtr
	addi r1, r1, _CIC_StdPutChar
	lrr.l r1, r1

	call .stupidhack

	b .out

.stupidhack:
	br r1

.out:
	call _PUSH

	"
end

procedure PutInteger (* num -- *)
	asm "

	call _POP

	lri.l r1, CIPtr
	addi r1, r1, _CIC_PutInteger
	lrr.l r1, r1

	call .stupidhack

	b .out

.stupidhack:
	br r1

.out:

	"
end