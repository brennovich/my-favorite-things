rockspec_format = "3.0"
package = "WMUtils"
version = "1.0-1"

source = {
   url = "."
}

description = {
   summary = "Series of hlua scripts for window management on macOS",
   detailed = [[
     Inspired on 2bwm and wmutils for Linux, this is a collection of
     Hammerspoon scripts to manage windows on macOS.
   ]],
   homepage = "https://github.com/brennovich/WMUtils.spoon",
   license = "MIT"
}

dependencies = {
   "lua >= 5.3"
}

test_dependencies = {
   "luaunit >= 3.4"
}

build = {
   type = "none"
}

test = {
   type = "command",
   command = "eval $(luarocks --local path) && lua tests/test.lua -o TAP"
}
