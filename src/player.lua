require "framework.ecs"
require "framework.vector"
require "framework.camera"
require "framework.transform"
require "framework.drawable"
require "framework.input"

Player = class(Entity)
function Player:new(x, y)
    x = x or 0
    y = y or 0
    Entity.new(self)
    self:add(TransComp(x + lm.random() * 64, y + lm.random() * 64))
    self:add(CamComp())

    self.Cam.camera:activate()
    self:add_drawable("sprite", Sprite("assets/test.png"))
    if lm.random() > 0.5 then self.sprite:set_shader("assets/test.glsl") end
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