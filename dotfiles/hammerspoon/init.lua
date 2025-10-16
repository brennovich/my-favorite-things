hs.loadSpoon("ReloadConfiguration")
hs.loadSpoon("AClock")

alertStyle = {
	radius = 10,
	strokeWidth = 4,
	strokeColor = { white = 1, alpha = 0.3 },
	textFont  = ".AppleSystemUIFont",
	textColor = { white = 1, alpha = 0.9 },
	fadeInDuration = 0,
	fadeOutDuration = 0,
}

gap = 10

hs.grid.ui.showExtraKeys = false

hs.grid.setGrid('2x2')
hs.grid.setMargins({gap, gap})

function centerWindow()
	local win = hs.window.focusedWindow()
	if not win then return end
	local f = win:frame()
	local ws = win:screen():frame()
	f.x = ws.x + (ws.w - f.w) / 2
	f.y = ws.y + (ws.h - f.h) / 2
	win:setFrame(f)
end

function moveWindow(dx, dy)
	return function()
		local win = hs.window.focusedWindow()
		if not win then return end
		local f = win:frame()
		f.x = f.x + dx
		f.y = f.y + dy
		win:setFrame(f)
	end
end

hs.window.animationDuration = 0
hs.hotkey.bind({"alt"}, "4", function()
    hs.application.open("Safari")
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "D", function()
    local output = hs.execute("defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo 0")
    local menubarHidden = tonumber(output:match("%d+")) == 1

    hs.osascript.applescript(string.format([[
        tell application "System Events"
	    tell dock preferences to set autohide menu bar to %s
	end tell
    ]], tostring(not menubarHidden)))
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
  spoon.AClock:toggleShow()
end)

hs.hotkey.bind({"alt", "shift"}, "H", moveWindow(-gap, 0))
hs.hotkey.bind({"alt", "shift"}, "L", moveWindow(gap, 0))
hs.hotkey.bind({"alt", "shift"}, "K", moveWindow(0, -gap))
hs.hotkey.bind({"alt", "shift"}, "J", moveWindow(0, gap))

hs.hotkey.bind({"alt"}, "H", function() hs.window.focusedWindow():focusWindowWest() end)
hs.hotkey.bind({"alt"}, "L", function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind({"alt"}, "K", function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind({"alt"}, "J", function() hs.window.focusedWindow():focusWindowSouth() end)

hs.hotkey.bind({"alt", "ctrl"}, "H", function() hs.grid.set(hs.window.focusedWindow(), {0, 0, 1, 2}) end)
hs.hotkey.bind({"alt", "ctrl"}, "L", function() hs.grid.set(hs.window.focusedWindow(), {1, 0, 1, 2}) end)
hs.hotkey.bind({"alt", "ctrl"}, "J", function() hs.grid.set(hs.window.focusedWindow(), {0, 1, 2, 1}) end)
hs.hotkey.bind({"alt", "ctrl"}, "K", function() hs.grid.set(hs.window.focusedWindow(), {0, 0, 2, 1}) end)

hs.hotkey.bind({"alt", "ctrl"}, "Space", centerWindow)

hs.hotkey.bind({"alt", "ctrl"}, "G", function()
    hs.grid.toggleShow()
end)

spoon.ReloadConfiguration:start()

hs.alert.show("Config loaded", alertStyle)
