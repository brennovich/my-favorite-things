local spoonPath = hs.spoons.scriptPath()
package.path = package.path .. ";" .. spoonPath .. "?.lua"

local WindowsSort = require("WindowsSort")
local SpacesModel = require("SpacesModel")
local NativeSpaceManager = require("NativeSpaceManager")

local obj = {}
obj.__index = obj

obj.name = "VirtualSpaces"
obj.version = "1.0"
obj.author = "brennovich"
obj.license = "MIT"

function obj:init()
	self.nativeSpaceManager = NativeSpaceManager.new()
	local activeSpace, storageSpace = self.nativeSpaceManager:setupForMainScreen()

	self._windowSorter = WindowsSort.new(
		hs.spaces.moveWindowToSpace,
		activeSpace,
		storageSpace
	)

	self.model = SpacesModel.new()
	self.windowFilter = hs.window.filter.new()

	-- This filter is unused but it seems to help address this bug:
	-- https://github.com/Hammerspoon/hammerspoon/issues/3276
	self.windowFilterOther = hs.window.filter.new()
	self.windowFilterOther:setCurrentSpace(true)

	self.windowFilter:subscribe(hs.window.filter.windowCreated, function(window)
		self:assignWindowToVirtualSpace(window, self.model:getCurrentVirtualSpace())
	end)
	self.windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
		self.model:removeWindow(window:id())
		self:_restoreWindowsFocusForVirtualSpace(self.model:getCurrentVirtualSpace())
	end)

	for _, win in ipairs(hs.window.allWindows()) do
		self:assignWindowToVirtualSpace(win, 1)
	end

	self.spaceWatcher = hs.spaces.watcher.new(function(spaceId)
		local actualSpace = hs.spaces.activeSpaceOnScreen()

		if actualSpace == self.nativeSpaceManager:getStorageSpace() then
			local focusedWindow = hs.window.focusedWindow()
			if not focusedWindow then
				return
			end

			local windowVirtualSpace = self.model:getVirtualSpaceForWindow(focusedWindow:id())

			if windowVirtualSpace and windowVirtualSpace ~= self.model:getCurrentVirtualSpace() then
				self:switchToVirtualSpace(windowVirtualSpace)
			end
		end
	end)
	self.spaceWatcher:start()

	return self
end

function obj:switchToVirtualSpace(virtualSpace)
	if not virtualSpace or virtualSpace < 1 then
		return
	end

	local currentSpace = hs.spaces.activeSpaceOnScreen()

	if virtualSpace == self.model:getCurrentVirtualSpace() and currentSpace == self.nativeSpaceManager:getActiveSpace() then
		return
	end

	local focusedWin = hs.window.focusedWindow()
	if focusedWin then
		self.model:saveFocusedWindowInVirtualSpace(self.model:getCurrentVirtualSpace(), focusedWin:id())
	end

	local categorizedWindows = self.model:categorizeWindowsForTransition(virtualSpace, self.model:getCurrentVirtualSpace())
	local activeSpace, storageSpace = self._windowSorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(
		categorizedWindows,
		currentSpace
	)
	self.nativeSpaceManager:updateSpaces(activeSpace, storageSpace)
	self.model:setCurrentVirtualSpace(virtualSpace)

	self:_restoreWindowsFocusForVirtualSpace(self.model:getCurrentVirtualSpace())
end

function obj:moveWindowToVirtualSpace(window, virtualSpace)
	if not window or not virtualSpace or virtualSpace < 1 then return end

	self:assignWindowToVirtualSpace(window, virtualSpace)

	local targetNativeSpace = (virtualSpace == self.model:getCurrentVirtualSpace())
		and self.nativeSpaceManager:getActiveSpace()
		or self.nativeSpaceManager:getStorageSpace()
	hs.spaces.moveWindowToSpace(window, targetNativeSpace)

	self:_restoreWindowsFocusForVirtualSpace(self.model:getCurrentVirtualSpace())
end

function obj:assignWindowToVirtualSpace(window, virtualSpace)
	if not self:_isValidWindowForVirtualSpace(window) then return end

	local winId = window:id()
	self.model:assignWindowToVirtualSpace(winId, virtualSpace)
	self.model:saveFocusedWindowInVirtualSpace(virtualSpace, winId)
end

function obj:_restoreWindowsFocusForVirtualSpace(virtualSpace)
	local windowId = self.model:getFocusedWindowForVirtualSpace(virtualSpace)
	if windowId and self.model:getVirtualSpaceForWindow(windowId) == virtualSpace then
		if self:_focusWindowById(windowId) then
			return
		end
	end

	-- Fallback: focus the first available window in the workspace
	local remainingWindows = self.model:getWindowsInVirtualSpace(self.model:getCurrentVirtualSpace())
	if #remainingWindows > 0 then
		if self:_focusWindowById(remainingWindows[1]) then
			self.model:saveFocusedWindowInVirtualSpace(virtualSpace, remainingWindows[1])
		end
	end
end

function obj:_isValidWindowForVirtualSpace(window)
	return window and window:isStandard() and not window:isFullScreen()
end

function obj:_focusWindowById(windowId)
	local win = hs.window.get(windowId)
	if win and win:isStandard() and not win:isMinimized() then
		win:focus()
		return true
	end
	return false
end

return obj
