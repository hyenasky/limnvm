#include "Runtime.d"
#include "lib/List.d"
#include "lib/Tree.d"
#include "Console.d"
#include "DeviceTree.d"
#include "IDisk.d"
#include "vnixfat.d"

asm preamble "

.org 0x100000

.ds ANTE
.dl Entry

Entry:

;r0 contains pointer to API
pushv r5, r0

;r1 contains devnode
pushv r5, r1

;r2 contains args
pushv r5, r2

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

	BootDevice@ "Boot1 on %x\n" Printf

	if (args@ 0 ~=)
		args@ "kernel args: %s\n" Printf
	end

	APIDevTree DeviceInit

	BootDevice@ IDiskInit
	VFSInit

	"Loading kernel image\n" Printf

	"vnix" 0x200000 VFSLoadFile
	if (0 ==)
		"Failed to load kernel image" Panic
		return
	end

	if (0x200000@ 0x58494E56 ~=)
		"Invalid kernel image" Panic
		return
	end

	CIPtr@ BootDevice@ args@ asm "
		pushv r5, r2
		pushv r5, r1
		pushv r5, r0
		b 0x200004
	"
end

procedure Panic (* errorstr -- *)
	"Panic: %s\n" Printf
end