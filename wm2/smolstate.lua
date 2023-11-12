-- SmolState hosts the current state of a SmolP
-- inside WM2. It is composed of two attributes:
--
--  (1) runtime_arg: This table hosts the runtime arguments
--          of the smol program.
--
--  (2) requesters: This table hosts which 'SmolP' requested
--          the start of the 'SmolP'. If this table is empty, the
--          'SmolP' should be stopped.

local class = require 'wm2.lib.middleclass'
local WM2Object = require('wm2.wm2object')
local SmolState = class('SmolState', WM2Object)

function SmolState:initialize()
    self:reset()
    WM2Object.initialize(self)
end

function SmolState:reset()
    self.runtime_arg = {}
    self.requesters = {}
end

return SmolState
