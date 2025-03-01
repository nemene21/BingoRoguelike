require "framework.ecs"

ChunkHandlerComp = class(Comp)
function ChunkHandlerComp:new()
    Entity.new(Comp)
    self.name = "ChunkHandler"
    self.chunkpos = Vec()
end

local calc_chunkpos
function ChunkHandlerComp:_process(delta)
    local trans = self.entity.Trans
    assert(trans, "Parent entity has no TransComp")

    calc_chunkpos:set(
        math.floor((trans.pos.x / 8) / CHUNKSIZE),
        math.floor((trans.pos.y / 8) / CHUNKSIZE)
    )
end
