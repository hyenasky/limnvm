(* extremely simple, read-only implementation of AFS3, only reads root directory *)

const AFSSuperblockNumber 0x0
const AFSSuperblockCache 0x110000
const AFSSuperblockMagic 0xAF5AF5AF

struct AFSSuperblock
	4 Magic
	4 Blocks
	4 ReservedBlocks
	4 NumFiles
	4 NumDirs
	4 NumInodes
	4 UsedInodes
	4 StartBlockBitmap
	4 SizeBlockBitmap
	4 StartInodeBitmap
	4 SizeInodeBitmap
	4 StartInodeBlocks
	4 SizeInodeBlocks
	4 StartData
	1 Dirty
	32 VolName
endstruct

procedure AFSInit (* -- *)
	"AFS: Mounting filesystem\n" PutString

	AFSSuperblockNumber AFSSuperblockCache IReadBlock

	AFSSuperblockCache AFSSuperblock_Magic + @
	if (AFSSuperblockMagic ~=)
		"AFS: Invalid superblock\n" Panic
		while (1) end
	end
end