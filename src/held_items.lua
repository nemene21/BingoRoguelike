
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

    if is_pressed("break") then
        local chunk = get_chunk_at_pos(mx, my)
        chunk.tilemap:damage_tile(
            math.floor(mx / 8),
            math.floor(my / 8),
            0.1
        )
    end
end

return function()
    look_vec = Vec()
end