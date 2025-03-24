
BlockComp = class(Comp)
function BlockComp:new(x, y, block)
    Comp.new(self, "Block")

    self.tilepos = Vec(x, y)
    self.block = block
    self.on_destroy = Signal()
    self.on_item_enter = Signal()
end

function BlockComp:_destroyed()
    self.on_destroy:emit()
    self.entity:kill()
end

function BlockComp:_item_enter(item)
    self.on_item_enter:emit(item)
end