local NativeSpaceManager = {}
NativeSpaceManager.__index = NativeSpaceManager

local MISSION_CONTROL_WAIT_TIME_S = 0.5
local SPACE_REMOVAL_DELAY_US = 100000
local SPACE_CREATION_DELAY_US = 10000

function NativeSpaceManager.new(hsSpaces, hsScreen, hsTimer, hsEventtap)
	local self = setmetatable({}, NativeSpaceManager)
	self._hsSpaces = hsSpaces or hs.spaces
	self._hsScreen = hsScreen or hs.screen
	self._hsTimer = hsTimer or hs.timer
	self._hsEventtap = hsEventtap or hs.eventtap
	self._activeSpace = nil
	self._storageSpace = nil
	return self
end

function NativeSpaceManager:setupForMainScreen()
	self._hsSpaces.setDefaultMCwaitTime(MISSION_CONTROL_WAIT_TIME_S)

	local mainScreen = self._hsScreen.mainScreen():getUUID()
	local allSpaces = self._hsSpaces.allSpaces()
	local screenSpaces = allSpaces[mainScreen]

	self:_ensureOnFirstSpace(screenSpaces)
	self:_removeExtraSpaces(screenSpaces)
	self:_createStorageSpace(mainScreen)

	local refreshedSpaces = self._hsSpaces.allSpaces()[mainScreen]
	self._activeSpace = refreshedSpaces[1]
	self._storageSpace = refreshedSpaces[2]

	return self._activeSpace, self._storageSpace
end

function NativeSpaceManager:getActiveSpace()
	return self._activeSpace
end

function NativeSpaceManager:getStorageSpace()
	return self._storageSpace
end

function NativeSpaceManager:updateSpaces(activeSpace, storageSpace)
	self._activeSpace = activeSpace
	self._storageSpace = storageSpace
end

function NativeSpaceManager:_ensureOnFirstSpace(screenSpaces)
	if self._hsSpaces.activeSpaceOnScreen() ~= screenSpaces[1] then
		self._hsSpaces.gotoSpace(screenSpaces[1])
		self._hsEventtap.keyStroke({}, "escape")
	end
end

function NativeSpaceManager:_removeExtraSpaces(screenSpaces)
	if #screenSpaces > 1 then
		for i = 2, #screenSpaces do
			self._hsTimer.usleep(SPACE_REMOVAL_DELAY_US)
			self._hsSpaces.removeSpace(screenSpaces[i], false)
		end
	end
end

function NativeSpaceManager:_createStorageSpace(mainScreen)
	self._hsTimer.usleep(SPACE_CREATION_DELAY_US)
	self._hsSpaces.addSpaceToScreen(mainScreen, true)
end

return NativeSpaceManager
