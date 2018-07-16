local rom = {}

function rom.new(vm, c)
	local r = {}
	
	local mmu = c.mmu

	r.rom = ffi.new("uint8_t[131072]")
	local rom = r.rom

	local function romh(s, t, offset, v)
		if s == 0 then -- byte
			if t == 0 then
				return rom[offset]
			end
		elseif s == 1 then -- int
			if t == 0 then
				local u1, u2 = rom[offset], rom[offset + 1]

				return (u2 * 0x100) + u1
			end
		elseif s == 2 then -- long
			if t == 0 then
				local u1, u2, u3, u4 = rom[offset], rom[offset + 1], rom[offset + 2], rom[offset + 3]

				return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1
			end
		end
	end

	mmu.mapArea(0x7FFF, romh)

	local e = love.filesystem.read("test.rom")
	for i = 1, #e do
		rom[i-1] = string.byte(e:sub(i,i))
	end

	return r
end

return rom