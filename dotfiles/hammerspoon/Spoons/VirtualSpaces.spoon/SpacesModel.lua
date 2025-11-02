local SpacesModel = {}
SpacesModel.__index = SpacesModel

function SpacesModel.new()
	local self = setmetatable({}, SpacesModel)
	self._focusedWindows = {}
	self._windowVirtualSpaceMap = {}
	self._virtualSpaceWindowsMap = {}
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

function SpacesModel:getAllWindowMappings()
	return self._windowVirtualSpaceMap
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

return SpacesModel
