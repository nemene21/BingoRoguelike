require "framework.ecs"
require "framework.tilemap"

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

    loaded_chunks[ckey(x, y)] = self

    if lf.getInfo(self.filename) ~= nil then
        self:load()
    else
        self:generate()
    end
end

function Chunk:unload()
    local chunk_data = {
        entities = {}
    }
    local entity
    for i = #self.entities, 1, -1 do
        entity = self.entities[i]
        entity:kill()
        table.insert(chunk_data.entities, entity:stringify())
        self.entities[i] = nil
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
    end
end

function Chunk:add_entity(entity)
    table.insert(self.entities, entity)
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

    for x = tilepos.x, tilepos.x + CHUNKSIZE do
        for y = tilepos.y, tilepos.y + CHUNKSIZE do
            if lm.noise(x*0.05+seed, y*0.05+seed) > 0.5 then
                tilemap:set_tile(x, y, 1, nil, lm.random())
            end
        end
    end
end

local chunkpos = Vec()
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