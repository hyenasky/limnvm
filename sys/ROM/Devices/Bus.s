BusBytesPerPort === 4

;r0 - port
;r1 - command
BusCommand:
	muli r0, r0, 4
	addi r0, r0, BusStart

	srr.b r0, r1

	push r2
.wait:
	lrr.b r2, r0
	cmpi r2, 0 ;wait until device is idle
	be .done

	b .wait

.done:
	pop r2

	ret

;r0 - port
;outputs:
;r0 - byte
BusReadByte:
	muli r0, r0, 4
	addi r0, r0, BusStart

	lrr.b r0, r0
	ret

;r0 - port
;outputs:
;r0 - int
BusReadInt:
	muli r0, r0, 4
	addi r0, r0, BusStart

	lrr.i r0, r0
	ret

;r0 - port
;outputs:
;r0 - long
BusReadLong:
	muli r0, r0, 4
	addi r0, r0, BusStart

	lrr.l r0, r0
	ret

;r0 - port
;r1 - byte
BusWriteByte:
	muli r0, r0, 4
	addi r0, r0, BusStart

	srr.b r0, r1
	ret

;r0 - port
;r1 - int
BusWriteInt:
	muli r0, r0, 4
	addi r0, r0, BusStart

	srr.i r0, r1
	ret

;r0 - port
;r1 - long
BusWriteLong:
	muli r0, r0, 4
	addi r0, r0, BusStart

	srr.l r0, r1
	ret



















