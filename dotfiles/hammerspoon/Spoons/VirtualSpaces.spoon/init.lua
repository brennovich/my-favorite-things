local spoonPath = hs.spoons.scriptPath()
package.path = package.path .. ";" .. spoonPath .. "?.lua"

local WindowsSort = require("WindowsSort")
local WindowFocus = require("WindowFocus")

local obj = {}
obj.__index = obj

obj.name = "VirtualSpaces"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj._currentWorkspace = 1
obj._windowWorkspaceMap = {}
obj._activeSpace = nil
obj._storageSpace = nil

function obj:init()
	local screenSpaces = self._setupMissionControl()

	self._activeSpace = screenSpaces[1]
	self._storageSpace = screenSpaces[2]

	self._windowSorter = WindowsSort.new(
		hs.spaces.moveWindowToSpace,
		self._activeSpace,
		self._storageSpace
	)

	self._windowFocus = WindowFocus.new()

	self.windowFilter = hs.window.filter.new()

	-- This filter is unused but it seems to help address this bug:
	-- https://github.com/Hammerspoon/hammerspoon/issues/3276
	self.windowFilterOther = hs.window.filter.new()
	self.windowFilterOther:setCurrentSpace(true)

	self.windowFilter:subscribe(hs.window.filter.windowCreated, function(window)
		self:assignWindowToWorkspace(window, self._currentWorkspace)
	end)

	self.windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
		self:_removeWindow(window:id())
	end)

	self:_scanExistingWindows()

	return self
end

function obj:_isManageableWindow(win)
	return win:isStandard() and not win:isFullScreen()
end

function obj:switchToWorkspace(workspaceNum)
	if not workspaceNum or workspaceNum < 1 then
		return
	end

	local currentSpace = hs.spaces.activeSpaceOnScreen()

	if workspaceNum == self._currentWorkspace and currentSpace == self._activeSpace then
		return
	end

	local focusedWin = hs.window.focusedWindow()
	if focusedWin then
		self._windowFocus:saveFocusedWindowInVirtualSpace(self._currentWorkspace, focusedWin:id())
	end

	self._activeSpace, self._storageSpace = self._windowSorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(
		self._windowWorkspaceMap,
		workspaceNum,
		self._currentWorkspace,
		currentSpace
	)

	if hs.spaces.activeSpaceOnScreen() ~= self._activeSpace then
		hs.spaces.gotoSpace(self._activeSpace)
		hs.eventtap.keyStroke({}, "escape")
	end

	self._currentWorkspace = workspaceNum
	local windowId = self._windowFocus:getFocusedWindowForVirtualSpace(workspaceNum)
	if windowId then
		local win = hs.window.get(windowId)
		if win then
			win:focus()
		end
	end
end

function obj:moveWindowToWorkspace(window, workspaceNum)
	if not window or not workspaceNum or workspaceNum < 1 then return end

	local winId = window:id()
	self._windowWorkspaceMap[winId] = workspaceNum

	local targetSpace = (workspaceNum == self._currentWorkspace) and self._activeSpace or self._storageSpace
	hs.spaces.moveWindowToSpace(window, targetSpace)
end

function obj:_scanExistingWindows()
	for _, win in ipairs(hs.window.allWindows()) do
		if self:_isManageableWindow(win) then
			hs.spaces.moveWindowToSpace(win, self._activeSpace)
			self:assignWindowToWorkspace(win, 1)
		end
	end
end

function obj:assignWindowToWorkspace(window, workspaceNum)
	if not window or not self:_isManageableWindow(window) then return end

	local winId = window:id()
	self._windowWorkspaceMap[winId] = workspaceNum
end

function obj:_removeWindow(winId)
	self._windowWorkspaceMap[winId] = nil
end

function obj:_setupMissionControl()
	local mainScreen = hs.screen.mainScreen():getUUID()

	local allSpaces = hs.spaces.allSpaces()
	local screenSpaces = allSpaces[mainScreen]


	if hs.spaces.activeSpaceOnScreen() ~= screenSpaces[1] then
		hs.spaces.gotoSpace(screenSpaces[1])
		hs.eventtap.keyStroke({}, "escape")
		hs.timer.usleep(100000)
	end
	if #screenSpaces > 1 then
		for i = 2, #screenSpaces do
			hs.spaces.removeSpace(screenSpaces[i], false)
		end
	end

	allSpaces = hs.spaces.allSpaces()
	screenSpaces = allSpaces[mainScreen]
	if #screenSpaces < 2 then
		hs.spaces.addSpaceToScreen(mainScreen, true)
		allSpaces = hs.spaces.allSpaces()
		screenSpaces = allSpaces[mainScreen]
	end

	return screenSpaces
end

return obj
