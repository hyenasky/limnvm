(* extremely simple, read-only implementation of vnixfat, only reads root directory *)

const VFSSuperblockNumber 0x0
const VFSSuperblockCache 0x110000
const VFSFATCache 0x120000
const VFSRootCache 0x130000
const VFSSuperblockMagic 0xAFBBAFBB
const VFSSuperblockVersion 0x4

struct VFSSuperblock
	1 Version
	4 Magic
	4 VolSize
	4 NumFiles
	1 Dirty
	4 BlocksUsed
	4 NumDirs
	4 NumReservedBlocks
	4 FATStart
	4 FATSize
	4 Root
	4 DataStart
endstruct

struct VFSDirEnt
	1 type
	1 permissions
	4 uid
	4 reserved
	4 timestamp
	4 startblock
	4 size
	4 bytesize
	37 name
	1 nullterm
endstruct

procedure VFSInit (* -- *)
	"VnF: Mounting filesystem\n" PutString

	VFSSuperblockNumber VFSSuperblockCache IReadBlock

	VFSSuperblockCache VFSSuperblock_Magic + @
	if (VFSSuperblockMagic ~=)
		"VnF: Invalid superblock\n" Panic
		while (1) end
	end

	VFSSuperblockCache VFSSuperblock_Version + gb
	if (VFSSuperblockVersion ~=)
		"VnF: Bad version on superblock\n" Panic
		while (1) end
	end

	VFSSuperblockCache VFSSuperblock_Root + @ VFSRootCache IReadBlock
end

procedure VFSLoadFile (* name destptr -- *)
	auto destptr
	destptr!

	VFSFileByName
	if (dup 0 ==)
		return
	end

	auto entryptr
	entryptr!

	auto cblock
	auto size

	entryptr@ VFSDirEnt_startblock + @ cblock!
	entryptr@ VFSDirEnt_size + @ size!

	auto i
	0 i!
	while (i@ size@ <)
		cblock@ destptr@ IReadBlock

		cblock@ VFSBlockStatus cblock!

		destptr@ 4096 + destptr!
		i@ 1 + i!
	end

	1
end

procedure VFSFileByName (* name -- entrypointer *)
	auto name
	name!

	auto i
	0 i!
	while (i@ 64 <)
		if (i@ 64 * VFSRootCache + VFSDirEnt_name + name@ StringCompare)
			i@ 64 * VFSRootCache + return
		end

		i@ 1 + i!
	end

	0
end

var VFSFatCached 0xFFFFFFFF
procedure VFSReadFATBlock (* fatblock -- *)
	auto fatblock
	fatblock!

	if (fatblock@ VFSFatCached@ ~=) (* only read in new block if not already in cache *)
		fatblock@ VFSSuperblockCache VFSSuperblock_FATStart + @ +
		VFSFATCache IReadBlock
		fatblock@ VFSFatCached!
	end
end

procedure VFSBlockStatus (* blocknum -- status *)
	auto bnum
	bnum!

	auto fatblock
	auto fatoff

	bnum@ 4096 / fatblock!
	bnum@ 4096 % fatoff!

	fatblock@ VFSReadFATBlock
	fatoff@ 4 * VFSFATCache + @
end