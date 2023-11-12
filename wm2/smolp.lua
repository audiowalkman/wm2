-- SmolP is a small ('smol') programm.
-- It can be started & stopped.
--
local class = require('wm2.lib.middleclass')
local utils = require('wm2.utils')
local WM2Object = require('wm2.wm2object')
local SmolId = require('wm2.smolid')
local SmolState = require('wm2.smolstate')
local SmolP = class('SmolP', WM2Object)

function SmolP:initialize(server, replication_key, options)
    -- Assert necessary arguments are set
    utils.isarg(server, 'server')
    utils.isarg(replication_key, 'replication_key')
    utils.unused_options(options, function (msg) self:warning(msg) end)
    self.server = server
    self.smolid = SmolId(self.class.name, replication_key)
    self.smolstate = SmolState()
    WM2Object.initialize(self)
    self:stop()
end

function SmolP:__tostring()
    return self.class.name .. '(' .. tostring(self.smolid) .. ')'
end

-- Set runtime state of SmolP
function SmolP:set_state(...)
    if self.active then
        error("Can't set state of " .. tostring(self) .. " while active")
    end
    self.smolstate.runtime_arg = {...}
    self:debug("set runtime arg to " .. tostring(self.smolstate.runtime_arg))
end

-- XXX: We need a 'delay' argument for 'start' & 'stop' and we need a 'duration' argument
-- for 'start'.
--
-- The most difficult thing about this is that we need to ensure that complicated cases as
--
--  - calling start with delay 3, but then already calling stop
--  - calling start with duration 4, but after 2 seconds calling stop
--  - ...
--
-- handled correctly.
--
-- Maybe there can always only be one 'active-state-changing' call
-- inside the queue?
--
-- So..
--
--  start(delay=2)                  translates to       start_call@TIME
--  start(delay=2,duration=2)       translates to       start_call@TIME,stop_call@TIME
--
-- and whenever 'start' or 'stop' is called again
--
-- ...
--
-- Do we really need this?
--
--  case FADEIN/FADEOUT => handle directly in Csound
--  case SEQUENCER      => handle in sequencer (
--              
--              for event in event_list do
--                  start_request
--                  wait
--                  stop_request
--              end
--
--         )


-- Start smol program
function SmolP:start()
    self:debug("start")
    self.active = true
end

-- Stop smol program
function SmolP:stop()
    self:debug("stop")
    self.active = false
end

return SmolP
