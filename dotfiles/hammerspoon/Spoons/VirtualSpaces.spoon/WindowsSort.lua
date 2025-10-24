local WindowsSort = {}
WindowsSort.__index = WindowsSort

function WindowsSort.new(windowMoverFn, activeNativeSpaceId, storageNativeSpaceId)
	local self = setmetatable({}, WindowsSort)
	self._windowMoverFn = windowMoverFn
	self._activeNativeSpaceId = activeNativeSpaceId
	self._storageNativeSpaceId = storageNativeSpaceId
	return self
end

function WindowsSort:mapWindowsToNativeSpacesFromCurrentNativeSpace(windowMap, targetVirtualSpace, currentVirtualSpace, currentNativeSpace)
	local isSwapping = currentNativeSpace == self._storageNativeSpaceId
	local activeSpace = self._activeNativeSpaceId
	local storageSpace = self._storageNativeSpaceId

	if isSwapping then
		activeSpace, storageSpace = storageSpace, activeSpace
	end

	for winId, virtualSpace in pairs(windowMap) do
		if virtualSpace == targetVirtualSpace then
			self._windowMoverFn(winId, activeSpace)
		elseif virtualSpace == currentVirtualSpace then
			self._windowMoverFn(winId, storageSpace)
		elseif isSwapping then
			self._windowMoverFn(winId, storageSpace)
		end
	end

	if isSwapping then
		self._activeNativeSpaceId = activeSpace
		self._storageNativeSpaceId = storageSpace
	end

	return activeSpace, storageSpace
end

return WindowsSort
