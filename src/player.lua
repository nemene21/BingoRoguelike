
Player = class(Entity)
function Player:new(x, y)
    Entity.new(self)
    self:add(TransComp(x, y, RectCollider(0, 2, 4, 4)))
    self:add(CamComp())
    self:add(ChunkLoaderComp())

    self.Cam.camera:activate()
    self:add_drawable("walk_particles", ParticleSys("assets/player_walk_particles.json"))
    self.walk_particles.layer = DrawLayers.VFX_UNDER
    self:add_drawable("sprite", Sprite("assets/test.png"))

    self:add_drawable("test_particles", ParticleSys("assets/test_particles.json"))
    self.test_particles.emitting = false -- true

    self:_init_inventory()
end

function Player:_craft(slot)
    if slot.stack == nil then
        self.craft_select = nil
        self.craft_outline:hide()
        return
    end

    if self.craft_select then
        local slot1 = slot
        local slot2 = self.craft_select
        local stack1 = slot1.stack
        local stack2 = slot2.stack
        local item1 = stack1.data
        local item2 = stack2.data

        local first_recipe = item1.item_id.." + "..item2.item_id
        local other_recipe = item2.item_id.." + "..item1.item_id

        local crafted = CRAFTING_RECIPES[first_recipe] or CRAFTING_RECIPES[other_recipe]
        if crafted then
            local maximum = stack1.amount < stack2.amount and stack1.amount or stack2.amount
            stack1.amount = stack1.amount - maximum
            stack2.amount = stack2.amount - maximum

            if stack1.amount == 0 then
                slot1:set_stack(ItemStack(crafted:copy(), maximum))
            else
                slot2:set_stack(ItemStack(crafted:copy(), maximum))
            end
            slot1:update_data()
            slot2:update_data()
        end

        self.craft_select = nil
        self.craft_outline:hide()
    else
        self.craft_select = slot
        self.craft_outline.pos:setv(self.craft_select.sprite.pos)
        self.craft_outline:show()
    end
end

function Player:_init_inventory()
    self.on_held_update = Signal()
    self.inventory = {}
    self.inventory_no_hotbar = {}
    self.hotbar = {}
    self.inventory_open = false

    self.slot_on = 1
    self.held_item = nil
    self.craft_select = nil

    self.mouse_slot = MouseSlot()
    current_scene:add_entity(self.mouse_slot)

    local slot_margin = 15
    local hotbar_distance = 6
    local inventory_origin = 9
    
    local slot
    for i = 0, 4 do
        slot = CraftSlot(inventory_origin + i * slot_margin, inventory_origin)
        slot.on_craft:connect(function(slot) self:_craft(slot) end)

        current_scene:add_entity(slot)
        table.insert(self.inventory, slot)
        table.insert(self.hotbar, slot)

        slot:set_mouse_slot(self.mouse_slot)
    end

    for y = 1, 3 do
        for x = 0, 4 do
            slot = CraftSlot(inventory_origin + x * slot_margin, inventory_origin + y * slot_margin + hotbar_distance)
            slot.on_craft:connect(function(slot) self:_craft(slot) end)
            
            current_scene:add_entity(slot)
            table.insert(self.inventory, slot)
            table.insert(self.inventory_no_hotbar, slot)
    
            slot:set_mouse_slot(self.mouse_slot)
            slot:hide()
            slot:pause()
        end
    end

    self:add_drawable("slot_on_outline", Sprite("assets/slot_on_outline.png"))
    self.slot_on_outline.layer = DrawLayers.UI

    self:add_drawable("craft_outline", Sprite("assets/craft_select.png"))
    self.craft_outline.layer = DrawLayers.UI
    self.craft_outline:hide()
end

