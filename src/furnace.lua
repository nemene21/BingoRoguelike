
Furnace = class(Entity)
function Furnace:new(x, y)
    Entity.new(self)

    self:add(BlockComp(x, y))
    self.Block.block[2] = 2
    
    self:add(TransComp(x*8, y*8))
    self:add_drawable("chimney", Sprite("assets/furnace_chimney.png"))
    self.chimney.pos:setv(self.Trans.pos)
    self.chimney.pos:add(6, -4)
    
    self:add_drawable("chimney_smoke", ParticleSys("assets/furnace_smoke.json"))
    self.chimney_smoke.pos:setv(self.Trans.pos)
    self.chimney_smoke.pos:add(6, -8)
    self.chimney_smoke.layer = DrawLayers.VFX_OVER
    self.chimney_smoke.emitting = true
end

function Furnace:_process(delta)


    add_light(self.Trans.pos, 5)
end

function Furnace:stringify()
    return class2string(self, {self.Block.tilepos.x, self.Block.tilepos.y})
end