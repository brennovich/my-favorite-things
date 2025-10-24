local WindowFocus = {}
WindowFocus.__index = WindowFocus

function WindowFocus.new()
	local self = setmetatable({}, WindowFocus)
	self._focusedWindows = {}
	return self
end

function WindowFocus:saveFocusedWindowInVirtualSpace(virtualSpace, windowId)
	self._focusedWindows[virtualSpace] = windowId
end

function WindowFocus:getFocusedWindowForVirtualSpace(virtualSpace)
	return self._focusedWindows[virtualSpace]
end

return WindowFocus
