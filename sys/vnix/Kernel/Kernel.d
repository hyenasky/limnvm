#include "Runtime.d"
#include "ACI.d"
#include "KHeap.d"

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

	"\nvnix - ball rolling\n" ACIPutString

	KHeapInit
end