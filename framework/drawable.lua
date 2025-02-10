require "framework.class"
require "framework.resource_manager"
require "framework.enum"

DrawLayers = enum({
    "BACKGROUND",
    "DEFAULT",
    "COUNT"
})

local draw_layers = {}
for i = 1, DrawLayers.COUNT do
    draw_layers[i] = {}
end

function draw_drawables()
    for i, layer in ipairs(draw_layers) do
        for j, drawable in ipairs(layer) do
            lg.setShader(drawable.shader:get())
            drawable:_draw()
            layer[j] = nil
        end
    end
    lg.setShader()
end

image_manager = ResManager(lg.newImage)
shader_manager = ResManager(lg.newShader)

Drawable = class()
function Drawable:new()
    self.shader = shader_manager:get("assets/default.glsl")
    self.visible = true
    self.layer = DrawLayers.DEFAULT
end

function Drawable:show()
    self.visible = true
end

function Drawable:hide()
    self.visible = false
end

function Drawable:set_shader(path)
    self.shader = shader_manager:get(path or "assets/default.glsl")
end

function Drawable:_push_to_layer()
    assert(self.layer ~= nil, "Drawable has no layer, did you forget Drawable.new(self)?")
    assert(self.layer <= #draw_layers, "Draw layer "..tostring(self.layer).." doesn't exist!")
    if not self.visible then return end

    table.insert(draw_layers[self.layer], self)
end

function Drawable:_draw() end

Sprite = class(Drawable)
function Sprite:new(path)
    Drawable.new(self)
    self.img_res = image_manager:get(path)
    self.pos = Vec()
end

function Sprite:_draw()
    lg.draw(self.img_res:get(), self.pos.x, self.pos.y)
end