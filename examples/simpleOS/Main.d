#include "Runtime.d"
#include "Console.d"

asm preamble "

.org 0x100000

.ds ANTE
.dl Entry

Entry:

;r0 contains pointer to API
call _PUSH

;r1 contains devnode
mov r0, r1
call _PUSH

;r2 contains args
mov r0, r2
call _PUSH

b Main

"

procedure Main (* ciptr bootdev args -- *)

    auto args
    auto BootDevice

    args!

    (* remember the boot device *)
    BootDevice!

    (* initialize the client interface *)
    CIPtr!
    "Hello World\n" Printf
 	args@ "Hey bitch: %s\n" Printf

 	pointerof DragonASCII Puts
end

asm "

DA === #dragon.txt

DragonASCII:
	.ds$ DA
	.db 0xA, 0x0

"