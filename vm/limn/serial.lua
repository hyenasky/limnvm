local serial = {}

-- implements a serial port
-- port 0x10: commands
--	0: idle
--	1: write
--	2: read
-- port 0x11: in/out byte

function serial.new(vm, c)
	local s = {}

	local stdo = false

	local bus = c.bus

	local input = {text = ""}

	local port11 = 0xFFFF

	local iq = {}
	local oq = {}

	bus.addPort(0x10, function (e,t,v)
		if t == 1 then
			if v == 1 then
				if stdo then
					io.write(string.char(port11))
					io.flush()
				end
				oq[#oq + 1] = string.char(port11)
			elseif v == 2 then
				if #iq > 0 then -- input queue has stuff
					port11 = string.byte(table.remove(iq,1))
				else
					port11 = 0xFFFF -- nada
				end
			end
		else
			return 0 -- always idle since this is all synchronous (god bless emulators)
		end
	end)

	bus.addPort(0x11, function (s,t,v)
		if t == 1 then
			port11 = v
		else
			return port11
		end
	end)

	function s.stream(e)
		for i = 1, #e do
			local c = e:sub(i,i)

			iq[#iq + 1] = c
		end
	end

	function s.read()
		if #oq > 0 then
			return table.remove(oq,1)
		else
			return false
		end
	end

	vm.registerOpt("-insf", function (arg, i)
		s.stream(io.open(arg[i+1]):read("*l"))

		return 2
	end)
	vm.registerOpt("-ins", function (arg, i)
		s.stream(io.read("*a"))

		return 1
	end)
	vm.registerOpt("-outs", function (arg, i)
		stdo = true

		return 1
	end)









	-- ui
	s.panel = panel.new(0,0,150,250)
	s.panel:setTitle("Serial Port")

	s.panel:addHook("Exit", function ()
		panel.cpanel.enabled = false
	end)

	local writepanel = panel.new(0,0,300,150)
	writepanel:setTitle("Write")

	writepanel:addText(
[[Type a string and press enter to
inject it into the serial port
stream.]], 0, 10)

	writepanel.i = writepanel:addTextInput(0, 40, 200, 10)

	writepanel:setActiveTI(writepanel.i)

	writepanel:addHook("Do it", function ()
		local si = writepanel.ti[writepanel.i][5]
		writepanel.ti[writepanel.i][5] = ""

		local i = 1
		while true do
			if i > #si then
				break
			end

			local c = si:sub(i,i)

			if not c then break end

			if c == "\\" then
				local e = si:sub(i+1,i+1)

				if e == "n" then --newline
					s.stream("\n")
				elseif e == "\\" then
					s.stream("\\")
				elseif e == "b" then
					s.stream(string.char(8))
				end

				i = i + 2
			else
				s.stream(c)
				i = i + 1
			end
		end
	end)

	s.panel:addHook("Write", function ()
		writepanel:draw()
	end)

	bus.panel:addHook("Serial Port", function ()
		s.panel:draw()
	end)

	return s
end

return serial