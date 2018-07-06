local mmu = {}

function mmu.new(vm, c, memsize)
	local m = {}

	m.memsize = memsize
	local memsize = m.memsize

	m.physmem = ffi.new("uint8_t[?]", memsize)
	local physmem = m.physmem

	m.areas = {}
	m.areas.n = 0
	local areas = m.areas

	--areas are sections of translated address space that
	--call back to a handler when accessed.
	--they're a bit of a bottleneck. there's probably
	--a better way to do this

	--the handlers are called like handler(t, offset, v)
	--t = 0: read, v = nil
	--t = 1: write, v = value

	function m.newArea(startAddr, endAddr,
		byteHandler,
		intHandler,
		longHandler
	)
		areas[areas.n + 1] = {
			startAddr,
			endAddr,

			byteHandler,
			intHandler,
			longHandler
		}
		areas.n = areas.n + 1

		return areas[areas.n] -- return reference to the area so it can be modified
	end
	local newArea = m.newArea

	--translated address space functions:
	--post-paging translation addresses
	--physmem starts at 0 in the translated address space

	--these are long and repetitive to avoid unnecessary function calls
	--to speed it up a lil bit
	--(although areas kinda butcher performance anyway)

	--LITTLE ENDIAN!!

	function m.TfetchByte(ptr)
		local narea = areas.n
		if narea > 0 then -- rip, we gotta search the areas table
			for i = 1, narea do
				local a = areas[i]

				local sa = a[1]

				if sa ~= -1 then -- a -1 sa means the area is disabled
					if (sa <= ptr) and (a[2] >= ptr) then -- match
						return a[3](0, ptr - sa) -- byte handler
					end
				end
			end
		end

		-- no match. physmem it is

		if ptr < memsize then
			return physmem[ptr]
		end
	end
	local TfetchByte = m.TfetchByte

	function m.TfetchInt(ptr)
		local narea = areas.n
		if narea > 0 then -- rip, we gotta search the areas table
			for i = 1, narea do
				local a = areas[i]

				local sa = a[1]

				if sa ~= -1 then -- a -1 sa means the area is disabled
					if (sa <= ptr) and (a[2] >= ptr) then -- match
						return a[4](0, ptr - sa) -- int handler
					end
				end
			end
		end

		-- no match. physmem it is

		if ptr+1 < memsize then
			local u1 = physmem[ptr]
			local u2 = physmem[ptr+1]

			return (u2 * 0x100) + u1 -- little endian
		end
	end
	local TfetchInt = m.TfetchInt

	function m.TfetchLong(ptr)
		local narea = areas.n
		if narea > 0 then -- rip, we gotta search the areas table
			for i = 1, narea do
				local a = areas[i]

				local sa = a[1]

				if sa ~= -1 then -- a -1 sa means the area is disabled
					if (sa <= ptr) and (a[2] >= ptr) then -- match
						return a[5](0, ptr - sa) -- long handler
					end
				end
			end
		end

		-- no match. physmem it is

		if ptr+3 < memsize then
			local u1 = physmem[ptr]
			local u2 = physmem[ptr+1]
			local u3 = physmem[ptr+2]
			local u4 = physmem[ptr+3]

			return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1 -- little endian
		end
	end
	local TfetchLong = m.TfetchLong

	--[[
		Store versions of the above.
	]]

	function m.TstoreByte(ptr, v)
		if v < 0 then
			v = bor(math.abs(v), 128)
		end

		local narea = areas.n
		if narea > 0 then -- rip, we gotta search the areas table
			for i = 1, narea do
				local a = areas[i]

				local sa = a[1]

				if sa ~= -1 then -- a -1 sa means the area is disabled
					if (sa <= ptr) and (a[2] >= ptr) then -- match
						return a[3](1, ptr - sa, v) -- byte handler
					end
				end
			end
		end

		-- no match. physmem it is

		if ptr < memsize then
			physmem[ptr] = v
		end
	end
	local TstoreByte = m.TstoreByte

	function m.TstoreInt(ptr, v)
		local narea = areas.n
		if narea > 0 then -- rip, we gotta search the areas table
			for i = 1, narea do
				local a = areas[i]

				local sa = a[1]

				if sa ~= -1 then -- a -1 sa means the area is disabled
					if (sa <= ptr) and (a[2] >= ptr) then -- match
						return a[4](1, ptr - sa, v) -- int handler
					end
				end
			end
		end

		-- no match. physmem it is

		if ptr+1 < memsize then
			local u1, u2 = (math.modf(v/256))%256, v%256

			physmem[ptr] = u2
			physmem[ptr+1] = u1 -- little endian
		end
	end
	local TstoreInt = m.TstoreInt

	function m.TstoreLong(ptr, v)
		local narea = areas.n
		if narea > 0 then -- rip, we gotta search the areas table
			for i = 1, narea do
				local a = areas[i]

				local sa = a[1]

				if sa ~= -1 then -- a -1 sa means the area is disabled
					if (sa <= ptr) and (a[2] >= ptr) then -- match
						return a[5](1, ptr - sa, v) -- long handler
					end
				end
			end
		end

		-- no match. physmem it is

		if ptr+3 < memsize then
			local u1, u2, u3, u4 = (math.modf(v/16777216))%256, (math.modf(v/65536))%256, (math.modf(v/256))%256, v%256

			physmem[ptr] = u4
			physmem[ptr+1] = u3
			physmem[ptr+2] = u2
			physmem[ptr+3] = u1 -- little endian
		end
	end
	local TstoreLong = m.TstoreLong

	--this is where paging translation etc will go
	--for now, just 1:1 it

	m.fetchByte = TfetchByte
	local fetchByte = m.fetchByte

	m.fetchInt = TfetchInt
	local fetchInt = m.fetchInt

	m.fetchLong = TfetchLong
	local fetchLong = m.fetchLong

	m.storeByte = TstoreByte
	local storeByte = m.storeByte

	m.storeInt = TstoreInt
	local storeInt = m.storeInt

	m.storeLong = TstoreLong
	local storeLong = m.storeLong

	-- reset vector, 0x5
	storeLong(0, 5)

	-- li r0, 'H'
	physmem[5] = 0x01
	physmem[6] = 0x00
	physmem[7] = 0x48
	physmem[8] = 0x00
	physmem[9] = 0x00
	physmem[10] = 0x00

	-- dbgprint
	physmem[11] = 0xF1

	-- li r0, 'i'
	physmem[12] = 0x01
	physmem[13] = 0x00
	physmem[14] = 0x69
	physmem[15] = 0x00
	physmem[16] = 0x00
	physmem[17] = 0x00

	-- dbgprint
	physmem[18] = 0xF1

	-- li r0, '!'
	physmem[19] = 0x01
	physmem[20] = 0x00
	physmem[21] = 0x21
	physmem[22] = 0x00
	physmem[23] = 0x00
	physmem[24] = 0x00

	-- dbgprint
	physmem[25] = 0xF1

	-- b 5
	physmem[26] = 0x1B
	physmem[27] = 0x05
	physmem[28] = 0x00
	physmem[29] = 0x00
	physmem[30] = 0x00

	return m
end

return mmu