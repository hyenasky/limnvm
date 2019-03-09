const NVRAMBase 0xF8001000
const NVRAMSize 65536

const NVRAMVarCount 255

const NVRAMMagic 0x0C001CA7

struct NVRAMHeader
	4 Magic
endstruct

struct NVRAMVariable
	16 Name
	240 Contents
endstruct

procedure NVRAMCheck (* -- ok? *)
	NVRAMHeader_Magic NVRAMOffset @
	if (NVRAMMagic ==)
		1 return
	end
	0 return
end

procedure NVRAMFormat (* -- *)
	auto i
	0 i!
	while (i@ NVRAMSize <)
		0 i@ NVRAMOffset !
		i@ 4 + i!
	end

	NVRAMMagic NVRAMHeader_Magic NVRAMOffset !
end

procedure NVRAMOffset (* loc -- nvaddr *)
	auto loc
	loc!

	if (loc@ NVRAMSize >=)
		0 return
	end

	loc@ NVRAMBase +
end

procedure NVRAMFindFree (* -- free or 0 *)
	auto i
	0 i!

	auto sp
	NVRAMHeader_SIZEOF sp!
	while (i@ NVRAMVarCount <)
		if (sp@ NVRAMOffset gb 0 ==)
			sp@ NVRAMOffset return
		end

		sp@ NVRAMVariable_SIZEOF + sp!
		i@ 1 + i!
	end

	0 return
end

procedure NVRAMDeleteVar (* name -- *)
	auto vl
	NVRAMGetVar vl!

	if (vl@ 0 ==) return end

	0 vl@ NVRAMVariable_Contents - sb
end

procedure NVRAMSetVar (* str name -- *)
	auto name
	name!

	auto str
	str!

	auto vl
	name@ NVRAMGetVar vl!

	if (vl@ 0 ==) (* doesnt exist, we need to make it *)
		NVRAMFindFree vl!

		if (vl@ 0 ==) (* no free space, abort *)
			return
		end

		vl@ name@ strcpy
		vl@ NVRAMVariable_Contents + str@ strcpy
	end else
		vl@ str@ strcpy
	end
end

procedure NVRAMSetVarNum (* num name -- *)
	auto name
	name!

	auto num
	num!

	auto buf
	15 Calloc buf!

	num@ buf@ itoa
	buf@ name@ NVRAMSetVar

	buf@ Free
end

procedure NVRAMGetVar (* name -- ptr or 0 *)
	auto name
	name!

	auto i
	0 i!

	auto sp
	NVRAMHeader_SIZEOF sp!
	while (i@ NVRAMVarCount <)
		if (sp@ NVRAMOffset name@ strcmp)
			sp@ NVRAMVariable_Contents + NVRAMOffset return
		end

		sp@ NVRAMVariable_SIZEOF + sp!
		i@ 1 + i!
	end

	0 return
end

procedure NVRAMGetVarNum (* var -- n *)
	NVRAMGetVar dup if (0 ~=) atoi return end
end