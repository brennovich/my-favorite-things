local SpacesModel = {}
SpacesModel.__index = SpacesModel

function SpacesModel.new()
	local self = setmetatable({}, SpacesModel)
	self._focusedWindows = {}
	self._windowVirtualSpaceMap = {}
	self._virtualSpaceWindowsMap = {}
	self._currentVirtualSpace = 1
	return self
end

function SpacesModel:saveFocusedWindowInVirtualSpace(virtualSpace, windowId)
	self._focusedWindows[virtualSpace] = windowId
end

function SpacesModel:getFocusedWindowForVirtualSpace(virtualSpace)
	return self._focusedWindows[virtualSpace]
end

function SpacesModel:assignWindowToVirtualSpace(windowId, virtualSpace)
	local oldSpace = self._windowVirtualSpaceMap[windowId]

	if oldSpace then
		self:_removeWindowFromList(oldSpace, windowId)
	end

	if not self._virtualSpaceWindowsMap[virtualSpace] then
		self._virtualSpaceWindowsMap[virtualSpace] = {}
	end
	table.insert(self._virtualSpaceWindowsMap[virtualSpace], windowId)

	self._windowVirtualSpaceMap[windowId] = virtualSpace
end

function SpacesModel:removeWindow(windowId)
	local virtualSpace = self._windowVirtualSpaceMap[windowId]

	if virtualSpace then
		self:_removeWindowFromList(virtualSpace, windowId)
	end

	self._windowVirtualSpaceMap[windowId] = nil
end

function SpacesModel:getVirtualSpaceForWindow(windowId)
	return self._windowVirtualSpaceMap[windowId]
end

function SpacesModel:getWindowsInVirtualSpace(virtualSpace)
	return self._virtualSpaceWindowsMap[virtualSpace] or {}
end

function SpacesModel:categorizeWindowsForTransition(targetVirtualSpace, currentVirtualSpace)
	local toActive = {}
	local toStorage = {}
	local others = {}

	for windowId, virtualSpace in pairs(self._windowVirtualSpaceMap) do
		if virtualSpace == targetVirtualSpace then
			table.insert(toActive, windowId)
		elseif virtualSpace == currentVirtualSpace then
			table.insert(toStorage, windowId)
		else
			table.insert(others, windowId)
		end
	end

	return {
		toActive = toActive,
		toStorage = toStorage,
		others = others
	}
end

function SpacesModel:_removeWindowFromList(virtualSpace, windowId)
	local windows = self._virtualSpaceWindowsMap[virtualSpace]
	if not windows then return end

	for i, wId in ipairs(windows) do
		if wId == windowId then
			table.remove(windows, i)
			return
		end
	end
end

function SpacesModel:getCurrentVirtualSpace()
	return self._currentVirtualSpace
end

function SpacesModel:setCurrentVirtualSpace(virtualSpace)
	self._currentVirtualSpace = virtualSpace
end

return SpacesModel
