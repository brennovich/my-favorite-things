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

TestWMUtilsMonocleMaximized = {}

function TestWMUtilsMonocleMaximized:setUp()
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

function TestWMUtilsMonocleMaximized:testMonocleMaximizedMaximizesToFullFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = initialFrame

	self.wmutils:monocleMaximized()

	local expectedFrame = {x = 0, y = 0, w = 1440, h = 900}
	lu.assertEquals(mockWindow._frame, expectedFrame)
end

function TestWMUtilsMonocleMaximized:testMonocleMaximizedHasHeightToleranceForConstrainedWindows()
	local maximizedFrame = {x = 0, y = 0, w = 1440, h = 880}
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = maximizedFrame
	self.wmutils.monocleMaximizedFrameCache[1] = initialFrame

	self.wmutils:monocleMaximized()

	lu.assertEquals(mockWindow._frame, initialFrame)
end

function TestWMUtilsMonocleMaximized:testMonocleMaximizedCachesOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:monocleMaximized()

	lu.assertNotNil(self.wmutils.monocleMaximizedFrameCache[1])
	lu.assertEquals(self.wmutils.monocleMaximizedFrameCache[1].x, initialFrame.x)
	lu.assertEquals(self.wmutils.monocleMaximizedFrameCache[1].y, initialFrame.y)
end

function TestWMUtilsMonocleMaximized:testMonocleMaximizedToggleRestoresOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:monocleMaximized()
	self.wmutils:monocleMaximized()

	lu.assertEquals(mockWindow._frame.x, initialFrame.x)
	lu.assertEquals(mockWindow._frame.y, initialFrame.y)
	lu.assertEquals(mockWindow._frame.w, initialFrame.w)
	lu.assertEquals(mockWindow._frame.h, initialFrame.h)
end

function TestWMUtilsMonocleMaximized:testMonocleMaximizedCacheIsIndependentFromMonocleCache()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:monocleMaximized()

	lu.assertNotNil(self.wmutils.monocleMaximizedFrameCache)
	lu.assertNotEquals(self.wmutils.monocleMaximizedFrameCache, self.wmutils.windowFrameCache)
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

	lu.assertNotNil(self.wmutils.windowFrameCache[1])
	lu.assertEquals(self.wmutils.windowFrameCache[1].x, 100)
	lu.assertEquals(self.wmutils.windowFrameCache[1].y, 100)
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

return {TestWMUtilsMonocleMaximized, TestWMUtilsCenterWindow, TestWMUtilsMonocle}
