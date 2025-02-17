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

    self:add_drawable("item_sprite", Spritesheet("assets/itemsheet.png", 8 * ItemTextures.COUNT, 8))
    self.item_sprite.pos:setv(self.Trans.pos)
    self.item_sprite.framepos.x = ItemTextures.NULL
end

function Slot:_process(delta)
    local mx, my = mouse_pos()
    local pos = self.Trans.pos

    self.sprite.scale:set(1)
    if centered_quad_has_point(pos.x, pos.y, SLOTSIZE, SLOTSIZE, mx, my) then
        self.sprite.scale:set(1.2)
    end
end