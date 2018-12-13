local bus = {}

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

local floor = math.floor

function bus.new(vm, c)
	local b = {}

	local mmu = c.mmu

	b.ports = {}
	local ports = b.ports

	function b.addPort(num, handler)
		ports[num] = handler
	end
	local addPort = b.addPort

	local function bush(s, t, offset, v)
		if offset >= 1024 then
			return 0
		end

		if band(offset, 3) ~= 0 then -- must be aligned to 4 bytes
			return 0
		end

		local port = offset/4

		local h = ports[port]
		if h then
			return h(s, t, v)
		else
			return 0
		end
	end

	mmu.mapArea(0x7FFE, bush)

	-- ui
	b.panel = panel.new(0,0,150,250)
	b.panel:setTitle("Bus")

	b.panel:addHook("Exit", function ()
		panel.cpanel.enabled = false
	end)

	c.panel:addHook("Bus", function ()
		b.panel:draw()
	end)

	return b
end

return bus