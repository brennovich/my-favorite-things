local lu = require('luaunit')

TestWMUtilsVirtualSpacesIntegration = {}

function TestWMUtilsVirtualSpacesIntegration:setUp()
	_G.hs = {
		hotkey = {
			modal = {
				new = function()
					return {
						entered = function() end,
						exited = function() end,
						exit = function() end
					}
				end
			}
		}
	}

	self.subscribedCallbacks = {}
	local mockVirtualSpaces = {
		subscribe = function(self, eventType, callback)
			table.insert(TestWMUtilsVirtualSpacesIntegration.subscribedCallbacks, {
				eventType = eventType,
				callback = callback
			})
			return self
		end
	}

	_G.spoon = { VirtualSpaces = mockVirtualSpaces }

	package.loaded['WMUtils'] = nil
	self.WMUtils = dofile('init.lua')
end

function TestWMUtilsVirtualSpacesIntegration:testInitSubscribesToVirtualSpaceChanged()
	self.WMUtils:init()

	lu.assertEquals(#self.subscribedCallbacks, 1)
	lu.assertEquals(self.subscribedCallbacks[1].eventType, "virtualSpaceChanged")
end

function TestWMUtilsVirtualSpacesIntegration:testVirtualSpaceChangedExitsResizeModal()
	self.WMUtils:setupResizeModal()
	self.WMUtils:init()

	local modalExitCalled = false
	self.WMUtils.resizeModal.exit = function()
		modalExitCalled = true
	end

	local callback = self.subscribedCallbacks[1].callback
	callback({
		eventType = "virtualSpaceChanged",
		currentSpace = { id = 2, windowCount = 0, windows = {} }
	})

	lu.assertTrue(modalExitCalled)
end

return { TestWMUtilsVirtualSpacesIntegration }
