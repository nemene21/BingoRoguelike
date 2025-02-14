require "framework.drawable"

ItemData = class()
function ItemData:new(name, texture, maxstack)
    self.name = name or "NULL"
    self.tex_res  = nil -- image_manager:get(texture or "assets/nil.png")
    self.maxstack = maxstack or 16
end

function item_compare(a, b)
    return a.name == b.name
end

function ItemData:copy()
    return ItemData:new(self.name, self.texture, self.maxstack)
end

local ITEM_REGISTRY = {
    stone_block = ItemData("Stone")
}

ItemStack = class()
function ItemStack:new(data, amount)
    self.data = data
    self.amount = amount or 0
end

function ItemStack:split()
    self.amount = math.floor(self.amount / 2)
    local new_stack = ItemStack(self.data:copy(), math.ceil(self.amount / 2))
    return new_stack
end

function ItemStack:take_from(stack)
    self:add(stack.data, 1)
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