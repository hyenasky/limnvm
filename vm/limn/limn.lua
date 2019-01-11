local cpu = {}

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

local floor = math.floor

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

	local TfetchByte = mmu.TfetchByte
	local TfetchInt = mmu.TfetchInt
	local TfetchLong = mmu.TfetchLong

	local TstoreByte = mmu.TstoreByte
	local TstoreInt = mmu.TstoreInt
	local TstoreLong = mmu.TstoreLong

	local translate = mmu.translate

	p.nstall = 0
	function p.stall(cycles)
		p.nstall = p.nstall + cycles
	end

	function p.int(num) -- raise interrupt
		local siq = #intq

		if siq < 256 then
			intq[siq+1] = num
		end
	end
	local int = p.int

	-- we only want 1 fault per cycle at most
	local faultOccurred = false

	function p.fault(num) -- raise fault
		if not faultOccurred then
			int(num)
			faultOccurred = true
		end
	end
	local fault = p.fault

	mmu.fault = fault -- let the mmu raise faults

	function p.getFlag(n)
		return getBit(reg[31], n)
	end
	local getFlag = p.getFlag

	function p.setFlag(n, v)
		reg[31] = setBit(reg[31], n, v)
	end
	local setFlag = p.setFlag

	function p.fillState(v)
		reg[34] = v

		mmu.translating = (getBit(v, 2) == 1)
	end
	local fillState = p.fillState

	function p.getState(n)
		return getBit(reg[34], n) or 0
	end
	local getState = p.getState

	function p.setState(n, v)
		reg[34] = setBit(reg[34], n, v) or 0
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
				if (n == 34) then
					fillState(v)
					return
				end

				reg[n] = v
			else -- privileges too low
				fault(3) -- raise privilege violation fault
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
				fault(3) -- raise privilege violation fault
				return 0
			end
		end
	end
	local pgReg = p.pgReg

	function p.reset()
		setState(0, 0) -- make sure we're in kernel mode

		local resetVector = fetchLong(0xFFFE0000)

		reg[32] = resetVector
	end

	-- push long to stack
	function p.push(v)
		reg[33] = reg[33] - 4
		TstoreLong(reg[33], v)
	end
	local push = p.push

	-- pop long from stack
	function p.pop()
		local v = TfetchLong(reg[33])
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

			return pc + 6
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
			return fetchLong(pc + 1), true
		end,
		[0x1C] = function (pc) -- [br]
			return pgReg(fetchByte(pc + 1)), true
		end,
		[0x1D] = function (pc) -- [be]
			if getFlag(0) == 1 then
				return fetchLong(pc + 1), true
			end

			return pc + 5, true
		end,
		[0x1E] = function (pc) -- [bne]
			if getFlag(0) == 0 then
				return fetchLong(pc + 1), true
			end

			return pc + 5, true
		end,
		[0x1F] = function (pc) -- [bg]
			if getFlag(1) == 1 then
				return fetchLong(pc + 1), true
			end

			return pc + 5, true
		end,
		[0x20] = function (pc) -- [bl]
			if (getFlag(1) == 0) and (getFlag(0) == 0) then
				return fetchLong(pc + 1), true
			end

			return pc + 5, true
		end,
		[0x21] = function (pc) -- [bge]
			if (getFlag(0) == 1) or (getFlag(1) == 1) then
				return fetchLong(pc + 1), true
			end

			return pc + 5, true
		end,
		[0x22] = function (pc) -- [ble]
			if (getFlag(0) == 1) or (getFlag(1) == 0) then
				return fetchLong(pc + 1), true
			end

			return pc + 5, true
		end,
		[0x23] = function (pc) -- [call]
			push(pc + 5)

			return fetchLong(pc + 1), true
		end,
		[0x24] = function (pc) -- [ret]
			return pop()
		end,

		-- comparison primitives

		[0x25] = function (pc) -- [cmp]
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
		[0x26] = function (pc) -- [cmpi]
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

		[0x27] = function (pc) -- [add]
			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)) + pgReg(fetchByte(pc + 3)))

			return pc + 4
		end,
		[0x28] = function (pc) -- [addi]
			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)) + fetchLong(pc + 3))

			return pc + 7
		end,
		[0x29] = function (pc) -- [sub]
			psReg(fetchByte(pc + 1), math.abs(pgReg(fetchByte(pc + 2)) - pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x2A] = function (pc) -- [subi]
			psReg(fetchByte(pc + 1), math.abs(pgReg(fetchByte(pc + 2)) - fetchLong(pc + 3)))

			return pc + 7
		end,
		[0x2B] = function (pc) -- [mul]
			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)) * pgReg(fetchByte(pc + 3)))

			return pc + 4
		end,
		[0x2C] = function (pc) -- [muli]
			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)) * fetchLong(pc + 3))

			return pc + 7
		end,
		[0x2D] = function (pc) -- [div]
			local de = pgReg(fetchByte(pc + 3))

			if de == 0 then
				fault(0x0) -- divide by zero fault
				return pc + 4
			end

			psReg(fetchByte(pc + 1), math.floor(pgReg(fetchByte(pc + 2)) / de))

			return pc + 4
		end,
		[0x2E] = function (pc) -- [divi]
			local de = fetchLong(pc + 3)

			if de == 0 then
				fault(0x0) -- divide by zero fault
				return pc + 7
			end

			psReg(fetchByte(pc + 1), math.floor(pgReg(fetchByte(pc + 2)) / de))

			return pc + 7
		end,
		[0x2F] = function (pc) -- [mod]
			local de = pgReg(fetchByte(pc + 3))

			if de == 0 then
				fault(0x0) -- divide by zero fault
				return pc + 4
			end

			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)) % de)

			return pc + 4
		end,
		[0x30] = function (pc) -- [modi]
			local de = fetchLong(pc + 3)

			if de == 0 then
				fault(0x0) -- divide by zero fault
				return pc + 7
			end

			psReg(fetchByte(pc + 1), pgReg(fetchByte(pc + 2)) % de)

			return pc + 7
		end,

		-- logic primitives

		[0x31] = function (pc) -- [not]
			psReg(fetchByte(pc + 1), bnot(pgReg(fetchByte(pc + 2))))

			return pc + 3
		end,
		[0x32] = function (pc) -- [ior]
			psReg(fetchByte(pc + 1), bor(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x33] = function (pc) -- [iori]
			psReg(fetchByte(pc + 1), bor(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))

			return pc + 7
		end,
		[0x34] = function (pc) -- [nor]
			psReg(fetchByte(pc + 1), bnor(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x35] = function (pc) -- [nori]
			psReg(fetchByte(pc + 1), bnor(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))

			return pc + 7
		end,
		[0x36] = function (pc) -- [eor]
			psReg(fetchByte(pc + 1), bxor(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x37] = function (pc) -- [eori]
			psReg(fetchByte(pc + 1), bxor(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))

			return pc + 7
		end,
		[0x38] = function (pc) -- [and]
			psReg(fetchByte(pc + 1), band(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x39] = function (pc) -- [andi]
			psReg(fetchByte(pc + 1), band(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))

			return pc + 7
		end,
		[0x3A] = function (pc) -- [nand]
			psReg(fetchByte(pc + 1), bnand(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x3B] = function (pc) -- [nandi]
			psReg(fetchByte(pc + 1), bnand(pgReg(fetchByte(pc + 2)), fetchLong(pc + 3)))

			return pc + 7
		end,
		[0x3C] = function (pc) -- [lsh]
			psReg(fetchByte(pc + 1), lshift(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x3D] = function (pc) -- [lshi]
			psReg(fetchByte(pc + 1), lshift(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3)))

			return pc + 4
		end,
		[0x3E] = function (pc) -- [rsh]
			psReg(fetchByte(pc + 1), rshift(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3))))

			return pc + 4
		end,
		[0x3F] = function (pc) -- [rshi]
			psReg(fetchByte(pc + 1), rshift(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3)))

			return pc + 4
		end,
		[0x40] = function (pc) -- [bset]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3)), 1))

			return pc + 4
		end,
		[0x41] = function (pc) -- [bseti]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3), 1))

			return pc + 4
		end,
		[0x42] = function (pc) -- [bclr]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), pgReg(fetchByte(pc + 3)), 0))

			return pc + 4
		end,
		[0x43] = function (pc) -- [bclri]
			psReg(fetchByte(pc + 1), setBit(pgReg(fetchByte(pc + 2)), fetchByte(pc + 3), 0))

			return pc + 4
		end,

		-- special instructions

		[0x44] = function (pc) -- [sys]
			local i = fetchByte(pc + 1)

			if i > 5 then i = 0 end

			int(0xA + i)

			return pc + 2
		end,
		[0x45] = function (pc) -- [cli]
			if kernelMode() then
				intq = {}
			else
				fault(3) -- privilege violation
			end

			return pc + 1
		end,
		[0x46] = function (pc) -- [brk]
			int(0x10)

			return pc + 1
		end,
		[0x47] = function (pc) -- [hlt]
			if kernelMode() then
				running = false
			else
				fault(3) -- privilege violation
			end
			
			return pc + 1
		end,
		[0x48] = function (pc) -- [iret]
			if kernelMode() then
				reg[34] = pop()
				reg[0] = pop()
				return pop()
			else
				fault(3) -- privilege violation
			end

			return pc + 1
		end,

		-- extensions

		[0x49] = function (pc) -- [bswap]
			local ts = pgReg(fetchByte(pc + 2))

			-- I actually hate lua for this
			local swapped = 
				bor(rshift(ts, 24),
					bor(band(lshift(ts, 8), 0xFF0000),
						bor(band(rshift(ts, 8), 0xFF00),
							band(lshift(ts, 24), 0xFF000000))))

			psReg(fetchByte(pc + 1), swapped)

			return pc + 3
		end,

		[0x4A] = function (pc) -- [httl]
			if kernelMode() then
				local htta = reg[36]

				print(string.format("%X", htta))

				for i = 0, 35 do
					if i == 34 then
						fillState(TfetchLong(htta+(34*4)))
					else
						reg[i] = TfetchLong(htta+(i*4))
					end
				end

				for i = 0, 36 do
					print(string.format("%d = %X", i, reg[i]))
				end

				return reg[32]
			else
				fault(3)
			end

			return pc + 1
		end,

		[0x4B] = function (pc) -- [htts]
			if kernelMode() then
				local htta = reg[36]

				for i = 0, 35 do
					TstoreLong(htta+(i*4), reg[i])
				end

				TstoreLong(htta+(34*4), pop())
				TstoreLong(htta+(0*4), pop())
				TstoreLong(htta+(32*4), pop())
			else
				fault(3)
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
			if p.nstall > 0 then
				p.nstall = p.nstall - 1
				return
			end

			faultOccurred = false

			local siq = #intq
			-- if interrupts in queue, vector table initialized, and interrupts enabled
			if (siq > 0) and (reg[35] ~= 0) and (getState(1) == 1) then
				-- do interrupt

				local n = intq[1] -- get num

				local v = TfetchLong(reg[35] + n*4) -- get vector

				if v ~= 0 then
					push(reg[32])
					push(reg[0])
					push(reg[34])

					reg[32] = v
					reg[0] = n
					setState(0, 0) -- kernel mode
					setState(1, 0) -- disable mmu
					table.remove(intq, 1)
				end
			end

			local pc = reg[32]

			local e = optable[TfetchByte(pc)]
			if e then
				local np, tr = e(pc)

				if not tr then
					reg[32] = np
				else
					reg[32] = translate(np)
				end
			else
				reg[32] = pc + 1
				print(string.format("invalid opcode at %X: %d (%s)", pc, TfetchByte(pc), string.char(TfetchByte(pc))))
				fault(1) -- invalid opcode
			end
		end
	end











	-- ui, wild west territory here on
	p.panel = panel.new(0,0,150,250)
	p.panel:setTitle("CPU")

	p.panel:addHook("Exit", function ()
		panel.cpanel.enabled = false
	end)

	local speedbox = panel.new(0,0,210,100)
	speedbox:setTitle("Speed")

	speedbox:addText("Input a speed in hertz.", 0, 10)

	speedbox.si = speedbox:addTextInput(0, 45, 80, 10)

	speedbox:setActiveTI(speedbox.si)

	speedbox.ti[speedbox.si][5] = tostring(vm.hz)

	p.panel:addHook("Speed", function ()
		speedbox:draw()
	end)

	function speedbox:keypressed(key, t, isrepeat)
		if key == "return" then
			local sc = tonumber(speedbox.ti[speedbox.si][5])
			if sc then
				vm.hz = sc
				vm.instructionsPerTick = vm.hz / vm.targetfps
			end
			speedbox.ti[speedbox.si][5] = tostring(vm.hz)
		end
	end

	p.panel:addHook("Soft Reset", function ()
		p.reset()
	end)

	p.panel:addHook("Hard Reset", function ()
		reg[0] = 0
		running = true
		intq = {}
		p.reset()
	end)

	p.panel.phook = p.panel:addHook("Pause", function ()
		if running then
			running = false
			p.panel:setHook(p.panel.phook, "Unpause")
		else
			running = true
			p.panel:setHook(p.panel.phook, "Pause")
		end
	end)

	local interruptbox = panel.new(0,0,300,150)

	interruptbox:setTitle("Interrupt")

	interruptbox:addText(
	[[Type a number and press enter to
raise an interrupt.]], 0, 10)

	interruptbox.i = interruptbox:addTextInput(0, 40, 100, 10)

	interruptbox:setActiveTI(interruptbox.i)

	interruptbox:addHook("Do it", function ()
		local si = interruptbox.ti[interruptbox.i][5]
		local e = tonumber(si)
		if e then
			int(e)
			interruptbox.ti[interruptbox.i][5] = ""
		end
	end)

	p.panel:addHook("Interrupt", function ()
		interruptbox:draw()
	end)

	local statebox = panel.new(0,0,250,260)

	statebox:setTitle("State")

	statebox.rx = {}
	statebox.ly = 20
	statebox.areg = 0

	for i = 0, 19 do
		statebox.rx[i] = statebox:addTextInput(0, statebox.ly, 100, 10)
		statebox.ly = statebox.ly + 10
	end

	statebox.ly = 20

	for i = 20, 36 do
		statebox.rx[i] = statebox:addTextInput(110, statebox.ly, 100, 10)
		statebox.ly = statebox.ly + 10
	end

	statebox:setUpdate(function (dt)
		for i = 0, 36 do
			if i ~= statebox.areg then
				statebox.ti[statebox.rx[i]][5] = string.format("0x%X", reg[i])
			end
		end
	end)

	function statebox:keypressed(key, t, isrepeat)
		if key == "up" then
			if statebox.areg < 1 then
				statebox.areg = 35
			else
				statebox.areg = statebox.areg - 1
			end
		elseif key == "down" then
			if statebox.areg == 35 then
				statebox.areg = 0
			else
				statebox.areg = statebox.areg + 1
			end
		end

		if key == "return" then
			if statebox.areg ~= -1 then
				local nr = tonumber(statebox.ti[statebox.rx[statebox.areg]][5])
				if nr then
					reg[statebox.areg] = nr
				end
			end
		else
			statebox:setActiveTI(statebox.rx[statebox.areg])
		end
	end

	p.panel:addHook("State", function ()
		statebox:draw()
	end)

	c.panel:addHook("CPU", function ()
		p.panel:draw()
	end)

	return p
end

return cpu























