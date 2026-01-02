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

TestWMUtilsTile = {}

function TestWMUtilsTile:setUp()
	package.loaded['WMUtils'] = nil

	self.updateResizeBorderCalls = 0

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
		}
	}

	_G.spoon = { VirtualSpaces = mockVirtualSpaces }

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	local originalUpdateResizeBorder = self.wmutils.updateResizeBorder
	self.wmutils.updateResizeBorder = function(obj, win)
		self.updateResizeBorderCalls = self.updateResizeBorderCalls + 1
		return originalUpdateResizeBorder(obj, win)
	end

	for i = 1, 4 do
		mockWindows[i]._frame = {x = 100 * i, y = 100, w = 600, h = 400}
	end
end

function TestWMUtilsTile:testTileSingleWindowMaximizesWithGaps()
	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1]}
	end

	self.wmutils:tile()

	local screenFrame = mockScreen:frame()
	local gap = self.wmutils.gap
	local expected = {
		x = screenFrame.x + gap,
		y = screenFrame.y + gap,
		w = screenFrame.w - (gap * 2),
		h = screenFrame.h - (gap * 2)
	}

	lu.assertEquals(mockWindows[1]._frame.x, expected.x)
	lu.assertEquals(mockWindows[1]._frame.y, expected.y)
	lu.assertEquals(mockWindows[1]._frame.w, expected.w)
	lu.assertEquals(mockWindows[1]._frame.h, expected.h)
end

function TestWMUtilsTile:testTileTwoWindowsMainStack()
	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1], mockWindows[2]}
	end

	self.wmutils:tile()

	local screenFrame = mockScreen:frame()
	local gap = self.wmutils.gap
	local usableW = screenFrame.w - (gap * 2)
	local usableH = screenFrame.h - (gap * 2)
	local mainW = usableW * self.wmutils.mainRatio
	local stackW = usableW * (1 - self.wmutils.mainRatio) - gap

	lu.assertEquals(mockWindows[1]._frame.x, screenFrame.x + gap)
	lu.assertEquals(mockWindows[1]._frame.w, mainW)
	lu.assertEquals(mockWindows[1]._frame.h, usableH)

	lu.assertEquals(mockWindows[2]._frame.x, screenFrame.x + gap + mainW + gap)
	lu.assertEquals(mockWindows[2]._frame.w, stackW)
	lu.assertEquals(mockWindows[2]._frame.h, usableH)
end

function TestWMUtilsTile:testTileThreeWindowsStackSplitsVertically()
	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1], mockWindows[2], mockWindows[3]}
	end

	self.wmutils:tile()

	local screenFrame = mockScreen:frame()
	local gap = self.wmutils.gap
	local usableW = screenFrame.w - (gap * 2)
	local usableH = screenFrame.h - (gap * 2)
	local mainW = usableW * self.wmutils.mainRatio
	local stackW = usableW * (1 - self.wmutils.mainRatio) - gap
	local stackH = usableH / 2

	lu.assertEquals(mockWindows[1]._frame.w, mainW)

	lu.assertEquals(mockWindows[2]._frame.h, stackH)
	lu.assertEquals(mockWindows[3]._frame.h, stackH - gap)
	lu.assertEquals(mockWindows[3]._frame.y, screenFrame.y + gap + stackH + gap)
end

function TestWMUtilsTile:testTilePrioritizesFocusedWindowAsMain()
	_G.hs.window.focusedWindow = function() return mockWindows[3] end
	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1], mockWindows[2], mockWindows[3]}
	end

	self.wmutils:tile()

	local screenFrame = mockScreen:frame()
	local gap = self.wmutils.gap
	local usableW = screenFrame.w - (gap * 2)
	local mainW = usableW * self.wmutils.mainRatio

	lu.assertEquals(mockWindows[3]._frame.w, mainW)
	lu.assertNotEquals(mockWindows[1]._frame.w, mainW)
end

