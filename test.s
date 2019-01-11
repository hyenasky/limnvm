.org 0x100000

.ds ANTE
.dl Entry

buffer:
	.bytes 256 0


;r0 - api
;r1 - devnode
Entry:
	addi r0, r0, 8
	lrr.l r2, r0

	call .test
	b .out

.test:
	li r0, buffer
	li r1, 255
	br r2

.out:
	ret