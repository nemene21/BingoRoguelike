require "framework.ecs"
require "framework.tilemap"

CHUNKSIZE = 16

Chunk = class()
function Chunk:new(x, y)
    self.x = x
    self.y = y
    self.filename = tostring(self.x)..","..tostring(self.y)..".chunk"
    self.entities = {}

    if lf.getInfo(self.filename) == nil then
        self:load()
    else
        self:generate()
    end
end

function Chunk:save()
    local chunk_data = {
        entities = {}
    }
    local entity
    for i = #self.entities, 0 do
        entity = self.entities[i]
        table.insert(chunk_data.entities, entity:stringify())
        self.entities[i] = nil
        entity:kill()
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

    for i, entity in ipairs(chunk_data.entities) do
        current_scene:add_entity(string2class(entity))
    end
end

function Chunk:add_entity(entity)
    table.insert(self.entities, entity)
end

function Chunk:generate()
    local tilepos = Vec(self.x * CHUNKSIZE, self.y * CHUNKSIZE)
    local tilemap = Tilemap(
        "assets/tileset.png",
        8,
        tilepos.x,
        tilepos.y,
        CHUNKSIZE
    )
    current_scene:add_entity(tilemap)
    self:add_entity(tilemap)

    for x = tilepos.x, tilepos.x + CHUNKSIZE do
        for y = tilepos.y, tilepos.y + CHUNKSIZE do
            if lm.noise(x*0.05, y*0.05) > 0.5 then
                tilemap:set_tile(x, y, 1)
            end
        end
    end
end