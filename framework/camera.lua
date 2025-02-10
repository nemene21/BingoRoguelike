
require "framework.ecs"
require "framework.transform"

-- <Camera class>
global_camera = nil
Camera = class()

function Camera:new(x, y)
    self.pos = Vec(x or 0, y or 0)
    self.offset = Vec()
end

function Camera:activate()
    global_camera = self
end

function Camera:follow(pos, speed)
    self.pos:dlerpv(pos, lt.getDelta() * (speed or 20))
end

function Camera:get_origin()
    return self.pos + self.offset
end

global_camera = Camera()

-- <Camera comp>
CamComp = class(Comp)

function CamComp:new()
    Comp.new(self, "Cam")
    self.camera = Camera()
end

function CamComp:_process(delta)
    local trans = self.entity.Trans
    if trans ~= nil then
        self.camera:follow(trans.pos)
    end
end