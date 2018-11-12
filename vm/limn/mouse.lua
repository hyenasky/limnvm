local mouse = {}

local bor, lshift = bor, lshift

function mouse.new(vm, c)
	local m = {}

	m.enable = false

	local int = c.cpu.int
	local bus = c.bus

	local port1 = 0
	local port2 = 0

	local inf1 = 0
	local inf2 = 0

	function m.info(i1, i2)
		inf1 = i1
		inf2 = i2

		if m.enable then
			int(0x34)
		end
	end

	bus.addPort(0x1C, function (s, t, v)
		if t == 0 then
			return 0
		else
			if v == 1 then -- read info
				port1 = inf1
				port2 = inf2
			elseif v == 2 then -- enable
				m.enable = true
			end
		end
	end)

	bus.addPort(0x1D, function (s, t, v)
		if t == 0 then
			return port1
		else
			port1 = v
		end
	end)

	bus.addPort(0x1E, function (s, t, v)
		if t == 0 then
			return port2
		else
			port2 = v
		end
	end)

	vm.registerCallback("keypressed", function (key, t, isrepeat)
		if t == "rgui" then
			if mfocused then
				mfocused = false
				love.mouse.setRelativeMode(false)
			end
		end
	end)

	vm.registerCallback("mousepressed", function (x, y, button)
		if not mfocused then
			mfocused = true
			love.mouse.setRelativeMode(true)
			return
		end

		m.info(1, button)
	end)

	vm.registerCallback("mousereleased", function (x, y, button)
		if not mfocused then return end

		m.info(2, button)
	end)

	vm.registerCallback("mousemoved", function (x, y, dx, dy)
		if not mfocused then return end

		if dx < 0 then
			dx = bor(math.abs(dx), 0x8000)
		end
		if dy < 0 then
			dy = bor(math.abs(dy), 0x8000)
		end

		m.info(3, bor(lshift(dx, 16), dy))
	end)

	return m
end

return mouse