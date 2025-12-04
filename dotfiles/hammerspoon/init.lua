hs.loadSpoon("WMUtils")
hs.loadSpoon("ToggleMenubar")
hs.loadSpoon("RoundedCorners")
hs.loadSpoon("VirtualSpaces")

if hs.console.darkMode(true) then
    hs.console.windowBackgroundColor({ red = 0.1, green = 0.1, blue = 0.12, alpha = 1 })
    hs.console.outputBackgroundColor({ red = 0.1, green = 0.1, blue = 0.12, alpha = 1 })
    hs.console.inputBackgroundColor({ red = 0.15, green = 0.15, blue = 0.17, alpha = 1 })

    hs.console.consoleCommandColor({ red = 0.4, green = 0.8, blue = 0.9, alpha = 1 })
    hs.console.consolePrintColor({ red = 0.85, green = 0.85, blue = 0.85, alpha = 1 })
    hs.console.consoleResultColor({ red = 0.95, green = 0.7, blue = 0.4, alpha = 1 })
    hs.console.alpha(.96)
end

alertStyle = {
	radius = 10,
	strokeWidth = 4,
	strokeColor = { white = 1, alpha = 0.3 },
	textFont  = ".AppleSystemUIFont",
	textColor = { white = 1, alpha = 0.9 },
	fadeInDuration = 0,
	fadeOutDuration = 0,
}

gap = 20

spoon.ToggleMenubar.gap = gap
spoon.WMUtils.gap = gap
spoon.RoundedCorners.radius = 9

hs.grid.ui.showExtraKeys = false

hs.grid.setGrid('6x6')
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
    hs.execute("kitty @ launch")
end)

for i = 1, 4 do
    hs.hotkey.bind({"leftalt"}, tostring(i), function()
	spoon.VirtualSpaces:switchToVirtualSpace(i)
    end)

    hs.hotkey.bind({"leftalt", "shift"}, tostring(i), function()
	spoon.VirtualSpaces:moveWindowToVirtualSpace(nil, i)
    end)
end

spoon.WMUtils:bindHotkeys(spoon.WMUtils.defaultHotkeys)

resizeModal = spoon.WMUtils:setupResizeModal()

hs.hotkey.bind({"leftalt", "ctrl"}, "R", function() resizeModal:enter() end)

spoon.WMUtils:bindResizeHotkeys(spoon.WMUtils.defaultResizeHotkeys)

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
