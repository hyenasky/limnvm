local mouse = {}

local bor, lshift, band = bor, lshift, band

function mouse.new(vm, c)
	local m = {}

	m.portA = 0
	m.portB = 0

	m.mid = 0x4D4F5553

	local inf1 = 0
	local inf2 = 0

	local ignore = false

	local ifs = {}

	local function int()
		if m.intn then
			c.cpu.int(m.intn)
		end
	end

	function m.info(i1, i2)
		ifs[#ifs+1] = {i1, i2}

		int()
	end

	function m.action(v)
		if v == 1 then -- read info
			local ift = table.remove(ifs, 1)
			m.portA = ift[1]
			m.portB = ift[2]
		end
	end

	vm.registerCallback("keypressed", function (key, t, isrepeat)
		if t == "rgui" then
			if mfocused then
				mfocused = false
				love.mouse.setGrabbed(false)
				love.mouse.setVisible(true)
				love.mouse.setRelativeMode(false)
				love.window.setTitle("limnvm")
			end
		end
	end)

	vm.registerCallback("mousepressed", function (x, y, button)
		if not mfocused then
			mfocused = true
			love.window.setTitle("limnvm - press right windows key to uncapture mouse")
			love.mouse.setVisible(false)
			love.mouse.setGrabbed(true)
			love.mouse.setRelativeMode(true)
			ignore = true
			return
		end

		m.info(1, button)
	end)

	vm.registerCallback("mousereleased", function (x, y, button)
		if not mfocused then return end

		if ignore then ignore = false return end

		m.info(2, button)
	end)

	vm.registerCallback("mousemoved", function (x, y, dx, dy)
		if not mfocused then return end

		local ndx = band(math.abs(dx), 0x7FFF)
		local ndy = band(math.abs(dy), 0x7FFF)

		if dx < 0 then
			dx = bor(ndx, 0x8000)
		end
		if dy < 0 then
			dy = bor(ndy, 0x8000)
		end

		m.info(3, bor(lshift(dx, 16), dy))
	end)

	return m
end

return mouse