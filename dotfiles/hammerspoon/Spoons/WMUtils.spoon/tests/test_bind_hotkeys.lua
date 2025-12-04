local lu = require('luaunit')

local mockWindow = {}
local mockScreen = {}

function mockWindow:id() return self._id end
function mockWindow:frame() return self._frame end
function mockWindow:setFrame(frame) self._frame = frame end
function mockWindow:screen() return mockScreen end

function mockScreen:frame() return {x = 0, y = 23, w = 1440, h = 877} end
function mockScreen:fullFrame() return {x = 0, y = 0, w = 1440, h = 900} end

TestWMUtilsBindHotkeys = {}

function TestWMUtilsBindHotkeys:setUp()
	package.loaded['WMUtils'] = nil

	self.hotkeyBindCalls = {}

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindow end
		},
		hotkey = {
			bind = function(mods, key, pressedfn, releasedfn, repeatfn)
				table.insert(self.hotkeyBindCalls, {
					mods = mods,
					key = key,
					pressedfn = pressedfn,
					releasedfn = releasedfn,
					repeatfn = repeatfn
				})
			end
		}
	}

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()

	mockWindow._id = 1
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
end

function TestWMUtilsBindHotkeys:testBindHotkeysCreatesHotkeyBindings()
	local mapping = {
		moveLeft = {{"alt", "shift"}, "h"}
	}

	self.wmutils:bindHotkeys(mapping)

	lu.assertEquals(#self.hotkeyBindCalls, 1)
	lu.assertEquals(self.hotkeyBindCalls[1].mods, {"alt", "shift"})
	lu.assertEquals(self.hotkeyBindCalls[1].key, "h")
end

function TestWMUtilsBindHotkeys:testMoveOperationsUseRepeatfn()
	local mapping = {
		moveLeft = {{"alt", "shift"}, "h"},
		moveRight = {{"alt", "shift"}, "l"}
	}

	self.wmutils:bindHotkeys(mapping)

	lu.assertEquals(#self.hotkeyBindCalls, 2)
	lu.assertNotNil(self.hotkeyBindCalls[1].repeatfn)
	lu.assertNotNil(self.hotkeyBindCalls[2].repeatfn)
end

function TestWMUtilsBindHotkeys:testResizeOperationsUseRepeatfn()
	local mapping = {
		resizeWider = {{"alt"}, "l"},
		resizeSlimmer = {{"alt"}, "h"}
	}

	self.wmutils:bindHotkeys(mapping)

	lu.assertEquals(#self.hotkeyBindCalls, 2)
	lu.assertNotNil(self.hotkeyBindCalls[1].repeatfn)
	lu.assertNotNil(self.hotkeyBindCalls[2].repeatfn)
end

function TestWMUtilsBindHotkeys:testNonRepeatOperationsDoNotUseRepeatfn()
	local mapping = {
		centerWindow = {{"alt", "ctrl"}, "space"}
	}

	self.wmutils:bindHotkeys(mapping)

	lu.assertEquals(#self.hotkeyBindCalls, 1)
	lu.assertNil(self.hotkeyBindCalls[1].repeatfn)
end

function TestWMUtilsBindHotkeys:testRepeatfnCallsCorrectMethod()
	local mapping = {
		moveLeft = {{"alt", "shift"}, "h"}
	}

	self.wmutils:bindHotkeys(mapping)

	local initialX = mockWindow._frame.x
	self.hotkeyBindCalls[1].repeatfn()

	lu.assertEquals(mockWindow._frame.x, initialX - self.wmutils.gap * 2)
end

function TestWMUtilsBindHotkeys:testDefaultHotkeysPropertyExists()
	lu.assertNotNil(self.wmutils.defaultHotkeys)
	lu.assertEquals(type(self.wmutils.defaultHotkeys), "table")
end

function TestWMUtilsBindHotkeys:testDefaultHotkeysContainsMoveOperations()
	lu.assertNotNil(self.wmutils.defaultHotkeys.moveLeft)
	lu.assertNotNil(self.wmutils.defaultHotkeys.moveRight)
	lu.assertNotNil(self.wmutils.defaultHotkeys.moveUp)
	lu.assertNotNil(self.wmutils.defaultHotkeys.moveDown)
end

function TestWMUtilsBindHotkeys:testDefaultHotkeysContainsGridOperations()
	lu.assertNotNil(self.wmutils.defaultHotkeys.leftHalf)
	lu.assertNotNil(self.wmutils.defaultHotkeys.rightHalf)
	lu.assertNotNil(self.wmutils.defaultHotkeys.topHalf)
	lu.assertNotNil(self.wmutils.defaultHotkeys.bottomHalf)
end

function TestWMUtilsBindHotkeys:testDefaultHotkeysContainsWindowOperations()
	lu.assertNotNil(self.wmutils.defaultHotkeys.centerWindow)
	lu.assertNotNil(self.wmutils.defaultHotkeys.monocle)
	lu.assertNotNil(self.wmutils.defaultHotkeys.telescope)
end

TestWMUtilsBindResizeHotkeys = {}

function TestWMUtilsBindResizeHotkeys:setUp()
	package.loaded['WMUtils'] = nil

	self.modalBindCalls = {}
	local mockModal = {
		bind = function(modal, mods, key, pressedfn, releasedfn, repeatfn)
			table.insert(self.modalBindCalls, {
				mods = mods,
				key = key,
				pressedfn = pressedfn,
				releasedfn = releasedfn,
				repeatfn = repeatfn
			})
		end
	}

	_G.hs = {
		window = {
			focusedWindow = function() return mockWindow end,
			filter = {
				new = function() return {} end
			}
		},
		hotkey = {
			modal = {
				new = function() return mockModal end
			}
		}
	}

	local WMUtils = dofile('init.lua')
	self.wmutils = WMUtils:init()
	self.wmutils:setupResizeModal()

	mockWindow._id = 1
	mockWindow._frame = {x = 100, y = 100, w = 800, h = 600}
end

function TestWMUtilsBindResizeHotkeys:testBindResizeHotkeysCreatesModalBindings()
	local mapping = {
		resizeSlimmer = {{}, "h"}
	}

	self.wmutils:bindResizeHotkeys(mapping)

	lu.assertEquals(#self.modalBindCalls, 1)
	lu.assertEquals(self.modalBindCalls[1].mods, {})
	lu.assertEquals(self.modalBindCalls[1].key, "h")
end

function TestWMUtilsBindResizeHotkeys:testResizeOperationsUseRepeatfn()
	local mapping = {
		resizeSlimmer = {{}, "h"},
		resizeWider = {{}, "l"}
	}

	self.wmutils:bindResizeHotkeys(mapping)

	lu.assertEquals(#self.modalBindCalls, 2)
	lu.assertNotNil(self.modalBindCalls[1].repeatfn)
	lu.assertNotNil(self.modalBindCalls[2].repeatfn)
end

function TestWMUtilsBindResizeHotkeys:testDefaultResizeHotkeysPropertyExists()
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys)
	lu.assertEquals(type(self.wmutils.defaultResizeHotkeys), "table")
end

function TestWMUtilsBindResizeHotkeys:testDefaultResizeHotkeysContainsResizeOperations()
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeSlimmer)
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeWider)
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeShorter)
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeTaller)
end

function TestWMUtilsBindResizeHotkeys:testDefaultResizeHotkeysContainsGridResizeOperations()
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeThinnerByGrid)
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeWiderByGrid)
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeShorterByGrid)
	lu.assertNotNil(self.wmutils.defaultResizeHotkeys.resizeTallerByGrid)
end

return {TestWMUtilsBindHotkeys, TestWMUtilsBindResizeHotkeys}
