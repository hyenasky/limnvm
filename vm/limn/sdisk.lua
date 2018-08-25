-- serial port disk

local sdisk = {}

function sdisk.new(vm, c)
	local sd = {}

	local serial = c.serial

	local enabled = true

	sd.disk = {}
	local disk = {}

	local stage = 0
	-- 0: idle
	-- 1: awaiting block:0
	-- 2: awaiting block:1
	-- 3: awaiting block:2
	-- 4: awaiting block:3

	local block = 0

	local zeroes = ""

	for i = 1, 4096 do
		zeroes = zeroes .. string.char(0)
	end

	vm.registerCallback("update", function (dt)
		if enabled then
			if stage == 0 then
				local c = serial.read()

				if not c then
					return
				end

				c = string.byte(c)

				if c == 0x4E then
					stage = 1
				end
			elseif (stage == 1) or (stage == 2) or (stage == 3) then
				local c = serial.read()

				if not c then
					return
				end

				block = (block * 0x100) + string.byte(c)

				stage = stage + 1
			elseif stage == 4 then
				local c = serial.read()

				if not c then
					return
				end

				block = (block * 0x100) + string.byte(c)

				serial.stream(string.char(0x4E))

				serial.stream(disk[block] or zeroes)

				stage = 0
				block = 0
			end
		end
	end)

	vm.registerOpt("-sdisk", function (arg, i)
		enabled = true

		return 1
	end)

	vm.registerOpt("-sdblock", function (arg, i)
		local b = tonumber(arg[i+1])
		local f = arg[i+2]

		local dat = ""

		if f == "-" then -- stdin
			dat = io.read("*a")
		else
			local bf = io.open(f, "r")

			if not bf then
				error("couldn't open block file "..f)
			end

			dat = bf:read("*a")

			bf:close()
		end

		local dd = ""
		for i = 1, 4096 do
			if i > #dat then
				dd = dd .. string.char(0)
			else
				dd = dd .. dat:sub(i,i)
			end
		end
		disk[b] = dd

		return 3
	end)

	return sd
end

return sdisk



