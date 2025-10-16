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

function leftHalfX(ws, f) return gap * 1.5 end
function rightHalfX(ws, f) return ws.w / 2 + gap * 0.5 end
function topHalfY(ws, f) return gap end
function bottomHalfY(ws, f) return ws.h / 2 + gap * 0.5 end
function fullWidthX(ws, f) return gap end
function fullWidthW(ws, f) return ws.w - gap * 2 end
function leftHalfW(ws, f) return ws.w / 2 - gap * 0.5 end
function rightHalfW(ws, f) return ws.w / 2 - gap * 2 end
function topHalfH(ws, f) return ws.h / 2 - gap end
function bottomHalfH(ws, f) return ws.h / 2 - gap * 2 end
function fullHeightH(ws, f) return ws.h - gap * 2 end
function centerX(ws, f) return (ws.w - f.w) / 2 end
function centerY(ws, f) return (ws.h - f.h) / 2 end
function keepWidth(ws, f) return f.w end
function keepHeight(ws, f) return f.h end
function shiftX(dx) return function(ws, f) return f.x - ws.x + dx end end
function shiftY(dy) return function(ws, f) return f.y - ws.y + dy end end

function placeWindow(xFn, yFn, wFn, hFn)
	return function()
		local win = hs.window.focusedWindow()
		if not win then return end
		local f = win:frame()
		local ws = win:screen():frame()

		f.x = ws.x + xFn(ws, f)
		f.y = ws.y + yFn(ws, f)
		f.w = wFn(ws, f)
		f.h = hFn(ws, f)
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

hs.hotkey.bind({"alt", "shift"}, "H", placeWindow(shiftX(-gap), shiftY(0), keepWidth, keepHeight))
hs.hotkey.bind({"alt", "shift"}, "L", placeWindow(shiftX(gap), shiftY(0), keepWidth, keepHeight))
hs.hotkey.bind({"alt", "shift"}, "K", placeWindow(shiftX(0), shiftY(-gap), keepWidth, keepHeight))
hs.hotkey.bind({"alt", "shift"}, "J", placeWindow(shiftX(0), shiftY(gap), keepWidth, keepHeight))

hs.hotkey.bind({"alt", "ctrl"}, "H", placeWindow(leftHalfX, topHalfY, leftHalfW, fullHeightH))
hs.hotkey.bind({"alt", "ctrl"}, "L", placeWindow(rightHalfX, topHalfY, rightHalfW, fullHeightH))
hs.hotkey.bind({"alt", "ctrl"}, "J", placeWindow(fullWidthX, bottomHalfY, fullWidthW, bottomHalfH))
hs.hotkey.bind({"alt", "ctrl"}, "K", placeWindow(fullWidthX, topHalfY, fullWidthW, topHalfH))

hs.hotkey.bind({"alt", "ctrl"}, "Space", placeWindow(centerX, centerY, keepWidth, keepHeight))


spoon.ReloadConfiguration:start()

hs.alert.show("Config loaded", alertStyle)
