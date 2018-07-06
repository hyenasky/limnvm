local cpu = {}

function cpu.new(vm, c)
	local p = {}

	p.reg = ffi.new("uint32_t[37]")
	local reg = p.reg

	p.intq = {}
	local intq = p.intq

	local running = true

	local mmu = c.mmu
	local fetchByte = mmu.fetchByte
	local fetchInt = mmu.fetchInt
	local fetchLong = mmu.fetchLong

	local storeByte = mmu.storeByte
	local storeInt = mmu.storeInt
	local storeLong = mmu.storeLong

	function p.int(num) -- raise interrupt
		local siq = #intq

		if siq < 256 then
			intq[siq+1] = num
		end
	end
	local int = p.int

	function p.getFlag(n)
		return getBit(reg[31], n)
	end
	local getFlag = p.getFlag

	function p.setFlag(n, v)
		reg[31] = setBit(reg[31], n, v)
	end
	local setFlag = p.setFlag

	function p.getState(n)
		return getBit(reg[34], n)
	end
	local getState = p.getState

	function p.setState(n, v)
		reg[34] = setBit(reg[34], n, v)
	end
	local setState = p.setState

	function p.kernelMode()
		return getBit(reg[34], 0) == 0
	end
	local kernelMode = p.kernelMode

	function p.userMode()
		return getBit(reg[34], 0) == 1
	end
	local userMode = p.userMode

	function p.psReg(n, v) -- privileged register save
		if n < 32 then -- user
			reg[n] = v
		else -- kernel
			if kernelMode() then -- in kernel mode
				reg[n] = v
			else -- privileges too low
				int(3) -- raise privilege violation fault
			end
		end
	end
	local psReg = p.psReg

	function p.pgReg(n) -- privileged register fetch
		if n < 32 then -- user
			return reg[n]
		else -- kernel
			if kernelMode() then -- in kernel mode
				return reg[n] or 0
			else -- privileges too low
				int(3) -- raise privilege violation fault
				return 0
			end
		end
	end
	local pgReg = p.pgReg

	function p.reset()
		local resetVector = fetchLong(0)

		reg[32] = resetVector
	end

	-- push long to stack
	function p.push(v)
		reg[33] = reg[33] - 4
		storeLong(reg[33], v)
	end
	local push = p.push

	-- pop long from stack
	function p.pop()
		local v = fetchLong(reg[33])
		reg[33] = reg[33] + 4
		return v
	end
	local pop = p.pop

	p.optable = {
		[0x0] = function (pc) -- [nop]
			return pc + 1
		end,

		-- load/store primitives

		[0x1] = function (pc) -- [li]
			psReg(fetchByte(pc + 1), fetchLong(pc + 2))

			return pc + 5
		end,
		[0x2] = function (pc) -- [mov]
			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)))

			return pc + 3
		end,
		[0x3] = function (pc) -- [xch]
			local r1, r2 = pgReg(fetchByte(pc + 1)), pgReg(fetchByte(pc + 2))
			psReg(fetchByte(pc + 2), r1)
			psReg(fetchByte(pc + 1), r2)

			return pc + 3
		end,
		[0x4] = function (pc) -- [lib]
			psReg(fetchByte(pc + 1), fetchByte(fetchLong(pc + 2)))

			return pc + 6
		end,
		[0x5] = function (pc) -- [lii]
			psReg(fetchByte(pc + 1), fetchInt(fetchLong(pc + 2)))

			return pc + 6
		end,
		[0x6] = function (pc) -- [lil]
			psReg(fetchByte(pc + 1), fetchLong(fetchLong(pc + 2)))

			return pc + 6
		end,
		[0x7] = function (pc) -- [sib]
			storeByte(fetchLong(pc + 1), pgReg(fetchByte(pc + 5)))

			return pc + 6
		end,
		[0x8] = function (pc) -- [sii]
			storeInt(fetchLong(pc + 1), pgReg(fetchByte(pc + 5)))

			return pc + 6
		end,
		[0x9] = function (pc) -- [sil]
			storeLong(fetchLong(pc + 1), pgReg(fetchByte(pc + 5)))

			return pc + 6
		end,
		[0xA] = function (pc) -- [lrb]
			psReg(fetchByte(pc + 1), fetchByte(pgReg(fetchByte(pc + 2))))

			return pc + 3
		end,
		[0xB] = function (pc) -- [lri]
			psReg(fetchByte(pc + 1), fetchInt(pgReg(fetchByte(pc + 2))))

			return pc + 3
		end,
		[0xC] = function (pc) -- [lrl]
			psReg(fetchByte(pc + 1), fetchLong(pgReg(fetchByte(pc + 2))))

			return pc + 3
		end,
		[0xD] = function (pc) -- [srb]
			storeByte(pgReg(fetchByte(pc + 1)), pgReg(fetchByte(pc + 2)))

			return pc + 3
		end,
		[0xE] = function (pc) -- [sri]
			storeInt(pgReg(fetchByte(pc + 1)), pgReg(fetchByte(pc + 2)))

			return pc + 3
		end,
		[0xF] = function (pc) -- [srl]
			storeLong(pgReg(fetchByte(pc + 1)), pgReg(fetchByte(pc + 2)))

			return pc + 3
		end,
		[0x10] = function (pc) -- [siib]
			storeByte(fetchLong(pc + 1), fetchByte(pc + 5))

			return pc + 6
		end,
		[0x11] = function (pc) -- [siii]
			storeInt(fetchLong(pc + 1), fetchInt(pc + 5))

			return pc + 7
		end,
		[0x12] = function (pc) -- [siil]
			storeLong(fetchLong(pc + 1), fetchLong(pc + 5))

			return pc + 9
		end,
		[0x13] = function (pc) -- [sirb]
			storeByte(pgReg(fetchByte(pc + 1)), fetchByte(pc + 2))

			return pc + 3
		end,
		[0x14] = function (pc) -- [siri]
			storeInt(pgReg(fetchByte(pc + 1)), fetchInt(pc + 2))

			return pc + 4
		end,
		[0x15] = function (pc) -- [sirl]
			storeLong(pgReg(fetchByte(pc + 1)), fetchLong(pc + 2))

			return pc + 6
		end,
		[0x16] = function (pc) -- [push]
			push(pgReg(fetchByte(pc + 1)))

			return pc + 2
		end,
		[0x17] = function (pc) -- [pushi]
			push(fetchLong(pc + 1))

			return pc + 5
		end,
		[0x18] = function (pc) -- [pop]
			psReg(fetchByte(pc + 1), pop())

			return pc + 2
		end,
		[0x19] = function (pc) -- [pusha]
			for i = 0, 31 do
				push(reg[i])
			end

			return pc + 1
		end,
		[0x1A] = function (pc) -- [popa]
			for i = 31, 0, -1 do
				reg[i] = pop()
			end

			return pc + 1
		end,

		-- control flow primitives

		[0x1B] = function (pc) -- [b]
			return fetchLong(pc + 1)
		end,
		[0x1C] = function (pc) -- [bi]
			return pc + fetchLong(pc + 1)
		end,
		[0x1D] = function (pc) -- [br]
			return pgReg(fetchByte(pc + 1))
		end,
		[0x1E] = function (pc) -- [bri]
			return pc + lsign(pgReg(fetchByte(pc+1)))
		end,
		[0x1F] = function (pc) -- [be]
			if getFlag(0) == 1 then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x20] = function (pc) -- [bei]
			if getFlag(0) == 1 then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x21] = function (pc) -- [bne]
			if getFlag(0) == 0 then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x22] = function (pc) -- [bnei]
			if getFlag(0) == 0 then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x23] = function (pc) -- [bg]
			if getFlag(1) == 1 then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x24] = function (pc) -- [bgi]
			if getFlag(1) == 1 then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x25] = function (pc) -- [bl]
			if getFlag(1) == 0 then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x26] = function (pc) -- [bli]
			if getFlag(1) == 0 then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x27] = function (pc) -- [bge]
			if (getFlag(0) == 1) or (getFlag(1) == 1) then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x28] = function (pc) -- [bgei]
			if (getFlag(0) == 1) or (getFlag(1) == 1) then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x29] = function (pc) -- [ble]
			if (getFlag(0) == 1) or (getFlag(1) == 0) then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x2A] = function (pc) -- [blei]
			if (getFlag(0) == 1) or (getFlag(1) == 0) then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x2B] = function (pc) -- [bc]
			if getFlag(2) == 1 then
				return fetchLong(pc + 1)
			end
			return pc + 5
		end,
		[0x2C] = function (pc) -- [bci]
			if getFlag(2) == 1 then
				return pc + lsign(fetchLong(pc + 1))
			end
			return pc + 5
		end,
		[0x2D] = function (pc) -- [call]
			push(pc + 5)

			return fetchLong(pc + 1)
		end,
		[0x2E] = function (pc) -- [ret]
			return pop()
		end,

		-- comparison primitives

		[0x2F] = function (pc) -- [cmp]
			local o1, o2 = pgReg(fetchByte(pc + 1)), pgReg(fetchByte(pc + 2))

			if o1 > o2 then
				setFlag(1, 1)
			else
				setFlag(1, 0)
			end

			if o1 == o2 then
				setFlag(0, 1)
			else
				setFlag(0, 0)
			end

			return pc + 3
		end,
		[0x30] = function (pc) -- [cmpi]
			local o1, o2 = pgReg(fetchByte(pc + 1)), fetchLong(pc + 2)

			if o1 > o2 then
				setFlag(1, 1)
			else
				setFlag(1, 0)
			end

			if o1 == o2 then
				setFlag(0, 1)
			else
				setFlag(0, 0)
			end

			return pc + 6
		end,

		-- arithmetic primitives

		[0x31] = function (pc) -- [add]
			psReg(fetchByte(pc + 1), pgReg(pc + 2) + pgReg(pc + 3))
			return pc + 4
		end,
		[0x32] = function (pc) -- [addi]
			psReg(fetchByte(pc + 1), pgReg(pc + 2) + fetchLong(pc + 3))
			return pc + 7
		end,
		[0x33] = function (pc) -- [sub]
			psReg(fetchByte(pc + 1), math.abs(pgReg(pc + 2) - pgReg(pc + 3)))
			return pc + 4
		end,
		[0x34] = function (pc) -- [subi]
			psReg(fetchByte(pc + 1), math.abs(pgReg(pc + 2) - fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x35] = function (pc) -- [mul]
			psReg(fetchByte(pc + 1), pgReg(pc + 2) * pgReg(pc + 3))
			return pc + 4
		end,
		[0x36] = function (pc) -- [muli]
			psReg(fetchByte(pc + 1), pgReg(pc + 2) * fetchLong(pc + 3))
			return pc + 7
		end,
		[0x37] = function (pc) -- [div]
			psReg(fetchByte(pc + 1), math.floor(pgReg(pc + 2) / pgReg(pc + 3)))
			return pc + 4
		end,
		[0x38] = function (pc) -- [divi]
			psReg(fetchByte(pc + 1), math.floor(pgReg(pc + 2) / fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x39] = function (pc) -- [mod]
			psReg(fetchByte(pc + 1), pgReg(pc + 2) % pgReg(pc + 3))
			return pc + 4
		end,
		[0x3A] = function (pc) -- [modi]
			psReg(fetchByte(pc + 1), pgReg(pc + 2) % fetchLong(pc + 3))
			return pc + 7
		end,

		-- logic primitives

		[0x3B] = function (pc) -- [not]
			psReg(fetchByte(pc + 1), bnot(pgReg(fetchByte(pc + 2))))
			return pc + 3
		end,
		[0x3C] = function (pc) -- [ior]
			psReg(fetchByte(pc + 1), bor(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x3D] = function (pc) -- [iori]
			psReg(fetchByte(pc + 1), bor(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x3E] = function (pc) -- [nor]
			psReg(fetchByte(pc + 1), bnor(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x3F] = function (pc) -- [nori]
			psReg(fetchByte(pc + 1), bnor(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x40] = function (pc) -- [eor]
			psReg(fetchByte(pc + 1), bxor(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x41] = function (pc) -- [eori]
			psReg(fetchByte(pc + 1), bxor(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x42] = function (pc) -- [and]
			psReg(fetchByte(pc + 1), band(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x43] = function (pc) -- [andi]
			psReg(fetchByte(pc + 1), band(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x44] = function (pc) -- [nand]
			psReg(fetchByte(pc + 1), bnand(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x45] = function (pc) -- [nandi]
			psReg(fetchByte(pc + 1), bnand(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))
			return pc + 7
		end,
		[0x46] = function (pc) -- [lsh]
			psReg(fetchByte(pc + 1), lshift(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x47] = function (pc) -- [lshi]
			psReg(fetchByte(pc + 1), lshift(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3)))
			return pc + 4
		end,
		[0x48] = function (pc) -- [rsh]
			psReg(fetchByte(pc + 1), rshift(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))
			return pc + 4
		end,
		[0x49] = function (pc) -- [rshi]
			psReg(fetchByte(pc + 1), rshift(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3)))
			return pc + 4
		end,
		[0x4A] = function (pc) -- [bset]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3)), 1))
			return pc + 4
		end,
		[0x4B] = function (pc) -- [bseti]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3), 1))
			return pc + 4
		end,
		[0x4C] = function (pc) -- [bclr]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3)), 0))
			return pc + 4
		end,
		[0x4D] = function (pc) -- [bclri]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3), 0))
			return pc + 4
		end,

		-- special instructions

		[0x4E] = function (pc) -- [sys]
			local i = fetchByte(pc + 1)

			if i > 5 then i = 0 end

			int(0xA + i)

			return pc + 2
		end,
		[0x4F] = function (pc) -- [cli]
			if kernelMode() then
				intq = {}
			else
				int(3) -- privilege violation
			end
			return pc + 1
		end,
		[0x50] = function (pc) -- [brk]
			int(0x10)
			return pc + 1
		end,
		[0x51] = function (pc) -- [hlt]
			if kernelMode() then
				running = false
			else
				int(3) -- privilege violation
			end
			return pc + 1
		end,

		-- temporary for vm debug purposes

		[0xF0] = function (pc) -- [] dump all registers to terminal
			for i = 0, 36 do
				print(string.format("%X = %X", i, reg[i]))
			end

			return pc + 1
		end,
		[0xF1] = function (pc) -- [] print character in r0
			io.write(string.char(reg[0]))
			io.flush()

			return pc + 1
		end,
	}
	local optable = p.optable

	function p.cycle()
		if running then
			local pc = reg[32]

			local e = optable[fetchByte(pc)]
			if e then
				reg[32] = e(pc)
			else
				reg[32] = pc + 1
				int(1) -- invalid opcode
			end
		end
	end

	return p
end

return cpu























