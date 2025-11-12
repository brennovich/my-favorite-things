local lu = require('luaunit')

local mockWindow = {}
local mockScreen = {}
local mockHs = {}

function mockWindow:id() return self._id end
function mockWindow:frame() return self._frame end
function mockWindow:setFrame(frame) self._frame = frame end
function mockWindow:maximize() self._frame = mockScreen:fullFrame() end
function mockWindow:screen() return mockScreen end
function mockWindow:isFullScreen() return self._isFullScreen or false end

function mockWindow:centerOnScreen()
	local screenFrame = mockScreen:frame()
	local winFrame = self:frame()
	self._frame = {
		x = screenFrame.x + (screenFrame.w - winFrame.w) / 2,
		y = screenFrame.y + (screenFrame.h - winFrame.h) / 2,
		w = winFrame.w,
		h = winFrame.h
	}
end


function mockScreen:frame() return {x = 0, y = 23, w = 1440, h = 877} end
function mockScreen:fullFrame() return {x = 0, y = 0, w = 1440, h = 900} end

function mockHs.focusedWindow() return mockWindow end

TestWMUtilsTelescope = {}

function TestWMUtilsTelescope:setUp()
	package.loaded['WMUtils'] = nil

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindow end
		}
	}

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	mockWindow._id = 1
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
end

function TestWMUtilsTelescope:testTelescopeMaximizesToFullFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = initialFrame

	self.wmutils:telescope()

	local expectedFrame = {x = 0, y = 0, w = 1440, h = 900}
	lu.assertEquals(mockWindow._frame, expectedFrame)
end

function TestWMUtilsTelescope:testTelescopeHasHeightToleranceForConstrainedWindows()
	local maximizedFrame = {x = 0, y = 0, w = 1440, h = 880}
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = maximizedFrame
	self.wmutils.telescopeFrameCache[1] = initialFrame

	self.wmutils:telescope()

	lu.assertEquals(mockWindow._frame, initialFrame)
end

function TestWMUtilsTelescope:testTelescopeCachesOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:telescope()

	lu.assertNotNil(self.wmutils.telescopeFrameCache[1])
	lu.assertEquals(self.wmutils.telescopeFrameCache[1].x, initialFrame.x)
	lu.assertEquals(self.wmutils.telescopeFrameCache[1].y, initialFrame.y)
end

function TestWMUtilsTelescope:testTelescopeToggleRestoresOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:telescope()
	self.wmutils:telescope()

	lu.assertEquals(mockWindow._frame.x, initialFrame.x)
	lu.assertEquals(mockWindow._frame.y, initialFrame.y)
	lu.assertEquals(mockWindow._frame.w, initialFrame.w)
	lu.assertEquals(mockWindow._frame.h, initialFrame.h)
end

function TestWMUtilsTelescope:testTelescopeCacheIsIndependentFromMonocleCache()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:telescope()

	lu.assertNotNil(self.wmutils.telescopeFrameCache)
	lu.assertNotEquals(self.wmutils.telescopeFrameCache, self.wmutils.monocleFrameCache)
end

TestWMUtilsCenterWindow = {}

function TestWMUtilsCenterWindow:setUp()
	package.loaded['WMUtils'] = nil

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindow end
		}
	}

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	mockWindow._id = 1
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
end

function TestWMUtilsCenterWindow:testCenterWindowCentersOnScreen()
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}

	self.wmutils:centerWindow()

	local screenFrame = mockScreen:frame()
	local expectedX = screenFrame.x + (screenFrame.w - 800) / 2
	local expectedY = screenFrame.y + (screenFrame.h - 600) / 2

	lu.assertEquals(mockWindow._frame.x, expectedX)
	lu.assertEquals(mockWindow._frame.y, expectedY)
	lu.assertEquals(mockWindow._frame.w, 800)
	lu.assertEquals(mockWindow._frame.h, 600)
end

TestWMUtilsMonocle = {}

function TestWMUtilsMonocle:setUp()
	package.loaded['WMUtils'] = nil

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindow end
		},
		grid = {
			get = function(win)
				return {x = 0, y = 0, w = 2, h = 2}
			end,
			getGrid = function(screen)
				return {w = 2, h = 2}
			end,
			maximizeWindow = function(win)
				local screenFrame = mockScreen:frame()
				win:setFrame({
					x = screenFrame.x + 15,
					y = screenFrame.y + 15,
					w = screenFrame.w - 30,
					h = screenFrame.h - 30
				})
			end
		}
	}

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	mockWindow._id = 1
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
end

