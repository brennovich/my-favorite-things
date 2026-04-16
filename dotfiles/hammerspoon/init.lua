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

hyper = hs.hotkey.modal.new()
hs.hotkey.bind({}, "f18", function() hyper:enter() end, function() hyper:exit() end)

hyper:bind({"ctrl", "cmd"}, "D", function()
    spoon.ToggleMenubar:toggle()
end)

hyper:bind({"ctrl", "cmd"}, "R", function()
    hs.reload()
end)

hyper:bind({"cmd"}, "Return", function()
    hs.execute("kitty @ launch")
end)

for i = 1, 4 do
    hyper:bind({}, tostring(i), function()
	spoon.VirtualSpaces:switchToVirtualSpace(i)
    end)

    hyper:bind({"shift"}, tostring(i), function()
	spoon.VirtualSpaces:moveWindowToVirtualSpace(nil, i)
    end)
end

spoon.WMUtils:bindHotkeys(spoon.WMUtils.defaultHotkeys, hyper)

resizeModal = spoon.WMUtils:setupResizeModal()

hyper:bind({"ctrl"}, "R", function() resizeModal:enter() end)

spoon.WMUtils:bindResizeHotkeys(spoon.WMUtils.defaultResizeHotkeys)

resizeModal:bind({}, "escape", function() resizeModal:exit() end)

hyper:bind({}, "H", function()
    hs.window.focusedWindow():focusWindowWest()
end)
hyper:bind({}, "L", function()
    hs.window.focusedWindow():focusWindowEast()
end)
hyper:bind({}, "K", function()
    hs.window.focusedWindow():focusWindowNorth()
end)
hyper:bind({}, "J", function()
    hs.window.focusedWindow():focusWindowSouth()
end)

hyper:bind({"ctrl"}, "G", function() hs.grid.toggleShow() end)
