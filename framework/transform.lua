require "framework.ecs"
require "framework.vector"

TransComp = class(Comp)
function TransComp:new(x, y, scalex, scaley, ang)
    Comp.new(self, "Trans")
    self.pos = Vec(x, y)
    self.scale = Vec(scalex or 1, scaley or 1)
    self.angle = ang
end

function TransComp:move(vec)
    self.pos:addv(vec)
end