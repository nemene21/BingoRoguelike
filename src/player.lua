require "framework.ecs"
require "framework.vector"
require "framework.camera"
require "framework.transform"
require "framework.drawable"
require "framework.input"
require "src.chunk_loader"

Player = class(Entity)
function Player:new(x, y)
    Entity.new(self)
    self:add(TransComp(x, y))
    self:add(CamComp())
    self:add(ChunkLoaderComp())

    self.Cam.camera:activate()
    self:add_drawable("sprite", Sprite("assets/test.png"))
end

local input = Vec()
function Player:_process(delta)
    input:set(
        btoi(is_pressed("right")) - btoi(is_pressed("left")),
        btoi(is_pressed("down")) - btoi(is_pressed("up"))
    )
    input:normalize()
    input:mul(delta * 300.0)

    if is_pressed("break") then
        local chunk = get_chunk_at_pos(self.Trans.pos:get())
        chunk.tilemap:damage_tile(
            math.floor(self.Trans.pos.x / 8),
            math.floor(self.Trans.pos.y / 8),
            delta * 4
        )
    end

    self.Trans:move(input)
    self.sprite.pos:setv(self.Trans.pos)
end