local ffi = require("ffi")
imgui = require "cimgui"
require "framework.input"
require "framework.ecs"

local code_buff = ffi.new("char[8192]", "Code goes here")

function update_debug(delta)
    imgui.love.Update(delta)
    imgui.NewFrame()
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