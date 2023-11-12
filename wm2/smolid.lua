-- SmolId encapsulates the ID of a SmolP
--
local class = require('wm2.lib.middleclass')
local utils = require('wm2.utils')
local WM2Object = require('wm2.wm2object')
local SmolId = class('SmolId', WM2Object)

function SmolId:initialize(smolp_type, replication_key)
    utils.isarg(smolp_type, 'smolp_type')
    utils.isarg(replication_key, 'replication_key')
    self.smolp_type = smolp_type:lower()
    self.replication_key = replication_key
    WM2Object.initialize(self)
end

function SmolId:__tostring()
    -- NOTE: We use delimiter '_', because this is allowed in
    -- Csound instrument names.
    return self.smolp_type .. '_' .. self.replication_key
end

return SmolId
