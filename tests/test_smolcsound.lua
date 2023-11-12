local lu = require('wm2.lib.luaunit')
local wm2 = require('wm2')

TestSmolCsound = {}

function TestSmolCsound:setUp()
    self.server = wm2.Server()
    self.smolcsound0 = wm2.SmolCsound(
        self.server,
        'test',
        {csound_code=[[
  asig oscil 0.4, 200
  kenv linenr 1, 2, 2, 0.005
  out asig * kenv
]]
    })
    self.smolcsound1 = wm2.SmolCsound(
        self.server,
        'test2',
        {csound_code=[[
  asig oscil 0.4, 200
  out asig]]
    }
    )
    self.patch = wm2.Patch(self.smolcsound0, self.smolcsound1)
    self.server:start(self.patch)
end

function TestSmolCsound:tearDown()
    self.server:stop()
end

function TestSmolCsound:test_start()
    self.smolcsound0:start()
    wm2.utils.sleep(4)
    -- self.smolcsound1:start()
    -- wm2.utils.sleep(2)
    self.smolcsound0:stop()
    wm2.utils.sleep(1)
    self.smolcsound0:start()
    wm2.utils.sleep(2)
    self.smolcsound0:stop()
    wm2.utils.sleep(3)
    -- self.smolcsound1:stop()
end

os.exit(lu.LuaUnit.run())
