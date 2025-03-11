local SLOTSIZE = 12

local SLOT_NUM_OFFSET

local SlotRenderer = class(Drawable)
Slot = class(Entity)
function Slot:new(x, y)
    Entity.new(self)
    self.stack = nil
    self:add(TransComp(x, y))
    
    self:add_drawable("amount_label", Label(nil, 0, 0, Vec(-1, 0)))
    self.amount_label.scale:set(0.5)

    self:add_drawable("item_sprite", OutlineSpritesheet("assets/itemsheet.png", 8, 8))
    self.item_sprite.pos:setv(self.Trans.pos)
    self.item_sprite.layer = DrawLayers.UI
    self.item_sprite.framepos.x = ItemTextures.NULL
    self.item_sprite:hide()

    self:add_drawable("sprite", OutlineSprite("assets/itemslot.png"))
    self.sprite.layer = DrawLayers.UI
    self.sprite.pos:setv(self.Trans.pos)
end

function Slot:set_mouse_slot(slot)
    self.mouse_slot = slot
end

function Slot:clear()
    self.stack = nil
    self.amount_label:hide()
    self.item_sprite:hide()
end

function Slot:update_data()
    if self.stack == nil then self:clear() return nil end
    if self.stack.amount == 0 then self:clear() return nil end
    self.item_sprite.framepos.x = self.stack.data.tex_id
    self.item_sprite:show()
    self.amount_label:show()

    self.amount_label:set_text(tostring(self.stack.amount))
    self.amount_label.pos:setv(self.Trans.pos)
    self.amount_label.pos:addv(SLOT_NUM_OFFSET)

    if self.stack.amount == 1 then self.amount_label:hide() end
end

function Slot:set_stack(stack)
    self.stack = stack
    self:update_data()
end

function Slot:_process(delta)
    local mx, my = mouse_pos()
    local pos = self.Trans.pos

    self.sprite.scale:set(1)
    if centered_quad_has_point(pos.x, pos.y, SLOTSIZE, SLOTSIZE, mx, my) then
        self.sprite.scale:set(1.2)
        if is_just_pressed("click") then
            self:_clicked()
        elseif is_just_pressed("secondary_click") then
            self:_secondary_clicked()
        end
    end
end

function Slot:_clicked()
    local mouse_stack = self.mouse_slot.stack
    if mouse_stack == nil or self.stack == nil then
        self.mouse_slot:set_stack(self.stack)
        self:set_stack(mouse_stack)

    elseif item_compare(mouse_stack.data, self.stack.data) then
        self.stack:take_all_from(mouse_stack)
        self.mouse_slot:update_data()
    else
        self.mouse_slot:set_stack(self.stack)
        self:set_stack(mouse_stack)
    end
    self:update_data()
end

function Slot:_secondary_clicked()
    local mouse_stack = self.mouse_slot.stack
    if mouse_stack and self.stack then
        self.stack:take_from(mouse_stack)
        self.mouse_slot:update_data()

    elseif mouse_stack and not self.stack then
        self:set_stack(ItemStack(mouse_stack.data:copy()), 1)
        mouse_stack.amount = mouse_stack.amount - 1
        self.mouse_slot:update_data()
    
    elseif not mouse_stack and self.stack then
        self.mouse_slot:set_stack(self.stack:split())
    end
    self:update_data()
end

MouseSlot = class(Slot)
function MouseSlot:new()
    Slot.new(self, 0, 0)
    self.sprite:hide()
    self:_process(0)
end

function MouseSlot:_process(delta)
    self.Trans.pos:set(mouse_pos())
    self.item_sprite.pos:setv(self.Trans.pos)
    self.amount_label.pos:setv(self.Trans.pos)
    self.amount_label.pos:addv(SLOT_NUM_OFFSET)
end

return function()
   SLOT_NUM_OFFSET = Vec(7, 2)
end