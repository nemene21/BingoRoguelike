Signal = class()

function Signal:new()
    self.callbacks = {}
end

function Signal:connect(callback)
    self.callbacks[callback] = true
end

function Signal:disconnect(callback)
    self.callbacks[callback] = nil
end

function Signal:emit(...)
    for callback, _ in pairs(self.callbacks) do
        callback(...)
    end
end

