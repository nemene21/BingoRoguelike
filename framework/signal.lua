require("framework.class")

Signal = class()

function Signal:new()
    self.callbacks = {}
end

function Signal:connect(callback)
    table.insert(self.callbacks, callback)
end

function Signal:emit(...)
    for i = 1, #self.callbacks do
        self.callbacks[i](...)
    end
end

