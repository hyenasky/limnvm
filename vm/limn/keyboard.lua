local keydev = {}

-- implements a AISA keyboard
-- port 0x16: commands
--  0: idle
--  1: pop scancode from queue
-- port 0x17: data

local layout = {}
layout.l = {}
layout.m = {}

layout.l = {
	[0] = 'a', --0
	'b', 'c', 'd', --3
	'e', 'f', 'g', --6
	'h', 'i', 'j', --9
	'k', 'l', 'm', --12
	'n', 'o', 'p', --15
	'q', 'r', 's', --18
	't', 'u', 'v', --21
	'w', 'x', 'y', --24
	'z', --25
	'0', '1', '2', --28
	'3', '4', '5', --31
	'6', '7', '8', --34
	'9', --35
	';', --36
	'space', --37
	'tab', -- 38
	'-', -- 39
	'=', -- 40
	'[', -- 41
	']', -- 42
	'\\', -- 43
	';', -- 44
	'/', -- 45
	'.', -- 46
	'\'', -- 47
	',', -- 48

	[50]='return', --50
	[51]='backspace', --51
	[52]='capslock', --52
	[53]='escape', --53
	[54]='left', --54
	[55]='right', --55
	[56]='down', --56
	[57]='up', --57
}

for k,v in pairs(layout.l) do
	layout.m[v] = k
end

layout.m["kpenter"] = 50
layout.m["kp0"] = 26
layout.m["kp1"] = 27
layout.m["kp2"] = 28
layout.m["kp3"] = 29
layout.m["kp4"] = 30
layout.m["kp5"] = 31
layout.m["kp6"] = 32
layout.m["kp7"] = 33
layout.m["kp8"] = 34
layout.m["kp9"] = 35

function keydev.new(vm, c)
	local kbd = {}
	kbd.kbb = {}

	local int = c.cpu.int

	function kbd.kbp()
		return table.remove(kbd.kbb,#kbd.kbb)
	end

	function kbd.kba(k)
		table.insert(kbd.kbb, 1, k)
	end

	local bus = c.bus

	local port17 = 0xFFFF

	bus.addPort(0x16, function(s, t, v)
		if s ~= 0 then
			return 0
		end

		if t == 1 then
			if v == 1 then -- pop scancode
				if #kbd.kbb > 0 then
					port17 = kbd.kbp()
				else
					port17 = 0xFFFF
					int(8) -- io error
				end
			elseif v == 2 then -- reset buffer
				kbd.kbb = {}
			end
		else
			return 0
		end
	end)

	bus.addPort(0x17, function (s,t,v)
		if t == 1 then
			port17 = v
		else
			return port17
		end
	end)

	vm.registerCallback("keypressed", function (key, t, isrepeat)
		if layout.m[t] then
			int(0x30)
			if love.keyboard.isDown("lshift") then
				kbd.kba(0xF0)
				kbd.kba(layout.m[t])
			elseif love.keyboard.isDown("lctrl") then
				kbd.kba(0xF1)
				kbd.kba(layout.m[t])
			else
				kbd.kba(layout.m[t])
			end
		end
	end)

	return kbd
end

return keydev