local panel = {}

panel.current = {}

panel.lstack = {}

function panel.new(x,y,w,h)
	local p = {}

	p.title = "Untitled"
	p.hooks = {}
	p.selected = 1
	p.general = function () end
	p.text = {}
	p.ti = {}
	p.ati = 0
	p.x = x or 0
	p.y = y or 0
	p.w = w or 640
	p.h = h or 400

	p.update = function (dt) end

	function p:setUpdate(up)
		p.update = up
	end

	function p:setMode(x,y,w,h)
		p.x = x or p.x
		p.y = y or p.y
		p.w = w or p.w
		p.h = h or p.h
	end

	function p:setGeneral(g)
		self.general = g
	end

	function p:addTextInput(x,y,w,h)
		self.ti[#self.ti+1] = {x,y,w,h,""}
		return #self.ti
	end

	function p:setActiveTI(ti)
		self.ati = ti
	end

	function p:addHook(text, hook)
		self.hooks[#self.hooks+1] = {text, hook}
		return #self.hooks
	end

	function p:setHook(h, text, hook)
		self.hooks[h] = {text, hook or self.hooks[h][2]}
	end

	function p:addText(text, x, y)
		self.text[#self.text + 1] = {text, x, y}
		return #self.text
	end

	function p:setText(t, text, x, y)
		self.text[t] = {text, x or self.text[t][2], y or self.text[t][3]}
	end

	function p:setTitle(title)
		self.title = title
	end

	function p:draw()
		panel.lstack[#panel.lstack + 1] = panel.current
		panel.current = self
	end

	return p
end

function panel.sp(p)
	panel.current = p
	panel.lstack = {}
end

function panel.update(dt)
	local c = panel.current

	if c.update then
		c.update(dt)
	end
end

function panel.textinput(text)
	local c = panel.current

	if c.ati ~= 0 then
		if #c.ti[c.ati][5]+1 < c.ti[c.ati][3]/8 then
			c.ti[c.ati][5] = c.ti[c.ati][5]..text
		end
	end
end

function panel.keypressed(key, t, isrepeat)
	local c = panel.current

	if #c.hooks ~= 0 then
		if key == "left" or key == "up" then
			if c.selected ~= 1 then
				c.selected = c.selected - 1
			end
		elseif key == "right" or key == "down" then
			if c.selected ~= #c.hooks then
				c.selected = c.selected + 1
			end
		elseif key == "return" then
			c.general(c.selected)
			c.hooks[c.selected][2]()
		end
	end

	if key == "escape" then
		if #panel.lstack ~= 0 then
			panel.current = table.remove(panel.lstack, #panel.lstack)
		end
	elseif key == "backspace" then
		if c.ati ~= 0 then
			c.ti[c.ati][5] = c.ti[c.ati][5]:sub(1,-2)
		end
	end

	if panel.current.keypressed then
		if panel.current == c then
			panel.current:keypressed(key, t, isrepeat)
		end
	end
end

local function pprint(txt, y, bx, bw)
	local e = ((bw/2) - (#txt*4)) + bx
	love.graphics.print(txt, e, y)
	return e
end

function panel.draw()
	local c = panel.current

	local cbx = c.x
	local cby = c.y

	if c.x == 0 then
		local ww = love.graphics.getWidth()
		cbx = (ww/2) - (c.w/2)
	end
	if c.y == 0 then
		local wh = love.graphics.getHeight()
		cby = (wh/2) - (c.h/2)
	end

	love.graphics.setColor(1, 1, 1, 0.62)
	love.graphics.rectangle("fill", cbx, cby, c.w, c.h)
	love.graphics.setColor(0,0,0,0.5)
	love.graphics.rectangle("line", cbx+5, cby+5, c.w-10, c.h-10)

	local bx = cbx+20
	local by = cby+20

	local bw = c.w-40
	local bh = c.h-40

	local hy = ((bh / 2) - ((#c.hooks*10)/2)) + by


	for k,v in ipairs(c.hooks) do
		love.graphics.setColor(0,0,0,1)
		local e = pprint(v[1], hy, bx, bw)

		if k == c.selected then
			love.graphics.setColor(0.1,0.1,0.1,1)
			love.graphics.rectangle("fill", e-2, hy-2, #v[1]*8 + 4, 12)
			love.graphics.setColor(0.9,0.9,0.9,1)
			love.graphics.print(v[1], e, hy)
		end

		hy = hy + 10
	end

	love.graphics.setColor(0,0,0,1)

	for k,v in ipairs(c.text) do
		love.graphics.print(v[1], v[2]+bx, v[3]+by)
	end

	for k,v in ipairs(c.ti) do
		love.graphics.setColor(0.8,0.8,0.8,0.5)
		love.graphics.rectangle("fill", v[1]+bx, v[2]+by, v[3], v[4])
		love.graphics.setColor(0,0,0,0.5)
		love.graphics.rectangle("line", v[1]+bx, v[2]+by, v[3], v[4])
		if k == c.ati then
			love.graphics.setColor(0.1,0.1,0.1,0.5)
			love.graphics.rectangle("fill", v[1]+bx+(#v[5]*8), v[2]+by, 5, v[4])
		end
		love.graphics.setColor(0,0,0,1)
		love.graphics.print(v[5], v[1]+bx, v[2]+by)
	end

	love.graphics.setColor(0,0,0,1)
	pprint(c.title, by, bx, bw)
end

return panel