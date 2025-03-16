
BasicHeldItem = class(Entity)
function BasicHeldItem:new(player, stack)
    self.player = player
    self.player.on_held_update:connect(self._item_swapped)

    self.stack = stack
    self:add(TansComp(player.Trans.pos:get()))

    self:add_drawable("sprite", Spritesheet("assets/itemsheet.png", 8, 8))
end

function BasicHeldItem:_process(delta)
    self.Trans.pos:setv(self.player.Trans.pos)
    self.sprite.pos:setv(self.Trans.pos)
end

function BasicHeldItem:_item_swapped()
    self.player.on_held_update:disconnect(self._item_swapped)
    self:kill()
end