local obj = {}
obj.__index = obj

obj.name = "WMUtils"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj.monocleFrameCache = {}
obj.telescopeFrameCache = {}
obj.gridFrameCache = {}
obj.tileFrameCache = {}
obj.gap = 15
obj.mainRatio = 0.6

obj.resizeStrokeColor = { red = 0.384, green = 0.388, blue = 0.631, alpha = 1 }
obj.resizeStrokeColorInner = { red = 0.53, green = 0.53, blue = 0.78, alpha = 0.6 }
obj.resizeStrokeWidth = 4.0
obj.resizeStrokeWidthInner = 1.0
obj.resizeBorderRadius = { xRadius = 9, yRadius = 9 }
obj.resizeBorderRadiusInner = { xRadius = 8, yRadius = 8 }

obj.resizeModal = nil
obj.resizeBorder = nil
obj.resizeWatcher = nil

obj.defaultHotkeys = {
	moveLeft = {{"leftalt", "shift"}, "h"},
	moveRight = {{"leftalt", "shift"}, "l"},
	moveUp = {{"leftalt", "shift"}, "k"},
	moveDown = {{"leftalt", "shift"}, "j"},
	leftHalf = {{"leftalt", "ctrl"}, "h"},
	rightHalf = {{"leftalt", "ctrl"}, "l"},
	topHalf = {{"leftalt", "ctrl"}, "k"},
	bottomHalf = {{"leftalt", "ctrl"}, "j"},
	centerWindow = {{"leftalt", "ctrl"}, "space"},
	monocle = {{"leftalt", "ctrl"}, "m"},
	telescope = {{"leftalt", "ctrl"}, "f"},
	tile = {{"leftalt", "ctrl"}, "t"}
}

obj.defaultResizeHotkeys = {
	resizeSlimmer = {{}, "h"},
	resizeWider = {{}, "l"},
	resizeShorter = {{}, "k"},
	resizeTaller = {{}, "j"},
	resizeThinnerByGrid = {{"shift"}, "h"},
	resizeWiderByGrid = {{"shift"}, "l"},
	resizeShorterByGrid = {{"shift"}, "k"},
	resizeTallerByGrid = {{"shift"}, "j"}
}

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

local function getTileableWindows(self)
	local focusedWin = hs.window.focusedWindow()
	if not focusedWin then return {}, nil end

	local screen = focusedWin:screen()
	local windows = {}

	if spoon and spoon.VirtualSpaces and spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace then
		local allWindows = spoon.VirtualSpaces:getWindowsForCurrentVirtualSpace()
		for _, win in ipairs(allWindows) do
			if win:screen() == screen then
				table.insert(windows, win)
			end
		end
	else
		for _, win in ipairs(hs.window.orderedWindows()) do
			if win:screen() == screen and win:isStandard() and not win:isFullScreen() then
				table.insert(windows, win)
			end
		end
	end

	return windows, focusedWin
end

local function calculateTileFrames(self, screen, windowCount)
	local screenFrame = screen:frame()
	local gap = self.gap

	local usableArea = {
		x = screenFrame.x + gap,
		y = screenFrame.y + gap,
		w = screenFrame.w - (gap * 2),
		h = screenFrame.h - (gap * 2)
	}

	if windowCount == 1 then
		return {{
			x = usableArea.x,
			y = usableArea.y,
			w = usableArea.w,
			h = usableArea.h
		}}
	end

	local mainW = usableArea.w * self.mainRatio
	local stackW = usableArea.w * (1 - self.mainRatio) - gap
	local stackCount = windowCount - 1
	local stackH = usableArea.h / stackCount

	local frames = {}

	table.insert(frames, {
		x = usableArea.x,
		y = usableArea.y,
		w = mainW,
		h = usableArea.h
	})

	for i = 0, stackCount - 1 do
		table.insert(frames, {
			x = usableArea.x + mainW + gap,
			y = usableArea.y + (i * stackH) + (i > 0 and gap or 0),
			w = stackW,
			h = stackH - (i > 0 and gap or 0)
		})
	end

	return frames
end

