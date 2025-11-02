local lu = require('luaunit')

local SpacesModel = require('SpacesModel')

TestSpacesModel = {}

function TestSpacesModel:testNew()
	local model = SpacesModel.new()

	lu.assertNotNil(model)
	lu.assertNotNil(model._focusedWindows)
end

function TestSpacesModel:testSaveFocusedWindowInVirtualSpace()
	local model = SpacesModel.new()

	model:saveFocusedWindowInVirtualSpace(1, 100)

	lu.assertEquals(model._focusedWindows[1], 100)
end

function TestSpacesModel:testGetFocusedWindowForVirtualSpace()
	local model = SpacesModel.new()

	model:saveFocusedWindowInVirtualSpace(1, 100)
	local windowId = model:getFocusedWindowForVirtualSpace(1)

	lu.assertEquals(windowId, 100)
end

function TestSpacesModel:testGetFocusedWindowForNonExistentVirtualSpace()
	local model = SpacesModel.new()

	local windowId = model:getFocusedWindowForVirtualSpace(999)

	lu.assertNil(windowId)
end

function TestSpacesModel:testOverwriteFocusedWindowInVirtualSpace()
	local model = SpacesModel.new()

	model:saveFocusedWindowInVirtualSpace(1, 100)
	model:saveFocusedWindowInVirtualSpace(1, 200)

	lu.assertEquals(model:getFocusedWindowForVirtualSpace(1), 200)
end

function TestSpacesModel:testMultipleVirtualSpaces()
	local model = SpacesModel.new()

	model:saveFocusedWindowInVirtualSpace(1, 100)
	model:saveFocusedWindowInVirtualSpace(2, 200)
	model:saveFocusedWindowInVirtualSpace(3, 300)

	lu.assertEquals(model:getFocusedWindowForVirtualSpace(1), 100)
	lu.assertEquals(model:getFocusedWindowForVirtualSpace(2), 200)
	lu.assertEquals(model:getFocusedWindowForVirtualSpace(3), 300)
end

function TestSpacesModel:testSaveNilWindowId()
	local model = SpacesModel.new()

	model:saveFocusedWindowInVirtualSpace(1, nil)

	lu.assertNil(model:getFocusedWindowForVirtualSpace(1))
end

function TestSpacesModel:testAssignWindowToVirtualSpace()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)

	lu.assertEquals(model:getVirtualSpaceForWindow(100), 1)
end

function TestSpacesModel:testAssignMultipleWindowsToSameVirtualSpace()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:assignWindowToVirtualSpace(200, 1)
	model:assignWindowToVirtualSpace(300, 2)

	lu.assertEquals(model:getVirtualSpaceForWindow(100), 1)
	lu.assertEquals(model:getVirtualSpaceForWindow(200), 1)
	lu.assertEquals(model:getVirtualSpaceForWindow(300), 2)
end

function TestSpacesModel:testReassignWindowToDifferentVirtualSpace()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:assignWindowToVirtualSpace(100, 2)

	lu.assertEquals(model:getVirtualSpaceForWindow(100), 2)
end

function TestSpacesModel:testRemoveWindow()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:removeWindow(100)

	lu.assertNil(model:getVirtualSpaceForWindow(100))
end

function TestSpacesModel:testRemoveNonExistentWindow()
	local model = SpacesModel.new()

	model:removeWindow(999)

	lu.assertNil(model:getVirtualSpaceForWindow(999))
end

function TestSpacesModel:testGetVirtualSpaceForNonExistentWindow()
	local model = SpacesModel.new()

	lu.assertNil(model:getVirtualSpaceForWindow(999))
end

function TestSpacesModel:testGetWindowsInVirtualSpace()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:assignWindowToVirtualSpace(200, 1)
	model:assignWindowToVirtualSpace(300, 2)

	local windows = model:getWindowsInVirtualSpace(1)

	lu.assertEquals(#windows, 2)
	lu.assertTrue(table.contains(windows, 100))
	lu.assertTrue(table.contains(windows, 200))
end

function TestSpacesModel:testGetWindowsInEmptyVirtualSpace()
	local model = SpacesModel.new()

	local windows = model:getWindowsInVirtualSpace(1)

	lu.assertEquals(#windows, 0)
end

function TestSpacesModel:testGetAllWindowMappings()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:assignWindowToVirtualSpace(200, 2)
	model:assignWindowToVirtualSpace(300, 1)

	local mappings = model:getAllWindowMappings()

	lu.assertEquals(mappings[100], 1)
	lu.assertEquals(mappings[200], 2)
	lu.assertEquals(mappings[300], 1)
end

function TestSpacesModel:testGetAllWindowMappingsWhenEmpty()
	local model = SpacesModel.new()

	local mappings = model:getAllWindowMappings()

	lu.assertEquals(next(mappings), nil)
end

function TestSpacesModel:testReassignWindowRemovesFromOldSpace()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:assignWindowToVirtualSpace(200, 1)
	model:assignWindowToVirtualSpace(100, 2)

	local space1Windows = model:getWindowsInVirtualSpace(1)
	local space2Windows = model:getWindowsInVirtualSpace(2)

	lu.assertEquals(#space1Windows, 1)
	lu.assertTrue(table.contains(space1Windows, 200))
	lu.assertFalse(table.contains(space1Windows, 100))

	lu.assertEquals(#space2Windows, 1)
	lu.assertTrue(table.contains(space2Windows, 100))
end

function TestSpacesModel:testRemoveWindowFromSpaceWithMultipleWindows()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:assignWindowToVirtualSpace(200, 1)
	model:assignWindowToVirtualSpace(300, 1)
	model:removeWindow(200)

	local windows = model:getWindowsInVirtualSpace(1)

	lu.assertEquals(#windows, 2)
	lu.assertTrue(table.contains(windows, 100))
	lu.assertTrue(table.contains(windows, 300))
	lu.assertFalse(table.contains(windows, 200))
end

function TestSpacesModel:testRemoveLastWindowLeavesSpaceEmpty()
	local model = SpacesModel.new()

	model:assignWindowToVirtualSpace(100, 1)
	model:removeWindow(100)

	local windows = model:getWindowsInVirtualSpace(1)

	lu.assertEquals(#windows, 0)
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

return TestSpacesModel
