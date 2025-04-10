
local ui_draw_layer = {}
local draw_layers = {}

local function drawable_comparator(a, b)
    return a.footprint > b.footprint
end

local function draw_layer(layer)
    table.sort(layer, drawable_comparator)
    local delta = lt.getDelta()
    
    for j, drawable in ipairs(layer) do
        lg.push()
        lg.setColor(unpack(drawable.color))
        lg.setShader(drawable.shader_res:get())
        drawable:_push_uniforms()
        
        lg.translate(drawable.pos:get())
        lg.rotate(drawable.angle)
        lg.scale(drawable.scale.x * btoi2(not drawable.flipx), drawable.scale.y * btoi2(not drawable.flipy))
        
        lg.translate(drawable.offset:get())

        drawable:_draw()
        layer[j] = nil
        lg.pop()
    end
end

function draw_drawables()
    for i, layer in ipairs(draw_layers) do
        draw_layer(layer)
    end
    lg.setShader()
end

function process_drawables(delta)
    for i, layer in ipairs(draw_layers) do
        for j, drawable in ipairs(layer) do
            drawable:_process(delta)
        end
    end
end

function draw_UI_drawables()
    draw_layer(ui_draw_layer)
    lg.setShader()
end

Drawable = class()
function Drawable:new()
    self.shader_res = shader_manager:get("assets/default.glsl")
    self.visible = true
    self.layer = DrawLayers.DEFAULT
    self.footprint = 0
    self.color = {1, 1, 1, 1}

    self.pos = Vec()
    self.scale = Vec(1, 1)
    self.angle = 0
    self.offset = Vec()
    self.flipx = false
    self.flipy = false

    self.unsent_uniforms = {}
end

function Drawable:show()
    self.visible = true
end

function Drawable:hide()
    self.visible = false
end

function Drawable:update_footprint()
    self.footprint = 0
end

function Drawable:set_shader(path)
    self.shader_res = shader_manager:get(path or "assets/default.glsl")
    self:update_footprint()
end

function Drawable:send_uniform(name, ...)
    self.unsent_uniforms[name] = {...}
end

function Drawable:_push_uniforms()
    local shader = self.shader_res:get()
    
    for name, data in pairs(self.unsent_uniforms) do
        shader:send(name, unpack(data))
    end
end

function Drawable:_push_to_layer()
    assert(self.layer ~= nil, "Drawable has no layer, did you forget Drawable.new(self)?")
    assert(self.layer <= #draw_layers+1, "Draw layer "..tostring(self.layer).." doesn't exist!")
    if not self.visible then return end

    if self.layer == DrawLayers.UI then
        table.insert(ui_draw_layer, self)
        return
    end
    table.insert(draw_layers[self.layer], self)
end

function Drawable:_process(delta) end
function Drawable:_draw() end

return function()
    DrawLayers = enum({
        "BACKGROUND",
        "VFX_UNDER",
        "DEFAULT",
        "VFX_OVER",
        "TILES",
        "TILE_CRACKS",
        "COUNT",
        "UI"
    })

    for i = 1, DrawLayers.COUNT do
        draw_layers[i] = {}
    end

    image_manager = ResManager(lg.newImage)
    shader_manager = ResManager(lg.newShader)
end