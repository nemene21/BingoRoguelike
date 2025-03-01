require "framework.class"
require "framework.misc"

Vec = class()

function Vec:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Vec:length()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vec:normalize()
    if self.x == 0 and self.y == 0 then return false end
    self:div(self:length())
end

function Vec:whole()
    return Vec(math.round(self.x), math.round(self.y))
end

function Vec:get()
    return self.x, self.y
end

function Vec:distance_to(other)
    local diffx = other.x - self.x
    local diffy = other.y - self.y
    return math.sqrt(diffx*diffx + diffy*diffy)
end

function Vec:compare(other)
    return other.x == self.x or other.y == self.y
end

function Vec:addv(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
end

function Vec:subv(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
end


function Vec:mulv(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
end

function Vec:divv(other)
    self.x = self.x / other.x
    self.y = self.y / other.y
end

function Vec:add(x, y)
    local y = y or x
    self.x = self.x + x
    self.y = self.y + y
end

function Vec:sub(x, y)
    local y = y or x
    self.x = self.x - x
    self.y = self.y - y
end

function Vec:mul(x, y)
    local y = y or x
    self.x = self.x * x
    self.y = self.y * y
end

function Vec:div(x, y)
    local y = y or x
    self.x = self.x / x
    self.y = self.y / y
end

function Vec:setv(other)
    self.x = other.x
    self.y = other.y
end

function Vec:set(x, y)
    local y = y or x
    self.x = x
    self.y = y
end

function Vec:dlerp(x, y, c)
    local blend = 0.5 ^ c
    self.x = lerp(x, self.x, blend)
    self.y = lerp(y, self.y, blend)
end

function Vec:dlerpv(to, c)
    local blend = 0.5 ^ c
    self.x = lerp(to.x, self.x, blend)
    self.y = lerp(to.y, self.y, blend)
end

 -- Operaror overloading (yuck)
function Vec:__add(other)
    if type(other) == "number" then
        return Vec(self.x + other, self.y + other)
    else
        return Vec(self.x + other.x, self.y + other.y)
    end
end

function Vec:__sub(other)
    if type(other) == "number" then
        return Vec(self.x - other, self.y - other)
    else
        return Vec(self.x - other.x, self.y - other.y)
    end
end

function Vec:__mul(other)
    if type(other) == "number" then
        return Vec(self.x * other, self.y * other)
    else
        return Vec(self.x * other.x, self.y * other.y)
    end
end

function Vec:__div(other)
    if type(other) == "number" then
        return Vec(self.x / other, self.y / other)
    else
        return Vec(self.x / other.x, self.y / other.y)
    end
end

