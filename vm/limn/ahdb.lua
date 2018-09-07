local ahdb = {}

-- implements a DMA drive controller, AISA Hard Disk Bus
-- supports up to 8 hot-pluggable drives

-- block size is 4096 bytes

-- interrupt 0x31 is raised when new information is available

-- port 0x18: commands
--	0: idle
--	1: select drive
--		port 19: ID 0-7
--	2: read block 
--		port 19: block number
--		port 1A: 32-bit physical buffer address
--	3: write block
--		port 19: block number
--		port 1A: 32-bit physical buffer address
--	4: read new information
--		port 19: what happened?
--			0: DMA transfer complete
--				details: block number
--			1: drive attached
--				details: drive ID
--			2: drive removed
--				details: drive ID
--		port 1A: details
--	5: poll drive
--		port 19: drive ID
--	returns:
--		port 19: bitfield
--			bit 0: drive attached here?
--		port 1A: size in 4kb blocks
-- port 0x19: data
-- port 0x1A: data

function ahdb.new(vm, c)
	local b = {}

	local bus = c.bus
	local readByte = c.mmu.TfetchByte
	local writeByte = c.mmu.TstoreByte

	local int = c.cpu.int

	b.drives = {}

	function b.attach(mask) -- attach drive
		-- find empty slot
		local id

		for i = 0, 7 do
			if not b.drives[i] then
				id = i
				break
			end
		end

		if not id then return false end -- abort

		b.drives[id] = {}
		local d = b.drives[id]

		d.blocks = 0
		d.id = id

		function d:image(image)
			if self.block then
				self.block:close()
			end

			self.block = block.new(image, 4096)

			self.blocks = self.block.blocks
		end

		function d:eject()
			b.info(2, self.id)

			b.drives[self.id] = nil
		end

		-- if mask is true, don't send an interrupt
		if not mask then
			b.info(1, id)
		end

		return id, d
	end

	local infowhat = 0
	local infodetails = 0

	function b.info(what, details)
		infowhat = what
		infodetails = details

		int(0x31)
	end

	local selected = 0 -- selected drive
	local port19 = 0
	local port1A = 0

	bus.addPort(0x18, function (s, t, v)
		if t == 0 then
			return 0
		else
			if v == 1 then -- select drive
				selected = port19
			elseif v == 2 then -- read block
				local block = port19
				local paddr = port1A

				local d = b.drives[selected]

				-- no valid drive selected, just do nothing
				-- this means the OS will be waiting for a DMA interrupt that will never come,
				-- block IO will just halt and hang it
				-- this should probably raise an error or something
				-- haha die
				if not d then
					return
				end

				local db = d.block
				db:seek(block)

				for i = 0, 4095 do
					writeByte(paddr + i, db:read())
				end

				b.info(0, block)
			elseif v == 3 then -- write block
				local block = port19
				local paddr = port1B

				local d = b.drives[selected]

				if not d then
					return
				end

				local db = d.block
				db:seek(block)

				for i = 0, 4095 do
					db:write(readByte(paddr + i))
				end

				b.info(0, block)
			elseif v == 4 then -- read info
				port19 = infowhat
				port1A = infodetails

				infowhat, infodetails = 0, 0
			elseif v == 5 then -- poll drive
				local id = port19

				if b.drives[id] then
					port19 = 1
					port1A = b.drives[id].blocks
				else
					port19 = 0
					port1A = 0
				end
			end
		end
	end)

	bus.addPort(0x19, function (s, t, v)
		if t == 0 then
			return port19
		else
			port19 = v
		end
	end)

	bus.addPort(0x1A, function (s, t, v)
		if t == 0 then
			return port1A
		else
			port1A = v
		end
	end)

	vm.registerOpt("-ahd", function (arg, i)
		local image = arg[i + 1]

		local x,y = b.attach(true)

		if not x then
			print("couldn't attach image "..image)
		else
			print(string.format("image %s on ahd%d", image, x))
		end

		y:image(image)

		return 2
	end)

	return b
end

return ahdb