local GRAVITY = 800
function Player:_process(delta)
    self.test_particles.pos:setv(self.Trans.pos)

    local xinput =  btoi(is_pressed("right")) - btoi(is_pressed("left"))
    xinput = xinput * 128
    self.Trans.vel.x = dlerp(self.Trans.vel.x, xinput, 30 * delta)

    self.Trans.vel:add(0, delta * GRAVITY)
    if self.Trans:on_floor() then
        if self.Trans.vel.y > 100 then
            self.sprite.scale:set(1.5, 0.5)
        end
        self.Trans.vel.y = 1
    end
    if self.Trans:on_ceil() then self.Trans.vel:mul(1, -0.2) end

    if is_just_pressed("jump") then
        self.Trans.vel.y = -256
    end

    if is_just_released("jump") then
        self.Trans.vel.y = self.Trans.vel.y * 0.25
    end

    if is_just_pressed("inventory open") then
        self.inventory_open = not self.inventory_open

        for i, slot in ipairs(self.inventory_no_hotbar) do
            slot.visible = self.inventory_open
            slot.paused  = not self.inventory_open
        end
    end

    self.slot_on_outline.pos:setv(self.hotbar[self.slot_on].Trans.pos)
    self.slot_on_outline.scale:setv(self.hotbar[self.slot_on].sprite.scale)

    if is_just_pressed("slot_1") then self.slot_on = 1; self:update_held_item() end
    if is_just_pressed("slot_2") then self.slot_on = 2; self:update_held_item() end
    if is_just_pressed("slot_3") then self.slot_on = 3; self:update_held_item() end
    if is_just_pressed("slot_4") then self.slot_on = 4; self:update_held_item() end
    if is_just_pressed("slot_5") then self.slot_on = 5; self:update_held_item() end

    local scroll = get_scroll()
    if scroll ~= 0 then
        self.slot_on = self.slot_on + scroll
        if self.slot_on > 5 then self.slot_on = 1 end
        if self.slot_on < 1 then self.slot_on = 5 end 

        self:update_held_item()
    end

    if self.hotbar[self.slot_on].stack ~= self.held_item then
        self:update_held_item()
    end

    if self.craft_select then
        self.craft_outline.pos:setv(self.craft_select.sprite.pos)
        self.craft_outline.scale:setv(self.craft_select.sprite.scale)

        local bob = math.abs(math.sin(lt.getTime() * 20) * 0.05)
        self.craft_outline.scale:add(bob)
    end

    if self.Trans.vel.y > 256 then self.Trans.vel.y = 256 end

    local mx, my = global_mouse_pos()
    self.look_dir = btoi2(mx > self.Trans.pos.x)
    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.flipx = self.look_dir < 0

    if self.Trans:on_floor() then
        self.sprite.angle = math.sin(lt.getTime() * PI * 10) * self.Trans.vel.x * 0.0025
    else
        -- self.sprite.angle = self.Trans.vel.y * 0.0025
    end

    local squash_amount = math.abs(self.Trans.vel.y) * 0.0025
    self.sprite.scale:dlerp(
        1 - squash_amount, 1 + squash_amount, delta * 20
    )

    self.walk_particles.pos:setv(self.Trans.pos)
    self.walk_particles.pos:add(0, 3)
    self.walk_particles.emitting = math.abs(self.Trans.vel.x) > 16
    add_light(self.Trans.pos, 4)
end

function Player:give_item(stack)
    for i, slot in ipairs(self.inventory) do
        if stack.amount <= 0 then
            break
        end

        if not slot.stack then
            slot.stack = ItemStack(stack.data, stack.amount)
            stack.amount = 0
            slot:update_data()
            break
        end
 
        if item_compare(slot.stack.data, stack.data) then
            slot.stack:take_all_from(stack)
            slot:update_data()
        end
    end
end

function Player:update_held_item()
    self.on_held_update:emit()

    local slot = self.hotbar[self.slot_on]
    local stack = slot.stack
    self.held_item = stack

    if not stack then return end

    current_scene:add_entity(
        stack.data.holdent(self, slot)
    )
end

function give(name, amount)
    current_scene.player:give_item(ItemStack(get_item(name), amount))
end