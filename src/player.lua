require "framework.ecs"
require "framework.vector"
require "framework.camera"
require "framework.transform"
require "framework.drawable"
require "framework.input"
require "src.chunk_loader"
require "src.inventory"

Player = class(Entity)
function Player:new(x, y)
    Entity.new(self)
    self:add(TransComp(x, y))
    self:add(CamComp())
    self:add(ChunkLoaderComp())

    self.Cam.camera:activate()
    self:add_drawable("sprite", Sprite("assets/test.png"))

    self.inventory = {}
    self:_init_inventory()
end

function Player:_init_inventory()
    self.mouse_slot = MouseSlot()
    self.mouse_slot:set_stack(ItemStack(get_item("stone_pickaxe")))
    current_scene:add_entity(self.mouse_slot)
    print(self.mouse_slot.amount)
    
    local slot
    for i = 0, 4 do
        slot = Slot(9 + i * 15, 9)
        current_scene:add_entity(slot)
        table.insert(self.inventory, slot)

        slot:set_stack(ItemStack(get_item("stone"), 3))
        slot:set_mouse_slot(self.mouse_slot)
    end
end

local input = Vec()
function Player:_process(delta)
    input:set(
        btoi(is_pressed("right")) - btoi(is_pressed("left")),
        btoi(is_pressed("down")) - btoi(is_pressed("up"))
    )
    input:normalize()
    input:mul(delta * 300.0)
    local mx, my = global_mouse_pos()

    if is_pressed("break") then
        local chunk = get_chunk_at_pos(mx, my)
        chunk.tilemap:damage_tile(
            math.floor(mx / 8),
            math.floor(my / 8),
            1
        )
    end

    self.Trans:move(input)
    self.sprite.pos:setv(self.Trans.pos)
end