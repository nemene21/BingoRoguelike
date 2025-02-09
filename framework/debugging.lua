local ffi = require("ffi")
imgui = require "cimgui"
require "framework.input"
require "framework.ecs"

process_time = 0
local process_time_sum = 0
draw_time = 0
local draw_time_sum = 0
local frames = 0

local code_buff = ffi.new("char[8192]", "Code goes here")

function update_debug(delta)
    imgui.love.Update(delta)
    imgui.NewFrame()
    frames = frames + 1

    if frames > 60 then
        frames = 1
        process_time_sum = 0
    end
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
    imgui.Text("FPS: "..tostring(lt.getFPS()))

    process_time = math.floor(process_time * 1000)
    draw_time = math.floor(draw_time * 1000)

    local allowed_ms = math.floor(1000 / 60.0)
    local color = process_time > allowed_ms and
        imgui.ImVec4_Float(1, 0, 0, 1) or imgui.ImVec4_Float(0, 1, 0, 1)

    imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, color)
    imgui.Text("Process time:      "..tostring(process_time).."/"..tostring(allowed_ms).."ms")
    imgui.PopStyleColor(1)

    process_time_sum = process_time_sum + process_time
    local avg_process_time = math.floor(process_time_sum / frames)

    color = avg_process_time > allowed_ms and
    imgui.ImVec4_Float(1, 0, 0, 1) or imgui.ImVec4_Float(0, 1, 0, 1)

    imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, color)
    imgui.Text("Avg. process time: "..tostring(avg_process_time).."/"..tostring(allowed_ms).."ms")
    imgui.PopStyleColor(1)

    color = draw_time > allowed_ms and
    imgui.ImVec4_Float(1, 0, 0, 1) or imgui.ImVec4_Float(0, 1, 0, 1)

    imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, color)
    imgui.Text("Draw time:         "..tostring(draw_time).."/"..tostring(allowed_ms).."ms")
    imgui.PopStyleColor(1)

    imgui.Separator()

    imgui.Text("Comps ("..tostring(ncomps).."):")
    imgui.Indent(16)
    for name, comp in pairs(current_scene.comps) do
        imgui.Text(name..": "..tostring(#comp))
    end
    imgui.Unindent(16)

    imgui.Text("Ents ("..tostring(largest_ent_id - #free_ent_ids).."):")
    imgui.Text("Archetypes:")

    imgui.Indent(16)
    imgui.Text("Archetype data to be..")
    imgui.Unindent(16)

    imgui.Render()
    imgui.love.RenderDrawLists()
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