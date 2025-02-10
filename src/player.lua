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
    self:add(CamComp())

    self.Cam.camera:activate()
    self:add_drawable("sprite", Sprite("assets/test.png"))
    self.sprite:set_shader("assets/test.glsl")
end

local input = Vec()
function Player:_process(delta)
    input:set(
        btoi(is_pressed("right")) - btoi(is_pressed("left")),
        btoi(is_pressed("down")) - btoi(is_pressed("up"))
    )
    input:normalize()
    input:mul(delta * 100.0)

    self.Trans:move(input)
    self.sprite.pos:setv(self.Trans.pos)
end