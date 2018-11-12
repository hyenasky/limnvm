BlitterCmdPort === 0x40
BlitterPortA === 0x41
BlitterPortB === 0x42
BlitterPortC === 0x43
BlitterPortD === 0x44

BlitterIntNum === 0x40

BlitterInterrupt:
	pusha
	sii.b BlitterSpinning, 0
	popa
	iret

BlitterSpinTimeout === 0x100000

BlitterSpin:
	push r0
	push r1
	li r1, 0

.spin:
	cmpi r1, BlitterSpinTimeout
	bge .timeout

	addi r1, r1, 1

	lri.b r0, BlitterSpinning
	cmpi r0, 0
	bne .spin

.out:
	pop r1
	pop r0
	ret

.timeout:
	li r0, BlitterStringTimeout
	call PutString

	sii.b BlitterSpinning, 0
	b .out

BlitterStringTimeout:
	.ds Blitter: Timed out
	.db 0xA, 0x0

BlitterInit:
	li r0, BlitterIntNum
	li r1, BlitterInterrupt
	call InterruptRegister

	ret

;r0 - cmd
;r1 - from
;r2 - dest
;r3 - dim
;r4 - modulo
BlitterOperation:
	sii.b BlitterSpinning, 1

	push r0

	li r0, BlitterPortA
	call BusWriteLong

	li r0, BlitterPortB
	mov r1, r2
	call BusWriteLong

	li r0, BlitterPortC
	mov r1, r3
	call BusWriteLong

	li r0, BlitterPortD
	mov r1, r4
	call BusWriteLong

	pop r0
	mov r1, r0

	li r0, BlitterCmdPort
	call BusCommand

	call BlitterSpin

	ret