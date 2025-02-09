require "framework.class"
require "framework.signal"

Input = class()
function Input:new(key, source)
    self.source = source or "keyboard"
    self.key = key
end

function Input:is_pressed()
    if self.source == "joystick" then
        local joystick = love.joystick.getJoysticks()[1]
        if joystick == nil then return false end
        return joystick:sDown(self.key)

    elseif self.source == "keyboard" then
        return love.keyboard.isDown(self.key)
    else
        return love.mouse.isDown(self.key)
    end
end

local actions = {
    test = {Input("t"), Input("p"), Input(1, "mouse")},
    left = {Input("a"), Input("left")},
    right = {Input("d"), Input("right")},
    down = {Input("s"), Input("down")},
    up = {Input("w"), Input("up")}
}

just_pressed = Signal()

function love.keypressed(key, scancode, isrepeat)
    for name, action in pairs(actions) do
        if action.source == "keyboard" and action.key == key then
            just_pressed:emit(name)
        end
    end
end

function check_mouse_input(key)
    for name, action in pairs(actions) do
        if action.source == "mouse" and action.key == key then
            just_pressed:emit(name)
        end
    end
end

function is_pressed(action)
    local action = actions[action]
    for i, key in ipairs(action) do
        if key:is_pressed() then
            return true
        end
    end
    return false
end