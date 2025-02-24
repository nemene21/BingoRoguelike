local ffi = require("ffi")
imgui = require "cimgui"
require "framework.input"
require "framework.ecs"

process_time = 0
draw_time = 0

local process_time_sum = 0
local draw_time_sum = 0
local frames = 0
local avg_process_time = 0
local avg_draw_time = 0

local allowed_ms = math.floor(1000 / 60.0)

local code_buff = ffi.new("char[8192]", "Code goes here")

function update_debug(delta)
    imgui.love.Update(delta)
    imgui.NewFrame()
    frames = frames + 1

    if frames > 60 then
        avg_process_time = math.floor(process_time_sum / frames)
        avg_draw_time = math.floor(draw_time_sum / frames)
        process_time_sum = 0
        draw_time_sum = 0
        frames = 1
    end
end

function show_stat_limited(name, stat, maximum, unit, flip)
    local flip = flip or false

    local unit = unit or ""
    local color
    if not flip then
        color = stat > maximum and imgui.ImVec4_Float(1, 0, 0, 1) or imgui.ImVec4_Float(0, 1, 0, 1)
    else
        color = stat < maximum and imgui.ImVec4_Float(1, 0, 0, 1) or imgui.ImVec4_Float(0, 1, 0, 1)
    end

    imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, color)
    imgui.Text(name..tostring(stat).."/"..tostring(maximum)..unit)
    imgui.PopStyleColor(1)
end

function render_debug()
    local ncomps = 0
    for k, v in pairs(current_scene.comps) do
        ncomps = ncomps + table.entries(v)
    end
    imgui.InputTextMultiline("##Code", code_buff, ffi.sizeof(code_buff), imgui.ImVec2_Float(300, 200))
    if imgui.Button("Run code") then
        local func = loadstring(ffi.string(code_buff))
        local did, error = pcall(func)
        if not did then print(error) end
    end

    imgui.Text("Drawcalls: "..tostring(lg.getStats().drawcalls))
    show_stat_limited("FPS: ", lt.getFPS(), 60, nil, true)

    process_time = math.floor(process_time * 1000)
    draw_time = math.floor(draw_time * 1000)

    process_time_sum = process_time_sum + process_time
    draw_time_sum = draw_time_sum + draw_time

    show_stat_limited("Process time:      ", process_time, allowed_ms, "ms")
    show_stat_limited("Avg. process time: ", avg_process_time, allowed_ms, "ms")
    show_stat_limited("Draw time:         ", draw_time, allowed_ms, "ms")
    show_stat_limited("Avg. draw time:    ", avg_draw_time, allowed_ms, "ms")

    imgui.Separator()

    imgui.Text("Comps ("..tostring(ncomps).."):")
    imgui.Indent(16)
    for name, comp in pairs(current_scene.comps) do
        imgui.Text(name..": "..tostring(#comp))
    end
    imgui.Unindent(16)

    imgui.Text("Ents ("..tostring(largest_ent_id - #free_ent_ids).."):")
    imgui.Text("Loaded chunks ("..tostring(table.entries(loaded_chunks)).."):")

    imgui.Indent(16)
    for key, chunk in pairs(loaded_chunks) do
        imgui.Text(key)
    end
    imgui.Unindent(16)

    imgui.Separator()
    image_manager:show_debug("Image")
    shader_manager:show_debug("Shader")

    imgui.Render()
    imgui.love.RenderDrawLists()
end

function particle_editor()
    imgui.Begin("Particle Editor")
    local thing = ffi.new("float[1]", 0.5)
    imgui.SliderFloat("Test", thing, 0, 1)
    imgui.End()
end

love.mousemoved = function(x, y, ...)
    imgui.love.MouseMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then

    end
end

love.mousepressed = function(x, y, button, ...)
    imgui.love.MousePressed(button)
    if not imgui.love.GetWantCaptureMouse() then
        check_mouse_input(button)
    end
end

love.mousereleased = function(x, y, button, ...)
    imgui.love.MouseReleased(button)
    if not imgui.love.GetWantCaptureMouse() then

    end
end

love.wheelmoved = function(x, y)
    imgui.love.WheelMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then

    end
end

love.keypressed = function(key, ...)
    imgui.love.KeyPressed(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        check_keyboard_input(key)
    end
end

love.keyreleased = function(key, ...)
    imgui.love.KeyReleased(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.textinput = function(t)
    imgui.love.TextInput(t)
    if imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end