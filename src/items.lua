DEFAULT_STACK_SIZE = 64

ItemData = class()
function ItemData:new(name, tex_id, maxstack, holdent)
    if holdent == nil then
        self.holdent = BasicHeldItem
    else
        self.holdent = holdent
    end
    self.name = name or "NULL"
    self.tex_id = tex_id or ItemTextures.NULL
    self.maxstack = maxstack or DEFAULT_STACK_SIZE
end

function item_compare(a, b)
    return a.item_id == b.item_id
end

function ItemData:copy()
    local cpy = ItemData(self.name, self.tex_id, self.maxstack, self.holdent)
    cpy.item_id = self.item_id
    cpy.block = self.block
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
    self.sprite:set_shader("assets/item_shine.glsl")
    self.sprite.framepos.x = self.stack.data.tex_id
end

function FloorItem:_process(delta)
    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.pos:add(0, math.sin(lt.getTime() * 2 + self.Trans.pos.x * 0.1) * 2 - 2)
    self.sprite:send_uniform("time", self.Trans.pos.x * 0.03 + lt.getTime() * 2)

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
        "LOG",
        "STONE_PICKAXE",
        "STONE_SWORD",
        "DYNAMITE",
        "GLOWSTICK",
        "HEALTH_POTION",
        "IRON_SCRAP",
        "CARVED_STONE",
        "COAL",
        "FURNACE",
        "TORCH",
        "REFINER",
        "COUNT"
    })
    -- ITEM DATA
    ITEM_REGISTRY = {}
    ITEM_REGISTRY.IRON_SCRAP = ItemData("Iron scrap", ItemTextures.IRON_SCRAP)
    ITEM_REGISTRY.LOG = ItemData("Log", ItemTextures.LOG)
    ITEM_REGISTRY.STONE_PICKAXE = ItemData("Stone pickaxe", ItemTextures.STONE_PICKAXE, 1, MiningHeldItem)

    ITEM_REGISTRY.CARVED_STONE = ItemData("Carved stone", ItemTextures.CARVED_STONE, nil, BlockHeldItem)
    ITEM_REGISTRY.CARVED_STONE.block = Tilenames.ROCK

    ITEM_REGISTRY.FURNACE = ItemData("Furnace", ItemTextures.FURNACE, nil, BlockHeldItem)
    ITEM_REGISTRY.FURNACE.block = Tilenames.FURNACE

    ITEM_REGISTRY.REFINER = ItemData("Refiner", ItemTextures.REFINER, nil, BlockHeldItem)
    ITEM_REGISTRY.REFINER.block = Tilenames.REFINER

    ITEM_REGISTRY.STONE = ItemData("Stone", ItemTextures.STONE)
    ITEM_REGISTRY.COAL = ItemData("Coal", ItemTextures.COAL)

    for id, item in pairs(ITEM_REGISTRY) do
        item.item_id = id
    end 

    -- LOOT TABLES
    LootTables = enum({
        "ROCK",
        "IRON_ORE",
        "COAL_ORE",
        "FURNACE",
        "REFINER"
    })

    loot_table_data = {}
    loot_table_data[LootTables.ROCK] = LootTable({
        STONE = 1
    })
    loot_table_data[LootTables.IRON_ORE] = LootTable({
        IRON_SCRAP = 1
    })
    loot_table_data[LootTables.COAL_ORE] = LootTable({
        COAL = 1
    })
    loot_table_data[LootTables.FURNACE] = LootTable({
        FURNACE = 1
    })
    loot_table_data[LootTables.REFINER] = LootTable({
        REFINER = 1
    })

    -- CRAFTING RECIPES
    CRAFTING_RECIPES = {
        ["STONE + STONE"] = ITEM_REGISTRY.CARVED_STONE,
        ["CARVED_STONE + COAL"] = ITEM_REGISTRY.FURNACE
    }

    -- REFINER RECIPES
    REFINER_RECIPES = {
        STONE = CARVED_STONE,
        WOOD = PLANK
    }
end