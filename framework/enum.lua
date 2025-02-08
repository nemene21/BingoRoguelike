
function enum(tbl)
    local i = 1
    for key, value in pairs(tbl) do
        tbl[key] = nil
        tbl[value] = i
    end
    setmetatable(tbl, {
        __index = function(tbl, key) error("ERROR: Constant '"..tostring(key).."' not in enum"),
        __newindex = function() error("ERROR: Enums are immutable") end
    })
end
