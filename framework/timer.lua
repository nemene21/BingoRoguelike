Timer = class()
function Timer:new(time, auto)
    self.time = time or 1
    self.max_time = time
    self.timescale = 1

    self.auto = auto or false
    self.running = false

    if auto then self:start() end

    self.on_timeout = Signal()
end

function Timer:start()
    self.running = true
end

function Timer:stop()
    self.running = false
end

function Timer:restart()
    self.time = self.max_time
    self:start()
end

function Timer:tick(dt)
    self.time = self.time - dt * self.timescale * btoi(self.running)
    
    if self.time < 0 then
        self.time = 0
        self.on_timeout:emit()

        if self.auto then self:restart() end
    end
end