local pressed_inputs = {}
local released_inputs = {}
local scroll = 0

function get_scroll() return scroll end

function add_scroll(adding)
    scroll = scroll + adding
end

Input = class()
function Input:new(key, source)
    self.source = source or "keyboard"
    self.key = key
end

function Input:is_pressed()
    -- Check joystick input
    if self.source == "joystick" then
        local joystick = love.joystick.getJoysticks()[1]
        if joystick == nil then return false end
        return joystick:sDown(self.key)
    
    -- Check keyboard input (return false instantly if debug GUI is focused)
    elseif self.source == "keyboard" then
        if imgui.love.GetWantCaptureKeyboard() then return false end
        return love.keyboard.isDown(self.key)

    -- Check mouse input (return false instantly if debug GUI is focused)
    else
        if imgui.love.GetWantCaptureMouse() then return false end
        return love.mouse.isDown(self.key)
    end
end

local actions = {
    ["action"] = {Input(1, "mouse")},
    ["inventory open"] = {Input("r")},
    ["craft"] = {Input("control")},

    slot_1 = {Input("1")},
    slot_2 = {Input("2")},
    slot_3 = {Input("3")},
    slot_4 = {Input("4")},
    slot_5 = {Input("5")},

    scroll_up = {Input("wu", "mouse")},
    scroll_down = {Input("wd", "mouse")},

    click = {Input(1, "mouse")},
    secondary_click = {Input(2, "mouse")},

    left  = {Input("a"), Input("left")},
    right = {Input("d"), Input("right")},
    jump  = {Input("space")}
}

function check_keyboard_input(key)
    table.insert(pressed_inputs, Input(key, "keyboard"))
end

function check_keyboard_released(key)
    table.insert(released_inputs, Input(key, "keyboard"))
end

function check_mouse_input(key)
    table.insert(pressed_inputs, Input(key, "mouse"))
end

function check_mouse_released(key)
    table.insert(released_inputs, Input(key, "mouse"))
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

function is_just_released(action)
    local action = actions[action]

    for i, first in ipairs(action) do
        for j, other in ipairs(released_inputs) do

            if first.key == other.key and first.source == other.source then
                return true
            end
        end
    end
    return false
end

function input_step()
    pressed_inputs = {}
    released_inputs = {}
    scroll = 0
end