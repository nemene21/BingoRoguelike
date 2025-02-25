require "misc.lua"

local lights = {}
local lightmap = love.image.newImageData(20, 12)

local OFFSET = 1000
local WIDTH  = 2001

local function hash(x, y)
    x = x + OFFSET
    y = y + OFFSET
    return x + y * WIDTH
end

local function unhash(hash)
    local y = math.floor(hash / WIDTH)
    local x = hash % WIDTH
    return x - OFFSET, y - OFFSET
end

function add_light(pos, intensity)
    local x, y = world2screen(pos:get())
    x = math.floor(x / 8)
    y = math.floor(y / 8)

    table.insert(lights, {
        x = x, y = y,
        intensity = intensity
    })
end

local function calculate_light(light)
    local light_vals = {}
    local queue = Queue()

    queue:push(hash(light_vals.x + 1, light_vals.y))
    queue:push(hash(light_vals.x - 1, light_vals.y))
    queue:push(hash(light_vals.x, light_vals.y + 1))
    queue:push(hash(light_vals.x, light_vals.y - 1))

    while not queue:empty() do

    end
end

function calculate_lights()
    for i, light in ipairs(lights) do
        calculate_light(light)
    end
    lights = {}
end

