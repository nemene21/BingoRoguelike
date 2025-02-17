
function enum(tbl)
    local enumerated = {}
    for i, value in ipairs(tbl) do
        enumerated[value] = i
    end
    setmetatable(tbl, {
        __index = function(tbl, key) error("ERROR: Constant '"..tostring(key).."' not in enum") end,
        __newindex = function() error("ERROR: Enums are immutable") end
    })
    return enumerated
end
