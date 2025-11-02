local SpacesModel = {}
SpacesModel.__index = SpacesModel

function SpacesModel.new()
	local self = setmetatable({}, SpacesModel)
	self._focusedWindows = {}
	self._windowVirtualSpaceMap = {}
	return self
end

function SpacesModel:saveFocusedWindowInVirtualSpace(virtualSpace, windowId)
	self._focusedWindows[virtualSpace] = windowId
end

function SpacesModel:getFocusedWindowForVirtualSpace(virtualSpace)
	return self._focusedWindows[virtualSpace]
end

function SpacesModel:assignWindowToVirtualSpace(windowId, virtualSpace)
	self._windowVirtualSpaceMap[windowId] = virtualSpace
end

function SpacesModel:removeWindow(windowId)
	self._windowVirtualSpaceMap[windowId] = nil
end

function SpacesModel:getVirtualSpaceForWindow(windowId)
	return self._windowVirtualSpaceMap[windowId]
end

function SpacesModel:getWindowsInVirtualSpace(virtualSpace)
	local windows = {}
	for windowId, vSpace in pairs(self._windowVirtualSpaceMap) do
		if vSpace == virtualSpace then
			table.insert(windows, windowId)
		end
	end
	return windows
end

function SpacesModel:getAllWindowMappings()
	return self._windowVirtualSpaceMap
end

return SpacesModel
