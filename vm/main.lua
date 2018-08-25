ffi = require("ffi")
require("misc")

panel = require("ui.panel")
panel.cpanel = require("ui.cpanel")
local cpanel = panel.cpanel

--[[
	Virtual machine
	Intended to be as modular as possible while still retaining speed
	CPU could be switched out, so could the device subsystem, and memory subsystem
	super mega modular
]]

local vm = {}

vm.speed = 1

vm.hz = 5000000
vm.targetfps = 60
vm.instructionsPerTick = 0

vm.cb = {}
vm.cb.update = {}
vm.cb.draw = {}
vm.cb.keypressed = {}
vm.cb.keyreleased = {}
vm.cb.mousepressed = {}
vm.cb.mousereleased = {}
vm.cb.mousemoved = {}
vm.cb.wheelmoved = {}
vm.cb.textinput = {}

function vm.registerCallback(t, cb)
	local t = vm.cb[t]
	if t then
		t[#t+1] = cb
	end
end

vm.optcb = {}

function vm.registerOpt(name, handler)
	vm.optcb[name] = handler
end

local dbmsg = false

function love.load(arg)
	vm.computer = require("computer").new(vm, 1024*1024*32) -- new computer with 32mb of mem

	local i = 1
	while true do
		if i > #arg then
			break
		end

		local h = vm.optcb[arg[i]]

		if h then
			i = i + h(arg, i)
		elseif arg[i] == "-hz" then
			vm.hz = tonumber(arg[i + 1])
			i = i + 2
		elseif arg[i] == "-dbg" then
			dbmsg = true
			i = i + 1
		else
			print("unrecognized option "..arg[i])
			i = i + 1
		end
	end

	vm.instructionsPerTick = vm.hz / vm.targetfps

	panel.sp(cpanel)

	love.graphics.setFont(love.graphics.newFont("ui/kongtext.ttf", 8))
	love.keyboard.setKeyRepeat(true)
end

local cycles = 0
local ct = 0

function love.update(dt)
	ct = ct + dt

	if dbmsg then
		if ct > 1 then
			print(string.format("%d hz", cycles))
			ct = 0
			cycles = 0
		end
	end

	local vct = vm.cb.update
	local vcl = #vct
	for i = 1, vcl do
		vct[i](dt)
	end

	local cycle = vm.computer.cpu.cycle

	if cycle then
		local t = vm.instructionsPerTick
		for i = 1, t do
			cycle()
			cycles = cycles + 1
		end
	end

	if cpanel.enabled then
		panel.update(dt)
	end
end

function love.draw()
	local wh = love.graphics.getHeight()
	local ww = love.graphics.getWidth()

	local s = 1

	local vct = vm.cb.draw
	local vcl = #vct
	for i = 1, vcl do
		vct[i](0, 0, s)
	end

	if cpanel.enabled then
		panel.draw()
	end
end

function love.keypressed(key, t, isrepeat)
	if cpanel.enabled then
		panel.keypressed(key, t, isrepeat)
	else
		if key == "rctrl" then
			cpanel.enabled = true
		end

		local vct = vm.cb.keypressed
		local vcl = #vct
		for i = 1, vcl do
			vct[i](key, t, isrepeat)
		end
	end
end

function love.keyreleased(key, t)
	local vct = vm.cb.keyreleased
	local vcl = #vct
	for i = 1, vcl do
		vct[i](key, t)
	end
end

function love.mousepressed(x, y, button)
	local vct = vm.cb.mousepressed
	local vcl = #vct
	for i = 1, vcl do
		vct[i](x, y, button)
	end
end

function love.mousereleased(x, y, button)
	local vct = vm.cb.mousereleased
	local vcl = #vct
	for i = 1, vcl do
		vct[i](x, y, button)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	local vct = vm.cb.mousemoved
	local vcl = #vct
	for i = 1, vcl do
		vct[i](x, y, dx, dy, istouch)
	end
end

function love.wheelmoved(x, y)
	local vct = vm.cb.wheelmoved
	local vcl = #vct
	for i = 1, vcl do
		vct[i](x, y)
	end
end

function love.textinput(text)
	local vct = vm.cb.textinput
	local vcl = #vct
	for i = 1, vcl do
		vct[i](text)
	end

	if cpanel.enabled then
		panel.textinput(text)
	end
end