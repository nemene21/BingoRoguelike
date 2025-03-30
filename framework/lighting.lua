local thread = love.thread.newThread("threads/light_thread.lua")
local channel_in  = love.thread.getChannel("light_request")
local channel_out = love.thread.getChannel("light_result")
thread:start(channel_in, channel_out)

local lights = {}
lightmap = love.image.newImageData(20, 12)
lightmap_image = love.graphics.newImage(lightmap)

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

local FIRST_TIME = true
function calculate_lights()
    local result = channel_out:pop()
    if not result and not FIRST_TIME then 
        lights = {}
        return nil
    end
    FIRST_TIME = false

    if result then
        lightmap = love.image.newImageData(20, 12, nil, result)
    end

    -- Calculating occlusion map
    local occlusion_map = {}
    for key, chunk in pairs(loaded_chunks) do
        for pos, tile in pairs(chunk.tilemap.tiledata) do
            local x = pos % chunk.tilemap.tilewidth + chunk.tilemap.tilepos.x
            local y = math.floor(pos / chunk.tilemap.tilewidth) + chunk.tilemap.tilepos.y

            -- Checks neighbors to see if tile is occluded
            for ox = -1, 1 do
                for oy = -1, 1 do
                    local neighbour_chunk = get_chunk_at_pos((x + ox) * 8, (y + oy) * 8)
                    if not neighbour_chunk then goto continue end
                    if not neighbour_chunk.tilemap:get_tile(x + ox, y + oy) then goto continue end
                end
            end

            x = x * 8 -- Transformation to screen tilepos 💀
            y = y * 8
            x, y = world2screen(x, y)
            x = math.floor(x * 0.125)
            y = math.floor(y * 0.125)
            occlusion_map[hash(x, y)] = true

            ::continue::
        end
    end

    channel_in:push({lights, occlusion_map})
    lightmap_image:replacePixels(lightmap)
    lights = {}
end

