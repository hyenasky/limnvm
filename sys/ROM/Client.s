;calls that a client program can make into the ROM
ClientInterface:
	.dl PutString
	.dl GetString
	.dl StdPutChar
	.dl StdGetChar
	.dl PutChar
	.dl GetChar
	.dl PutInteger
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
	.dl 0
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

;right now we just load block 1 off the serial disk
;at 0xA0000, check for the signature, and jump into it
;this will be way more sophisticated in the future

;r0 - block device
GoClient:
	li r0, 0
	li r1, 1
	li r2, ClientBottom
	call SerialReadBlock

	lri.l r0, ClientBottom
	cmpi r0, 0x45544E41
	be .go

	li r0, EBootSignature ;failed
	ret

.go:
	li r0, ClientInterface ;client interface pointer
	li r1, 0 ;boot device
	call 0xA0004

	ret
