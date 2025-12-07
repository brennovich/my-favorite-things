local lu = require('luaunit')

local testModules = require('tests/test_wmutils')
TestWMUtilsTelescope = testModules[1]
TestWMUtilsCenterWindow = testModules[2]
TestWMUtilsMonocle = testModules[3]
TestWMUtilsGridToggle = testModules[4]

local bindHotkeysModules = require('tests/test_bind_hotkeys')
TestWMUtilsBindHotkeys = bindHotkeysModules[1]
TestWMUtilsBindResizeHotkeys = bindHotkeysModules[2]

local tileModules = require('tests/test_tile')
TestWMUtilsTile = tileModules[1]

os.exit(lu.LuaUnit.run())
