var Running 0

var SelectedBlockDev 0

buffer PromptLine 128

buffer CommandTable 512

const VDBCache 0x120000

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
c<dev> - change to dev
s - save changes
i - print disk info
f<name> - format (will overwrite VDB, partition table wiped out)
p<number of partitions 1-8> - partition\n" PutString
end

procedure CmdPartition (* cstr -- *)
	auto np
	StringToInteger np!

	if (np@ 8 >)
		"cannot have more than 8 partitions\n" PutString
		return
	end
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

procedure CmdInfo (* cstr -- *)
	drop

	"Disk Info:\n" PutString
	"\tMagic: " PutString VDBCache VDB_Magic + dup PutString CR

	if (@ 0x4E4D494C ~=) (* check for signature *)
		"Invalid volume descriptor. Run 'f' to format.\n" PutString
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
		end

		ptr@ PTE_SIZEOF + ptr!
		i@ 1 + i!
	end
end







