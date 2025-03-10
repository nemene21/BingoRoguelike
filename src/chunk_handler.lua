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

    if not self.chunkpos:compare(calc_chunkpos) then
        local chunk = loaded_chunks[ckey(self.chunkpos:get())]
        if chunk then chunk:remove_entity(self.entity) end

        self.chunkpos:setv(calc_chunkpos)
        chunk = loaded_chunks[ckey(self.chunkpos:get())]
        if chunk then
            chunk:add_entity(self.entity)
        else
            chunk_fugitive(self.entity)
        end
    end
end

return function()
    calc_chunkpos = Vec()
end