require "src.items"
require "framework.ecs"

local SlotRenderer = class(Drawable)
Slot = class(Entity)
function Slot:new(x, y)
    Entity.new(self)
    self.tex_res = nil
    self.stack = nil
    self:add(TransComp(x, y))
    self:add_drawable(SlotRenderer(self))
end

function SlotRenderer:new(slot)
    Drawable.new(self)
    self.slot = slot
    self.layer = DrawLayers.UI
end

function SlotRenderer:_draw()
    local slot = self.slot
    lg.circle("fill", slot.Trans.pos.x, slot.Trans.pos.y, 8)
end