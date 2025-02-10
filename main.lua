
require "framework.ecs"
require "framework.debugging"
require "src.game"

function love.load()
--[[     if love.system.getOS() == "Windows" then
        local ffi = require'ffi'
        local dwm = ffi.load("dwmapi")
        ffi.cdef"void DwmFlush();"
        local oldpresent = love.graphics.present
        function love.graphics.present()
            oldpresent()
            dwm.DwmFlush()
        end
    end ]]

    RES = Vec(160, 90) * 4
    lw.setMode(RES.x, RES.y)
    screen = lg.newCanvas(RES.x, RES.y)
    screen:setFilter("nearest", "nearest")
    lw.setFullscreen(true)
    lg.setDefaultFilter("nearest", "nearest")

    imgui.love.Init()

    game = Game()
    set_current_scene(game)
    for x = 0, 3 do
        for y = 0, 3 do
            Chunk(x, y)
        end
    end
end

function love.update(delta)
    process_time = love.timer.getTime()
    current_scene:process_entities(delta)
    update_debug(delta)
    input_step()
    process_time = love.timer.getTime() - process_time
end

function love.draw()
    draw_time = love.timer.getTime()
    lg.setCanvas(screen)
    lg.clear()
    lg.translate((RES * 0.5 - global_camera:get_origin():whole()):get())

    current_scene:draw_entities(lt.getDelta())
    draw_drawables()

    lg.reset()

    local screenpos = Vec(
        lg.getWidth()  * 0.5,
        lg.getHeight() * 0.5
    )
    local cam_pos = global_camera.pos
    lg.scale(lg.getWidth() / RES.x, lg.getHeight() / RES.y)
    lg.translate(-deci_to_rounded(cam_pos.x), -deci_to_rounded(cam_pos.y))
    lg.draw(screen)

    lg.translate(deci_to_rounded(cam_pos.x), deci_to_rounded(cam_pos.y))
    lg.setColor(0, 0, 0, 1)
    lg.rectangle("line", 0, 0, RES.x, RES.y)
    lg.reset()

    draw_time = love.timer.getTime() - draw_time
    render_debug()
end

function love.quit()
    imgui.love.Shutdown()
end