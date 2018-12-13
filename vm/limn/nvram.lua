local nvram = {}

function nvram.new(vm, c)
	local nr = {}

	local log = vm.log.log

	local mmu = c.mmu

	nr.mem = ffi.new("uint8_t[4096]")
	local mem = nr.mem

	local sm = ffi.new("uint8_t[4096]")

	mmu.mapArea(0x7900, function (s, t, offset, v)
		if offset > 4095 then
			return 0
		end

		if t == 0 then
			if s == 0 then
				return mem[offset]
			elseif s == 1 then
				local u1, u2 = mem[offset], mem[offset + 1]

				return (u2 * 0x100) + u1
			elseif s == 2 then
				local u1, u2, u3, u4 = mem[offset], mem[offset + 1], mem[offset + 2], mem[offset + 3]

				return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1
			end
		elseif t == 1 then
			if s == 0 then
				mem[offset] = v

				sm[offset] = v
			elseif s == 1 then
				local u1, u2 = (math.modf(v/256))%256, v%256

				mem[offset] = u2
				mem[offset+1] = u1 -- little endian

				sm[offset] = u2
				sm[offset+1] = u1 -- little endian
			elseif s == 2 then
				local u1, u2, u3, u4 = (math.modf(v/16777216))%256, (math.modf(v/65536))%256, (math.modf(v/256))%256, v%256

				mem[offset] = u4
				mem[offset+1] = u3
				mem[offset+2] = u2
				mem[offset+3] = u1 -- little endian

				sm[offset] = u4
				sm[offset+1] = u3
				sm[offset+2] = u2
				sm[offset+3] = u1 -- little endian
			end
		end
	end)

	nr.nvramfile = false

	vm.registerOpt("-nvram,autorun", function (arg, i)
		local ar = arg[i + 1]

		for i = 1, #ar do
			local c = ar:sub(i,i)
			mem[3+i] = string.byte(c)
		end

		mem[4+#ar] = 0

		return 2
	end)

	vm.registerOpt("-nvram,stdin", function (arg, i)
		local ar = arg[i + 1]

		mem[132] = tonumber(ar)

		return 2
	end)

	vm.registerOpt("-nvram,stdout", function (arg, i)
		local ar = arg[i + 1]

		mem[133] = tonumber(ar)

		return 2
	end)

	vm.registerOpt("-nvram,")

	vm.registerOpt("-nvram", function (arg, i)
		nr.nvramfile = arg[i + 1]

		local h = io.open(nr.nvramfile, "rb")
		local c = h:read("*a")

		for i = 1, #c do
			local ch = c:sub(i,i)
			mem[i-1] = string.byte(ch)
			sm[i-1] = string.byte(ch)
		end

		return 2
	end)

	vm.registerCallback("quit", function ()
		if not nr.nvramfile then return end

		log("saving nvram")

		local h = io.open(nr.nvramfile, "wb")
		for i = 0, 4095 do
			h:write(string.char(sm[i]))
		end
	end)

	return nr
end

return nvram