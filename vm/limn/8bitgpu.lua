-- implements a simple 8-bit color, 1120x832 display, with simple 2d acceleration

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

local floor = math.floor

local gpu = {}

local palette = require("limn/8bitgpu_palette")

-- port 0x12: commands
--  0: idle
--  1: get info
--  2: draw rectangle
-- port 0x13: data
-- port 0x14: data
-- port 0x15: data

function gpu.new(vm, c)
	local g = {}

	local mmu = c.mmu

	local int = c.cpu.int

	g.height = 832
	local height = g.height

	g.width = 1120
	local width = g.width

	local fbs = width * height
	local bytesPerRow = width

	g.framebuffer = ffi.new("uint8_t[?]", fbs) -- least significant bit is left-most pixel
	local framebuffer = g.framebuffer

	g.canvas = love.graphics.newCanvas(width,height)
	local canvas = g.canvas

	vm.registerOpt("-display", function (arg, i)
		local w,h = tonumber(arg[i+1]), tonumber(arg[i+2])

		g.height = h
		g.width = w
		height = h
		width = w

		fbs = width * height
		bytesPerRow = width

		g.canvas:release()

		g.canvas = love.graphics.newCanvas(w,h)
		canvas = g.canvas

		g.framebuffer = nil
		g.framebuffer = ffi.new("uint8_t[?]", fbs)
		framebuffer = g.framebuffer

		love.window.setMode(width, height)

		return 3
	end)

	g.queue = ffi.new([[
		struct {
			int where;
			int what;
			int a;
			int d;
		}[1024*1024]
	]])
	local gqueue = g.queue

	local queued = 0

	local function queue(s, offset, v, d)
		if d == 0 then -- pixel
			if s == 0 then
				-- 1 modified pixel to queue

				local e = gqueue[queued]

				e.where = offset
				e.what = v
				e.d = 0

				queued = queued + 1
			elseif s == 1 then
				-- 2 modified pixels to queue

				local e1,e2 = gqueue[queued],gqueue[queued + 1]

				e1.where = offset
				e2.where = offset + 1

				e1.what = band(v, 0xFF)
				e2.what = rshift(v, 8)

				e1.d = 0
				e2.d = 0

				queued = queued + 2
			elseif s == 2 then
				-- 4 modified pixels to queue

				local e1,e2,e3,e4 = gqueue[queued],gqueue[queued+1],gqueue[queued+2],gqueue[queued+3]

				e1.where = offset
				e2.where = offset + 1
				e3.where = offset + 2
				e4.where = offset + 3

				e1.what = band(v, 0xFF)
				e2.what = rshift(band(v, 0xFF00), 8)
				e3.what = rshift(band(v, 0xFF0000), 16)
				e4.what = rshift(band(v, 0xFF000000), 24)

				e1.d = 0
				e2.d = 0
				e3.d = 0
				e4.d = 0

				queued = queued + 4
			end
		else -- rectangle
			local e = gqueue[queued]

			e.where = s
			e.what = offset
			e.a = v
			e.d = 1

			queued = queued + 1
		end
	end

	local function gpuh(s, t, offset, v)
		if offset >= fbs then
			int(8) -- io error
			return 0
		end

		if s == 0 then -- byte
			if t == 0 then
				return framebuffer[offset]
			else
				queue(s, offset, v, 0)
			end
		elseif s == 1 then -- int
			if t == 0 then
				local u1, u2 = framebuffer[offset], framebuffer[offset + 1]

				return (u2 * 0x100) + u1
			else
				queue(s, offset, v, 0)
			end
		elseif s == 2 then -- long
			if t == 0 then
				local u1, u2, u3, u4 = framebuffer[offset], framebuffer[offset + 1], framebuffer[offset + 2], framebuffer[offset + 3]

				return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1
			else
				queue(s, offset, v, 0)
			end
		end
	end

	-- 8 128kb pages to accomodate 1 megapixel
	mmu.mapArea(0x7A00, gpuh)
	mmu.mapArea(0x7A01, function (s, t, offset, v)
		return gpuh(s, t, offset + 0x20000, v)
	end)
	mmu.mapArea(0x7A02, function (s, t, offset, v)
		return gpuh(s, t, offset + 0x40000, v)
	end)
	mmu.mapArea(0x7A03, function (s, t, offset, v)
		return gpuh(s, t, offset + 0x60000, v)
	end)
	mmu.mapArea(0x7A04, function (s, t, offset, v)
		return gpuh(s, t, offset + 0x80000, v)
	end)
	mmu.mapArea(0x7A05, function (s, t, offset, v)
		return gpuh(s, t, offset + 0xA0000, v)
	end)
	mmu.mapArea(0x7A06, function (s, t, offset, v)
		return gpuh(s, t, offset + 0xC0000, v)
	end)
	mmu.mapArea(0x7A07, function (s, t, offset, v)
		return gpuh(s, t, offset + 0xE0000, v)
	end)

	local port13 = 0
	local port14 = 0
	local port15 = 0

	local bus = c.bus

	bus.addPort(0x12, function(s, t, v)
		if s ~= 0 then
			return 0
		end

		if t == 1 then
			if v == 1 then -- gpuinfo
				port13 = width
				port14 = height
			elseif v == 2 then -- rectangle
				-- port13 is width x height, both 16-bit
				-- port14 is x,y; both 16-bit
				-- port15 is color

				queue(port13, port14, port15, 1)
			end
		else
			return 0
		end
	end)

	bus.addPort(0x13, function (s, t, v)
		if t == 0 then
			return port13
		else
			port13 = v
		end
	end)

	bus.addPort(0x14, function (s, t, v)
		if t == 0 then
			return port14
		else
			port14 = v
		end
	end)

	bus.addPort(0x15, function (s, t, v)
		if t == 0 then
			return port15
		else
			port15 = v
		end
	end)

	vm.registerCallback("draw", function (x,y,s)
		if queued > 0 then
			love.graphics.setCanvas(canvas)

			local nq = queued - 1
			for i = 0, nq do
				local e = gqueue[i]

				if e.d == 0 then -- pixel
					local bx = e.where % bytesPerRow
					local by = floor(e.where / bytesPerRow)

					local w = e.what

					framebuffer[e.where] = w

					local g = palette[w]

					love.graphics.setColor(g.r/255, g.g/255, g.b/255, 1)
					love.graphics.points(bx,by)
				elseif e.d == 1 then -- rectangle
					local g = palette[e.a]

					local rw = rshift(e.where, 16)
					local rh = band(e.where, 0xFFFF)

					local rx = rshift(e.what, 16)
					local ry = band(e.what, 0xFFFF)

					love.graphics.setColor(g.r/255, g.g/255, g.b/255, 1)
					love.graphics.rectangle("fill", rx, ry, rw, rh)

					for x = rx, rw+rx-1 do
						for y = ry, rh+ry-1 do
							framebuffer[y * width + x] = e.a
						end
					end
				end
			end

			love.graphics.setCanvas()

			queued = 0
		end

		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(canvas, x, y, 0, s, s)
	end)

	return g
end

return gpu