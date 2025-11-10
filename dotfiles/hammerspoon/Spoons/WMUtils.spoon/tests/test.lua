local lu = require('luaunit')

local testModules = require('tests/test_wmutils')
TestWMUtilsMonocleMaximized = testModules[1]
TestWMUtilsCenterWindow = testModules[2]
TestWMUtilsMonocle = testModules[3]

os.exit(lu.LuaUnit.run())
