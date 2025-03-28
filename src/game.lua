
Game = class(Scene)
function Game:new()
    Scene.new(self)
end

function Game:restart()
    clear_world()
    self.player = Player(0, 0)

    self:add_entity(self.player)
    give("STONE_PICKAXE", 1)
    give("REFINER", 3)
    give("LOG", 16)
end

function Game:_process(delta)
    process_chunks()
end