require "framework.ecs"
require "framework.vector"
require "src.chunk"

TransComp = class(Comp)
function TransComp:new(x, y, collides, scalex, scaley, ang)
    Comp.new(self, "Trans")
    self.pos = Vec(x, y)
    self.scale = Vec(scalex or 1, scaley or 1)
    self.angle = ang
    self.vel = Vec()
    self.collides = collides or false
end

function TransComp:_process()
    self:move(self.vel)
end

local collision_point = Vec()
function TransComp:get_collision(movx, movy)
    local chunk = get_chunk_at_pos(self.pos:get())
    if not chunk then return false end

    local tilemap = chunk.tilemap
    if not tilemap then return false end

    local tilex, tiley = math.floor(self.pos.x / tilemap.tilesize), math.floor(self.pos.y / tilemap.tilesize)

    if tilemap:get_tile(tilex, tiley) then
        collision_point:set(tilex, tiley)
        collision_point:mul(tilemap.tilesize)
        collision_point:sub(1)
        if movx < 0 then collision_point.x = collision_point.x + tilemap.tilesize + 2 end
        if movy < 0 then collision_point.y = collision_point.y + tilemap.tilesize + 2 end
        return collision_point
    else return nil end
end

function TransComp:do_collision(movx, movy)
    if not self.collides then return false end

    local collides_at = self:get_collision(movx, movy)
    
    if collides_at then
        if movx ~= 0 then self.pos.x = collides_at.x end
        if movy ~= 0 then self.pos.y = collides_at.y end
    end
end

function TransComp:move(vec)
    self.pos.x = self.pos.x + vec.x
    self:do_collision(vec.x, 0)
    self.pos.y = self.pos.y + vec.y
    self:do_collision(0, vec.y)
end

function TransComp:_draw_debug()
    
end