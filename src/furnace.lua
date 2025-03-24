
Furnace = class(Entity)
function Furnace:new(x, y, block)
    Entity.new(self)
    self:add(BlockComp(x, y, block))
    self.Block.block[2] = 2
    
    self:add(TransComp(x*8, y*8))
end

function Furnace:_process()
    add_light(self.Trans.pos, 5)
end