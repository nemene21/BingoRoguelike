require "framework.ecs"
require "src.player"
require "framework.tilemap"
require "src.chunk"
require "src.chunk_loader"

Game = class(Scene)
function Game:new()
    Scene.new(self)
end

function Game:restart()
    clear_world()
    self.player = Player(100, 100)

    self:add_entity(self.player)
    self:add_entity(FloorItem(ItemStack(get_item("stone")), 100, 100))
end

function Game:_process(delta)
    process_chunks()
end