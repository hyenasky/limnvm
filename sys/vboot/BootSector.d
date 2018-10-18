#include "Runtime.d"

(*

Stage Zero bootloader.
Finds a bootable partition, loads sectors 0-7 from it, and jumps into it.

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

struct VDB
	16 Label
	128 PartitionTable
	4 Magic
endstruct

struct PTE
	8 Label
	4 Blocks
	1 Status
	3 Unused
endstruct

const VDBCache 0x100000

const PartitionBootable 0x1

procedure Error (* string -- *)
	"Panic: " PutString PutString
end

procedure Main (* ciptr bootdev -- *)
	auto BootDevice

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"\n\n==== Bootloader ====\n" PutString
	"boot0 on blk" PutString
	BootDevice@ PutInteger
	CR

	"Loading volume descriptor block\n" PutString
	0 VDBCache BootDevice@ ReadBlock

	"Disk Info:\n" PutString
	"\tMagic: " PutString VDBCache VDB_Magic + dup PutString CR

	if (@ 0x4E4D494C ~=) (* check for signature *)
		"Invalid volume descriptor.\n" Error
		return
	end

	"\tDisk Label: " PutString VDBCache VDB_Label + PutString

	"\nBootable partitions:\n" PutString

	auto i
	0 i!
	auto ptr
	VDBCache VDB_PartitionTable + ptr!
	while (i@ 8 <)
		if (ptr@ PTE_Status + gb PartitionBootable ==)
			'\t' StdPutChar i@ PutIntegerD ": " PutString
			ptr@ PutString
			CR
		end

		ptr@ PTE_SIZEOF + ptr!
		i@ 1 + i!
	end

	while (1) end
end



