local computer = {}

function computer.new(vm, memsize)
	local c = {}

	-- ui
	c.panel = panel.new(0,0,150,250)
	c.panel:setTitle("Computer")

	c.panel:addHook("Exit", function ()
		panel.cpanel.enabled = false
	end)

	panel.cpanel:addHook("Computer", function ()
		c.panel:draw()
	end)

	-- chipset
	c.bus = require("limn/ebus").new(vm, c)
	c.mmu = require("limn/mmu").new(vm, c)
	c.cpu = require("limn/limn1k").new(vm, c)

	c.bus.insertBoard(0, "ram256", memsize)

	return c
end

return computer