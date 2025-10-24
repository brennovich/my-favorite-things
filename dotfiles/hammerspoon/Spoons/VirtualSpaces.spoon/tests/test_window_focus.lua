local lu = require('luaunit')

local WindowFocus = require('WindowFocus')

TestWindowFocus = {}

function TestWindowFocus:testNew()
	local focus = WindowFocus.new()

	lu.assertNotNil(focus)
	lu.assertNotNil(focus._focusedWindows)
end

function TestWindowFocus:testSaveFocusedWindowInVirtualSpace()
	local focus = WindowFocus.new()

	focus:saveFocusedWindowInVirtualSpace(1, 100)

	lu.assertEquals(focus._focusedWindows[1], 100)
end

function TestWindowFocus:testGetFocusedWindowForVirtualSpace()
	local focus = WindowFocus.new()

	focus:saveFocusedWindowInVirtualSpace(1, 100)
	local windowId = focus:getFocusedWindowForVirtualSpace(1)

	lu.assertEquals(windowId, 100)
end

function TestWindowFocus:testGetFocusedWindowForNonExistentVirtualSpace()
	local focus = WindowFocus.new()

	local windowId = focus:getFocusedWindowForVirtualSpace(999)

	lu.assertNil(windowId)
end

function TestWindowFocus:testOverwriteFocusedWindowInVirtualSpace()
	local focus = WindowFocus.new()

	focus:saveFocusedWindowInVirtualSpace(1, 100)
	focus:saveFocusedWindowInVirtualSpace(1, 200)

	lu.assertEquals(focus:getFocusedWindowForVirtualSpace(1), 200)
end

function TestWindowFocus:testMultipleVirtualSpaces()
	local focus = WindowFocus.new()

	focus:saveFocusedWindowInVirtualSpace(1, 100)
	focus:saveFocusedWindowInVirtualSpace(2, 200)
	focus:saveFocusedWindowInVirtualSpace(3, 300)

	lu.assertEquals(focus:getFocusedWindowForVirtualSpace(1), 100)
	lu.assertEquals(focus:getFocusedWindowForVirtualSpace(2), 200)
	lu.assertEquals(focus:getFocusedWindowForVirtualSpace(3), 300)
end

function TestWindowFocus:testSaveNilWindowId()
	local focus = WindowFocus.new()

	focus:saveFocusedWindowInVirtualSpace(1, nil)

	lu.assertNil(focus:getFocusedWindowForVirtualSpace(1))
end

return TestWindowFocus
