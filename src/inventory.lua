require "src.items"
require "framework.ecs"

local SlotRenderer = class(Drawable)
Slot = class(Entity)
function Slot:new(x, y)
    Entity.new(self)
    self.tex_res = nil
    self.stack = nil
    self:add(TransComp(x, y))
    self:add_drawable("sprite", Sprite("assets/itemslot.png"))
    self.sprite.layer = DrawLayers.UI
end