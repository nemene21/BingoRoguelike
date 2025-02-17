function btoi(boolean)
    return boolean and 1 or 0
end

function lerp(a, b, c)
    return a + (b - a) * c
end

function dlerp(a, b, c)
    local blend = 0.5^c
    return lerp(b, a, blend)
end

function math.round(n)
    return math.floor((math.floor(n*2) + 1)/2)
end

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

function deci(x)
    if x > 0 then
        return x - math.floor(x)
    else
        return x - math.ceil(x)
    end
end

function deci_to_rounded(x)
    return x - math.round(x)
end

function table.entries(tbl)
    local i = 0
    for k, v in pairs(tbl) do
        i = i + 1
    end
    return i
end

function clear_dir(directory)
    local files = love.filesystem.getDirectoryItems(directory)

    for _, filename in ipairs(files) do
        local path = directory.."/"..filename

        if love.filesystem.getInfo(path, "file") then
            love.filesystem.remove(path)
        end
    end
end

function round_n(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function screen2world(x, y)
    local cx, cy = global_camera:get_origin()
    x = x + cx - RES.x * 0.5
    y = y + cy - RES.y * 0.5
    return x, y
end

function global_mouse_pos()
    return screen2world(mouse_pos())
end

function mouse_pos()
    local x, y = love.mouse.getPosition()
    local w, h = lg.getDimensions()
    x = (x / w) * RES.x
    y = (y / h) * RES.y
    return x, y
end

function quad_has_point(qx, qy, w, h, x, y)
    return x > qx and x < qx + w and y > qy and y < qy + h
end

lg = love.graphics
lm = love.math
la = love.audio
le = love.event
lk = love.keyboard
lt = love.timer
lw = love.window
lf = love.filesystem