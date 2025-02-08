require "framework.ecs"
require "framework.tilemap"

Chunk = class(Entity)
function Chunk:new(x, y)
    Entity.new(self)
    self.x = x
    self.y = y
    self.filename = tostring(self.x)..","..tostring(self.y)..".chunk"
    self.entities = {}
end

function Chunk:save()
    local chunk_data = {
        entities = {}
    }
    for key, entity in pairs(self.entities) do
        table.insert(chunk_data.entities, entity:stringify())
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
        self.scene:add_entity(string2class(entity))
    end
end

function Chunk:add_entity(entity)
    table.insert(self.entities, entity)
end