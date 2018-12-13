.struct NVRAM
	NotNVRAM 0xF2000000
	Magic 4
	AutorunBuffer 128
	DefaultStdIn 1
	DefaultStdOut 1
	DefaultFGColor 1
	DefaultBGColor 1
end-struct

NVRAMInit:
	push r0
	lri.l r0, NVRAM_Magic
	cmpi r0, 0x45544E41
	bne .badnvram

	lri.b r0, NVRAM_DefaultStdIn
	sir.b IOStdIn, r0
	lri.b r0, NVRAM_DefaultStdOut
	sir.b IOStdOut, r0
	lri.b r0, NVRAM_DefaultFGColor
	sir.b ConsoleFGColor, r0
	lri.b r0, NVRAM_DefaultBGColor
	sir.b ConsoleBGColor, r0

.out:
	pop r0
	ret

.badnvram:
	sii.b IOStdOut, CharFallbackStdOut
	sii.b IOStdIn, CharFallbackStdIn

	sii.b ConsoleFGColor, 0x00
	sii.b ConsoleBGColor, 0x63

	push r0
	li r0, NVRAMStringBad
	call PutString
	pop r0

	call PutInteger

	b .out

NVRAMStringBad:
	.ds Invalid NVRAM: 
	.db 0x0