local function sortWindowsForTiling(windows, focusedWin)
	local sorted = {}

	if focusedWin then
		table.insert(sorted, focusedWin)
	end

	for _, win in ipairs(windows) do
		if not focusedWin or win:id() ~= focusedWin:id() then
			table.insert(sorted, win)
		end
	end

	return sorted
end

local function frameEquals(f1, f2, tolerance)
	tolerance = tolerance or 1
	return math.abs(f1.x - f2.x) < tolerance and
	       math.abs(f1.y - f2.y) < tolerance and
	       math.abs(f1.w - f2.w) < tolerance and
	       math.abs(f1.h - f2.h) < tolerance
end

function obj:init()
	return self
end

function obj:updateResizeBorder(win)
	updateResizeBorder(self, win)
end

local function gridCellEquals(cell1, cell2)
	return cell1.x == cell2.x and
	       cell1.y == cell2.y and
	       cell1.w == cell2.w and
	       cell1.h == cell2.h
end

function obj:leftHalf()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()
	local currentCell = hs.grid.get(win)
	local gridSize = hs.grid.getGrid(win:screen())
	local targetCell = {x = 0, y = 0, w = gridSize.w / 2, h = gridSize.h}

	if gridCellEquals(currentCell, targetCell) and self.gridFrameCache[winId] then
		win:setFrame(self.gridFrameCache[winId])
		self.gridFrameCache[winId] = nil
		self:updateResizeBorder(win)
		return
	end

	self.gridFrameCache[winId] = win:frame()
	hs.grid.set(win, targetCell, win:screen())
	self:updateResizeBorder(win)
end

function obj:rightHalf()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()
	local currentCell = hs.grid.get(win)
	local gridSize = hs.grid.getGrid(win:screen())
	local targetCell = {x = gridSize.w / 2, y = 0, w = gridSize.w / 2, h = gridSize.h}

	if gridCellEquals(currentCell, targetCell) and self.gridFrameCache[winId] then
		win:setFrame(self.gridFrameCache[winId])
		self.gridFrameCache[winId] = nil
		self:updateResizeBorder(win)
		return
	end

	self.gridFrameCache[winId] = win:frame()
	hs.grid.set(win, targetCell, win:screen())
	self:updateResizeBorder(win)
end

function obj:topHalf()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()
	local currentCell = hs.grid.get(win)
	local gridSize = hs.grid.getGrid(win:screen())
	local targetCell = {x = 0, y = 0, w = gridSize.w, h = gridSize.h / 2}

	if gridCellEquals(currentCell, targetCell) and self.gridFrameCache[winId] then
		win:setFrame(self.gridFrameCache[winId])
		self.gridFrameCache[winId] = nil
		self:updateResizeBorder(win)
		return
	end

	self.gridFrameCache[winId] = win:frame()
	hs.grid.set(win, targetCell, win:screen())
	self:updateResizeBorder(win)
end

function obj:bottomHalf()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()
	local currentCell = hs.grid.get(win)
	local gridSize = hs.grid.getGrid(win:screen())
	local targetCell = {x = 0, y = gridSize.h / 2, w = gridSize.w, h = gridSize.h / 2}

	if gridCellEquals(currentCell, targetCell) and self.gridFrameCache[winId] then
		win:setFrame(self.gridFrameCache[winId])
		self.gridFrameCache[winId] = nil
		self:updateResizeBorder(win)
		return
	end

	self.gridFrameCache[winId] = win:frame()
	hs.grid.set(win, targetCell, win:screen())
	self:updateResizeBorder(win)
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
	win:centerOnScreen()
	updateResizeBorder(self, win)
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

	if isMaximized and self.monocleFrameCache[winId] then
		win:setFrame(self.monocleFrameCache[winId])
		self.monocleFrameCache[winId] = nil
		updateResizeBorder(self, win)
		return
	end

	self.monocleFrameCache[winId] = win:frame()
	hs.grid.maximizeWindow(win)
	updateResizeBorder(self, win)
end

