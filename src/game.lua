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
    self:add_entity(Player())
end