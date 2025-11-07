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

resizeBorder = nil
resizeWatcher = nil

local function createResizeBorder(win)
	if resizeBorder then
		resizeBorder:hide()
		resizeBorder:delete()
		resizeBorder = nil
	end

	if win then
		local screen = win:screen()
		local sf = screen:fullFrame()
		local wf = win:frame()

		resizeBorder = hs.canvas.new(sf)
		resizeBorder:appendElements({
			type = "rectangle",
			action = "stroke",
			strokeWidth = 4.0,
			strokeColor = { red = 0.384, green = 0.388, blue = 0.631, alpha = 1 },
			roundedRectRadii = { xRadius = 9, yRadius = 9 },
			frame = {
				x = wf.x - sf.x - 1,
				y = wf.y - sf.y - 1,
				h = wf.h + 2,
				w = wf.w + 2
			}
		}, { type = "rectangle",
			action = "stroke",
			strokeWidth = 1.0,
			strokeColor = { red = 0.53, green = 0.53, blue = 0.78, alpha = 0.6 },
			roundedRectRadii = { xRadius = 8, yRadius = 8 },
			frame = {
				x = wf.x - sf.x + 1,
				y = wf.y - sf.y + 1,
				h = wf.h - 2,
				w = wf.w - 2
			}
		})
		resizeBorder:level("tornOffMenu")
		resizeBorder:show()
	end
end

local function updateResizeBorder(win)
	if resizeBorder and win then
		local screen = win:screen()
		local sf = screen:fullFrame()
		local wf = win:frame()
		resizeBorder[1].frame = {
			x = wf.x - sf.x - 1,
			y = wf.y - sf.y - 1,
			h = wf.h + 2,
			w = wf.w + 2
		}
		resizeBorder[2].frame = {
			x = wf.x - sf.x + 1,
			y = wf.y - sf.y + 1,
			h = wf.h - 2,
			w = wf.w - 2
		}
	end
end

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

resizeModal = hs.hotkey.modal.new()

function resizeModal:entered()
	local win = hs.window.focusedWindow()
	if win then
		createResizeBorder(win)

		resizeWatcher = hs.window.filter.new(nil)
		resizeWatcher:subscribe(hs.window.filter.windowMoved, function(window, appName, event)
			if window == hs.window.focusedWindow() then
				updateResizeBorder(window)
			end
		end)
		resizeWatcher:subscribe(hs.window.filter.windowFocused, function(window, appName, event)
			createResizeBorder(window)
		end)
	end
end

function resizeModal:exited()
	if resizeWatcher then
		resizeWatcher:unsubscribeAll()
		resizeWatcher = nil
	end
	if resizeBorder then
		resizeBorder:hide()
		resizeBorder:delete()
		resizeBorder = nil
	end
end

resizeModal:bind({}, "escape", function()
	resizeModal:exit()
end)

resizeModal:bind({}, "h", function()
	local win = hs.window.focusedWindow()
	if win then
		local frame = win:frame()
		frame.w = frame.w - gap * 2
		win:setFrame(frame)
		updateResizeBorder(win)
	end
end)

resizeModal:bind({}, "l", function()
	local win = hs.window.focusedWindow()
	if win then
		local frame = win:frame()
		frame.w = frame.w + gap * 2
		win:setFrame(frame)
		updateResizeBorder(win)
	end
end)

resizeModal:bind({}, "k", function()
	local win = hs.window.focusedWindow()
	if win then
		local frame = win:frame()
		frame.h = frame.h - gap * 2
		win:setFrame(frame)
		updateResizeBorder(win)
	end
end)

resizeModal:bind({}, "j", function()
	local win = hs.window.focusedWindow()
	if win then
		local frame = win:frame()
		frame.h = frame.h + gap * 2
		win:setFrame(frame)
		updateResizeBorder(win)
	end
end)

hs.hotkey.bind({"leftalt", "ctrl"}, "R", function()
	resizeModal:enter()
end)
