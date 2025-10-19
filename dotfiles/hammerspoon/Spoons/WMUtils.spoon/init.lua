local obj = {}
obj.__index = obj

obj.name = "WMUtils"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj.windowFrameCache = {}
obj.gap = 15

function obj:init()
	return self
end

function obj:moveWindow(dx, dy)
	local win = hs.window.focusedWindow()
	if not win then return end
	local f = win:frame()
	f.x = f.x + dx
	f.y = f.y + dy
	win:setFrame(f)
end

function obj:centerWindow()
	local win = hs.window.focusedWindow()
	if not win then return end
	local f = win:frame()
	local ws = win:screen():frame()
	f.x = ws.x + (ws.w - f.w) / 2
	f.y = ws.y + (ws.h - f.h) / 2
	win:setFrame(f)
end

function obj:monocle()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()
	local currentCell = hs.grid.get(win)
	local gridSize = hs.grid.getGrid(win:screen())

	local isMaximized = (currentCell.x == 0 and
	                     currentCell.y == 0 and
	                     currentCell.w == gridSize.w and
	                     currentCell.h == gridSize.h)

	if isMaximized and self.windowFrameCache[winId] then
		win:setFrame(self.windowFrameCache[winId])
		self.windowFrameCache[winId] = nil
		return
	end

	self.windowFrameCache[winId] = win:frame()
	hs.grid.maximizeWindow(win)
end

return obj