function TestWMUtilsMonocle:testMonocleCachesOriginalFrame()
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}

	self.wmutils:monocle()

	lu.assertNotNil(self.wmutils.monocleFrameCache[1])
	lu.assertEquals(self.wmutils.monocleFrameCache[1].x, 100)
	lu.assertEquals(self.wmutils.monocleFrameCache[1].y, 100)
end

function TestWMUtilsMonocle:testMonocleToggleRestoresOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:monocle()
	self.wmutils:monocle()

	lu.assertEquals(mockWindow._frame.x, initialFrame.x)
	lu.assertEquals(mockWindow._frame.y, initialFrame.y)
	lu.assertEquals(mockWindow._frame.w, initialFrame.w)
	lu.assertEquals(mockWindow._frame.h, initialFrame.h)
end

TestWMUtilsGridToggle = {}

function TestWMUtilsGridToggle:setUp()
	package.loaded['WMUtils'] = nil

	self.gridSetCalls = {}
	self.currentGridCell = nil
	self.updateResizeBorderCalls = 0

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindow end
		},
		grid = {
			get = function(win)
				return self.currentGridCell or {x = 0, y = 0, w = 1, h = 1}
			end,
			set = function(win, cell, screen)
				table.insert(self.gridSetCalls, {cell = cell})
				self.currentGridCell = cell
			end,
			getGrid = function(screen)
				return {w = 2, h = 2}
			end
		}
	}

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	local originalUpdateResizeBorder = self.wmutils.updateResizeBorder
	self.wmutils.updateResizeBorder = function(obj, win)
		self.updateResizeBorderCalls = self.updateResizeBorderCalls + 1
		return originalUpdateResizeBorder(obj, win)
	end

	mockWindow._id = 1
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
end

function TestWMUtilsGridToggle:testLeftHalfFirstCallStoresFrameAndMovesToLeftPosition()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 1}

	self.wmutils:leftHalf()

	lu.assertNotNil(self.wmutils.gridFrameCache[1])
	lu.assertEquals(self.wmutils.gridFrameCache[1].x, initialFrame.x)
	lu.assertEquals(self.wmutils.gridFrameCache[1].y, initialFrame.y)
	lu.assertEquals(#self.gridSetCalls, 1)
	lu.assertEquals(self.gridSetCalls[1].cell, {x = 0, y = 0, w = 1, h = 2})
end

function TestWMUtilsGridToggle:testLeftHalfSecondCallRestoresOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 1}

	self.wmutils:leftHalf()
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 2}
	self.wmutils:leftHalf()

	lu.assertEquals(mockWindow._frame.x, initialFrame.x)
	lu.assertEquals(mockWindow._frame.y, initialFrame.y)
	lu.assertEquals(mockWindow._frame.w, initialFrame.w)
	lu.assertEquals(mockWindow._frame.h, initialFrame.h)
	lu.assertEquals(self.wmutils.gridFrameCache[1], nil)
end

function TestWMUtilsGridToggle:testGridPositionsShareSameCache()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 1}

	self.wmutils:rightHalf()
	self.currentGridCell = {x = 1, y = 0, w = 1, h = 2}
	self.wmutils:leftHalf()
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 2}

	lu.assertNotNil(self.wmutils.gridFrameCache[1])
	lu.assertEquals(self.wmutils.gridFrameCache[1].x, initialFrame.x)
end

function TestWMUtilsGridToggle:testGridCacheIndependentFromMonocleCache()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 1}

	self.wmutils:leftHalf()

	lu.assertNotNil(self.wmutils.gridFrameCache)
	lu.assertNotEquals(self.wmutils.gridFrameCache, self.wmutils.monocleFrameCache)
	lu.assertNotEquals(self.wmutils.gridFrameCache, self.wmutils.telescopeFrameCache)
end

function TestWMUtilsGridToggle:testLeftHalfCallsUpdateResizeBorder()
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
	self.currentGridCell = {x = 0, y = 0, w = 1, h = 1}

	self.wmutils:leftHalf()

	lu.assertEquals(self.updateResizeBorderCalls, 1)
end

return {TestWMUtilsTelescope, TestWMUtilsCenterWindow, TestWMUtilsMonocle, TestWMUtilsGridToggle}
