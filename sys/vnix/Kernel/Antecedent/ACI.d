var CIPtr 0

asm "

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
	add r30, r30, r29
	lrr.l r30, r30

	call .e
	pop r29
	ret

.e:
	br r30

_CIC_Putc === 0
_CIC_Getc === 4
_CIC_Gets === 8
_CIC_Puts === 12
_CIC_DevTree === 16
_CIC_Malloc === 20
_CIC_Calloc === 24
_CIC_Free === 28
_CIC_PUSH === 32
_CIC_POP === 36

; v --
ACIPush:
	push r30

	call _POP

	li r30, _CIC_PUSH
	call _CIC_Call

	pop r30
	ret

; -- v
ACIPop:
	push r30

	li r30, _CIC_POP
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; string --
ACIPuts:
	push r30

	call _POP

	li r30, _CIC_Puts
	call _CIC_Call

	pop r30
	ret

; buffer maxchars --
ACIGets:
	push r30

	call _POP
	mov r1, r0

	call _POP

	li r30, _CIC_Gets
	call _CIC_Call

	pop r30
	ret

; char -- 
ACIPutc:
	push r30

	call _POP

	li r30, _CIC_Putc
	call _CIC_Call

	pop r30
	ret

; -- char
ACIGetc:
	push r30

	call _POP

	li r30, _CIC_Getc
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; -- root dcp
ACIDevTree:
	push r30

	li r30, _CIC_DevTree
	call _CIC_Call

	call _PUSH

	mov r0, r1
	call _PUSH

	pop r30
	ret

; sz -- ptr
ACIMalloc:
	push r30

	call _POP

	li r30, _CIC_Malloc
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; sz -- ptr
ACICalloc:
	push r30

	call _POP

	li r30, _CIC_Calloc
	call _CIC_Call

	call _PUSH

	pop r30
	ret

; ptr -- 
ACIFree:
	push r30

	call _POP

	li r30, _CIC_Free
	call _CIC_Call

	pop r30
	ret

"