local computer = {}

function computer.new(vm, memsize)
	local c = {}

	c.mmu = require("limn/mmu").new(vm, c, memsize)
	c.cpu = require("limn/cpu").new(vm, c)
	c.bus = require("limn/bus").new(vm, c)

	c.rom = require("limn/rom").new(vm, c)

	c.cpu.reset()

	return c
end

return computer