local lu = require('luaunit')

local NativeSpaceManager = require('NativeSpaceManager')

TestNativeSpaceManager = {}

function TestNativeSpaceManager:testNew()
	local mockSpaces = {}
	local mockScreen = {}
	local mockTimer = {}
	local mockEventtap = {}

	local manager = NativeSpaceManager.new(mockSpaces, mockScreen, mockTimer, mockEventtap)

	lu.assertNotNil(manager)
	lu.assertEquals(manager._hsSpaces, mockSpaces)
	lu.assertEquals(manager._hsScreen, mockScreen)
	lu.assertEquals(manager._hsTimer, mockTimer)
	lu.assertEquals(manager._hsEventtap, mockEventtap)
end

function TestNativeSpaceManager:testGetActiveSpaceBeforeSetup()
	local manager = NativeSpaceManager.new({}, {}, {}, {})

	lu.assertNil(manager:getActiveSpace())
end

function TestNativeSpaceManager:testGetStorageSpaceBeforeSetup()
	local manager = NativeSpaceManager.new({}, {}, {}, {})

	lu.assertNil(manager:getStorageSpace())
end

function TestNativeSpaceManager:testUpdateSpaces()
	local manager = NativeSpaceManager.new({}, {}, {}, {})

	manager:updateSpaces("active-123", "storage-456")

	lu.assertEquals(manager:getActiveSpace(), "active-123")
	lu.assertEquals(manager:getStorageSpace(), "storage-456")
end

function TestNativeSpaceManager:testUpdateSpacesMultipleTimes()
	local manager = NativeSpaceManager.new({}, {}, {}, {})

	manager:updateSpaces("active-1", "storage-1")
	lu.assertEquals(manager:getActiveSpace(), "active-1")
	lu.assertEquals(manager:getStorageSpace(), "storage-1")

	manager:updateSpaces("active-2", "storage-2")
	lu.assertEquals(manager:getActiveSpace(), "active-2")
	lu.assertEquals(manager:getStorageSpace(), "storage-2")
end

return TestNativeSpaceManager
