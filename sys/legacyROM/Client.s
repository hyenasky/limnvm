;calls that a client program can make into the ROM
ClientInterface:
	.dl PutString
	.dl GetString
	.dl StdPutChar
	.dl StdGetChar
	.dl PutChar
	.dl GetChar
	.dl PutInteger
	.dl PutIntegerD
	.dl ListBDevs
	.dl BlockDriverList
	.dl BlockDriverRegister
	.dl ReadBlock
	.dl WriteBlock
	.dl StringZero
	.dl StringCopy
	.dl StringLength
	.dl StringToInteger
	.dl StringTokenize
	.dl Reset
	.dl InterruptRegister
	.dl StringCompare
	.dl BlitterOperation
	.dl MmuGetRAM
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0

EBootSignature === 1

;load block 1 off the specified block device at ClientBottom
;then jump into it if it has ascii "ANTE" signature at start

;r0 - block device
;r1 - arguments
GoClient:
	sii.l ClientBottom, 0

	push r3
	push r2
	push r1

	mov r3, r0

	li r1, 1 ;load block 1
	li r2, ClientBottom
	call ReadBlock

	lri.l r0, ClientBottom
	cmpi r0, 0x45544E41 ; "ANTE"
	be .go

	li r0, EBootSignature ;failed
	b .out

.go:
	li r0, ClientInterface ;client interface pointer
	mov r1, r3 ;boot device
	pop r2
	push r1
	call 0xA0004

.out:
	pop r1
	pop r2
	pop r3
	
	ret
