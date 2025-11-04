local WindowsSort = {}
WindowsSort.__index = WindowsSort

function WindowsSort.new(windowMoverFn, activeNativeSpaceId, storageNativeSpaceId)
	local self = setmetatable({}, WindowsSort)
	self._windowMoverFn = windowMoverFn
	self._activeNativeSpaceId = activeNativeSpaceId
	self._storageNativeSpaceId = storageNativeSpaceId
	return self
end

function WindowsSort:mapWindowsToNativeSpacesFromCurrentNativeSpace(categorizedWindows, currentNativeSpace)
	local nativeSpaceSwitchHappened = currentNativeSpace == self._storageNativeSpaceId
	local activeSpace = self._activeNativeSpaceId
	local storageSpace = self._storageNativeSpaceId

	if nativeSpaceSwitchHappened then
		activeSpace, storageSpace = storageSpace, activeSpace
	end

	for _, winId in ipairs(categorizedWindows.toActive) do
		self._windowMoverFn(winId, activeSpace)
	end

	for _, winId in ipairs(categorizedWindows.toStorage) do
		self._windowMoverFn(winId, storageSpace)
	end

	if nativeSpaceSwitchHappened then
		for _, winId in ipairs(categorizedWindows.others) do
			self._windowMoverFn(winId, storageSpace)
		end

		self._activeNativeSpaceId = activeSpace
		self._storageNativeSpaceId = storageSpace
	end

	return activeSpace, storageSpace
end

return WindowsSort
