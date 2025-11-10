local obj = {}
obj.__index = obj

obj.name = "WMUtils"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj.windowFrameCache = {}
obj.fullscreenFrameCache = {}
obj.gap = 15

obj.resizeStrokeColor = { red = 0.384, green = 0.388, blue = 0.631, alpha = 1 }
obj.resizeStrokeColorInner = { red = 0.53, green = 0.53, blue = 0.78, alpha = 0.6 }
obj.resizeStrokeWidth = 4.0
obj.resizeStrokeWidthInner = 1.0
obj.resizeBorderRadius = { xRadius = 9, yRadius = 9 }
obj.resizeBorderRadiusInner = { xRadius = 8, yRadius = 8 }

obj.resizeModal = nil
obj.resizeBorder = nil
obj.resizeWatcher = nil

local function createResizeBorder(self, win)
	if self.resizeBorder then
		self.resizeBorder:hide()
		self.resizeBorder:delete()
		self.resizeBorder = nil
	end

	if win then
		local screen = win:screen()
		local sf = screen:fullFrame()
		local wf = win:frame()

		self.resizeBorder = hs.canvas.new(sf)
		self.resizeBorder:appendElements({
			type = "rectangle",
			action = "stroke",
			strokeWidth = self.resizeStrokeWidth,
			strokeColor = self.resizeStrokeColor,
			roundedRectRadii = self.resizeBorderRadius,
			frame = {
				x = wf.x - sf.x - 1,
				y = wf.y - sf.y - 1,
				h = wf.h + 2,
				w = wf.w + 2
			}
		}, {
			type = "rectangle",
			action = "stroke",
			strokeWidth = self.resizeStrokeWidthInner,
			strokeColor = self.resizeStrokeColorInner,
			roundedRectRadii = self.resizeBorderRadiusInner,
			frame = {
				x = wf.x - sf.x + 1,
				y = wf.y - sf.y + 1,
				h = wf.h - 2,
				w = wf.w - 2
			}
		})
		self.resizeBorder:level("tornOffMenu")
		self.resizeBorder:show()
	end
end

local function updateResizeBorder(self, win)
	if self.resizeBorder and win then
		local screen = win:screen()
		local sf = screen:fullFrame()
		local wf = win:frame()
		self.resizeBorder[1].frame = {
			x = wf.x - sf.x - 1,
			y = wf.y - sf.y - 1,
			h = wf.h + 2,
			w = wf.w + 2
		}
		self.resizeBorder[2].frame = {
			x = wf.x - sf.x + 1,
			y = wf.y - sf.y + 1,
			h = wf.h - 2,
			w = wf.w - 2
		}
	end
end

local function moveWindow(self, dx, dy)
	local win = hs.window.focusedWindow()
	if not win then return end
	local f = win:frame()
	f.x = f.x + dx
	f.y = f.y + dy
	win:setFrame(f)
	updateResizeBorder(self, win)
end

local function resize(self, dw, dh)
	local win = hs.window.focusedWindow()
	if not win then return end
	local frame = win:frame()
	frame.w = frame.w + dw
	frame.h = frame.h + dh
	win:setFrame(frame)
	updateResizeBorder(self, win)
end

function obj:init()
	return self
end

function obj:moveLeft()
	moveWindow(self, -self.gap * 2, 0)
end

function obj:moveRight()
	moveWindow(self, self.gap * 2, 0)
end

function obj:moveUp()
	moveWindow(self, 0, -self.gap * 2)
end

function obj:moveDown()
	moveWindow(self, 0, self.gap * 2)
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

function obj:fullscreen()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()
	local currentFrame = win:frame()
	local screenFullFrame = win:screen():fullFrame()

	local isFullscreen = (currentFrame.x == screenFullFrame.x and
	                      currentFrame.y == screenFullFrame.y and
	                      currentFrame.w == screenFullFrame.w and
	                      currentFrame.h == screenFullFrame.h)

	if isFullscreen and self.fullscreenFrameCache[winId] then
		win:setFrame(self.fullscreenFrameCache[winId])
		self.fullscreenFrameCache[winId] = nil
		return
	end

	self.fullscreenFrameCache[winId] = currentFrame
	win:setFrame(screenFullFrame)
end

function obj:resizeWider()
	resize(self, self.gap * 2, 0)
end

function obj:resizeSlimmer()
	resize(self, -self.gap * 2, 0)
end

function obj:resizeTaller()
	resize(self, 0, self.gap * 2)
end

function obj:resizeShorter()
	resize(self, 0, -self.gap * 2)
end

function obj:setupResizeModal()
	self.resizeModal = hs.hotkey.modal.new()
	local spoon = self

	function self.resizeModal.entered()
		local win = hs.window.focusedWindow()
		if win then
			createResizeBorder(spoon, win)

			spoon.resizeWatcher = hs.window.filter.new(nil)
			spoon.resizeWatcher:subscribe(hs.window.filter.windowMoved, function(window, appName, event)
				if window == hs.window.focusedWindow() then
					updateResizeBorder(spoon, window)
				end
			end)
			spoon.resizeWatcher:subscribe(hs.window.filter.windowFocused, function(window, appName, event)
				createResizeBorder(spoon, window)
			end)
		end
	end

	function self.resizeModal.exited()
		if spoon.resizeWatcher then
			spoon.resizeWatcher:unsubscribeAll()
			spoon.resizeWatcher = nil
		end
		if spoon.resizeBorder then
			spoon.resizeBorder:hide()
			spoon.resizeBorder:delete()
			spoon.resizeBorder = nil
		end
	end

	return self.resizeModal
end

return obj
