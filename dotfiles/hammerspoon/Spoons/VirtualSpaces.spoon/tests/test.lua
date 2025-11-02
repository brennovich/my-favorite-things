local lu = require('luaunit')

TestWindowsSort = require('tests/test_windows_sort')
TestSpacesModel = require('tests/test_spaces_model')
TestNativeSpaceManager = require('tests/test_native_space_manager')

os.exit(lu.LuaUnit.run())
