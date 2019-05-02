#include "Runtime.d"
#include "Console.d"

asm preamble "

.org 0x100000

.ds ANTE
.dl Entry

Entry:

li r5, MyStack

;r0 contains pointer to API
pushv r5, r0

;r1 contains devnode
pushv r5, r1

;r2 contains args
pushv r5, r2

b Main

"

buffer MyStack 256

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