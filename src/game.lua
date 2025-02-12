require "framework.ecs"
require "src.player"
require "framework.tilemap"
require "src.chunk"
require "src.chunk_loader"

Game = class(Scene)
function Game:new()
    Scene.new(self)
    self:restart()
end

function Game:restart()
    self.player = Player()
    self:add_entity(self.player)
end

function Game:_process(delta)
    process_chunks()
end