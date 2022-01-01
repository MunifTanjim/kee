cache = ".luacheckcache"
-- https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
  "211/_.*",
  "212/_.*",
  "213/_.*",
}
include_files = { "*.luacheckrc", "src/**/*.lua" }
std = "lua51+luajit"

-- vim: set filetype=lua :
