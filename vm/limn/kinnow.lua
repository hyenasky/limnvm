-- implements a simple 8-bit color, 1120x832 framebuffer, with simple 2d acceleration

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

local floor = math.floor

local gpu = {}

local palette = require("limn/kinnow_palette")

-- port 0x12: commands
--  0: idle
--  1: get info
--  2: draw rectangle
--  3: enable vsync
--  4: scroll
-- port 0x13: data
-- port 0x14: data
-- port 0x15: data

function gpu.new(vm, c)
	local g = {}

	local log = vm.log.log

	local mmu = c.mmu

	local int = c.cpu.int

	g.height = love.graphics.getHeight()
	local height = g.height

	g.width = love.graphics.getWidth()
	local width = g.width

	local fbs = width * height
	local bytesPerRow = width

	g.framebuffer = ffi.new("uint8_t[?]", fbs) -- least significant bit is left-most pixel
	local framebuffer = g.framebuffer

	g.imageData = love.image.newImageData(width, height)
	local imageData = g.imageData

	g.image = love.graphics.newImage(imageData)
	local image = g.image

	g.imageFFI = ffi.cast("uint32_t*", imageData:getPointer())
	local imageFFI = g.imageFFI

	g.canvas = love.graphics.newCanvas(width,height)
	local canvas = g.canvas

	g.vsync = false

	local enabled = true

	vm.registerOpt("-gpu,display", function (arg, i)
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

	vm.registerOpt("-gpu,off", function (arg, i)
		enabled = false

		return 1
	end)

	local subRectX1 = false
	local subRectY1 = false
	local subRectX2 = false
	local subRectY2 = false
	local m = false

	local function subRect(x,y,x1,y1)
		if not subRectX1 then -- first thingy this frame
			subRectX1 = x
			subRectY1 = y
			subRectX2 = x1
			subRectY2 = y1
			return
		end

		if x < subRectX1 then
			subRectX1 = x
		end
		if y < subRectY1 then
			subRectY1 = y
		end
		if x1 > subRectX2 then
			subRectX2 = x1
		end
		if y1 > subRectY2 then
			subRectY2 = y1
		end
	end

	local function action(s, offset, v, d)
		if d == 0 then -- pixel
			if s == 0 then
				-- 1 modified pixel
				local e1 = band(v, 0xFF)

				framebuffer[offset] = e1

				local bx = offset % bytesPerRow
				local by = floor(offset / bytesPerRow)

				subRect(bx,by,bx+1,by+1)
			elseif s == 1 then
				-- 2 modified pixels

				local e1 = band(v, 0xFF)
				local e2 = rshift(band(v, 0xFF00), 8)

				framebuffer[offset] = e1
				framebuffer[offset + 1] = e2

				local bx = offset % bytesPerRow
				local by = floor(offset / bytesPerRow)

				subRect(bx,by,bx+2,by+1)
			elseif s == 2 then
				-- 4 modified pixels

				local e1 = band(v, 0xFF)
				local e2 = rshift(band(v, 0xFF00), 8)
				local e3 = rshift(band(v, 0xFF0000), 16)
				local e4 = rshift(band(v, 0xFF000000), 24)

				framebuffer[offset] = e1
				framebuffer[offset + 1] = e2
				framebuffer[offset + 2] = e3
				framebuffer[offset + 3] = e4

				local bx = offset % bytesPerRow
				local by = floor(offset / bytesPerRow)

				subRect(bx,by,bx+4,by+1)
			end
		elseif d == 1 then -- rectangle
			local rw = rshift(s, 16)
			local rh = band(s, 0xFFFF)

			local rx = rshift(offset, 16)
			local ry = band(offset, 0xFFFF)

			subRect(rx,ry,rx+rw,ry+rh)

			for x = rx, rw+rx-1 do
				for y = ry, rh+ry-1 do
					framebuffer[y * width + x] = v
				end
			end
		elseif d == 2 then -- scroll
			subRect(0,0,width-1,height-1)

			local rows = s
			local color = offset

			local mod = rows * width

			for y = 0, height-rows-1 do
				for x = 0, width-1 do
					local b = y * width + x
					framebuffer[b] = framebuffer[b + mod]
				end
			end

			for y = height-rows, height-1 do
				for x = 0, width-1 do
					framebuffer[y * width + x] = color
				end
			end
		end
		m = true
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
				action(s, offset, v, 0)
			end
		elseif s == 1 then -- int
			if t == 0 then
				local u1, u2 = framebuffer[offset], framebuffer[offset + 1]

				return (u2 * 0x100) + u1
			else
				action(s, offset, v, 0)
			end
		elseif s == 2 then -- long
			if t == 0 then
				local u1, u2, u3, u4 = framebuffer[offset], framebuffer[offset + 1], framebuffer[offset + 2], framebuffer[offset + 3]

				return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1
			else
				action(s, offset, v, 0)
			end
		end
	end

	local pcount = math.ceil((width*height)/131072)
	log(string.format("mapping %d bytes of framebuffer from %x to %x", pcount*131072, 0x7A00*131072, (0x7A00+pcount)*131072))
	for i = 0, pcount do
		mmu.mapArea(0x7A00 + i, function (s, t, offset, v)
			return gpuh(s, t, offset + (i * 0x20000), v)
		end)
	end

	local port13 = 0
	local port14 = 0
	local port15 = 0

	local bus = c.bus

	bus.addPort(0x12, function(s, t, v)
		if not enabled then return 0 end

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

				action(port13, port14, port15, 1)
			elseif v == 3 then -- vsync enable
				g.vsync = true
			elseif v == 4 then -- scroll
				-- port13 is rows
				-- port14 is backfill color

				action(port13, port14, port15, 2)
			elseif v == 5 then -- present
				port13 = 1
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
		if enabled then
			if m then
				imageData:mapPixel(function (x,y,r,g,b,a)
					local e = palette[framebuffer[y * width + x]]

					return e.r/255,e.g/255,e.b/255,1
				end, subRectX1, subRectY1, subRectX2 - subRectX1, subRectY2 - subRectY1)

				m = false
				subRectX1 = false

				image:replacePixels(imageData)
			end

			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(image)

			if g.vsync then
				int(0x35)
			end
		end
	end)

	return g
end

return gpu