require "framework.class"
require "framework.signal"

local pressed_inputs = {}

Input = class()
function Input:new(key, source)
    self.source = source or "keyboard"
    self.key = key
end

function Input:is_pressed()
    if imgui.love.GetWantCaptureKeyboard() or imgui.love.GetWantCaptureMouse() then
        return false
    end

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

function check_keyboard_input(key)
    table.insert(pressed_inputs, Input(key, "keyboard"))
end

function check_mouse_input(key)
    table.insert(pressed_inputs, Input(key, "mouse"))
end

function love.joystickpressed(joystick, key)
    table.insert(pressed_inputs, Input(key, "joystick"))
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

function is_just_pressed(action)
    local action = actions[action]

    for i, first in ipairs(action) do
        for j, other in ipairs(pressed_inputs) do

            if first.key == other.key and first.source == other.source then
                return true
            end
        end
    end        
    return false
end

function input_step()
    pressed_inputs = {}
end