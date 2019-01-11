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
endtable

procedure AutoBoot (* -- ok? *)
	auto bootnode

	"boot-dev" NVRAMGetVar dup if (0 ==)
		drop "/ahdb/0/a" "boot-dev" NVRAMSetVar
		"/ahdb/0/a"
	end

	DevTreeWalk bootnode!

	if (bootnode@ 0 ==)
		2 return
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

	auto brecord
	4096 Calloc brecord!

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

	brecord@ BootRecord_OSLabel + " OS: %s\n" Printf

	auto bblock
	auto bbc
	brecord@ BootRecord_BootBlockStart + @ bblock!
	brecord@ BootRecord_BootBlockCount + @ bbc!

	brecord@ Free

	auto ptr
	BootBottom ptr!

	devnode@ DeviceSelectNode
		auto i
		0 i!

		while (i@ bbc@ <)
			ptr@ bblock@ "readBlock" DCallMethod drop ok!

			if (ok@ ERR ==)
				5 return (* failed to load boot blocks *)
			end

			i@ 1 + i!
			ptr@ 4096 + ptr!
		end
	DeviceExit

	if (BootBottom@ BootMagic ~=)
		6 return
	end

	API devnode@ args@ BootBottom 4 + @ asm "

	pusha

	call _POP
	mov r10, r0

	call _POP
	mov r2, r0

	call _POP
	mov r1, r0

	call _POP

	call .layer
	b .out

	.layer:
	br r10

	.out:

	popa

	"

	1 (* ok *)
end