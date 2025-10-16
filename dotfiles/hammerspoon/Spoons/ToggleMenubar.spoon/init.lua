local obj = {}
obj.__index = obj

obj.name = "ToggleMenubar"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj.gap = 10

function obj:init()
	return self
end

function obj:toggle()
	local output = hs.execute("defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo 0")
	local menubarHidden = tonumber(output:match("%d+")) == 1
	local gridSize = hs.grid.getGrid()

	hs.osascript.applescript(string.format([[
		tell application "System Events"
			tell dock preferences to set autohide menu bar to %s
		end tell
	]], tostring(not menubarHidden)))

	hs.timer.doAfter(0.5, function()
		hs.grid.setGrid(gridSize)
		hs.grid.setMargins({self.gap, self.gap})
	end)
end

return obj
