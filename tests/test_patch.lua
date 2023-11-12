local lu = require('wm2.lib.luaunit')
local wm2 = require('wm2')

-- Test patch with SmolP
TestPatch = {}

function TestPatch:setUp()
    self.server = wm2.Server()
    self.smolp0 = wm2.SmolP(self.server, 'test')
    self.smolp1 = wm2.SmolP(self.server, 'test2')
    self.smolid0 = self.smolp0.smolid
    self.smolid1 = self.smolp1.smolid
    self.patch = wm2.Patch(self.smolp0, self.smolp1)
end

function TestPatch:tearDown()
    self.server:stop()
end

-- Test that getting a 'SmolP' works with the 'patch.smolps[SmolId]' syntax.
function TestPatch:test_get_smolp()
    lu.assertEquals(self.patch.smolps[self.smolid0], self.smolp0)
    lu.assertEquals(self.patch.smolps[self.smolid1], self.smolp1)
end

-- Test that asking a patch for its size returns the number of 'SmolP'
-- inside a patch.
function TestPatch:test_smolp_count()
    lu.assertEquals(self.patch.smolp_count, 2)
end


-- Test patch with SmolCsound
TestCsoundPatch = {}

function TestCsoundPatch:setUp()
    self.server = wm2.Server()
    self.smolcsound0 = wm2.SmolCsound(
        self.server,
        'test',
        [[
  asig oscil 1, 200
  out asig]]
    )
    self.patch = wm2.Patch(self.smolcsound0)
end


function TestCsoundPatch:tearDown()
    self.server:stop()
end

function TestCsoundPatch:test_csound_orchestra()
    lu.assertEquals(
        self.patch.csound_orchestra,
[[

instr "smolcsound.instr"
  asig oscil 1, 200
  out asig
endin]]
    )
end

os.exit(lu.LuaUnit.run())
