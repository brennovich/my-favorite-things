local spoonPath = hs.spoons.scriptPath()
package.path = package.path .. ";" .. spoonPath .. "?.lua"

local WindowsSort = require("WindowsSort")
local SpacesModel = require("SpacesModel")

local obj = {}
obj.__index = obj

obj.name = "VirtualSpaces"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj._currentWorkspace = 1
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
	self.windowFocusMemory = SpacesModel.new()
	self.windowFilter = hs.window.filter.new()

	-- This filter is unused but it seems to help address this bug:
	-- https://github.com/Hammerspoon/hammerspoon/issues/3276
	self.windowFilterOther = hs.window.filter.new()
	self.windowFilterOther:setCurrentSpace(true)

	self.windowFilter:subscribe(hs.window.filter.windowCreated, function(window)
		self:assignWindowToWorkspace(window, self._currentWorkspace)
	end)
	self.windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
		self.windowFocusMemory:removeWindow(window:id())
	end)

	for _, win in ipairs(hs.window.allWindows()) do
		self:assignWindowToWorkspace(win, 1)
	end

	return self
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
		self.windowFocusMemory:saveFocusedWindowInVirtualSpace(self._currentWorkspace, focusedWin:id())
	end

	self._activeSpace, self._storageSpace = self._windowSorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(
		self.windowFocusMemory:getAllWindowMappings(),
		workspaceNum,
		self._currentWorkspace,
		currentSpace
	)

	self._currentWorkspace = workspaceNum
	obj:_restoreWindowsFocusForVirtualSpace(self._currentWorkspace)
end

function obj:_restoreWindowsFocusForVirtualSpace(virtualSpaceId)
	local windowId = self.windowFocusMemory:getFocusedWindowForVirtualSpace(virtualSpaceId)
	if windowId and self.windowFocusMemory:getVirtualSpaceForWindow(windowId) == virtualSpaceId then
		local win = hs.window.get(windowId)
		if win then
			win:focus()
		end
		return
	end

	-- Fallback: focus the first available window in the workspace
	local remainingWindows = self.windowFocusMemory:getWindowsInVirtualSpace(self._currentWorkspace)
	if #remainingWindows > 0 then
		local firstWinId = remainingWindows[1]
		local win = hs.window.get(firstWinId)
		if win then
			win:focus()
		end
		self.windowFocusMemory:saveFocusedWindowInVirtualSpace(virtualSpaceId, firstWinId)
	end
end

function obj:moveWindowToWorkspace(window, workspaceNum)
	if not window or not workspaceNum or workspaceNum < 1 then return end

	self:assignWindowToWorkspace(window, workspaceNum)

	local targetNativeSpace = (workspaceNum == self._currentWorkspace) and self._activeSpace or self._storageSpace
	hs.spaces.moveWindowToSpace(window, targetNativeSpace)

	obj:_restoreWindowsFocusForVirtualSpace(self._currentWorkspace)
end

function obj:assignWindowToWorkspace(window, workspaceNum)
	if not window or not (window:isStandard() and not window:isFullScreen()) then return end

	local winId = window:id()
	self.windowFocusMemory:assignWindowToVirtualSpace(winId, workspaceNum)
	self.windowFocusMemory:saveFocusedWindowInVirtualSpace(workspaceNum, winId)
end

-- _setupMissionControl prepares the Native Spaces for our Virtual Spaces.
--
-- Setups Mission Control with two spaces: one active and one storage.
-- Info: It doesn't support multiple monitors yet
function obj:_setupMissionControl()
	-- By default Hammerspoon has this delay set to 0.3
	-- https://www.hammerspoon.org/docs/hs.spaces.html#MCwaitTime
	hs.spaces.setDefaultMCwaitTime(0.5)

	-- Get current spaces setup for main screen
	local mainScreen = hs.screen.mainScreen():getUUID()
	local allSpaces = hs.spaces.allSpaces()
	local screenSpaces = allSpaces[mainScreen]

	-- Ensure we are in the first space in case we had loaded
	-- Hammerspoon in a different space other than the first one.
	-- This avoids issues when removing spaces as we can't remove
	-- the space we are in.
	if hs.spaces.activeSpaceOnScreen() ~= screenSpaces[1] then
		hs.spaces.gotoSpace(screenSpaces[1])
		-- Dismiss Mission Control if it was opened during space
		-- manipulations. Hammerspoon spaces manipulation uses
		-- accessibility controls that depends on activating Mission
		-- Control UI
		hs.eventtap.keyStroke({}, "escape")
	end

	-- Let's clear all spaces, this ensures all windows are moved to the
	-- first native space.
	if #screenSpaces > 1 then
		for i = 2, #screenSpaces do
			hs.timer.usleep(100000)
			hs.spaces.removeSpace(screenSpaces[i], false)
		end
	end

	-- Now we create the native space that will serve as storage.
	hs.timer.usleep(10000)
	hs.spaces.addSpaceToScreen(mainScreen, true)

	-- Return refreshed spaces info.
	return hs.spaces.allSpaces()[mainScreen]
end

return obj
