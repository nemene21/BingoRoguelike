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