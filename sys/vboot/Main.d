#include "Runtime.d"

asm preamble "

.org 0x100000

.ds VBOO

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH
b Main

"

procedure Main (* ciptr bootdev -- *)
	auto BootDevice

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"boot1 on blk" PutString
	BootDevice@ PutInteger
	'\n' StdPutChar

	"Ooh-ooh... we're halfway there! Ooh-ooh... squidward on a chair!\n" FatalError
end

procedure FatalError (* errorstr -- *)
	"\nFatal Error: " PutString
	PutString

	while (1) end
end