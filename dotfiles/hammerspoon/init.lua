hs.loadSpoon("WMUtils")
hs.loadSpoon("ToggleMenubar")
hs.loadSpoon("RoundedCorners")
hs.loadSpoon("VirtualSpaces")

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
spoon.WMUtils.gap = gap
spoon.RoundedCorners.radius = 9

hs.grid.ui.showExtraKeys = false

hs.grid.setGrid('2x2')
hs.grid.setMargins({gap, gap})

hs.window.animationDuration = 0

spoon.RoundedCorners:start()

hs.hotkey.bind({"ctrl", "leftalt", "cmd"}, "D", function()
    spoon.ToggleMenubar:toggle()
end)

for i = 1, 4 do
    hs.hotkey.bind({"leftalt"}, tostring(i), function()
	spoon.VirtualSpaces:switchToVirtualSpace(i)
    end)

    hs.hotkey.bind({"leftalt", "shift"}, tostring(i), function()
	local win = hs.window.focusedWindow()
	if win then
	    spoon.VirtualSpaces:moveWindowToVirtualSpace(win, i)
	end
    end)
end

hs.hotkey.bind({"leftalt", "shift"}, "H", function()
    spoon.WMUtils:moveWindow(-spoon.WMUtils.gap*2, 0)
end)
hs.hotkey.bind({"leftalt", "shift"}, "L", function()
    spoon.WMUtils:moveWindow(spoon.WMUtils.gap*2, 0)
end)
hs.hotkey.bind({"leftalt", "shift"}, "K", function()
    spoon.WMUtils:moveWindow(0, -spoon.WMUtils.gap*2)
end)
hs.hotkey.bind({"leftalt", "shift"}, "J", function()
    spoon.WMUtils:moveWindow(0, spoon.WMUtils.gap*2)
end)

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
