local lu = require('luaunit')

local testModules = require('tests/test_wmutils')
TestWMUtilsFullscreen = testModules[1]
TestWMUtilsCenterWindow = testModules[2]

os.exit(lu.LuaUnit.run())
