local utils = {}

-- Check if two tables are equal,
-- see https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua
function utils.table_eq(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

-- Test that 'arg' is not 'nil' or 'false'.
function utils.isarg(arg, name, err)
    if not err then
        err = error
    end

    if not arg then
        err(name .. " missing")
    end
end

-- Sleep for 'n' seconds
function utils.sleep(n)
    -- Is this only linux/unix compatible?
    -- Could it be more precise?
    os.execute("sleep " .. tonumber(n))
end

-- Pop value with 'key' from table
function utils.pop(table, key)
    if not table then return end
    local value = table[key]
    table[key] = nil
    return value
end

-- Warn unused options
function utils.unused_options(options, warn)
    if not options then return end
    for key, value in pairs(options) do
        warn("Unused option key = " .. key .. "; value = " .. value)
    end
end

return utils
