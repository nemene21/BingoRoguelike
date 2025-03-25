
Furnace = class(Entity)
function Furnace:new(x, y)
    Entity.new(self)

    self:add(BlockComp(x, y))
    self.Block.block[2] = 2
    
    self:add(TransComp(x*8, y*8))
    self:add_drawable("chimney", Sprite("assets/furnace_chimney.png"))
end

function Furnace:_process(delta)
    self.chimney.pos:setv(self.Trans.pos)
    self.chimney.pos:add(6, -4)
    self.chimney.pos:floor()
    
    add_light(self.Trans.pos, 5)
end

function Furnace:stringify()
    return class2string(self, {self.Block.tilepos.x, self.Block.tilepos.y})
end