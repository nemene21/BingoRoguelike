msgpack = require "msgpack.luajit-msgpack-pure"
local class_registry = {}


function table.entries(tbl)
    local i = 0
    for k, v in pairs(tbl) do
        i = i + 1
    end
    return i
end

local function create(creating, ...)
    local instance = setmetatable({}, creating)
    if instance.new then
        instance:new(...)
    end
    return instance
end

function class(superclass)
    local making = setmetatable({}, {
        __index = superclass,
        __call = create
    })
    making.__index = making
    making.__name = tostring(table.entries(class_registry) + 1)
    class_registry[making.__name] = making

    return making
end

function class2string(tbl, init_args, ...)
    local data = {
        class_name = tbl.__name,
        init_args  = table.shallow_copy(init_args or {}),
        properties = {}
    }
    local args = {...}
    for i, key in ipairs(args) do
        data.properties[key] = tbl[key]
    end
    return msgpack.pack(data)
end

function string2class(data)
    local offset, data = msgpack.unpack(data)
    local tbl = class_registry[data.class_name](unpack(data.init_args))
    for key, value in pairs(data.properties) do
        tbl[key] = value
    end
    return tbl
end