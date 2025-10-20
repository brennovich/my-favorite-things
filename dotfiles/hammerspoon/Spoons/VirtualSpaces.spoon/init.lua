local obj = {}
obj.__index = obj

obj.name = "VirtualSpaces"
obj.version = "1.0"
obj.author = "brnnc"
obj.license = "MIT"

obj._currentWorkspace = 1
obj._windowWorkspaceMap = {}
obj._workspaceFocusedWindow = {}
obj._activeSpace = nil
obj._storageSpace = nil

function obj:init()
	local screenSpaces = self._setupMissionControl()

	self._activeSpace = screenSpaces[1]
	self._storageSpace = screenSpaces[2]

	self.windowFilter = hs.window.filter.new()

	-- This filter is unused but it seems to help address this bug:
	-- https://github.com/Hammerspoon/hammerspoon/issues/3276
	self.windowFilterOther = hs.window.filter.new()
	self.windowFilterOther:setCurrentSpace(true)

	self.windowFilter:subscribe(hs.window.filter.windowCreated, function(window)
		self:assignWindowToWorkspace(window, self._currentWorkspace)
	end)

	self.windowFilter:subscribe(hs.window.filter.windowDestroyed, function(window)
		self:_removeWindow(window)
	end)

	self:_scanExistingWindows()

	return self
end

function obj:switchToWorkspace(workspaceNum)
	if workspaceNum < 1 then return end

	local currentSpace = hs.spaces.activeSpaceOnScreen()

	if workspaceNum == self._currentWorkspace and currentSpace == self._activeSpace then
		return
	end

	local focusedWin = hs.window.focusedWindow()
	if focusedWin then
		self._workspaceFocusedWindow[self._currentWorkspace] = focusedWin:id()
	end

	local toStorage = {}
	local toActive = {}
	for winId, wsNum in pairs(self._windowWorkspaceMap) do
		if wsNum == self._currentWorkspace then
			toStorage[winId] = true
		elseif wsNum == workspaceNum then
			toActive[winId] = true
		end
	end

	for _, win in ipairs(self.windowFilter:getWindows()) do
		if win:isStandard() and not win:isFullScreen() then
			local winId = win:id()
			if toStorage[winId] then
				hs.spaces.moveWindowToSpace(win, self._storageSpace)
			elseif toActive[winId] then
				hs.spaces.moveWindowToSpace(win, self._activeSpace)
			end
		end
	end

	if hs.spaces.activeSpaceOnScreen() ~= self._activeSpace then
		hs.spaces.gotoSpace(self._activeSpace)
		hs.eventtap.keyStroke({}, "escape")
	end

	if self._workspaceFocusedWindow[workspaceNum] then
		local win = hs.window.get(self._workspaceFocusedWindow[workspaceNum])
		if win then
			win:focus()
		end
	end

	self._currentWorkspace = workspaceNum
end

function obj:moveWindowToWorkspace(window, workspaceNum)
	if not window or workspaceNum < 1 then return end

	local winId = window:id()
	self._windowWorkspaceMap[winId] = workspaceNum

	if workspaceNum == self._currentWorkspace then
		hs.spaces.moveWindowToSpace(window, self._activeSpace)
	else
		hs.spaces.moveWindowToSpace(window, self._storageSpace)
	end
end

function obj:_scanExistingWindows()
	local allWindows = hs.window.allWindows()
	for _, win in ipairs(allWindows) do
		if win:isStandard() and not win:isFullScreen() then
			hs.spaces.moveWindowToSpace(win, self._activeSpace)
			self:assignWindowToWorkspace(win, 1)
		end
	end
end

function obj:assignWindowToWorkspace(window, workspaceNum)
	if not window or not window:isStandard() or window:isFullScreen() then return end

	local winId = window:id()
	self._windowWorkspaceMap[winId] = workspaceNum
end

function obj:_removeWindow(window)
	local winId = window:id()
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
