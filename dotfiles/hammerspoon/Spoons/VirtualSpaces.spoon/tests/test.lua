local lu = require('luaunit')

TestWindowsSort = require('tests/test_windows_sort')
TestWindowFocus = require('tests/test_window_focus')

os.exit(lu.LuaUnit.run())
