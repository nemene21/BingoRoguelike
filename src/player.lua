require "framework.ecs"
require "framework.vector"
require "framework.camera"
require "framework.transform"
require "framework.drawable"
require "framework.input"

Player = class(Entity)
function Player:new(x, y)
    Entity.new(self)
    self:add(TransComp(x, y))
    self:add(CameraComp())
    self.Cam.camera:activate()
    self.sprite = Sprite("assets/test.png")
end

function Player:free()
    print("Dead D:")
end

function Player:_process(delta)
    local input = Vec(
        btoi(is_pressed("right")) - btoi(is_pressed("left")), 
        btoi(is_pressed("down")) - btoi(is_pressed("up"))
    )
    self.Trans:move(input:normalized() * 100.0 * delta)
    self.sprite.pos = self.Trans.pos
end

function Player:_draw()
    self.sprite:draw()
end