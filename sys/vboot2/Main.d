#include "Runtime.d"
#include "lib/List.d"
#include "lib/Tree.d"
#include "DeviceTree.d"
#include "IDisk.d"
#include "vnixfat.d"

asm preamble "

.org 0x100000

.ds ANTE

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

	CIPtr@ BootDevice@ BootPartition@ PartitionTable@ args@ asm "
		call _POP
		mov r4, r0
		call _POP
		mov r3, r0
		call _POP
		mov r2, r0
		call _POP
		mov r1, r0
		call _POP
		b 0x200004
	"
end

procedure Panic (* errorstr -- *)
	"Panic: %s\n" Printf
end