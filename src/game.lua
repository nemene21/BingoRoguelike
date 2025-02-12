require "framework.ecs"
require "src.player"
require "framework.tilemap"
require "src.chunk"
require "src.chunk_loader"

Game = class(Scene)
function Game:new()
    Scene.new(self)
    self.chunk_archetype = Archetype(self, "ChunkLoader")
    self:restart()
end

function Game:restart()
    self:add_entity(Player())
end

local chunkpos = Vec()
function Game:_process(delta)
    -- Unload chunks that are too far
    for key, chunk in pairs(chunks) do
        for entity in self.chunk_archetype:iterate() do
            chunkpos:set(chunk.x, chunk.y)
            chunkpos:sub()
        end
    end
end