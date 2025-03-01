local json = require "json.json"

local particle_pool = {}

ParticleSys = class(Drawable)
function ParticleSys:new(path)
    Drawable.new(self)
    self.particles = {}
    self:set_data(path)
end

function ParticleSys:set_data(path)
    local data = json.decode(love.filesystem.read(path))
    for key, val in pairs(data) do self[key] = val end

    self.tex_res = image_manager:get(self.texture_path)

    self.spawn_timer = Timer(1 / self.firerate_min)
    self.spawn_timer.on_timeout:connect(function()
        for i = 1, lm.random(self.amount_min, self.amount_max) do
            self:_spawn()
        end
        self.spawn_timer.max_time = 1 / lerp(self.firerate_min, self.firerate_max, lm.random())
        self.spawn_timer:restart()
    end)
    self.spawn_timer:start()
    self:update_batch()
end

function ParticleSys:update_batch()
    local max_particles = self.amount_max * (self.lifetime_max * self.firerate_max) + 1
    self.batch = lg.newSpriteBatch(self.tex_res:get(), max_particles)
end

function ParticleSys:process_particle(pcl, delta)
    pcl.x = pcl.x + pcl.vx * delta
    pcl.y = pcl.y + pcl.vy * delta
    pcl.angle = pcl.angle + pcl.angle_vel * delta

    pcl.lf = pcl.lf - delta

    local blend = pcl.lf / pcl.lf_max
    pcl.curr_scale = pcl.scale * blend

    local color_blend = 1 - blend
    pcl.curr_color[1] = lerp(pcl.color[1], pcl.color_end[1], color_blend)
    pcl.curr_color[2] = lerp(pcl.color[2], pcl.color_end[2], color_blend)
    pcl.curr_color[3] = lerp(pcl.color[3], pcl.color_end[3], color_blend)
    pcl.curr_color[4] = lerp(pcl.color[4], pcl.color_end[4], color_blend)
end

function ParticleSys:_spawn()
    local pcl = table.remove(particle_pool) or {}
    pcl.x = 0
    pcl.y = 0

    if self.local_coords then
        pcl.x = pcl.x + self.pos.x
        pcl.y = pcl.y + self.pos.y
    end

    local vel = lerp(self.start_velocity_min, self.start_velocity_max, lm.random())
    local direction = self.direction + lm.random(-self.spread, self.spread) * 0.5
    direction = math.rad(direction)

    pcl.vx = math.cos(direction) * vel
    pcl.vy = math.sin(direction) * vel

    pcl.scale = lerp(self.scale_min, self.scale_max, lm.random())
    pcl.scale_end = self.scale_end or pcl.scale

    pcl.angle = math.rad(lerp(self.angle_min, self.angle_max, lm.random()))
    pcl.angle_vel = math.rad(lerp(self.start_angle_velocity_min, self.start_angle_velocity_max, lm.random()))

    pcl.lf = lerp(self.lifetime_min, self.lifetime_max, lm.random())
    pcl.lf_max = pcl.lf

    local r_blend, g_blend, b_blend, a_blend = lm.random(), lm.random(), lm.random(), lm.random()
    local shared_color_blend = lm.random()
    r_blend = lerp(shared_color_blend, r_blend, self.color_deviation)
    g_blend = lerp(shared_color_blend, g_blend, self.color_deviation)
    b_blend = lerp(shared_color_blend, b_blend, self.color_deviation)

    if not pcl.color then pcl.color = {} end
    pcl.color[1] = lerp(self.color_min[1], self.color_max[1], r_blend) / 255
    pcl.color[2] = lerp(self.color_min[2], self.color_max[2], g_blend) / 255
    pcl.color[3] = lerp(self.color_min[3], self.color_max[3], b_blend) / 255
    pcl.color[4] = lerp(self.color_min[4], self.color_max[4], a_blend) / 255

    if not pcl.color_end then pcl.color_end = {} end
    pcl.color_end[1] = (self.color_end[1] or (pcl.color[1] * 255)) / 255
    pcl.color_end[2] = (self.color_end[2] or (pcl.color[2] * 255)) / 255
    pcl.color_end[3] = (self.color_end[3] or (pcl.color[3] * 255)) / 255
    pcl.color_end[4] = (self.color_end[4] or (pcl.color[4] * 255)) / 255
    pcl.curr_color = {}

    table.insert(self.particles, pcl)
end

function ParticleSys:_process(delta)
    local delta = delta * self.time_scale
    if self.emitting then
        self.spawn_timer:tick(delta)
    end

    for i, pcl in ipairs(self.particles) do
        self:process_particle(pcl, delta)
    end

    local i = 1
    local pcl_count = #self.particles
    while self.particles[i] ~= nil do
        if self.particles[i].lf <= 0 then
            table.insert(particle_pool, self.particles[i])
            self.particles[i] = self.particles[pcl_count]
            self.particles[pcl_count] = nil

            pcl_count = pcl_count - 1
        else
            i = i + 1
        end
    end
end

function ParticleSys:_draw()
    local w, h = self.tex_res:get():getDimensions()
    w = w * 0.5
    h = h * 0.5

    if self.local_coords then lg.translate(-self.pos.x, -self.pos.y) end

    self.batch:clear()
    for i, pcl in ipairs(self.particles) do
        self.batch:setColor(unpack(pcl.curr_color))
        self.batch:add(pcl.x, pcl.y, pcl.angle, pcl.curr_scale, pcl.curr_scale, w, h)
    end
    lg.setColor(1, 1, 1, 1)
    lg.draw(self.batch)
end