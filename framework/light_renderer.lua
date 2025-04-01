LightRenderer = class(Entity)
function LightRenderer:new()
    Entity.new(self)
    self:add_drawable("sys", ParticleSys("assets/ligth_particles.json"))
end

function LightRenderer:proess(delta)
    self.sys.pos:set(global_camera:get_origin())
end