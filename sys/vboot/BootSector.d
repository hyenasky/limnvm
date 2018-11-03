#include "TinyRuntime.d"

(*

Stage Zero bootloader.
Finds a bootable partition, loads sectors 1-15 from it, and jumps into it.

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

buffer PromptLine 6

buffer PartitionStart 32

procedure Error (* string -- *)
	"Panic: " PutString PutString
end

procedure Prompt (* -- *)
	"@" PutString
	PromptLine dup StringZero 5 GetString
end

procedure Main (* ciptr bootdev -- *)
	auto BootDevice

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"\n\n==== Bootloader ====\n" PutString

	"\nbootdev? default:" PutString
	BootDevice@ PutInteger
	CR

	Prompt

	if (PromptLine gb 0 ~=)
		PromptLine StringToInteger BootDevice!
	end

	"boot0 on blk" PutString
	BootDevice@ PutInteger
	CR

	"Loading volume descriptor block\n" PutString
	0 VDBCache BootDevice@ ReadBlock

	"Disk Info:\n" PutString

	if (VDBCache VDB_Magic + @ 0x4E4D494C ~=) (* check for signature *)
		"Invalid volume descriptor.\n" Error
		return
	end

	"\tDisk Label: " PutString VDBCache VDB_Label + PutString

	"\nBootable partitions:\n" PutString

	auto i
	0 i!

	auto ptr
	VDBCache VDB_PartitionTable + ptr!

	auto ps
	0 ps!

	auto bootp
	0 bootp!

	auto bpcount
	0 bpcount!
	while (i@ 8 <)
		if (ptr@ PTE_Status + gb PartitionBootable ==)
			'\t' StdPutChar i@ PutIntegerD ": " PutString
			ptr@ PutString
			CR

			if (i@ 0 ==)
				ps@ 2 + ps!
			end

			ps@ i@ 4 * PartitionStart + !
			ptr@ PTE_Blocks + @ ps@ + ps!

			i@ bootp!
			bpcount@ 1 + bpcount!
		end else
			0xFFFFFFFF i@ 4 * PartitionStart + !
		end

		ptr@ PTE_SIZEOF + ptr!
		i@ 1 + i!
	end

	if (bpcount@ 0 ==)
		"No bootable partitions.\n" Error
		return
	end

	if (bpcount@ 1 >)
		"boot partition? default:" PutString
		bootp@ PutInteger CR
		Prompt

		if (PromptLine gb 0 ~=)
			PromptLine StringToInteger bootp!
		end
	end

	BootDevice@ PutInteger ':' StdPutChar bootp@ PutIntegerD CR

	(* now load block 1-15 of selected partition at 0x100000, this contains boot1 *)

	bootp@ 4 * PartitionStart + @ ps!

	if (ps@ 0xFFFFFFFF ==)
		"Bad partition\n" Error
		return
	end

	0x100000 ptr!

	1 i!
	while (i@ 16 <)
		ps@ i@ + ptr@ BootDevice@ ReadBlock

		ptr@ 4096 + ptr!
		i@ 1 + i!
	end

	if (0x100000@ 0x0C001CA7 ~=)
		"invalid boot1\n" Error
		return
	end

	CIPtr@ BootDevice@ bootp@ PartitionStart asm "
		call _POP
		mov r3, r0
		call _POP
		mov r2, r0
		call _POP
		mov r1, r0
		call _POP
		call 0x100004
	"
end



