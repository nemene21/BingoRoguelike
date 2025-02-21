require "framework.ecs"
require "framework.vector"
require "src.chunk"

TransComp = class(Comp)
function TransComp:new(x, y, scalex, scaley, ang)
    Comp.new(self, "Trans")
    self.pos = Vec(x, y)
    self.scale = Vec(scalex or 1, scaley or 1)
    self.angle = ang
    self.vel = Vec()
end

function TransComp:_process()
    self:move(self.vel)
end

function TransComp:check_collision()
    local chunk = get_chunk_at_pos(self.pos:get())
    local tilemap = chunk.tilemap

    if tilemap:get_tile()
end

function TransComp:move(vec)
    self.pos.x = self.pos.x + vec.x
    
    self.pos.y = self.pos.y + vec.y
end