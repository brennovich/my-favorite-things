hs.loadSpoon("ReloadConfiguration")
hs.loadSpoon("AClock")
hs.loadSpoon("WMUtils")
hs.loadSpoon("ToggleMenubar")

alertStyle = {
	radius = 10,
	strokeWidth = 4,
	strokeColor = { white = 1, alpha = 0.3 },
	textFont  = ".AppleSystemUIFont",
	textColor = { white = 1, alpha = 0.9 },
	fadeInDuration = 0,
	fadeOutDuration = 0,
}

gap = 15

spoon.ToggleMenubar.gap = gap

hs.grid.ui.showExtraKeys = false

hs.grid.setGrid('2x2')
hs.grid.setMargins({gap, gap})

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

spoon.ReloadConfiguration:start()

hs.hotkey.bind({"ctrl", "leftalt", "cmd"}, "D", function()
    spoon.ToggleMenubar:toggle()
end)

hs.hotkey.bind({"cmd", "leftalt", "ctrl"}, "C", function()
    spoon.AClock:toggleShow()
end)

hs.hotkey.bind({"leftalt"}, "4", function()
    hs.application.open("Safari")
end)

hs.hotkey.bind({"leftalt", "shift"}, "H", moveWindow(-gap*2, 0))
hs.hotkey.bind({"leftalt", "shift"}, "L", moveWindow(gap*2, 0))
hs.hotkey.bind({"leftalt", "shift"}, "K", moveWindow(0, -gap*2))
hs.hotkey.bind({"leftalt", "shift"}, "J", moveWindow(0, gap*2))

hs.hotkey.bind({"leftalt"}, "H", function()
    hs.window.focusedWindow():focusWindowWest()
end)
hs.hotkey.bind({"leftalt"}, "L", function()
    hs.window.focusedWindow():focusWindowEast()
end)
hs.hotkey.bind({"leftalt"}, "K", function()
    hs.window.focusedWindow():focusWindowNorth()
end)
hs.hotkey.bind({"leftalt"}, "J", function()
    hs.window.focusedWindow():focusWindowSouth()
end)

hs.hotkey.bind({"leftalt", "ctrl"}, "H", function()
    hs.grid.set(hs.window.focusedWindow(), {0, 0, 1, 2})
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "L", function()
    hs.grid.set(hs.window.focusedWindow(), {1, 0, 1, 2})
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "J", function()
    hs.grid.set(hs.window.focusedWindow(), {0, 1, 2, 1})
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "K", function()
    hs.grid.set(hs.window.focusedWindow(), {0, 0, 2, 1})
end)

hs.hotkey.bind({"leftalt", "ctrl"}, "Space", function()
    spoon.WMUtils:centerWindow()
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "G", function()
    hs.grid.toggleShow()
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "M", function()
    spoon.WMUtils:monocle()
end)

hs.alert.show("Config loaded", alertStyle)
