#include "Runtime.d"

(*

Boot sector for disktools
Just load the next 30 sectors from the disk and jump into the base

*)

asm preamble "

.org 0xA0000 ;loaded here by auntie antecedent

.ds ANTE

;r0 contains pointer to client interface
call _PUSH

;r1 contains blockdev number
mov r0, r1
call _PUSH
b Main

;if main returns, itll go back into the ROM

"

const Base 0x100000

procedure Main (* ciptr bootdev -- *)
	auto BootDevice

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"Booting disktools on blockdev" PutString
	BootDevice@ PutInteger
	CR

	"Loading disk" PutString

	auto sector
	2 sector!
	auto ptr
	Base ptr!
	while (sector@ 32 <)
		sector@ ptr@ BootDevice@ ReadBlock
		'.' StdPutChar

		sector@ 1 + sector!
		ptr@ 4096 + ptr!
	end
	CR

	"Verifying integrity\n" PutString

	if (Base@ 0x4F4F5444 ~=)
		"Disktools corrupted!\n" PutString
		return
	end

	CIPtr@ BootDevice@ asm "
		call _POP
		mov r1, r0
		call _POP
		call 0x100004
	"
end



