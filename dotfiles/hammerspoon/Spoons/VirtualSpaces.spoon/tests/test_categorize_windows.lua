local lu = require('luaunit')

local VirtualSpaces = dofile('init.lua')

TestCategorizeWindows = {}

function TestCategorizeWindows:setUp()
	self.obj = setmetatable({}, VirtualSpaces)
	self.obj._currentWorkspace = 1
	self.obj._windowWorkspaceMap = {
		[100] = 1,
		[101] = 1,
		[200] = 2,
		[201] = 2,
		[300] = 3,
		[301] = 3,
	}
end

function TestCategorizeWindows:testVirtualSpaceSwitchMovesCurrentWorkspaceToStorage()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, false)

	lu.assertEquals(toStorage[100], true)
	lu.assertEquals(toStorage[101], true)
	lu.assertNil(toStorage[200])
	lu.assertNil(toStorage[201])
end

function TestCategorizeWindows:testVirtualSpaceSwitchMovesTargetWorkspaceToActive()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, false)

	lu.assertEquals(toActive[200], true)
	lu.assertEquals(toActive[201], true)
	lu.assertNil(toActive[100])
	lu.assertNil(toActive[101])
end

function TestCategorizeWindows:testVirtualSpaceSwitchDoesNotMoveOtherWorkspaces()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, false)

	lu.assertNil(toStorage[300])
	lu.assertNil(toStorage[301])
	lu.assertNil(toActive[300])
	lu.assertNil(toActive[301])
end

function TestCategorizeWindows:testNativeSpaceSwitchMovesCurrentWorkspaceToStorage()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, true)

	lu.assertEquals(toStorage[100], true)
	lu.assertEquals(toStorage[101], true)
end

function TestCategorizeWindows:testNativeSpaceSwitchMovesOtherWorkspacesToStorage()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, true)

	lu.assertEquals(toStorage[300], true)
	lu.assertEquals(toStorage[301], true)
end

function TestCategorizeWindows:testNativeSpaceSwitchMovesTargetWorkspaceToActive()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, true)

	lu.assertEquals(toActive[200], true)
	lu.assertEquals(toActive[201], true)
	lu.assertNil(toStorage[200])
	lu.assertNil(toStorage[201])
end

function TestCategorizeWindows:testVirtualSpaceSwitchToSameWorkspace()
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(1, false)

	lu.assertNil(toStorage[100])
	lu.assertNil(toStorage[101])
	lu.assertEquals(toActive[100], true)
	lu.assertEquals(toActive[101], true)
end

function TestCategorizeWindows:testEmptyWindowMap()
	self.obj._windowWorkspaceMap = {}
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(2, false)

	lu.assertNil(next(toStorage))
	lu.assertNil(next(toActive))
end

function TestCategorizeWindows:testNoWindowsInCurrentWorkspace()
	self.obj._currentWorkspace = 5
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(3, false)

	lu.assertEquals(toActive[300], true)
	lu.assertEquals(toActive[301], true)
	lu.assertNil(toStorage[100])
	lu.assertNil(toStorage[200])
end

function TestCategorizeWindows:testNoWindowsInTargetWorkspace()
	self.obj._currentWorkspace = 1
	local toStorage, toActive = self.obj:_categorizeWindowsForSwitch(5, false)

	lu.assertEquals(toStorage[100], true)
	lu.assertEquals(toStorage[101], true)
	lu.assertNil(next(toActive))
end

return TestCategorizeWindows
