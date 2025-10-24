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

	self.appWatcher = hs.application.watcher.new(function(appName, eventType, app)
		if eventType == hs.application.watcher.activated then
			if not app then return end

			local currentSpace = hs.spaces.activeSpaceOnScreen()

			if currentSpace == self._storageSpace then
				hs.timer.doAfter(0.1, function()
					for _, win in ipairs(app:allWindows()) do
						if self:_isManageableWindow(win) then
							local targetWorkspace = self._windowWorkspaceMap[win:id()]

							if targetWorkspace then
								self:switchToWorkspace(targetWorkspace)
								return
							end
						end
					end
				end)
			end
		end
	end)
	self.appWatcher:start()

	self:_scanExistingWindows()

	return self
end

function obj:_isManageableWindow(win)
	return win:isStandard() and not win:isFullScreen()
end

function obj:_saveFocusedWindow()
	local focusedWin = hs.window.focusedWindow()
	if focusedWin then
		self._workspaceFocusedWindow[self._currentWorkspace] = focusedWin:id()
	end
end

function obj:_restoreFocusedWindow(workspaceNum)
	if self._workspaceFocusedWindow[workspaceNum] then
		local win = hs.window.get(self._workspaceFocusedWindow[workspaceNum])
		if win then
			win:focus()
		end
	end
end

function obj:_moveWindowsByCategory(targetWorkspace, isSwapping)
	for winId, wsNum in pairs(self._windowWorkspaceMap) do
		if wsNum == targetWorkspace then
			hs.spaces.moveWindowToSpace(winId, self._activeSpace)
		elseif wsNum == self._currentWorkspace then
			hs.spaces.moveWindowToSpace(winId, self._storageSpace)
		elseif isSwapping then
			hs.spaces.moveWindowToSpace(winId, self._storageSpace)
		end
	end
end

function obj:switchToWorkspace(workspaceNum)
	if not workspaceNum or workspaceNum < 1 then
		return
	end

	local currentSpace = hs.spaces.activeSpaceOnScreen()

	if workspaceNum == self._currentWorkspace and currentSpace == self._activeSpace then
		return
	end

	self:_saveFocusedWindow()

	local isSwapping = currentSpace == self._storageSpace
	if isSwapping then
		self._activeSpace, self._storageSpace = self._storageSpace, self._activeSpace
	end

	self:_moveWindowsByCategory(workspaceNum, isSwapping)

	if hs.spaces.activeSpaceOnScreen() ~= self._activeSpace then
		hs.spaces.gotoSpace(self._activeSpace)
		hs.eventtap.keyStroke({}, "escape")
	end

	self._currentWorkspace = workspaceNum
	self:_restoreFocusedWindow(workspaceNum)
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