function obj:telescope()
	local win = hs.window.focusedWindow()
	if not win then return end

	local winId = win:id()

	if win:isFullScreen() then
		self.telescopeFrameCache[winId] = nil
		return
	end

	local currentFrame = win:frame()
	local screenFullFrame = win:screen():fullFrame()

	local heightTolerance = 30
	local isMaximized = (currentFrame.x == screenFullFrame.x and
	                     currentFrame.y == screenFullFrame.y and
	                     currentFrame.w >= screenFullFrame.w and
	                     currentFrame.h >= screenFullFrame.h - heightTolerance)

	if isMaximized and self.telescopeFrameCache[winId] then
		win:setFrame(self.telescopeFrameCache[winId])
		self.telescopeFrameCache[winId] = nil
		updateResizeBorder(self, win)
		return
	end

	self.telescopeFrameCache[winId] = currentFrame
	win:maximize()
	updateResizeBorder(self, win)
end

function obj:tile()
	local windows, focusedWin = getTileableWindows(self)
	if #windows == 0 then return end

	local screen = focusedWin and focusedWin:screen() or windows[1]:screen()

	if self:_isCurrentlyTiled(windows, screen) then
		for _, win in ipairs(windows) do
			local cached = self.tileFrameCache[win:id()]
			if cached then
				win:setFrame(cached)
			end
		end
		self:updateResizeBorder(focusedWin)
		return
	end

	for _, win in ipairs(windows) do
		if not self.tileFrameCache[win:id()] then
			self.tileFrameCache[win:id()] = win:frame()
		end
	end

	local sortedWindows = sortWindowsForTiling(windows, focusedWin)
	local frames = calculateTileFrames(self, screen, #sortedWindows)
	for i, win in ipairs(sortedWindows) do
		win:setFrame(frames[i])
	end

	self:updateResizeBorder(focusedWin)
end

function obj:_isCurrentlyTiled(windows, screen)
	local focusedWin = hs.window.focusedWindow()
	local sortedWindows = sortWindowsForTiling(windows, focusedWin)
	local frames = calculateTileFrames(self, screen, #sortedWindows)

	for i, win in ipairs(sortedWindows) do
		if not frameEquals(win:frame(), frames[i], 2) then
			return false
		end
	end

	return true
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

function obj:resizeWiderByGrid()
	local win = hs.window.focusedWindow()
	if not win then return end
	hs.grid.resizeWindowWider(win)
	updateResizeBorder(self, win)
end

function obj:resizeThinnerByGrid()
	local win = hs.window.focusedWindow()
	if not win then return end
	hs.grid.resizeWindowThinner(win)
	updateResizeBorder(self, win)
end

function obj:resizeTallerByGrid()
	local win = hs.window.focusedWindow()
	if not win then return end
	hs.grid.resizeWindowTaller(win)
	updateResizeBorder(self, win)
end

function obj:resizeShorterByGrid()
	local win = hs.window.focusedWindow()
	if not win then return end
	hs.grid.resizeWindowShorter(win)
	updateResizeBorder(self, win)
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

function obj:bindHotkeys(mapping)
	local repeatableActions = {
		moveLeft = true,
		moveRight = true,
		moveUp = true,
		moveDown = true,
		resizeWider = true,
		resizeSlimmer = true,
		resizeTaller = true,
		resizeShorter = true
	}

	for action, hotkey in pairs(mapping) do
		local mods = hotkey[1]
		local key = hotkey[2]
		local fn = function() self[action](self) end

		if repeatableActions[action] then
			hs.hotkey.bind(mods, key, fn, nil, fn)
		else
			hs.hotkey.bind(mods, key, fn)
		end
	end

	return self
end

function obj:bindResizeHotkeys(mapping)
	if not self.resizeModal then
		error("resizeModal not initialized. Call setupResizeModal() first.")
	end

	local repeatableActions = {
		resizeWider = true,
		resizeSlimmer = true,
		resizeTaller = true,
		resizeShorter = true,
		resizeWiderByGrid = true,
		resizeThinnerByGrid = true,
		resizeTallerByGrid = true,
		resizeShorterByGrid = true
	}

	for action, hotkey in pairs(mapping) do
		local mods = hotkey[1]
		local key = hotkey[2]
		local fn = function() self[action](self) end

		if repeatableActions[action] then
			self.resizeModal:bind(mods, key, fn, nil, fn)
		else
			self.resizeModal:bind(mods, key, fn)
		end
	end

	return self
end

return obj
