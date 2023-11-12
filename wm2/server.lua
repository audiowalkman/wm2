-- Server encapsulates the public API and global constants that
-- are used by small ('smol') programs.

local luaCsnd6 = require('luaCsnd6')
local log = require('wm2.lib.log')
local class = require('wm2.lib.middleclass')
local utils = require('wm2.utils')
local WM2Object = require('wm2.wm2object')
local Server = class('Server', WM2Object)

function Server:initialize(options)
    WM2Object.initialize(self)
    self.csound = luaCsnd6.Csound()
    local o, p = options, utils.pop
    csound_options = {
        "-odac",
        "-d",
        "--sched",
        "--nchnls=" .. (p(o, 'channel_count') or 1),
        "--sample-rate=" .. (p(o, 'sampling_rate') or 44100),
        "--control-rate=" .. (p(o, 'control_rate') or 4410),
        "--messagelevel=0",
        "--logfile=./.wm2csound.log",
    }
    for _, csound_option in ipairs(csound_options) do
        self:debug("set csound flag", csound_option)
        self.csound:SetOption(csound_option)
    end
    utils.unused_options(o, function (msg) self:warning(msg) end)
end

function Server:__tostring()
    return "Server()"
end

-- Start server by loading patch into program. If another patch
-- was present all running SmolP are stopped and their states are
-- dropped.
function Server:start(patch)
    self:info("Start server with patch '" .. tostring(patch) .. "'")
    self:stop()
    self.patch = patch
    local orc = patch.csound_orchestra
    self:debug("Set csound orchestra to\n\n" .. orc .. '\n')
    self.csound:CompileOrc(orc)
    self.csound:Start()
end

-- Stops all runnings processes, reset patch, close csound server.
function Server:stop()
    self:info("Stop server")
    self:panic()
    self.patch = nil
    self.csound:Stop()
end

-- Unconditionally stop all playing 'SmolP'.
function Server:panic()
    self:debug("panic")
    if self.patch then
        for _, smolp in pairs(self.patch.smolps) do
            smolp:stop()
            smolp.smolstate:reset()
        end
    end
end

-- XXX: request_start / request_stop should have LOCKS! I think it's dangerous
-- to run multiple 'request_start' / 'request_stop' simultaneously, they should
-- always be sequential...

-- Alternatively we need a 'queue' and the main thread always handles the request
-- calls sequentially (begin with the oldest, if done, continue with the next one).
-- 
-- But with a queue, we don't immediately get the error state (if it worked or not).
-- But maybe it doesn't need to be an error, but's it's sufficient if it's logged inside
-- the server.
--
-- And another advantage of using queues vs. using locks is that the 'request_start/stop'
-- calls aren't blocking if another call is already there.

-- Request start of 'SmolP' with 'SmolId'. 'requester' is also a 'SmolId'.
function Server:request_start(smolid, requester, ...)
    function err(message)
        error("start request rejected: " .. message)
    end

    self:debug(tostring(requester) .. " requests start of " .. tostring(smolid))

    utils.isarg(smolid, 'smolid', err)
    utils.isarg(requester, 'requester', err)

    local arg = {...}  -- contains SmolP runtime state
    local smolp = self.patch.smolps[smolid]
    utils.isarg(smolp, "SmolP with SmolId '" .. tostring(smolid) .. "'", err)

    local smolstate = smolp.smolstate
    if smolp.active and not utils.table_eq(smolstate.runtime_arg, arg) then
        err(
            tostring(smolp) ..
            " is already running with a different state.\n\n\tRequested state: "
            .. tostring(arg) ..
            "\n\tRunning state: " .. tostring(smolstate.runtime_arg)
        )
    end

    if smolstate.requesters[requester] then
        err('requester ' .. tostring(requester) .. ' already requested ' .. tostring(smolp))
    end
    smolstate.requesters[requester] = 1

    if not smolp.active then
        -- NOTE: Only set state of SmolP if it isn't active, as
        -- it's forbidden otherwise. Also when SmolP is already running
        -- there isn't any reason why we should set it, because if
        -- it runs, it is already in the correct state.
        smolp:set_state(table.unpack(arg))
        smolp:start()
    end
end

-- Request stop of 'SmolP' with 'SmolId'. 'requester' is also a 'SmolId'.
function Server:request_stop(smolid, requester)
    function err(message)
        error("stop request rejected: " .. message)
    end

    self:debug(tostring(requester) .. " requests stop of " .. tostring(smolid))

    utils.isarg(smolid, 'smolid', err)
    utils.isarg(requester, 'requester', err)

    local smolp = self.patch.smolps[smolid]
    utils.isarg(smolp, "SmolP with SmolId '" .. tostring(smolid) .. "'", err)

    local smolstate = smolp.smolstate
    smolstate.requesters[requester] = nil
    if #(smolstate.requesters) == 0 then
        smolp:stop()
    end
end

return Server
