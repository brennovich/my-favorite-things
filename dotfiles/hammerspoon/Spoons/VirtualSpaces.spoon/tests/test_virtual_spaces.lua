local lu = require('luaunit')
local SpacesModel = require('SpacesModel')

TestVirtualSpacesWindowDestroyed = {}

function TestVirtualSpacesWindowDestroyed:setUp()
	self.model = SpacesModel.new()
	self.focusedWindowId = nil
	self.focusedWindow = nil
end

function TestVirtualSpacesWindowDestroyed:testRestoresFocusToAnotherWindowInSameVirtualSpace()
	self.model:assignWindowToVirtualSpace(1, 1)
	self.model:assignWindowToVirtualSpace(2, 1)
	self.model:saveFocusedWindowInVirtualSpace(1, 1)

	self.model:removeWindow(1)

	local windows = self.model:getWindowsInVirtualSpace(1)

	lu.assertEquals(#windows, 1)
	lu.assertTrue(table.contains(windows, 2))
end

function TestVirtualSpacesWindowDestroyed:testDoesNotFocusWindowInDifferentVirtualSpace()
	self.model:assignWindowToVirtualSpace(1, 1)
	self.model:assignWindowToVirtualSpace(2, 2)
	self.model:saveFocusedWindowInVirtualSpace(1, 1)

	self.model:removeWindow(1)

	local windows1 = self.model:getWindowsInVirtualSpace(1)
	local windows2 = self.model:getWindowsInVirtualSpace(2)

	lu.assertEquals(#windows1, 0)
	lu.assertEquals(#windows2, 1)
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

return TestVirtualSpacesWindowDestroyed
