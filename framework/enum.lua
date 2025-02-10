
function enum(tbl)
    local i = 1
    for key, value in pairs(tbl) do
        tbl[key] = nil
        tbl[value] = i
        i = i + 1
    end
    setmetatable(tbl, {
        __index = function(tbl, key) error("ERROR: Constant '"..tostring(key).."' not in enum") end,
        __newindex = function() error("ERROR: Enums are immutable") end
    })
    return tbl
end
