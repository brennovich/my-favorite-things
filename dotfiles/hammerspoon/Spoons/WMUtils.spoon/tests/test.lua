local lu = require('luaunit')

local testModules = require('tests/test_wmutils')
TestWMUtilsTelescope = testModules[1]
TestWMUtilsCenterWindow = testModules[2]
TestWMUtilsMonocle = testModules[3]
TestWMUtilsGridToggle = testModules[4]

os.exit(lu.LuaUnit.run())
