local fnl = require "fnl.fnl"

local BIOME_DATA
local cave_noise
local biome_noise

CHUNK_DIST = 2
CHUNKSIZE = 16

function ckey(x, y)
    return x..","..y
end

function from_ckey(str)
    local x, y = str:match("([^,]+),([^,]+)")
    return tonumber(x), tonumber(y)
end

loaded_chunks = {}

Chunk = class()
function Chunk:new(x, y)
    self.x = x
    self.y = y
    self.filename = "chunkdata/"..tostring(self.x)..","..tostring(self.y)..".chunk"
    self.entities = {}
    self.tilemap = nil

    loaded_chunks[ckey(x, y)] = self

    if lf.getInfo(self.filename) ~= nil then
        self:load()
    else
        self:generate()
    end
    self:load_fugitives()
end

function Chunk:unload()
    local chunk_data = {
        entities = {}
    }
    local entity
    for entity, _ in pairs(self.entities) do
        if not entity.alive then goto continue end
        entity:kill()
        table.insert(chunk_data.entities, entity:stringify())
        self.entities[entity] = nil
        ::continue::
    end

    local file = lf.newFile(self.filename)
    file:open("w")
    file:write(msgpack.pack(chunk_data))
    file:close()
end

function Chunk:load()
    local file = lf.newFile(self.filename)
    file:open("r")
    local strdata = file:read()
    local offset, chunk_data = msgpack.unpack(strdata)
    file:close()

    local entity
    for i, entity in ipairs(chunk_data.entities) do
        entity = string2class(entity)
        current_scene:add_entity(entity)
        self:add_entity(entity)
        if entity.__name == Tilemap.__name then
            self.tilemap = entity
        end
    end
end

function Chunk:add_entity(entity)
    self.entities[entity] = true
end

function Chunk:remove_entity(entity)
    self.entities[entity] = nil
end

function chunk_fugitive(entity)
    local chunkpos = entity.ChunkHandler.chunkpos
    local path = "chunkdata/fugitives/"..tostring(chunkpos.x)..","..tostring(chunkpos.y)..".ents"

    local frozen_ents
 
    local file = lf.newFile(path)
    if lf.getInfo(path) then
        file:open("r")
        local strdata = file:read()
        local offset, ents = msgpack.unpack(strdata)
        frozen_ents = ents
        file:close()
    else
        frozen_ents = {}
    end

    table.insert(frozen_ents, entity:stringify())
    file:open("w")
    file:write(msgpack.pack(frozen_ents))
    file:close()

    entity:kill()
end

function tile_raycast(fromx, fromy, tox, toy)
    local x, y = math.floor(fromx), math.floor(fromy)
    local dx, dy = tox - fromx, toy - fromy
    local sx, sy = (dx >= 0) and 1 or -1, (dy >= 0) and 1 or -1
    dx, dy = math.abs(dx), math.abs(dy)

    local tDeltaX = (dx == 0) and math.huge or 1 / dx
    local tDeltaY = (dy == 0) and math.huge or 1 / dy

    local tMaxX = (sx > 0) and ((1 - (fromx - x)) * tDeltaX) or ((fromx - x) * tDeltaX)
    local tMaxY = (sy > 0) and ((1 - (fromy - y)) * tDeltaY) or ((fromy - y) * tDeltaY)

    while true do
        local chunk = get_chunk_at_pos(math.floor(x) * 8, math.floor(y) * 8)
        if chunk and chunk.tilemap:get_tile(math.floor(x), math.floor(y)) then
            return x, y
        end
        if x == math.floor(tox) and y == math.floor(toy) then break end
        if tMaxX < tMaxY then
            x, tMaxX = x + sx, tMaxX + tDeltaX
        else
            y, tMaxY = y + sy, tMaxY + tDeltaY
        end
    end

    return tox, toy
end

function tile_edge_raycast(fromx, fromy, tox, toy)
    local x, y = math.floor(fromx), math.floor(fromy)
    local dx, dy = tox - fromx, toy - fromy
    local sx, sy = (dx >= 0) and 1 or -1, (dy >= 0) and 1 or -1
    dx, dy = math.abs(dx), math.abs(dy)

    local lx, ly = x, y

    local tDeltaX = (dx == 0) and math.huge or 1 / dx
    local tDeltaY = (dy == 0) and math.huge or 1 / dy

    local tMaxX = (sx > 0) and ((1 - (fromx - x)) * tDeltaX) or ((fromx - x) * tDeltaX)
    local tMaxY = (sy > 0) and ((1 - (fromy - y)) * tDeltaY) or ((fromy - y) * tDeltaY)

    while true do
        local chunk = get_chunk_at_pos(math.floor(x) * 8, math.floor(y) * 8)
        if chunk and chunk.tilemap:get_tile(math.floor(x), math.floor(y)) then
            return lx, ly
        end
        lx, ly = x, y

        if x == math.floor(tox) and y == math.floor(toy) then break end
        if tMaxX < tMaxY then
            x, tMaxX = x + sx, tMaxX + tDeltaX
        else
            y, tMaxY = y + sy, tMaxY + tDeltaY
        end
    end

    return x, y
