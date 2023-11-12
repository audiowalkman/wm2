-- The following functions help parsing yml files to 'wm2.Patch' objects.

local lyaml = require('lyaml')
local log = require('wm2.lib.log')
local Server = require('wm2.server')
local Patch = require('wm2.patch')

local smolp_registry = {}

function register_smolp(smolp_type, name)
    smolp_registry[name] = smolp_type
end

function parse_yml(yml)
    local table = lyaml.load(yml)

    -- Configure wm2 server
    local configuration = table.configure or {}
    -- Declare all used SmolP
    local declaration = table.declare or {}
    -- Register new SmolP types
    local registration = table.register or {}

    register_registration(registration)
    local server = Server(configuration)
    local patch = declaration_to_patch(declaration, table)

    return server, patch
end

function declaration_to_patch(declaration, table)
    patch_arg = {}
    for smolp_name, replications in pairs(declaration) do
        local smolp_type = smolp_registry[smolp_name]
        if smolp_type then
            for replication_key, options in pairs(replications or {}) do
                smolp = smolp_type(server, replication_key, options)
                table.insert(patch_arg, smolp)
            end
        else
            log:warning("Couldn't find smolp_type with name " .. smolp_name ". IGNORED")
        end
    end
    return Patch(table.unpack(patch_arg))
end

function register_registration(registration)
end

return register_smolp, parse_yml
