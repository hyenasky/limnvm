local blitter = {}

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

function blitter.new(vm, c)
	local b = {}

	local mmu = c.mmu
	local bus = c.bus

	local writeByte = mmu.TstoreByte
	local readByte = mmu.TfetchByte

	local copy = mmu.copy

	local int = c.cpu.int

	local port0 = 0
	local port1 = 0
	local port2 = 0
	local port3 = 0
	local port4 = 0

	bus.addPort(0x40, function(s, t, v)
		if s ~= 0 then
			return 0
		end

		if t == 1 then
			local from = port1
			local dest = port2
			local dim = port3
			local modulo = port4

			local w = band(dim, 0xFFFF)
			local h = rshift(dim, 16)

			local mf = band(modulo, 0xFFFF)
			local md = rshift(modulo, 16)

			--local t = love.timer.getTime()

			if v == 1 then -- COPY
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, readByte(from))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 2 then -- FILL
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, from)
						dest = dest + 1
					end
					dest = dest + md
				end
			elseif v == 3 then -- OR
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, bor(readByte(dest), readByte(from)))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 4 then -- NOR
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, bnot(bor(readByte(dest), readByte(from))))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 5 then -- XOR
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, bxor(readByte(dest), readByte(from)))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 6 then -- NOT
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, bnot(readByte(from)))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 7 then -- AND
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, band(readByte(dest), readByte(from)))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 8 then -- NAND
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, bnot(band(readByte(dest), readByte(from))))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			elseif v == 9 then -- XNOR
				for r = 0, h-1 do
					for c = 0, w-1 do
						writeByte(dest, bnot(bxor(readByte(dest), readByte(from))))
						from = from + 1
						dest = dest + 1
					end
					from = from + mf
					dest = dest + md
				end
			end

			--print("blitter done in "..tostring(love.timer.getTime() - t).." seconds")

			int(0x40)
		else
			return 0
		end
	end)

	bus.addPort(0x41, function (s, t, v)
		if t == 0 then
			return port1
		else
			port1 = v
		end
	end)

	bus.addPort(0x42, function (s, t, v)
		if t == 0 then
			return port2
		else
			port2 = v
		end
	end)

	bus.addPort(0x43, function (s, t, v)
		if t == 0 then
			return port3
		else
			port3 = v
		end
	end)

	bus.addPort(0x44, function (s, t, v)
		if t == 0 then
			return port4
		else
			port4 = v
		end
	end)

	return b
end

return blitter