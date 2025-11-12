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

hs.hotkey.bind({"leftalt", "ctrl", "cmd"}, "R", function()
    hs.reload()
end)

hs.hotkey.bind({"leftalt", "cmd"}, "Return", function()
    hs.execute("open -n -a Ghostty")
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

hs.hotkey.bind({"leftalt", "shift"}, "H", function() spoon.WMUtils:moveLeft() end)
hs.hotkey.bind({"leftalt", "shift"}, "L", function() spoon.WMUtils:moveRight() end)
hs.hotkey.bind({"leftalt", "shift"}, "K", function() spoon.WMUtils:moveUp() end)
hs.hotkey.bind({"leftalt", "shift"}, "J", function() spoon.WMUtils:moveDown() end)

hs.hotkey.bind({"leftalt", "ctrl"}, "Space", function() spoon.WMUtils:centerWindow() end)
hs.hotkey.bind({"leftalt", "ctrl"}, "M", function() spoon.WMUtils:monocle() end)
hs.hotkey.bind({"leftalt", "ctrl"}, "F", function() spoon.WMUtils:telescope() end)

resizeModal = spoon.WMUtils:setupResizeModal()

hs.hotkey.bind({"leftalt", "ctrl"}, "R", function() resizeModal:enter() end)

resizeModal:bind({}, "h", function() spoon.WMUtils:resizeSlimmer() end)
resizeModal:bind({}, "l", function() spoon.WMUtils:resizeWider() end)
resizeModal:bind({}, "k", function() spoon.WMUtils:resizeShorter() end)
resizeModal:bind({}, "j", function() spoon.WMUtils:resizeTaller() end)

resizeModal:bind({}, "escape", function() resizeModal:exit() end)

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

hs.hotkey.bind({"leftalt", "ctrl"}, "G", function() hs.grid.toggleShow() end)

hs.hotkey.bind({"leftalt", "ctrl"}, "H", function()
    spoon.WMUtils:leftHalf()
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "L", function()
    spoon.WMUtils:rightHalf()
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "J", function()
    spoon.WMUtils:bottomHalf()
end)
hs.hotkey.bind({"leftalt", "ctrl"}, "K", function()
    spoon.WMUtils:topHalf()
end)
