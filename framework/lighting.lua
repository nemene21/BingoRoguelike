require "framework.misc"

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

local sqrt2 = math.sqrt(2)

local point_queue = Queue()
local function calculate_light(light, occlusion_map)
    local light_vals = {}
    point_queue:clear()

    if tile_occluded(light.x, light.y) then return light_vals end

    point_queue:push(hash(light.x + 1, light.y))
    point_queue:push(hash(light.x - 1, light.y))
    point_queue:push(hash(light.x, light.y + 1))
    point_queue:push(hash(light.x, light.y - 1))
    light_vals[hash(light.x, light.y)] = light.intensity

    local current
    local cx, cy -- Current x, y
    while not point_queue:empty() do
        current = point_queue:pop()
        cx, cy = unhash(current)

        if tile_occluded(cx, cy) then -- Tile occluded
            light_vals[current] = 0
            goto continue
        end

        local brightest = -1
        local dist = -1
        local neighbor_hash
        local neighbor_brightness

        for i, neighbor in ipairs(NEIGHBOR_KERNEL) do
            neighbor_hash = hash(cx + neighbor[1], cy + neighbor[2])
            neighbor_brightness = light_vals[neighbor_hash]

            if neighbor_brightness then
                if neighbor_brightness > brightest then
                    brightest = neighbor_brightness
                    dist = (neighbor[1] == 0 or neighbor[2] == 0) and 1 or sqrt2
                end
            end
        end

        light_vals[current] = brightest - dist
        if light_vals[current] > 1 then
            local neighbor
            neighbor = hash(cx + 1, cy)
            if light_vals[neighbor] == nil then point_queue:push(neighbor) end

            neighbor = hash(cx - 1, cy)
            if light_vals[neighbor] == nil then point_queue:push(neighbor) end

            neighbor = hash(cx, cy + 1)
            if light_vals[neighbor] == nil then point_queue:push(neighbor) end

            neighbor = hash(cx, cy - 1)
            if light_vals[neighbor] == nil then point_queue:push(neighbor) end
        end
        ::continue::
    end
    return light_vals
end

function calculate_lights()
    lightmap:mapPixel(function(x, y, r, g, b, a)
        return 0, 0, 0, 1
    end)

    local occlusion_map = {}
    for key, chunk in pairs(loaded_chunks) do
        for index, tile in pairs(chunk.tilemap.tiledata) do
            
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

