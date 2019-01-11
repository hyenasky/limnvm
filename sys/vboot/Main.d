#include "Runtime.d"
#include "IDisk.d"
#include "vnixfat.d"

asm preamble "

.org 0x100000

.dl 0x0C001CA7

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

;r4 contains args
mov r0, r4
call _PUSH

b Main

"

procedure Main (* ciptr bootdev bootpartition partitiontable args -- *)
	auto args
	auto BootDevice
	auto BootPartition
	auto PartitionTable

	args!

	PartitionTable!

	BootPartition!

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"Boot1 on " PutString
	BootDevice@ PutInteger
	':' StdPutChar BootPartition@ PutInteger CR

	if (args@ 0 ~=)
		"kernel args: " PutString args@ PutString CR
	end

	BootDevice@ BootPartition@ PartitionTable@ IDiskInit
	VFSInit

	"Loading kernel image\n" PutString

	"vnix" 0x200000 VFSLoadFile
	if (0 ==)
		"Failed to load kernel image\n" Panic
		return
	end

	if (0x200000@ 0x58494E56 ~=)
		"Invalid kernel image\n" Panic
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
	"Panic: " PutString
	PutString
end