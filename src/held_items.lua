
BasicHeldItem = class(Entity)
function BasicHeldItem:new(player, slot)
    Entity.new(self)
    self.player = player

    self._swap_callback = function()
        self.player.on_held_update:disconnect(self._swap_callback)
        self:kill()
    end
    self.player.on_held_update:connect(self._swap_callback)

    self.slot = slot
    self.stack = slot.stack
    self:add(TransComp(0, 0))

    self:add_drawable("sprite", Spritesheet("assets/itemsheet.png", 8, 8))
    self.sprite.framepos.x = self.stack.data.tex_id
end

function BasicHeldItem:_process(delta)
    self.Trans.pos:setv(self.player.Trans.pos)

    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.pos:add(self.player.look_dir * 6, 0)
    self.sprite.flipx = self.player.sprite.flipx
end

-- BLOCK ITEM
local look_vec

BlockHeldItem = class(BasicHeldItem)
function BlockHeldItem:new(player, slot)
    BasicHeldItem.new(self, player, slot)

    self:add_drawable("block_hologram", Spritesheet("assets/tileset.png", 8, 8, false))
    self.block_hologram.layer = DrawLayers.TILES
    self.block_hologram.framepos:set(self.stack.data.block - 1, 0)

    self.place_cooldown = 0
end

local player_mine_range = 32
function BlockHeldItem:_process(delta)
    BasicHeldItem._process(self, delta)
    self.place_cooldown = self.place_cooldown - delta

    local mx, my = global_mouse_pos()
    self.Trans.pos:setv(self.player.Trans.pos)

    look_vec:set(mx - self.player.Trans.pos.x, my - self.player.Trans.pos.y)
    local dist = look_vec:length()
    look_vec.x = look_vec.x / dist
    look_vec.y = look_vec.y / dist

    if dist > player_mine_range then
        mx = self.player.Trans.pos.x + look_vec.x * player_mine_range
        my = self.player.Trans.pos.y + look_vec.y * player_mine_range
    end
    local snapped_mx, snapped_my = math.floor(mx / 8), math.floor(my / 8)

    self.block_hologram.pos:set(snapped_mx * 8, snapped_my * 8)
    self.block_hologram.color[4] = math.abs(math.sin(lt.getTime() * 4) * 0.2) + 0.5

    if (is_pressed("action") and self.place_cooldown < 0) or is_just_pressed("action") then
        self.place_cooldown = 0.05
        local chunk = get_chunk_at_pos(snapped_mx * 8, snapped_my * 8)

        if chunk.tilemap:get_tile(snapped_mx, snapped_my, 1) then goto continue end
        self.stack.amount = self.stack.amount - 1
        self.slot:update_data()
        if self.stack.amount == 0 then
            self.player:update_held_item()
        end

        chunk.tilemap:set_tile(snapped_mx, snapped_my, self.stack.data.block)
        ::continue::
    end
end

-- MINING ITEM
MiningHeldItem = class(BasicHeldItem)
function MiningHeldItem:new(player, slot)
    BasicHeldItem.new(self, player, slot)
    self.anim_coeff = 0
    self.sprite.offset:set(-4, -8)

    self:add_drawable("block_hover", Sprite("assets/block_hover.png", false))
    self.block_hover.layer = DrawLayers.VFX_OVER
    self.block_hover.offset:sub(1)
end

function MiningHeldItem:_process(delta)
    local mx, my = global_mouse_pos()
    self.Trans.pos:setv(self.player.Trans.pos)

    look_vec:set(mx - self.player.Trans.pos.x, my - self.player.Trans.pos.y)
    local dist = look_vec:length()
    look_vec.x = look_vec.x / dist
    look_vec.y = look_vec.y / dist

    if dist > player_mine_range then
        mx = self.player.Trans.pos.x + look_vec.x * player_mine_range
        my = self.player.Trans.pos.y + look_vec.y * player_mine_range
    end
    look_vec:mul(8)

    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.pos:addv(look_vec)
    self.sprite.angle = look_vec:angle()
    self.sprite.flipy = self.player.look_dir < 0

    self.sprite.angle = self.sprite.angle + math.sin(lt.getTime() * 30) * 0.6 * self.anim_coeff

    local lookx, looky = tile_raycast(
        self.player.Trans.pos.x / 8,
        self.player.Trans.pos.y / 8,
        mx/8, my/8
    )
    lookx, looky = math.floor(lookx), math.floor(looky)

    local chunk = get_chunk_at_pos(lookx * 8, looky * 8)
    self.block_hover.pos:set(lookx * 8, looky * 8)
    self.block_hover:hide()

    if is_pressed("action") then 
        chunk.tilemap:damage_tile(
            lookx, looky, 0.1
        )
        self.anim_coeff = lerp(self.anim_coeff, 1, delta * 20)
    else
        self.anim_coeff = lerp(self.anim_coeff, 0, delta * 20)
    end

    if chunk.tilemap:get_tile(lookx, looky) then
        self.block_hover:show()
    end
end

return function()
    look_vec = Vec()
end