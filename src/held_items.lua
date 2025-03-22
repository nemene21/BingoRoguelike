
BasicHeldItem = class(Entity)
function BasicHeldItem:new(player, stack)
    Entity.new(self)
    self.player = player

    self._swap_callback = function()
        self.player.on_held_update:disconnect(self._swap_callback)
        self:kill()
    end
    self.player.on_held_update:connect(self._swap_callback)

    self.stack = stack
    self:add(TransComp(0, 0))

    self:add_drawable("sprite", Spritesheet("assets/itemsheet.png", 8, 8))
    self.sprite.framepos.x = stack.data.tex_id
end

function BasicHeldItem:_process(delta)
    self.Trans.pos:setv(self.player.Trans.pos)

    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.pos:add(self.player.look_dir * 6, 0)
    self.sprite.flipx = self.player.sprite.flipx
end

-- BLOCK ITEM
BlockItem = class(BasicHeldItem)

-- MINING ITEM
MiningHeldItem = class(BasicHeldItem)
function MiningHeldItem:new(player, stack)
    BasicHeldItem.new(self, player, stack)
    self.anim_coeff = 0
    self.sprite.offset:set(-4, -8)

    self:add_drawable("block_hover", Sprite("assets/block_hover.png", false))
    self.block_hover.layer = DrawLayers.VFX_OVER
    self.block_hover.offset:sub(1)
end

local look_vec
local player_mine_range = 24
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

    if is_pressed("break") then 
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