ItemData = class()
function ItemData:new(name, tex_id, maxstack, holdent)
    self.holdent = holdent or BasicHeldItem
    self.name = name or "NULL"
    self.tex_id = tex_id or ItemTextures.NULL
    self.maxstack = maxstack or 16
end

function item_compare(a, b)
    return a.name == b.name
end

function ItemData:copy()
    local cpy = ItemData(self.name, self.tex_id, self.maxstack)
    return cpy
end

local ITEM_REGISTRY

function get_item(name)
    assert(ITEM_REGISTRY[name], name.." is not an item.")
    return ITEM_REGISTRY[name]:copy()
end

ItemStack = class()
function ItemStack:new(data, amount)
    self.data = data
    self.amount = amount or 1
end

function ItemStack:split()
    local new_stack = ItemStack(self.data:copy(), math.ceil(self.amount / 2))
    self.amount = math.floor(self.amount / 2)
    return new_stack
end

function ItemStack:take_from(stack)
    if stack.amount == 0 then return false end

    if self:add(stack.data, 1) then
        stack.amount = stack.amount - 1
        return true
    end
end

function ItemStack:take_all_from(stack)
    while true do
        if not self:take_from(stack) then return nil end
    end
end

function ItemStack:add(adding)
    if not item_compare(self.data, adding) then
        return false
    end
    if self.amount >= self.data.maxstack then
        return false
    end
    self.amount = self.amount + 1
    return true
end

FloorItem = class(Entity)
function FloorItem:new(name, amount, x, y)
    Entity.new(self)
    self:add(TransComp(x, y, PointCollider(0, 4)))
    self:add(ChunkHandlerComp())

    self.stack = ItemStack(get_item(name), amount)
    self.item_name = name
    self:add_drawable("sprite", Spritesheet("assets/itemsheet.png", 8, 8))
    self.sprite.framepos.x = self.stack.data.tex_id
end

function FloorItem:_process(delta)
    self.sprite.pos:setv(self.Trans.pos)
    self.Trans.vel.y = self.Trans.vel.y + 800 * delta
    if self.Trans:on_floor() then self.Trans.vel.y = 0 end

    if self.Trans.vel.y > 256 then self.Trans.vel.y = 256 end

    local player = current_scene.player
    if not player then return nil end

    local dist = self.Trans.pos:distance_to(player.Trans.pos)
    if dist < 8 then
        player:give_item(self.stack)
        if self.stack.amount == 0 then
            self:kill()
        end
    end
end

function FloorItem:stringify()
    return class2string(self, {self.item_name, self.stack.amount, self.Trans.pos.x, self.Trans.pos.y})
end

LootTable = class()
function LootTable:new(drops)
    self.drops = drops
end

function LootTable:drop(x, y)
    local floor_item
    for name, amount in pairs(self.drops) do
        floor_item = FloorItem(name, amount, x, y)

        current_scene:add_entity(floor_item)
    end
end

return function()
    -- ITEM TEXTURES
    ItemTextures = enum0({
        "NULL",
        "STONE",
        "WOOD",
        "STONE_PICKAXE",
        "STONE_SWORD",
        "DYNAMITE",
        "GLOWSTICK",
        "HEALTH_POTION",
        "COUNT"
    })
    -- ITEM DATA
    ITEM_REGISTRY = {}
    ITEM_REGISTRY.STONE = ItemData("Stone", ItemTextures.STONE)
    ITEM_REGISTRY.STONE_PICKAXE = ItemData("Stone pickaxe", ItemTextures.STONE_PICKAXE, 1)

    -- LOOT TABLES
    LootTables = enum({
        "ROCK"
    })

    loot_table_data = {}
    loot_table_data[LootTables.ROCK] = LootTable({
        stone = 5
    })
end