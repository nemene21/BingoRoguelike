require "framework.ecs"
require "framework.vector"
require "framework.camera"
require "framework.transform"
require "framework.drawable"
require "framework.input"
require "framework.particles"

require "src.chunk_loader"
require "src.inventory"
require "framework.lighting"

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

    self:_init_inventory()
end

function Player:_init_inventory()
    self.inventory = {}
    self.inventory_no_hotbar = {}
    self.hotbar = {}
    self.inventory_open = false

    self.mouse_slot = MouseSlot()
    self.mouse_slot:set_stack(ItemStack(get_item("stone_pickaxe")))
    current_scene:add_entity(self.mouse_slot)

    local slot_margin = 15
    local hotbar_distance = 6
    local inventory_origin = 9
    
    local slot
    for i = 0, 4 do
        slot = Slot(inventory_origin + i * slot_margin, inventory_origin)
        current_scene:add_entity(slot)
        table.insert(self.inventory, slot)
        table.insert(self.hotbar, slot)

        slot:set_stack(ItemStack(get_item("stone"), 5))
        slot:set_mouse_slot(self.mouse_slot)
    end

    for x = 0, 4 do
        for y = 1, 3 do
            slot = Slot(inventory_origin + x * slot_margin, inventory_origin + y * slot_margin + hotbar_distance)
            current_scene:add_entity(slot)
            table.insert(self.inventory, slot)
            table.insert(self.inventory_no_hotbar, slot)
    
            slot:set_stack(ItemStack(get_item("stone"), 5))
            slot:set_mouse_slot(self.mouse_slot)
            slot:hide()
            slot:pause()
        end
    end
end

local GRAVITY = 800
function Player:_process(delta)
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

    if is_just_pressed("inventory open") then
        self.inventory_open = not self.inventory_open

        for i, slot in ipairs(self.inventory_no_hotbar) do
            slot.visible = self.inventory_open
            slot.paused  = not self.inventory_open
        end
    end

    if self.Trans.vel.y > 256 then self.Trans.vel.y = 256 end

    local mx, my = global_mouse_pos()

    if is_pressed("break") then
        local chunk = get_chunk_at_pos(mx, my)
        chunk.tilemap:damage_tile(
            math.floor(mx / 8),
            math.floor(my / 8),
            0.1
        )
    end
    local mx, my = global_mouse_pos()
    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.flipx = mx < self.Trans.pos.x

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
    add_light(self.Trans.pos, 5)
end