end

function Chunk:load_fugitives()
    local path = "chunkdata/fugitives/"..tostring(self.x)..","..tostring(self.y)..".ents"
    if not lf.getInfo(path) then return end

    local file = lf.newFile(path)
    file:open("r")
    local str_data = file:read()
    local offset, frozen_ents = msgpack.unpack(str_data)
    file:close()
    lf.remove(path)

    for _, ent_str in ipairs(frozen_ents) do
        local entity = string2class(ent_str)
        self.entities[entity] = true
        current_scene:add_entity(entity)
    end
end

local seed = lm.random()*1000
function Chunk:generate()
    local tilepos = Vec(self.x * CHUNKSIZE, self.y * CHUNKSIZE)
    local tilemap = Tilemap(
        "assets/tileset.png",
        8,
        tilepos.x,
        tilepos.y,
        CHUNKSIZE+1
    )
    current_scene:add_entity(tilemap)
    self:add_entity(tilemap)
    self.tilemap = tilemap

    local noise_val, biome_noise_val, biome_index, biome
    for x = tilepos.x, tilepos.x + CHUNKSIZE - 1 do
        for y = tilepos.y, tilepos.y + CHUNKSIZE - 1 do

            noise_val = map01(cave_noise:getNoise2D(x + seed, y + seed))
            if noise_val > 0.5 or math.abs(x) < 5 then goto continue end

            biome_noise_val = map01(biome_noise:getNoise2D(x + seed, y + seed))
            biome_index = math.ceil(#BIOME_DATA * biome_noise_val)
            biome = BIOME_DATA[biome_index]
            local tile = biome.base_tile

            for ore_tile, data in pairs(biome.ores) do
                local ore_seed = 100 * ore_tile
                noise_val = map01(data.noise:getNoise2D(x + ore_seed, y + ore_seed))

                if noise_val < data.chance then
                    tile = ore_tile
                end
            end

            self.tilemap:set_tile(x, y, tile)
            ::continue::
        end
    end
end

local chunkpos
function process_chunks()
    -- Unload chunks that are too far
    local dist
    for key, chunk in pairs(loaded_chunks) do
        for i, comp in ipairs(current_scene:query_comp("ChunkLoader")) do
            chunkpos:set(chunk.x, chunk.y)
            chunkpos:sub(comp.chunkpos.x, comp.chunkpos.y)
            dist = chunkpos:length()

            if dist > CHUNK_DIST then
                chunk:unload()
                loaded_chunks[key] = nil
            end
        end
    end
end

function clear_world()
    if not love.filesystem.getInfo("chunkdata", "directory") then
        love.filesystem.createDirectory("chunkdata")
    end
    if not love.filesystem.getInfo("chunkdata/fugitives", "directory") then
        love.filesystem.createDirectory("chunkdata/fugitives")
    end

    for key, chunk in pairs(loaded_chunks) do
        chunk:unload()
        loaded_chunks[key] = nil
    end
    clear_dir("chunkdata")
    clear_dir("chunkdata/fugitives")
end

function get_chunk_at_pos(x, y)
    local key = ckey(math.floor((x/8)/CHUNKSIZE), math.floor((y/8)/CHUNKSIZE))
    return loaded_chunks[key]
end

return function()
    local BASIC_ORES = {
        [Tilenames.IRON_ORE] = {0.2, 0.25},
        [Tilenames.COAL_ORE] = {0.2, 0.25}
    }
    BIOME_DATA = {
        {
            name = "Cave",
            base_tile = Tilenames.ROCK,
            ores = table.shallow_copy(BASIC_ORES)
        },
        {
            name = "Nonsense test biome",
            base_tile = Tilenames.PLANK,
            ores = table.shallow_copy(BASIC_ORES)
        }
    }
    for i, biome in ipairs(BIOME_DATA) do
        for ore, data in pairs(biome.ores) do
            local noise = fnl.createState()
            noise:setNoiseType("perlin")
            noise:setFrequency(data[1])

            biome.ores[ore] = {
                noise = noise,
                chance = data[2]
            }
        end
    end

    cave_noise = fnl.createState()
    cave_noise:setNoiseType("perlin")
    cave_noise:setFrequency(0.075)

    biome_noise = fnl.createState()
    biome_noise:setNoiseType("cellular")
    biome_noise:setFrequency(0.02)
    biome_noise:setSeed(seed)
    biome_noise:setLacunarity(0)
    biome_noise:setOctaves(0)
    biome_noise:setGain(100)
    biome_noise:setCellularReturnType("cellvalue")

    chunkpos = Vec()
end