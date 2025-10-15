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

hs.hotkey.bind({"alt", "ctrl"}, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + gap * 1.5
  f.y = max.y + gap
  f.w = max.w / 2 - gap * 0.5
  f.h = max.h - gap * 2
  win:setFrame(f)
end)

hs.hotkey.bind({"alt", "ctrl"}, "L", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + max.w / 2 + gap * 0.5
  f.y = max.y + gap
  f.w = max.w / 2 - gap * 1.5
  f.h = max.h - gap * 2
  win:setFrame(f)
end)

hs.hotkey.bind({"alt", "ctrl"}, "Space", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w - f.w) / 2
  f.y = max.y + (max.h - f.h) / 2
  win:setFrame(f)
end)

spoon.ReloadConfiguration:start()

hs.alert.show("Config loaded", alertStyle)
