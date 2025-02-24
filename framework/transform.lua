require "framework.ecs"
require "framework.vector"
require "src.chunk"

function RectCollider(x, y, width, height)
    local width  = width  * 0.5
    local height = height * 0.5
    local points = {}
    table.insert(points, {x +  width, y + height})
    table.insert(points, {x + -width, y + height})
    table.insert(points, {x +  width, y + -height})
    table.insert(points, {x + -width, y + -height})
    return points
end


TransComp = class(Comp)
function TransComp:new(x, y, collider, scalex, scaley, ang)
    Comp.new(self, "Trans")
    self.pos = Vec(x, y)
    self.scale = Vec(scalex or 1, scaley or 1)
    self.angle = ang
    self.vel = Vec()
    self.kb = Vec()
    self.movement = Vec()
    self.touching = Vec()

    self:set_collider(collider)
end

function TransComp:_process(delta)
    self.movement:setv(self.vel)
    self.movement:addv(self.kb)
    self.movement:mul(delta)
    self:move(self.movement)
end

function TransComp:set_collider(collider)
    self.collider = collider
    self.collides = collider ~= nil
end

local collision_point = Vec()
function TransComp:get_collision(point, movx, movy)
    local chunk = get_chunk_at_pos(self.pos:get())
    if not chunk then return false end

    local tilemap = chunk.tilemap
    if not tilemap then return false end

    local tilex, tiley = math.floor((self.pos.x + point[1]) / tilemap.tilesize), math.floor((self.pos.y + point[2]) / tilemap.tilesize)

    if tilemap:get_tile(tilex, tiley) then
        collision_point:set(tilex, tiley)
        collision_point:mul(tilemap.tilesize)
        collision_point:sub(0.1)

        if movx < 0 then collision_point.x = collision_point.x + tilemap.tilesize + 0.2 end
        if movy < 0 then collision_point.y = collision_point.y + tilemap.tilesize + 0.2 end
        return collision_point
    else return nil end
end

function TransComp:do_collision(movx, movy)
    if not self.collides then return false end

    for i, point in ipairs(self.collider) do
        local collides_at = self:get_collision(point, movx, movy)
        
        if collides_at then
            if movx ~= 0 then
                self.pos.x = collides_at.x - point[1]
                self.touching.x = movx
            end
            if movy ~= 0 then
                self.pos.y = collides_at.y - point[2]
                self.touching.y = movy
            end
        end
    end
end

function TransComp:on_floor()
    return self.touching.y > 0
end

function TransComp:on_ceil()
    return self.touching.y < 0
end

function TransComp:on_left_wall()
    return self.touching.x < 0
end

function TransComp:on_right_wall()
    return self.touching.x > 0
end

function TransComp:on_wall()
    return self.touching.x ~= 0
end

function TransComp:move(vec)
    self.touching:set(0)

    self.pos.x = self.pos.x + vec.x
    self:do_collision(vec.x, 0)
    self.pos.y = self.pos.y + vec.y
    self:do_collision(0, vec.y)
end