#include "Runtime.d"

asm preamble "

.org 0x100000

.ds DTOO

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH
b Main

"

var BootDevice 0

#include "CommandLine.d"

procedure Main (* ciptr bootdev -- *)
	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"==== Disktools ====\n" PutString

	CommandLine
end

procedure FatalError (* errorstr -- *)
	"\nFatal Error: " PutString
	PutString

	while (1) end
end