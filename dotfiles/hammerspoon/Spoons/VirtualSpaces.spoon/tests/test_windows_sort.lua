local lu = require('luaunit')

local WindowsSort = require('WindowsSort')

TestWindowsSort = {}

function TestWindowsSort:testNew()
	local mockMover = function() end
	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	lu.assertEquals(sorter._activeNativeSpaceId, "active-123")
	lu.assertEquals(sorter._storageNativeSpaceId, "storage-456")
end

function TestWindowsSort:testMovesTargetVirtualSpaceWindowsToActiveSpace()
	local moves = {}
	local mockMover = function(winId, spaceId)
		table.insert(moves, {winId = winId, spaceId = spaceId})
	end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {"win2", "win3"},
		toStorage = {"win1"},
		others = {}
	}

	sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(categorizedWindows, "active-123")

	local targetMoves = {}
	for _, move in ipairs(moves) do
		if move.winId == "win2" or move.winId == "win3" then
			table.insert(targetMoves, move)
		end
	end

	lu.assertEquals(#targetMoves, 2)
	lu.assertEquals(targetMoves[1].spaceId, "active-123")
	lu.assertEquals(targetMoves[2].spaceId, "active-123")
end

function TestWindowsSort:testMovesCurrentVirtualSpaceWindowsToStorageSpace()
	local moves = {}
	local mockMover = function(winId, spaceId)
		table.insert(moves, {winId = winId, spaceId = spaceId})
	end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {"win2"},
		toStorage = {"win1"},
		others = {}
	}

	sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(categorizedWindows, "active-123")

	local currentMove = nil
	for _, move in ipairs(moves) do
		if move.winId == "win1" then
			currentMove = move
		end
	end

	lu.assertNotNil(currentMove)
	lu.assertEquals(currentMove.spaceId, "storage-456")
end

function TestWindowsSort:testSwapsSpacesWhenCurrentNativeSpaceIsStorage()
	local mockMover = function() end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {"win2"},
		toStorage = {"win1"},
		others = {}
	}

	local newActive, newStorage = sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(
		categorizedWindows, "storage-456"
	)

	lu.assertEquals(newActive, "storage-456")
	lu.assertEquals(newStorage, "active-123")
end

function TestWindowsSort:testMovesOtherWindowsToStorageWhenSwapping()
	local moves = {}
	local mockMover = function(winId, spaceId)
		table.insert(moves, {winId = winId, spaceId = spaceId})
	end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {"win2"},
		toStorage = {"win1"},
		others = {"win3"}
	}

	sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(categorizedWindows, "storage-456")

	local win3Move = nil
	for _, move in ipairs(moves) do
		if move.winId == "win3" then
			win3Move = move
		end
	end

	lu.assertNotNil(win3Move)
	lu.assertEquals(win3Move.spaceId, "active-123")
end

function TestWindowsSort:testDoesNotSwapWhenCurrentNativeSpaceIsActive()
	local mockMover = function() end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {},
		toStorage = {},
		others = {}
	}

	local newActive, newStorage = sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(
		categorizedWindows, "active-123"
	)

	lu.assertEquals(newActive, "active-123")
	lu.assertEquals(newStorage, "storage-456")
end

function TestWindowsSort:testHandlesEmptyWindowMap()
	local moveCount = 0
	local mockMover = function()
		moveCount = moveCount + 1
	end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {},
		toStorage = {},
		others = {}
	}

	sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(categorizedWindows, "active-123")

	lu.assertEquals(moveCount, 0)
end

function TestWindowsSort:testPersistsSwappedSpacesInInstance()
	local mockMover = function() end

	local sorter = WindowsSort.new(mockMover, "active-123", "storage-456")

	local categorizedWindows = {
		toActive = {},
		toStorage = {},
		others = {}
	}

	sorter:mapWindowsToNativeSpacesFromCurrentNativeSpace(categorizedWindows, "storage-456")

	lu.assertEquals(sorter._activeNativeSpaceId, "storage-456")
	lu.assertEquals(sorter._storageNativeSpaceId, "active-123")
end

return TestWindowsSort