function TestWMUtilsTile:testTileToggleRestoresOriginalFrames()
	local initialFrames = {}
	for i = 1, 3 do
		initialFrames[i] = {
			x = mockWindows[i]._frame.x,
			y = mockWindows[i]._frame.y,
			w = mockWindows[i]._frame.w,
			h = mockWindows[i]._frame.h
		}
	end

	self.wmutils:tile()
	self.wmutils:tile()

	for i = 1, 3 do
		lu.assertEquals(mockWindows[i]._frame.x, initialFrames[i].x)
		lu.assertEquals(mockWindows[i]._frame.y, initialFrames[i].y)
		lu.assertEquals(mockWindows[i]._frame.w, initialFrames[i].w)
		lu.assertEquals(mockWindows[i]._frame.h, initialFrames[i].h)
	end
end

function TestWMUtilsTile:testTileCachesOriginalFrames()
	self.wmutils:tile()

	lu.assertNotNil(self.wmutils.tileFrameCache[1])
	lu.assertNotNil(self.wmutils.tileFrameCache[2])
	lu.assertNotNil(self.wmutils.tileFrameCache[3])
end

function TestWMUtilsTile:testTileHandlesMissingVirtualSpaces()
	_G.spoon.VirtualSpaces = nil

	self.wmutils:tile()

	local screenFrame = mockScreen:frame()
	local gap = self.wmutils.gap
	local usableW = screenFrame.w - (gap * 2)
	local mainW = usableW * self.wmutils.mainRatio

	lu.assertEquals(mockWindows[1]._frame.w, mainW)
end

function TestWMUtilsTile:testTileNoWindowsIsNoOp()
	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {}
	end
	_G.hs.window.orderedWindows = function() return {} end

	self.wmutils:tile()

	lu.assertEquals(#self.wmutils.tileFrameCache, 0)
end

function TestWMUtilsTile:testTileRespectsGapProperty()
	self.wmutils.gap = 25

	self.wmutils:tile()

	local screenFrame = mockScreen:frame()
	local gap = 25
	local expected = screenFrame.x + gap

	lu.assertEquals(mockWindows[1]._frame.x, expected)
end

function TestWMUtilsTile:testTileCacheIndependentFromOtherCaches()
	self.wmutils:tile()

	lu.assertNotEquals(self.wmutils.tileFrameCache, self.wmutils.monocleFrameCache)
	lu.assertNotEquals(self.wmutils.tileFrameCache, self.wmutils.telescopeFrameCache)
	lu.assertNotEquals(self.wmutils.tileFrameCache, self.wmutils.gridFrameCache)
end

function TestWMUtilsTile:testTileCallsUpdateResizeBorder()
	self.wmutils:tile()

	lu.assertEquals(self.updateResizeBorderCalls, 1)
end

function TestWMUtilsTile:testTileCachePersistsWhenWindowCountChanges()
	local initialFrames = {}
	for i = 1, 3 do
		initialFrames[i] = {
			x = mockWindows[i]._frame.x,
			y = mockWindows[i]._frame.y,
			w = mockWindows[i]._frame.w,
			h = mockWindows[i]._frame.h
		}
	end

	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1], mockWindows[2], mockWindows[3]}
	end

	self.wmutils:tile()

	lu.assertNotEquals(mockWindows[1]._frame.x, initialFrames[1].x)

	_G.spoon.VirtualSpaces.getWindowsForCurrentVirtualSpace = function()
		return {mockWindows[1], mockWindows[2]}
	end

	self.wmutils:tile()

	lu.assertNotEquals(mockWindows[1]._frame.x, initialFrames[1].x)

	self.wmutils:tile()

	lu.assertEquals(mockWindows[1]._frame.x, initialFrames[1].x)
	lu.assertEquals(mockWindows[1]._frame.y, initialFrames[1].y)
	lu.assertEquals(mockWindows[1]._frame.w, initialFrames[1].w)
	lu.assertEquals(mockWindows[1]._frame.h, initialFrames[1].h)

	lu.assertEquals(mockWindows[2]._frame.x, initialFrames[2].x)
	lu.assertEquals(mockWindows[2]._frame.y, initialFrames[2].y)
	lu.assertEquals(mockWindows[2]._frame.w, initialFrames[2].w)
	lu.assertEquals(mockWindows[2]._frame.h, initialFrames[2].h)
end

return {TestWMUtilsTile}
