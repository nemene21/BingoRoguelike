require "framework.ecs"
require "framework.vector"
require "framework.camera"
require "framework.transform"
require "framework.drawable"

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
        btoi(lk.isDown("d")) - btoi(lk.isDown("a")), 
        btoi(lk.isDown("s")) - btoi(lk.isDown("w"))
    )
    self.Trans:move(input:normalized() * 100.0 * delta)
    self.sprite.pos = self.Trans.pos

    current_scene.tilemap:set_tilev((self.Trans.pos / current_scene.tilemap.tilesize):whole(), 3)
end

function Player:_draw()
    self.sprite:draw()
end