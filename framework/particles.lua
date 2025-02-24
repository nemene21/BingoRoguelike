require "framework.drawable"
require "framework.timer"

ParticleSys = class(Drawable)
function ParticleSys:new(path)
    Drawable.new(self)
    self.particles = {}

    self.spawn_timer = Timer(0.1, true)
    self.spawn_timer.on_timeout:connect(function()
        print("skibidi")
        self:_spawn()
    end)
end

function ParticleSys:process_particle(pcl, delta)
    pcl.x = pcl.x + pcl.velx * delta
    pcl.y = pcl.y + pcl.vely * delta
end

function ParticleSys:_spawn()
    local pcl = {
        x = lm.random() * 64,
        y = lm.random() * 64,
        vx = lm.random() * 16,
        vy = lm.random() * 16,
        scale = lm.random() * 0.5 + 0.5
    }
    self.particles[pcl] = true
end

function ParticleSys:_process(delta)
    self.spawn_timer:tick(delta)

    for pcl, _ in ipairs(self.particles) do
        self:process_particle(pcl, delta)
    end
end

function ParticleSys:_draw()
    for pcl, _ in ipairs(self.particles) do
        lg.circle("fill", pcl.x, pcl.y, 3 * pcl.scale)
    end
    -- lg.circle("fill", 0, 0, 128)
end