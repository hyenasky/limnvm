#include "API.d"

struct BootRecord
	4 Magic
	1 ret
	16 OSLabel
	4 BootBlockStart
	4 BootBlockCount
endstruct

const BootMagic 0x45544E41
const BootRM 0x24

const BootBottom 0x100000

table BootErrors
	0
	"ok"
	"not supported by device"
	"failed to load boot record"
	"invalid boot record"
	"aborted while loading boot blocks"
	"bad boot blocks"
	"no such device"
endtable

procedure DevBootable (* dnode -- bootable? *)
	DevBootableR swap drop
end

procedure DevBootableR (* dnode -- brecord bootable? *)
	auto devnode
	devnode!

	if (devnode@ 0 ==)
		7 return
	end

	auto brecord
	4096 Calloc brecord!

	"loading boot record\n" Printf

	devnode@ DeviceSelectNode
		auto ok
		brecord@ 1 "readBlock" DCallMethod
	DeviceExit

	ok!
	if (ok@ ~~)
		brecord@ Free
		2 return (* not supported *)
	end

	ok!
	if (ok@ ERR ==)
		brecord@ Free
		3 return (* failed to load boot record *)
	end

	if (brecord@ BootRecord_Magic + @ BootMagic == brecord@ BootRecord_ret + gb BootRM == && ~~)
		brecord@ Free
		4 return (* invalid boot record *)
	end

	brecord@ 1 return
end

procedure AutoBoot (* -- ok? *)
	"autoboot: /bootdisk\n\n" Printf

	auto bootnode

	"/bootdisk" DevTreeWalk bootnode!

	if (bootnode@ 0 ==)
		7 return
	end

	bootnode@

	"boot-args" NVRAMGetVar dup if (0 ==)
		drop "" "boot-args" NVRAMSetVar
		""
	end

	BootNode
end

procedure BootNode (* devnode args -- ok? *)
	auto args
	args!

	auto devnode
	devnode!

	args@ devnode@ "bootnode:\n\tnode: %x\n\targs: %s\n\n" Printf

	auto brecord
	auto ok

	devnode@ DevBootableR ok!

	if (ok@ 1 ~=)
		ok@ return
	end

	brecord!

	auto bblock
	auto bbc
	brecord@ BootRecord_BootBlockStart + @ bblock!
	brecord@ BootRecord_BootBlockCount + @ bbc!

	brecord@ BootRecord_OSLabel + bblock@ bbc@ "boot record info:\n\tboot blocks: %d\n\tstarting at: block %d\n\tOS label: %s\n\n" Printf

	brecord@ Free

	auto ptr
	BootBottom ptr!

	ptr@ bbc@ "loading %d boot blocks at 0x%x" Printf

	devnode@ DeviceSelectNode
		auto i
		0 i!

		while (i@ bbc@ <)
			ptr@ bblock@ "readBlock" DCallMethod drop ok!

			if (ok@ ERR ==)
				'\n' Putc
				5 return (* failed to load boot blocks *)
			end

			'.' Putc

			bblock@ 1 + bblock!
			i@ 1 + i!
			ptr@ 4096 + ptr!
		end

		'\n' Putc
	DeviceExit

	if (BootBottom@ BootMagic ~=)
		6 return
	end

	BootBottom 4 + @ args@ devnode@ API "passing control to boot blocks\nwith:\tAPI: %x\n\tnode: %x\n\targs: %s\n\tentrypoint: 0x%x\n\n" Printf

	API devnode@ args@ BootBottom 4 + @ asm "

	popv r5, r3

	popv r5, r2

	popv r5, r1

	popv r5, r0

	pusha

	call .layer
	b .out

	.layer:
	br r3

	.out:

	popa

	"

	1 (* ok *)
end