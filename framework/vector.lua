require "framework.class"
require "framework.misc"

Vec = class()

function Vec:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Vec:length()
    return (self.x^2 + self.y^2)^0.5
end

function Vec:normalized()
    local leng = self:length()
    if leng == 0 then
        return self
    else
        return self / leng
    end
end

function Vec:whole()
    return Vec(math.round(self.x), math.round(self.y))
end

function Vec:get()
    return self.x, self.y
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

