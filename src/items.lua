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
function FloorItem:new(stack, x, y)
    Entity.new(self)
    self:add(TransComp(x, y, PointCollider(0, 4)))

    self.stack = stack
    self:add_drawable("sprite", Spritesheet("assets/itemsheet.png", 8, 8))
    self.sprite.framepos.x = stack.data.tex_id
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