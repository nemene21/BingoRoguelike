
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
function MiningHeldItem:_process(delta)
    local mx, my = global_mouse_pos()
    self.Trans.pos:setv(self.player.Trans.pos)

    look_vec:set(mx - self.player.Trans.pos.x, my - self.player.Trans.pos.y)
    look_vec:normalize()
    look_vec:mul(8)

    self.sprite.pos:setv(self.Trans.pos)
    self.sprite.pos:addv(look_vec)
    self.sprite.angle = look_vec:angle()
    self.sprite.flipy = self.player.look_dir < 0

    self.sprite.angle = self.sprite.angle + math.sin(lt.getTime() * 30) * 0.6 * self.anim_coeff

    local snapped_mx, snapped_my = math.floor(mx / 8), math.floor(my / 8)
    self.block_hover.pos:set(snapped_mx * 8, snapped_my * 8)
    self.block_hover:hide()

    local chunk = get_chunk_at_pos(mx, my)

    if is_pressed("break") then 
        chunk.tilemap:damage_tile(
            snapped_mx,
            snapped_my,
            0.1
        )
        self.anim_coeff = lerp(self.anim_coeff, 1, delta * 20)
    else
        self.anim_coeff = lerp(self.anim_coeff, 0, delta * 20)
    end

    if chunk.tilemap:get_tile(snapped_mx, snapped_my) then
        self.block_hover:show()
    end
end

return function()
    look_vec = Vec()
end