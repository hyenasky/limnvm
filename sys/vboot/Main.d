#include "Runtime.d"
#include "IDisk.d"
#include "afs.d"

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

b Main

"

procedure Main (* ciptr bootdev bootpartition partitiontable -- *)
	auto BootDevice
	auto BootPartition
	auto PartitionTable

	PartitionTable!

	BootPartition!

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"\nboot1 on " PutString
	BootDevice@ PutInteger
	':' StdPutChar BootPartition@ PutInteger CR

	BootDevice@ BootPartition@ PartitionTable@ IDiskInit
	AFSInit

	"this is where we'll mount the filesystem and load the kernel or whatever\n" Panic
end

procedure Panic (* errorstr -- *)
	"Panic: " PutString
	PutString
end