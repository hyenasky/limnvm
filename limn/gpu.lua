-- implements a simple 2-bit grayscale, 640x480 display

local lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol =
	lshift, rshift, tohex, arshift, band, bxor, bor, bnot, bror, brol

local floor = math.floor

local gpu = {}

local palette = ffi.new("uint8_t[4]")

palette[0] = 0
palette[1] = 64
palette[2] = 191
palette[3] = 255

function gpu.new(vm, c)
	local g = {}

	local mmu = c.mmu

	g.height = 480
	local height = g.height

	g.width = 640
	local width = g.width

	local fbs = ((width*height)/4)
	local bytesPerRow = width/4

	g.framebuffer = ffi.new("uint8_t[?]", fbs) -- least significant bit is left-most pixel
	local framebuffer = g.framebuffer

	g.canvas = love.graphics.newCanvas(640,480)
	local canvas = g.canvas

	g.queue = ffi.new([[
		struct {
			int where;
			int what; 
		}[1024*1024]
	]])
	local gqueue = g.queue

	local queued = 0

	local function queue(s, offset, v)
		if s == 0 then
			-- 4 modified pixels to queue

			local e = gqueue[queued]

			e.where = offset
			e.what = v

			queued = queued + 1
		elseif s == 1 then
			-- 8 modified pixels to queue

			local e1,e2 = gqueue[queued],gqueue[queued + 1]

			e1.where = offset
			e2.where = offset + 1

			e1.what = band(v, 0xFF)
			e2.what = rshift(v, 8)

			queued = queued + 2
		elseif s == 2 then
			-- 16 modified pixels to queue

			local e1,e2,e3,e4 = gqueue[queued],gqueue[queued+1],gqueue[queued+2],gqueue[queued+3]

			e1.where = offset
			e2.where = offset + 1
			e3.where = offset + 2
			e4.where = offset + 3

			e1.what = band(v, 0xFF)
			e2.what = rshift(band(v, 0xFF00), 8)
			e3.what = rshift(band(v, 0xFF0000), 16)
			e4.what = rshift(band(v, 0xFF000000), 24)

			queued = queued + 4
		end
	end

	local function gpuh(s, t, offset, v)
		if offset >= fbs then
			return 0
		end

		if s == 0 then -- byte
			if t == 0 then
				return framebuffer[offset]
			else
				framebuffer[offset] = v

				queue(s, offset, v)
			end
		elseif s == 1 then -- int
			if t == 0 then
				local u1, u2 = framebuffer[offset], framebuffer[offset + 1]

				return (u2 * 0x100) + u1
			else
				local u1, u2 = (math.modf(v/256))%256, v%256
				framebuffer[offset] = u2
				framebuffer[offset + 1] = u1

				queue(s, offset, v)
			end
		elseif s == 2 then -- long
			if t == 0 then
				local u1, u2, u3, u4 = framebuffer[offset], framebuffer[offset + 1], framebuffer[offset + 2], framebuffer[offset + 3]

				return (u4 * 0x1000000) + (u3 * 0x10000) + (u2 * 0x100) + u1
			else
				local u1, u2, u3, u4 = (math.modf(v/16777216))%256, (math.modf(v/65536))%256, (math.modf(v/256))%256, v%256
				framebuffer[offset] = u4
				framebuffer[offset + 1] = u3
				framebuffer[offset + 2] = u2
				framebuffer[offset + 3] = u1

				queue(s, offset, v)
			end
		end
	end

	mmu.mapArea(0x7A00, gpuh)

	vm.registerCallback("update", function (dt)
		if queued > 0 then

			love.graphics.setCanvas(canvas)

			local nq = queued - 1
			for i = 0, nq do
				local e = gqueue[i]

				local bx = (e.where % bytesPerRow) * 4
				local by = floor(e.where / bytesPerRow)

				local w = e.what

				local p1 = band(w, 3)
				local p2 = rshift(band(w, 12), 2)
				local p3 = rshift(band(w, 48), 4)
				local p4 = rshift(band(w, 192), 6)

				local g = palette[p1]/255
				love.graphics.setColor(g,g,g,1)
				love.graphics.points(bx,by)

				g = palette[p2]/255
				love.graphics.setColor(g,g,g,1)
				love.graphics.points(bx+1,by)

				g = palette[p3]/255
				love.graphics.setColor(g,g,g,1)
				love.graphics.points(bx+2,by)

				g = palette[p4]/255
				love.graphics.setColor(g,g,g,1)
				love.graphics.points(bx+3,by)
			end

			love.graphics.setCanvas()

			queued = 0
		end
	end)

	vm.registerCallback("draw", function ()
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(canvas)
	end)

	return g
end

return gpu