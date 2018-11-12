var Running 0

var SelectedBlockDev 0

buffer PromptLine 128

buffer CommandTable 512

buffer PartitionTable 32

const VDBCache 0x120000

const MiscCache 0x130000

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

procedure BuildPT (* -- *)
	auto i
	0 i!

	auto ptr
	VDBCache VDB_PartitionTable + ptr!

	auto ps
	0 ps!
	while (i@ 8 <)
		if (ptr@ PTE_Status + gb 0 ~=)
			if (i@ 0 ==)
				ps@ 2 + ps!
			end

			ps@ i@ 4 * PartitionTable + !
			ptr@ PTE_Blocks + @ ps@ + ps!
		end else
			0xFFFFFFFF i@ 4 * PartitionTable + !
		end

		ptr@ PTE_SIZEOF + ptr!
		i@ 1 + i!
	end
end

procedure SaveVDB (* -- *)
	"Writing VDB...\n" PutString
	0 VDBCache SelectedBlockDev@ WriteBlock
end

procedure SelectDev (* dev -- *)
	auto ndb
	ndb!

	SaveVDB
	"Reading new VDB...\n" PutString
	0 VDBCache ndb@ ReadBlock

	ndb@ SelectedBlockDev!

	BuildPT
end

procedure CommandLine (* -- *)
	CLInit

	"Type h for a list of commands.\n" PutString

	1 Running!

	while (Running@)
		CLPrompt
	end
end

procedure CLNotACommand (* cstr -- *)
	drop
	"Not a valid command.\n" PutString
end

procedure CLRegisterCommand (* handler char -- *)
	4 * CommandTable + !
end

procedure CLInit (* -- *)
	BootDevice@ SelectedBlockDev!
	0 VDBCache BootDevice@ ReadBlock

	BuildPT

	auto i
	0 i!
	while (i@ 128 <)
		pointerof CLNotACommand i@ CLRegisterCommand
		i@ 1 + i!
	end

	pointerof CmdHelpText 'h' CLRegisterCommand
	pointerof CmdQuit 'q' CLRegisterCommand
	pointerof CmdChangeDev 'c' CLRegisterCommand
	pointerof CmdSave 's' CLRegisterCommand
	pointerof CmdInfo 'i' CLRegisterCommand
	pointerof CmdFormat 'f' CLRegisterCommand
	pointerof CmdPartition 'p' CLRegisterCommand
end

procedure CLPrompt (* -- *)
	PromptLine StringZero

	SelectedBlockDev@ PutIntegerD "> " PutString
	PromptLine 127 GetString

	PromptLine gb dup
	if (0 ==)
		return
	end
	4 * CommandTable + @ PromptLine 1 + swap Call
end

procedure CmdHelpText (* cstr -- *)
	drop
"h - help
q - quit
s - save changes
i - print disk info
p - partition
f<name> - format (will overwrite VDB, partition table wiped out)
c<dev> - change to dev\n" PutString
end

procedure CmdPartition (* cstr -- *)
	drop

	auto pbase

	auto i
	0 i!
	while (i@ 8 <)
		VDBCache VDB_PartitionTable + PTE_SIZEOF i@ * + pbase!

		pbase@ PutIntegerD CR

		"partition " PutString i@ PutIntegerD ": \n" PutString
		"\tstatus (0 unused, 1 boot, 2 used): " PutString
		PromptLine StringZero
		PromptLine 1 GetString
		PromptLine StringToInteger dup pbase@ PTE_Status + sb

		if (0 ~=)
			"\tlabel: " PutString
			PromptLine StringZero
			PromptLine 7 GetString
			pbase@ PTE_Label + PromptLine StringCopy

			"\tblocks: " PutString
			PromptLine StringZero
			PromptLine 10 GetString
			PromptLine StringToInteger pbase@ PTE_Blocks + !
		end

		i@ 1 + i!
	end

	BuildPT
end

procedure CmdFormat (* cstr -- *)
	auto ptr
	VDBCache ptr!
	auto max
	VDBCache 4096 + max!
	while (ptr@ max@ <)
		0 ptr@ !
		ptr@ 4 + ptr!
	end

	VDBCache swap StringCopy

	0x4E4D494C VDBCache VDB_Magic + !
end

procedure CmdQuit (* cstr -- *)
	drop
	"Bye!\n" PutString
	0 Running!
end

procedure CmdChangeDev (* cstr -- *)
	StringToInteger dup
	"Switching to blk" PutString PutIntegerD CR
	SelectDev
end

procedure CmdSave (* cstr -- *)
	drop
	SaveVDB
end

procedure BReadBlock (* block buffer partition -- *)
	auto p
	p!

	auto buf
	buf!

	auto block
	block!

	p@ 4 * PartitionTable + @ block@ + buf@ SelectedBlockDev@ ReadBlock
end

procedure BWriteBlock (* block buffer partition -- *)
	auto p
	p!

	auto buf
	buf!

	auto block
	block!

	p@ 4 * PartitionTable + @ block@ + buf@ SelectedBlockDev@ WriteBlock
end

procedure CmdInfo (* cstr -- *)
	drop

	"Disk Info:\n" PutString
	"\tMagic: " PutString VDBCache VDB_Magic + dup PutString CR

	if (@ 0x4E4D494C ~=) (* check for signature *)
		"Invalid volume descriptor. Type 'f<name>' to format.\n" PutString
		return
	end

	"\tDisk Label: " PutString VDBCache VDB_Label + PutString

	"\nPartitions:\n" PutString

	auto i
	0 i!
	auto ptr
	VDBCache VDB_PartitionTable + ptr!
	while (i@ 8 <)
		if (ptr@ PTE_Status + gb 0 ~=)
			'\t' StdPutChar i@ PutIntegerD ": " PutString
			ptr@ PutString
			CR
			"\t\tStatus: " PutString ptr@ PTE_Status + gb PutIntegerD CR
			"\t\tSize: " PutString ptr@ PTE_Blocks + @ PutIntegerD " blocks\n" PutString
		end

		ptr@ PTE_SIZEOF + ptr!
		i@ 1 + i!
	end
end







