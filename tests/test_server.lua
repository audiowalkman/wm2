local lu = require('wm2.lib.luaunit')
local wm2 = require('wm2')

TestServer = {}

function TestServer:setUp()
    self.server = wm2.Server()
    self.smolp0 = wm2.SmolP(self.server, 'test')
    self.smolp1 = wm2.SmolP(self.server, 'test2')
    self.smolid0 = self.smolp0.smolid
    self.smolid1 = self.smolp1.smolid
    self.patch = wm2.Patch(self.smolp0, self.smolp1)
    self.server:start(self.patch)
end

function TestServer:tearDown()
    self.server:stop()
end

-- Simple test that ensures the state of 'SmolP' is
-- changed as expected by 'request_start' and 'request_stop'.
function TestServer:test_request_start_stop_state_is_set()
    self:_assert_smolp_unset()
    self.server:request_start(self.smolid0, self.smolid0, 10, 20)
    self:_assert_smolp_set()
    self.server:request_stop(self.smolid0, self.smolid0)
    self:_assert_smolp_unset(10, 20)
end

-- helper functions for 'test_request_start_stop_state_is_set'
function TestServer:_assert_smolp_unset(...)
    local arg = {...}
    lu.assertTrue(not self.smolp0.active)
    lu.assertEquals(self.smolp0.smolstate.runtime_arg, arg)
    lu.assertEquals(self.smolp0.smolstate.requesters, {})
end

function TestServer:_assert_smolp_set()
    lu.assertTrue(self.smolp0.active)
    lu.assertEquals(self.smolp0.smolstate.runtime_arg, {10, 20})
    lu.assertEquals(self.smolp0.smolstate.requesters, {[self.smolid0] = 1})
end

-- Test that 'request_start' fails if no smolid is provided
function TestServer:test_request_start_without_smolid()
    lu.assertErrorMsgContains('smolid missing', function() self.server:request_start() end)
end

-- Test that 'request_start' fails if no requester is provided
function TestServer:test_request_start_without_requester()
    lu.assertErrorMsgContains('requester missing', function () self.server:request_start(self.smolid0) end)
end

-- Test that 'request_start' fails if no SmolP exists with provided SmolKey
function TestServer:test_request_start_with_undefined_smolkey()
    lu.assertErrorMsgContains(
        "SmolP with SmolId '1' missing",
        function () self.server:request_start(1, self.smolid0) end
    )
end

-- Test that 'request_start' fails if SmolP is already running with a different state
function TestServer:test_request_start_with_different_state()
    function req(...)
        local state = {...}
        self.server:request_start(self.smolid0, self.smolid0, table.unpack(arg))
    end
    req(10, 20)
    lu.assertErrorMsgContains('is already running with a different state', req, 5)
end

-- Test that 'request_start' fails if requester already requested SmolP
function TestServer:test_request_start_with_different_state()
    function req()
        self.server:request_start(self.smolid0, self.smolid0)
    end
    req()
    lu.assertErrorMsgContains('requester ' .. tostring(self.smolid0) .. ' already requested', req)
end

-- Test that 'request_stop' fails if no smolid is provided
function TestServer:test_request_stop_without_smolid()
    lu.assertErrorMsgContains('smolid missing', function() self.server:request_stop() end)
end

-- Test that 'request_stop' fails if no requester is provided
function TestServer:test_request_stop_without_requester()
    lu.assertErrorMsgContains('requester missing', function() self.server:request_stop(self.smolid0) end)
end

-- Test that 'request_stop' fails if SmolP with smolid is not defined in patch
function TestServer:test_request_stop_undefined_smolp()
    lu.assertErrorMsgContains(
        "SmolP with SmolId '1' missing",
        function () self.server:request_stop(1, self.smolid0) end
    )
end

function TestServer:test_panic()
    print(self.smolp0.active, 'smolp0 active?')
    self.server:request_start(self.smolid0, self.smolid0)
    self.server:request_start(self.smolid1, self.smolid1, 1, 2)
    self.server:panic()
    print(self.smolp0.active, 'smolp0 active?')
    lu.assertFalse(self.smolp0.active)
    lu.assertFalse(self.smolp1.active)
    lu.assertEquals(#self.smolp1.smolstate.runtime_arg, 0)
end

os.exit(lu.LuaUnit.run())
