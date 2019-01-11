asm preamble "

.org 0x200000

.ds VNIX

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH

;r2 contains boot partition
mov r0, r2
call _PUSH

;r3 contains partition table ptr
mov r0, r3
call _PUSH

;r4 contains args string ptr
mov r0, r4
call _PUSH

sir.l AnteSP, sp
li sp, VNIXStack

b Main

	.bytes 4096 0
VNIXStack:

"