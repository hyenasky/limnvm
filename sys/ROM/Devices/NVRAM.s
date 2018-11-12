NVRAMLocAutorun === 0xF2000004 ;128 byte buffer

NVRAMInit:
	push r0
	lri.l r0, NVRAM
	cmpi r0, 0x45544E41
	bne .badnvram

.out:
	pop r0
	ret

.badnvram:
	push r0
	li r0, NVRAMStringBad
	call PutString
	pop r0

	call PutInteger

	b .out

NVRAMStringBad:
	.ds Invalid NVRAM: 
	.db 0x0