require "framework.drawable"

ItemData = class()
function ItemData:new(name, tex_id, maxstack)
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

local ITEM_REGISTRY = {
    stone = ItemData("Stone", ItemTextures.STONE),
    stone_pickaxe = ItemData("Stone pickaxe", ItemTextures.STONE_PICKAXE, 1),
}

function get_item(name)
    return ITEM_REGISTRY[name]:copy()
end

ItemStack = class()
function ItemStack:new(data, amount)
    self.data = data
    self.amount = amount or 1
end

function ItemStack:split()
    self.amount = math.floor(self.amount / 2)
    local new_stack = ItemStack(self.data:copy(), math.ceil(self.amount / 2))
    return new_stack
end

function ItemStack:take_from(stack)
    self:add(stack.data, 1)
    stack.amount = stack.amount - 1
end

function ItemStack:take_all_from(stack)
    while self:take_from(stack) do end
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