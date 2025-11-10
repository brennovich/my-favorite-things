local lu = require('luaunit')

local mockWindow = {}
local mockScreen = {}
local mockHs = {}

function mockWindow:id()
	return self._id
end

function mockWindow:frame()
	return self._frame
end

function mockWindow:setFrame(frame)
	self._frame = frame
end

function mockWindow:screen()
	return mockScreen
end

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

function mockScreen:frame()
	return {x = 0, y = 23, w = 1920, h = 1057}
end

function mockScreen:fullFrame()
	return {x = 0, y = 0, w = 1920, h = 1080}
end

function mockHs.focusedWindow()
	return mockWindow
end

TestWMUtilsFullscreen = {}

function TestWMUtilsFullscreen:setUp()
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

function TestWMUtilsFullscreen:testFullscreenMaximizesToFullFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = initialFrame

	self.wmutils:fullscreen()

	local expectedFrame = {x = 0, y = 0, w = 1920, h = 1080}
	lu.assertEquals(mockWindow._frame, expectedFrame)
end

function TestWMUtilsFullscreen:testFullscreenCachesOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:fullscreen()

	lu.assertNotNil(self.wmutils.fullscreenFrameCache[1])
	lu.assertEquals(self.wmutils.fullscreenFrameCache[1].x, initialFrame.x)
	lu.assertEquals(self.wmutils.fullscreenFrameCache[1].y, initialFrame.y)
end

function TestWMUtilsFullscreen:testFullscreenToggleRestoresOriginalFrame()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:fullscreen()
	self.wmutils:fullscreen()

	lu.assertEquals(mockWindow._frame.x, initialFrame.x)
	lu.assertEquals(mockWindow._frame.y, initialFrame.y)
	lu.assertEquals(mockWindow._frame.w, initialFrame.w)
	lu.assertEquals(mockWindow._frame.h, initialFrame.h)
end

function TestWMUtilsFullscreen:testFullscreenCacheIsIndependentFromMonocleCache()
	local initialFrame = {x = 100, y = 100, w = 800, h = 600}
	mockWindow._frame = {x = initialFrame.x, y = initialFrame.y, w = initialFrame.w, h = initialFrame.h}

	self.wmutils:fullscreen()

	lu.assertNotNil(self.wmutils.fullscreenFrameCache)
	lu.assertNotEquals(self.wmutils.fullscreenFrameCache, self.wmutils.windowFrameCache)
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

return {TestWMUtilsFullscreen, TestWMUtilsCenterWindow}
