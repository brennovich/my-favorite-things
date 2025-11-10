local lu = require('luaunit')

TestWindowsSort = require('tests/test_windows_sort')
TestSpacesModel = require('tests/test_spaces_model')
TestNativeSpaceManager = require('tests/test_native_space_manager')
TestVirtualSpacesWindowDestroyed = require('tests/test_virtual_spaces')

os.exit(lu.LuaUnit.run())
