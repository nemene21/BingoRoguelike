require "src.items"
require "framework.ecs"

local SLOTSIZE = 12

local SlotRenderer = class(Drawable)
Slot = class(Entity)
function Slot:new(x, y)
    Entity.new(self)
    self.stack = nil
    self:add(TransComp(x, y))

    self:add_drawable("item_sprite", Spritesheet("assets/itemsheet.png", 8, 8))
    self.item_sprite.pos:setv(self.Trans.pos)
    self.item_sprite.layer = DrawLayers.UI
    self.item_sprite.framepos.x = ItemTextures.NULL
    self.item_sprite.pos:add(0, -1)

    self:add_drawable("sprite", Sprite("assets/itemslot.png"))
    self.sprite.layer = DrawLayers.UI
    self.sprite.pos:setv(self.Trans.pos)
end

function Slot:set_mouse_slot(slot)
    self.mouse_slot = slot
end

function Slot:set_stack(stack)
    self.stack = stack
    self.item_sprite.framepos.x = stack.data.tex_id
end

function Slot:_process(delta)
    local mx, my = mouse_pos()
    local pos = self.Trans.pos

    self.sprite.scale:set(1)
    if centered_quad_has_point(pos.x, pos.y, SLOTSIZE, SLOTSIZE, mx, my) then
        self.sprite.scale:set(1.2)
        if is_just_pressed("click") then
            self:_clicked()
        end
    end
end

function Slot:_clicked()
    local mouse_stack = self.mouse_slot.stack
    self.mouse_slot:set_stack(self.stack)
    self:set_stack(mouse_stack)
end

MouseSlot = class(Slot)
function MouseSlot:new()
    Slot.new(self, 0, 0)
    self.sprite:hide()
end

function MouseSlot:_process(delta)
    self.Trans.pos:set(mouse_pos())
    self.item_sprite.pos:setv(self.Trans.pos)
end