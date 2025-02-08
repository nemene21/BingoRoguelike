require "framework.ecs"
require "src.player"
require "framework.tilemap"
require "src.chunk"

Game = class(Scene)
function Game:new()
    Scene.new(self)
    self:restart()
end

function Game:restart()
    self.chunk = Chunk(0, 0)
    self:add_entity(self.chunk)
    self:add_entity(Player())
end

function Game:test_chunk()
    self.chunk:save()
    self.chunk:load()
end