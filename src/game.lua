require "framework.ecs"
require "src.player"
require "framework.tilemap"

Game = class(Scene)
function Game:new()
    Scene.new(self)
    self:restart()
end

function Game:restart()
    local tilemap = Tilemap("assets/tileset.png", 8, -5, -5, 128)
    self.tilemap = tilemap
    for x = 0, 64 do
        for y = 0, 64 do
            if lm.noise(x*0.05, y*0.05) > 0.5 then
                tilemap:set_tile(x, y, 1)
            end
        end
    end
    
    self:add_entity(tilemap)

    local player = Player()
    self:add_entity(player)
end