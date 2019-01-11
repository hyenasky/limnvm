local mmu = {}

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

function mmu.new(vm, c, memsize)
	local m = {}

	local mmu = m

	m.memsize = memsize
	local memsize = m.memsize

	m.physmem = ffi.new("uint8_t[?]", memsize)
	local physmem = m.physmem

	m.areas = ffi.new("uint16_t[32768]")
	m.areah = {}
	local areas = m.areas
	local areah = m.areah

	m.physstart = 0
	local physstart = m.physstart

	m.physend = physstart + memsize
	local physend = m.physend

	m.translating = false

	local lsa = 0

	--areas are 128kb pages of translated address space that
	--call back to a handler when accessed.
	--they're a bit of a bottleneck. there's probably
	--a better way to do this

	--the handlers are called like handler(s, t, offset, v)

	--s = 0: byte
	--s = 1: int
	--s = 2: long

	--t = 0: read, v = nil
	--t = 1: write, v = value

	function m.mapArea(page, handler)
		local n = 0

		for i = 1, 32768 do
			if not areah[i] then
				n = i
				break
			end
		end

		areah[n] = handler

		areas[page] = n
	end
	local mapArea = m.mapArea

	function m.unmapArea(page)
		local e = areas[page]
		areas[page] = 0

		areah[e] = nil
	end
	local unmapArea = m.unmapArea

	--translated address space functions:
	--post-paging translation addresses
	--physmem starts at 0 in the translated address space

	--these are long and repetitive to avoid unnecessary function calls
	--to speed it up a lil bit
	--(although areas kinda butcher performance anyway)

	--LITTLE ENDIAN!!

	function m.TfetchByte(ptr)
		local m = areas[rshift(ptr, 17)]

		if m ~= 0 then -- mapped
			lsa = ptr

			local e = areah[m](0, 0, band(ptr, 0x1FFFF))

			return e
		end

		-- no match. physmem it is

		if (physstart <= ptr) and (physend >= ptr) then
			lsa = ptr

			local e = physmem[ptr - physstart]

			return e
		else
			print(string.format("fb %x lsa %x", ptr, lsa))
			mmu.fault(7) -- this is cpu dependent
		end

		return 0
	end
	local TfetchByte = m.TfetchByte

	function m.TfetchInt(ptr)
		local m = areas[rshift(ptr, 17)]

		if m ~= 0 then -- mapped
			lsa = ptr
			return areah[m](1, 0, band(ptr, 0x1FFFF))
		end

		-- no match. physmem it is

		if (physstart <= ptr) and (physend >= ptr+1) then
			lsa = ptr

			local b = ptr - physstart

			local u1 = physmem[b]
			local u2 = physmem[b+1]

			return (u2 * 0x100) + u1 -- little endian
		else
			print(string.format("fi %x lsa %x", ptr, lsa))
			mmu.fault(7) -- this is cpu dependent
		end

		return 0
	end
	local TfetchInt = m.TfetchInt

	function m.TfetchLong(ptr)
		local m = areas[rshift(ptr, 17)]

		if m ~= 0 then -- mapped
			lsa = ptr
			return areah[m](2, 0, band(ptr, 0x1FFFF))
		end

		-- no match. physmem it is

		if (physstart <= ptr) and (physend >= ptr+3) then
			lsa = ptr
			local b = ptr - physstart

			local u1 = physmem[b]
			local u2 = physmem[b+1]
			local u3 = physmem[b+2]
			local u4 = physmem[b+3]

			return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1 -- little endian
		else
			print(string.format("fl %x lsa %x", ptr, lsa))
			mmu.fault(7) -- this is cpu dependent
		end

		return 0
	end
	local TfetchLong = m.TfetchLong

	--[[
		Store versions of the above.
	]]

	function m.TstoreByte(ptr, v)
		local m = areas[rshift(ptr, 17)]

		if m ~= 0 then -- mapped
			lsa = ptr
			return areah[m](0, 1, band(ptr, 0x1FFFF), v)
		end

		-- no match. physmem it is

		if (physstart <= ptr) and (physend >= ptr) then
			lsa = ptr
			physmem[ptr - physstart] = v
		else
			print(string.format("sb %x lsa %x", ptr, lsa))
			mmu.fault(7) -- this is cpu dependent
		end
	end
	local TstoreByte = m.TstoreByte

	function m.TstoreInt(ptr, v)
		local m = areas[rshift(ptr, 17)]

		if m ~= 0 then -- mapped
			lsa = ptr
			return areah[m](1, 1, band(ptr, 0x1FFFF), v)
		end

		-- no match. physmem it is

		if (physstart <= ptr) and (physend >= ptr+1) then
			lsa = ptr
			local u1, u2 = (math.modf(v/256))%256, v%256
			local b = ptr - physstart

			physmem[b] = u2
			physmem[b+1] = u1 -- little endian
		else
			print(string.format("si %x lsa %x", ptr, lsa))
			mmu.fault(7) -- this is cpu dependent
		end
	end
	local TstoreInt = m.TstoreInt

	function m.TstoreLong(ptr, v)
		local m = areas[rshift(ptr, 17)]

		if m ~= 0 then -- mapped
			lsa = ptr
			return areah[m](2, 1, band(ptr, 0x1FFFF), v)
		end

		-- no match. physmem it is

		if (physstart <= ptr) and (physend >= ptr+3) then
			lsa = ptr
			local u1, u2, u3, u4 = (math.modf(v/16777216))%256, (math.modf(v/65536))%256, (math.modf(v/256))%256, v%256
			local b = ptr - physstart

			physmem[b] = u4
			physmem[b+1] = u3
			physmem[b+2] = u2
			physmem[b+3] = u1 -- little endian
		else
			print(string.format("sl %x lsa %x", ptr, lsa))
			mmu.fault(7) -- this is cpu dependent
		end
	end
	local TstoreLong = m.TstoreLong

	-- mmu registers

	m.registers = ffi.new("uint32_t[32]")
	local registers = m.registers

	--[[

	0: RAM size
	1: base
	2: bounds
	3: page table
	4: faulting address

	]]

	registers[0] = memsize

	mapArea(0x7FF9, function (s, t, offset, v)
		if offset > 128 then
			return 0
		end

		if band(offset, 3) ~= 0 then -- must be aligned to 4 bytes
			return 0
		end

		if s ~= 2 then
			return 0
		end

		if t == 0 then
			return registers[offset/4]
		else
			registers[offset/4] = v
		end
	end)

	--this is where paging translation etc will go

	function m.fetchByte(ptr)
		if not m.translating then return TfetchByte(ptr) end

		local bptr = ptr + registers[1]
		if bptr >= registers[2] then
			registers[4] = bptr
			mmu.fault(7)
		end

		return TfetchByte(bptr)
	end
	local fetchByte = m.fetchByte

	function m.fetchInt(ptr)
		if not m.translating then return TfetchInt(ptr) end

		local bptr = ptr + registers[1]
		if bptr+1 >= registers[2] then
			registers[4] = bptr
			mmu.fault(7)
		end

		return TfetchInt(bptr)
	end
	local fetchInt = m.fetchInt

	function m.fetchLong(ptr)
		if not m.translating then return TfetchLong(ptr) end

		local bptr = ptr + registers[1]
		if bptr+3 >= registers[2] then
			registers[4] = bptr
			mmu.fault(7)
		end

		return TfetchLong(bptr)
	end
	local fetchLong = m.fetchLong


	function m.storeByte(ptr, v)
		if not m.translating then return TstoreByte(ptr, v) end

		local bptr = ptr + registers[1]
		if bptr >= registers[2] then
			registers[4] = bptr
			mmu.fault(7)
		end

		return TstoreByte(bptr, v)
	end
	local storeByte = m.storeByte

	function m.storeInt(ptr, v)
		if not m.translating then return TstoreInt(ptr, v) end

		local bptr = ptr + registers[1]
		if bptr+1 >= registers[2] then
			registers[4] = bptr
			mmu.fault(7)
		end

		return TstoreInt(bptr, v)
	end
	local storeInt = m.storeInt

	function m.storeLong(ptr, v)
		if not m.translating then return TstoreLong(ptr, v) end

		local bptr = ptr + registers[1]
		if bptr+3 >= registers[2] then
			registers[4] = bptr
			mmu.fault(7)
		end

		return TstoreLong(bptr, v)
	end
	local storeLong = m.storeLong

	function m.translate(addr)
		if not m.translating then return addr end

		local bptr = addr + registers[1]
		if bptr >= registers[2] then
			return false
		end

		return bptr
	end

	return m
end

return mmu