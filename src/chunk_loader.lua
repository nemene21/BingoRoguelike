require "framework.ecs"
require "src.chunk"

ChunkLoaderComp = class(Comp)
function ChunkLoaderComp:new()
    Comp.new(self, "ChunkLoader")
    self.chunkpos = Vec()
end

local calc_chunkpos = Vec()
function ChunkLoaderComp:_process(delta)
    local trans = self.entity.Trans
    assert(trans, "Parent entity has no TransComp")

    calc_chunkpos:set(
        math.floor((trans.pos.x / 8) / CHUNKSIZE),
        math.floor((trans.pos.y / 8) / CHUNKSIZE)
    )

    if calc_chunkpos.x ~= self.chunkpos.x or calc_chunkpos.y ~= self.chunkpos.y then
        self.chunkpos:setv(calc_chunkpos)
    end

    local chunk
    for x = -CHUNK_DIST, CHUNK_DIST do
        for y = -CHUNK_DIST, CHUNK_DIST do
            calc_chunkpos:set(x, y)
            if calc_chunkpos:length() < CHUNK_DIST then

                calc_chunkpos:addv(self.chunkpos)
                chunk = loaded_chunks[ckey(calc_chunkpos:get())]
                if chunk == nil then
                    Chunk(calc_chunkpos:get())
                end
            end
        end
    end
end