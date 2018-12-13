;character device interface

;==== OwO what's this? ====
;chardevs have a number descriptor
;which is just an index into CharDevTable
;
;the entries in the table are a structure
;that contains pointers to functions like
;PutChar, GetChar, and others

;caveats: the lack of a major/minor system
;prevents drivers that can handle multiple
;instances of the same device
;block devices do have this though

;default devices:
;0: serial
;1: graphical console
;2: keyboard

;first 128 chardev numbers reserved (0-127)

.struct CharDev
	PutChar 4
	GetChar 4
end-struct

CharFallbackStdIn === 2
CharFallbackStdOut === 1

CharDevNull:
	li r0, 0xFFFF
	ret

;register default devices
CharDevInit:
	sii.b CharLastDev, 0

	call SerialInit
	call ConsoleInit
	call KeyboardInit

	ret

;r0 - PutChar
;r1 - GetChar
CharDevRegister:
	push r10
	push r3
	push r2

	mov r2, r1
	mov r1, r0

	lri.b r0, CharLastDev
	addi r3, r0, 1
	sir.b CharLastDev, r3

	muli r0, r0, CharDev_sizeof
	addi r0, r0, CharDevTable

	addi r3, r0, CharDev_PutChar
	srr.l r3, r1

	addi r3, r0, CharDev_GetChar
	srr.l r3, r2

	pop r2
	pop r3
	pop r10
	ret

;r0 - char
;r1 - num
PutChar:
	muli r1, r1, CharDev_sizeof
	addi r1, r1, CharDevTable

	addi r1, r1, CharDev_PutChar
	lrr.l r1, r1

	cmpi r1, 0 ;not supported or no chardev
	be .nope

	br r1
	;no ret because the handler will take us back up

.nope:
	ret

;r0 - num
;outputs:
;r0 - byte
GetChar:
	muli r0, r0, CharDev_sizeof
	addi r0, r0, CharDevTable

	addi r0, r0, CharDev_GetChar
	lrr.l r0, r0

	cmpi r0, 0 ;not supported or not a chardev
	be .nope

	br r0
	;no ret because handler will take us back up

.nope:
	li r0, 0xFFFF
	ret


StdPutChar:
	push r1
	lri.b r1, IOStdOut

	call PutChar
	pop r1
	ret

StdGetChar:
	lri.b r0, IOStdIn

	call GetChar
	ret