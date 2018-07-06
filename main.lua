ffi = require("ffi")
require("misc")

--[[
	Virtual machine
	Intended to be as modular as possible while still retaining speed
	CPU could be switched out, so could the device subsystem, and memory subsystem
	super mega modular
]]

local vm = {}

vm.speed = 1

vm.cb = {}
vm.cb.update = {}
vm.cb.draw = {}
vm.cb.keypressed = {}
vm.cb.keyreleased = {}
vm.cb.mousepressed = {}
vm.cb.mousereleased = {}
vm.cb.mousemoved = {}
vm.cb.wheelmoved = {}

function vm.registerCallback(t, cb)
	if vm.cb[t] then
		vm.cb[t] = cb
	end
end

function love.load(arg)
	vm.computer = require("computer").new(vm, 1024*1024*32) -- new computer with 32mb of mem
end

local cycles = 0
local ct = 0

function love.update(dt)
	ct = ct + dt
	if ct > 1 then
		print(string.format("%d hz", cycles))
		ct = 0
		cycles = 0
	end

	local vcut = vm.cb.update
	local vcul = #vcut
	for i = 1, vcul do
		vcut[i](dt)
	end

	local cycle = vm.computer.cpu.cycle

	local t = love.timer.getTime
	local timeslice = 1/30 --should be equivalent to 1/targetfps

	if cycle then
		local s = t()
		local e = timeslice + s
		while t() < e do
			cycle()
			cycles = cycles + 1
		end
	end
end

function love.draw()
	local vcdt = vm.cb.draw
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i]()
	end
end

function love.keypressed(key, t, isrepeat)
	local vcdt = vm.cb.keypressed
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i](key, t, isrepeat)
	end
end

function love.keyreleased(key, t)
	local vcdt = vm.cb.keyreleased
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i](key, t)
	end
end

function love.mousepressed(x, y, button)
	local vcdt = vm.cb.mousepressed
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i](x, y, button)
	end
end

function love.mousereleased(x, y, button)
	local vcdt = vm.cb.mousereleased
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i](x, y, button)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	local vcdt = vm.cb.mousemoved
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i](x, y, dx, dy, istouch)
	end
end

function love.wheelmoved(x, y)
	local vcdt = vm.cb.wheelmoved
	local vcdl = #vcdt
	for i = 1, vcdl do
		vcdt[i](x, y)
	end
end