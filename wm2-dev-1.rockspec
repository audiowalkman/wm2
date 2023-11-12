package = "wm2"
version = "dev-1"
source = {
   url = "git+https://github.com/audiowalkman/wm2"
}
description = {
   summary = "vi for audio",
   detailed = [[
vi for audio
]],
   homepage = "https://github.com/audiowalkman/wm2",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua ~> 5.4"
}
build = {
   type = "builtin",
   modules = {
      t = "t.lua",
      ["tests.test_patch"] = "tests/test_patch.lua",
      ["tests.test_server"] = "tests/test_server.lua",
      ["tests.test_smolcsound"] = "tests/test_smolcsound.lua",
      ["wm2.init"] = "wm2/init.lua",
      ["wm2.lib.log"] = "wm2/lib/log.lua",
      ["wm2.lib.luaunit"] = "wm2/lib/luaunit.lua",
      ["wm2.lib.middleclass"] = "wm2/lib/middleclass.lua",
      ["wm2.main"] = "wm2/main.lua",
      ["wm2.parser"] = "wm2/parser.lua",
      ["wm2.patch"] = "wm2/patch.lua",
      ["wm2.server"] = "wm2/server.lua",
      ["wm2.smolcsound"] = "wm2/smolcsound.lua",
      ["wm2.smolid"] = "wm2/smolid.lua",
      ["wm2.smolp"] = "wm2/smolp.lua",
      ["wm2.smolstate"] = "wm2/smolstate.lua",
      ["wm2.smoltui"] = "wm2/smoltui.lua",
      ["wm2.utils"] = "wm2/utils.lua",
      ["wm2.wm2object"] = "wm2/wm2object.lua"
   },
   copy_directories = {
      "tests"
   }
}
