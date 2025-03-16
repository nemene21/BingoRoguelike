
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