local lu = require('luaunit')

local mockWindows = {}
local mockScreen = {}

function mockScreen:frame() return {x = 0, y = 23, w = 1440, h = 877} end
function mockScreen:fullFrame() return {x = 0, y = 0, w = 1440, h = 900} end
function mockScreen:id() return 1 end

for i = 1, 4 do
	mockWindows[i] = {
		_id = i,
		_frame = {x = 100 * i, y = 100, w = 600, h = 400},
		id = function(self) return self._id end,
		frame = function(self) return self._frame end,
		setFrame = function(self, f) self._frame = f end,
		screen = function() return mockScreen end,
		isStandard = function() return true end,
		isFullScreen = function() return false end
	}
end

TestWMUtilsTiledResize = {}

function TestWMUtilsTiledResize:setUp()
	package.loaded['WMUtils'] = nil

	local mockVirtualSpaces = {
		getWindowsForCurrentVirtualSpace = function(self)
			return {mockWindows[1], mockWindows[2], mockWindows[3]}
		end
	}

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindows[1] end,
			orderedWindows = function()
				return {mockWindows[1], mockWindows[2], mockWindows[3]}
			end
		},
		grid = {
			getGrid = function() return {w = 2, h = 2} end
		}
	}

	_G.spoon = { VirtualSpaces = mockVirtualSpaces }

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	for i = 1, 4 do
		mockWindows[i]._frame = {x = 100 * i, y = 100, w = 600, h = 400}
	end
end

function TestWMUtilsTiledResize:testResizeModeDetectsTiledLayout()
	self.wmutils:tile()

	local isTiled = self.wmutils:isInTiledResizeMode()

	lu.assertTrue(isTiled)
end

function TestWMUtilsTiledResize:testResizeModeDetectsFloatingLayout()
	local isTiled = self.wmutils:isInTiledResizeMode()

	lu.assertFalse(isTiled)
end

function TestWMUtilsTiledResize:testResizeModeSingleWindowReturnsFalse()
	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1]}
	end

	self.wmutils:tile()

	local isTiled = self.wmutils:isInTiledResizeMode()

	lu.assertFalse(isTiled)
end

function TestWMUtilsTiledResize:testResizeTiledMainStackWider()
	self.wmutils:tile()

	local mainWidthBefore = mockWindows[1]._frame.w
	local stackWidthBefore = mockWindows[2]._frame.w

	self.wmutils:resizeTiledMainStack(30)

	lu.assertTrue(mockWindows[1]._frame.w > mainWidthBefore)
	lu.assertTrue(mockWindows[2]._frame.w < stackWidthBefore)
end

function TestWMUtilsTiledResize:testResizeTiledMainStackNarrower()
	self.wmutils:tile()

	local mainWidthBefore = mockWindows[1]._frame.w
	local stackWidthBefore = mockWindows[2]._frame.w

	self.wmutils:resizeTiledMainStack(-30)

	lu.assertTrue(mockWindows[1]._frame.w < mainWidthBefore)
	lu.assertTrue(mockWindows[2]._frame.w > stackWidthBefore)
end

function TestWMUtilsTiledResize:testMainRatioBoundsCheckingMin()
	self.wmutils:tile()
	self.wmutils.activeTileMainRatio = 0.25

	self.wmutils:resizeTiledMainStack(-1000)

	lu.assertTrue(self.wmutils.activeTileMainRatio >= 0.2)
end

function TestWMUtilsTiledResize:testMainRatioBoundsCheckingMax()
	self.wmutils:tile()
	self.wmutils.activeTileMainRatio = 0.75

	self.wmutils:resizeTiledMainStack(1000)

	lu.assertTrue(self.wmutils.activeTileMainRatio <= 0.8)
end

function TestWMUtilsTiledResize:testMainStackResizeAffectsAllWindows()
	self.wmutils:tile()

	local win1Before = {w = mockWindows[1]._frame.w, x = mockWindows[1]._frame.x}
	local win2Before = {w = mockWindows[2]._frame.w, x = mockWindows[2]._frame.x}
	local win3Before = {w = mockWindows[3]._frame.w, x = mockWindows[3]._frame.x}

	self.wmutils:resizeTiledMainStack(30)

	lu.assertNotEquals(mockWindows[1]._frame.w, win1Before.w)
	lu.assertNotEquals(mockWindows[2]._frame.w, win2Before.w)
	lu.assertNotEquals(mockWindows[3]._frame.w, win3Before.w)
end

function TestWMUtilsTiledResize:testResizeTiledStackWindowTaller()
	self.wmutils:tile()

	_G.hs.window.focusedWindow = function() return mockWindows[2] end

	local stackHeightBefore = mockWindows[2]._frame.h

	self.wmutils:resizeTiledStackWindow(30)

	lu.assertTrue(mockWindows[2]._frame.h > stackHeightBefore)
end

function TestWMUtilsTiledResize:testResizeTiledStackWindowShorter()
	self.wmutils:tile()

	_G.hs.window.focusedWindow = function() return mockWindows[2] end

	local stackHeightBefore = mockWindows[2]._frame.h

	self.wmutils:resizeTiledStackWindow(-30)

	lu.assertTrue(mockWindows[2]._frame.h < stackHeightBefore)
end

function TestWMUtilsTiledResize:testStackHeightRedistributesEqually()
	self.wmutils:tile()

	_G.hs.window.focusedWindow = function() return mockWindows[2] end

	self.wmutils:resizeTiledStackWindow(30)

	lu.assertNotNil(self.wmutils.activeTileStackHeights[2])
end

function TestWMUtilsTiledResize:testStackResizeOnlyWhenFocusedInStack()
	self.wmutils:tile()

	_G.hs.window.focusedWindow = function() return mockWindows[1] end

	local mainHeightBefore = mockWindows[1]._frame.h

	self.wmutils:resizeTiledStackWindow(30)

	lu.assertEquals(mockWindows[1]._frame.h, mainHeightBefore)
end

return {TestWMUtilsTiledResize}
