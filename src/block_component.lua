
BlockComp = class(Comp)
function BlockComp:new(x, y)
    Comp.new(self, "Block")

    self.tilepos = Vec(x, y)
    self.on_destroy = Signal()
    self.on_item_enter = Signal()

    self.chunk = get_chunk_at_pos(x*8, y*8)
    local tilemap = self.chunk.tilemap
    tilemap.tileents[x + y * tilemap.tilewidth] = self
    self.block = tilemap:get_tile(x, y)
end

function BlockComp:_destroyed()
    self.on_destroy:emit()
    self.entity:kill()
end

function BlockComp:_item_enter(item)
    self.on_item_enter:emit(item)
end