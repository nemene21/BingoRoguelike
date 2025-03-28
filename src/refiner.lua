
Refiner = class(Entity)
function Refiner:new(x, y)
    Entity.new(self)
    self:add(TransComp(x*8, y*8))

    self:add(BlockComp(x, y))
    self.Block.block[2] = 1

    self:add_drawable("clip", Sprite("assets/refiner_clip.png"))
    self.clip.pos:setv(self.Trans.pos)
    self.clip.pos:add(4, 4)

    self:add_drawable("crank", Sprite("assets/refiner_crank.png"))
    self.crank.pos:setv(self.Trans.pos)
    self.crank.pos:add(4, -3)
    self.crank.offset:add(1, 0)
    self.crank_timer = 0
end

function Refiner:_process(delta)
    self.crank_timer = self.crank_timer + delta
    self.crank.scale.x = math.sin(self.crank_timer * 6)

    self.clip.offset.y = -3 - math.abs(math.sin(self.crank_timer * 6)) * 4
end

function Refiner:stringify()
    return class2string(self, {self.Block.tilepos.x, self.Block.tilepos.y})
end