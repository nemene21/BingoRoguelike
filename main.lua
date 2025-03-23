
require "framework.misc"
require "framework.class"
require "framework.ecs"

function love.load()
    load_directory("src")
    load_directory("framework")
    call_init_funcs()
    
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

    RES = Vec(160, 90)-- * 4
    lw.setMode(RES.x, RES.y)
    screen = lg.newCanvas(RES.x, RES.y)
    screen:setFilter("nearest", "nearest")
    lw.setFullscreen(true)
    lg.setDefaultFilter("nearest", "nearest")

    imgui.love.Init()
    -- love.window.setVSync(0)

    game = Game()
    set_current_scene(game)
    game:restart()

    POST_PROCESS_SHADER = lg.newShader("assets/post_processing.glsl", nil)
    local filenames = {}
    for i = 1, 64 do filenames[i] = "assets/color_pallete/"..tostring(i)..".png" end
    local color_pallete_lut = lg.newVolumeImage(filenames)
    POST_PROCESS_SHADER:send("color_pallete", color_pallete_lut)
end

local MIN_DELTA = 1 / 30
function love.update(delta)
    local delta = math.min(delta, MIN_DELTA)
    process_time = love.timer.getTime()
    current_scene:process_entities(delta)
    current_scene:_process(delta)
    update_debug(delta)
    input_step()
    
    current_scene:push_entity_drawables(lt.getDelta())
    process_drawables(delta)
    
    calculate_lights()
    process_time = love.timer.getTime() - process_time
end

function love.draw()
    draw_time = love.timer.getTime()
    lg.clear(0.1, 0.1, 0.1, 1)

    lg.setCanvas(screen)
    lg.clear(0, 0, 0, 0)
    local camx, camy = global_camera:get_origin()
    lg.translate(RES.x * 0.5 - camx, RES.y * 0.5 - camy)

    draw_drawables()

    lg.origin()
    lg.scale(8, 8)
    lg.setBlendMode("multiply", "premultiplied")
    -- lg.draw(lightmap_image, 0, 0)
    lg.reset()

    local screenpos = Vec(
        lg.getWidth()  * 0.5,
        lg.getHeight() * 0.5
    )
    local cam_pos = global_camera.pos
    lg.scale(lg.getWidth() / RES.x, lg.getHeight() / RES.y)

    lg.setShader(POST_PROCESS_SHADER)
    lg.draw(screen)
    lg.setShader()

    draw_UI_drawables()

    lg.setColor(0, 0, 0, 1)
    lg.reset()

    draw_time = love.timer.getTime() - draw_time
    -- particle_editor()
    render_debug()
end

function love.quit()
    imgui.love.Shutdown()
end