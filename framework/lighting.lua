require "framework.misc"

local thread = love.thread.newThread("framework/light_thread.lua")
local channel_in  = love.thread.getChannel("light_request")
local channel_out = love.thread.getChannel("light_result")

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
    x = math.floor(x / 8 + 0.5)
    y = math.floor(y / 8 + 0.5)

    table.insert(lights, {
        x = x, y = y,
        intensity = intensity
    })
end

local NEIGHBOR_KERNEL = {
    { 1,  0}, { 0,  1},
    {-1,  0}, { 0, -1},
    { 1,  1}, { 1, -1},
    {-1, -1}, {-1,  1}
}

local function tile_occluded(x, y)
    local chunk = get_chunk_at_pos(screen2world(x * 8, y * 8))
    if not chunk then return false end

    for x2 = 0, 1 do
        for y2 = 0, 1 do
            local tilex, tiley = screen2world((x + x2) * 8, (y + y2) * 8)

            chunk = get_chunk_at_pos(tilex, tiley)
            if not chunk then return false end

            tilex = math.floor(tilex * 0.125)
            tiley = math.floor(tiley * 0.125)
            if not chunk.tilemap:get_tile(tilex, tiley) then return false end
        end
    end
    return true
end

function calculate_lights()
    -- Clearing the lightmap
    lightmap:mapPixel(function(x, y, r, g, b, a)
        return 0, 0, 0, 1
    end)

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

            x = x * 8
            y = y * 8
            x, y = world2screen(x, y)
            x = math.floor(x * 0.125)
            y = math.floor(y * 0.125)
            occlusion_map[hash(x, y)] = true

            ::continue::
        end
    end

    for i, light in ipairs(lights) do
        local light_vals = calculate_light(light, occlusion_map)

        local x, y
        for key, value in pairs(light_vals) do
            x, y = unhash(key)

            if x >= 0 and x < 20 and y >= 0 and y < 12 then
                lightmap:setPixel(x, y, value, value, value, 1)
            end
        end
    end
    lights = {}
    lightmap_image:replacePixels(lightmap)
end

