
Game = class(Scene)
function Game:new()
    Scene.new(self)
end

function Game:restart()
    clear_world()
    self.player = Player(100, 100)

    self:add_entity(self.player)
end

function Game:_process(delta)
    process_chunks()
end