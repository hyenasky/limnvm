--MAIN PANEL

local cpanel = panel.new(0,0,200,100)

cpanel.enabled = false

cpanel:setTitle("Control Mode")

cpanel:addHook("Exit", function ()
	cpanel.enabled = false
end)

function cpanel:keypressed(key, t, isrepeat)
	if key == "escape" then
		self.enabled = false
	end
end

return cpanel