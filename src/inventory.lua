require "src.items"
require "framework.ecs"

local SLOTSIZE = 12

local SlotRenderer = class(Drawable)
Slot = class(Entity)
function Slot:new(x, y)
    Entity.new(self)
    self.stack = nil
    self:add(TransComp(x, y))

    self:add_drawable("sprite", Sprite("assets/itemslot.png"))
    self.sprite.layer = DrawLayers.UI
    self.sprite.pos:setv(self.Trans.pos)
end

function Slot:_process(delta)
    local mx, my = mouse_pos()
    local pos = self.Trans.pos

    if quad_has_point(pos.x, pos.y, SLOTSIZE, SLOTSIZE, mx, my) then
        print("SKIBIDI")
    end
end