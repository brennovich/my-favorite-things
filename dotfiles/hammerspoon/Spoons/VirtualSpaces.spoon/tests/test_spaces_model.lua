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

return TestSpacesModel
