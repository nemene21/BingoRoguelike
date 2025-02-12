require "framework.ecs"

CHUNK_DIST = 1

ChunkLoaderComp = class(Comp)
function ChunkLoaderComp:new()
    Comp.new(self, "ChunkLoader")
    self.chunkpos = Vec()
end

local calculated_chunkpos = Vec()
function ChunkLoaderComp:_process(delta)
    local trans = self.entity.Trans
    assert(trans, "Parent entity has no TransComp")

    calculated_chunkpos:set(
        math.floor((trans.pos.x / 8) / CHUNKSIZE),
        math.floor((trans.pos.y / 8) / CHUNKSIZE)
    )

    if calculated_chunkpos.x ~= self.chunkpos.x or calculated_chunkpos.y ~= self.chunkpos.y then
        self.chunkpos:setv(calculated_chunkpos)
    end
end