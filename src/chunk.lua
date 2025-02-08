require "framework.ecs"
require "framework.tilemap"

Chunk = class(Entity)
function Chunk:new(x, y)
    self.owned = {}
end

function Chunk:save()
    
end