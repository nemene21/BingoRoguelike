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
    self:add_drawable("sprite", Sprite("assets/test.png"))

    self.inventory = {}
    self:_init_inventory()

    self:add_drawable("test_sys", ParticleSys("assets/test_particles.json"))
end

function Player:_init_inventory()
    self.mouse_slot = MouseSlot()
    self.mouse_slot:set_stack(ItemStack(get_item("stone_pickaxe")))
    current_scene:add_entity(self.mouse_slot)
    
    local slot
    for i = 0, 4 do
        slot = Slot(9 + i * 15, 9)
        current_scene:add_entity(slot)
        table.insert(self.inventory, slot)

        slot:set_stack(ItemStack(get_item("stone"), 5))
        slot:set_mouse_slot(self.mouse_slot)
    end
end

local GRAVITY = 800
function Player:_process(delta)
    local xinput =  btoi(is_pressed("right")) - btoi(is_pressed("left"))
    xinput = xinput * 128
    self.Trans.vel.x = dlerp(self.Trans.vel.x, xinput, 30 * delta)

    self.Trans.vel:add(0, delta * GRAVITY)
    if self.Trans:on_floor() then self.Trans.vel.y = 1 end
    if self.Trans:on_ceil() then self.Trans.vel:mul(1, -0.2) end

    if is_just_pressed("jump") then
        self.Trans.vel.y = -256
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

    self.test_sys.pos:setv(self.Trans.pos)
    add_light(self.Trans.pos, 4)
end