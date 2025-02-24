require "framework.drawable"
require "framework.timer"

local json = require "json.json"

ParticleSys = class(Drawable)
function ParticleSys:new(path)
    Drawable.new(self)
    self.particles = {}

    local data = json.decode(love.filesystem.read(path))
    for key, val in pairs(data) do self[key] = val end

    self.tex_res = image_manager:get(self.texture_path)

    self.spawn_timer = Timer(0.1, true)
    self.spawn_timer.on_timeout:connect(function()
        self:_spawn()
    end)
end

function ParticleSys:process_particle(pcl, delta)
    pcl.x = pcl.x + pcl.vx * delta
    pcl.y = pcl.y + pcl.vy * delta
    pcl.angle = pcl.angle + pcl.angle_vel * delta

    pcl.lf = pcl.lf - delta
end

function ParticleSys:_spawn()
    local pcl = {}
    pcl.x = 0
    pcl.y = 0

    local vel = lerp(self.start_velocity_min, self.start_velocity_max, lm.random())
    local direction = self.direction + lm.random(-self.spread, self.spread) * 0.5
    direction = math.rad(direction)

    pcl.vx = math.cos(direction) * vel
    pcl.vy = math.sin(direction) * vel

    pcl.scale = lerp(self.scale_min, self.scale_max, lm.random())

    pcl.angle = lerp(self.angle_min, self.angle_max, lm.random())
    pcl.angle_vel = lerp(self.start_angle_velocity_min, self.start_angle_velocity_max, lm.random())

    pcl.lf = lerp(self.lifetime_min, self.lifetime_max, lm.random())
    pcl.lf_max = pcl.lf

    table.insert(self.particles, pcl)
end

function ParticleSys:_process(delta)
    local delta = delta * self.time_scale
    self.spawn_timer:tick(delta)

    for i, pcl in ipairs(self.particles) do
        self:process_particle(pcl, delta)
    end

    local i = 1
    local pcl_count = #self.particles
    while self.particles[i] ~= nil do
        if self.particles[i].lf <= 0 then
            self.particles[i] = self.particles[pcl_count]
            self.particles[pcl_count] = nil

            pcl_count = pcl_count - 1
        else
            i = i + 1
        end
    end
end

function ParticleSys:_draw()
    for i, pcl in ipairs(self.particles) do
        lg.draw(self.tex_res:get(), pcl.x, pcl.y, pcl.angle, pcl.scale, pcl.scale)
    end
    lg.circle("fill", 0, 0, 2)
end