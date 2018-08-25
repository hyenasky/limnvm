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

	-- compy
	c.mmu = require("limn/mmu").new(vm, c, memsize)
	c.cpu = require("limn/cpu").new(vm, c)
	c.bus = require("limn/bus").new(vm, c)

	-- devices
	c.rom = require("limn/rom").new(vm, c)
	c.gpu = require("limn/8bitgpu").new(vm, c)
	c.serial = require("limn/serial").new(vm, c)
	c.sdisk = require("limn/sdisk").new(vm, c)
	c.keyboard = require("limn/keyboard").new(vm, c)

	-- init
	c.cpu.reset()

	return c
end

return computer