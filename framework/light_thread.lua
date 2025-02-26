
love.

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

        if occlusion_map[current] then -- Tile occluded
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