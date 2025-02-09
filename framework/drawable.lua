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
            drawable:draw()
            layer[j] = nil
        end
    end
end

image_manager = ResManager(lg.newImage)
shader_manager = ResManager(lg.newShader)

Drawable = class()
function Drawable:new()
    self.shader = shader_manager:get("default.glsl")
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
    self.shader = shader_manager:get(path or "default.glsl")
end

function Drawable:_push_to_layer()
    assert(self.layer <= #draw_layers, "Draw layer "..tostring(self.layer).." doesn't exist!")
    table.insert(draw_layers[self.layer], self)
end

function Drawable:draw()

end

Sprite = class(Drawable)
function Sprite:new(path)
    self.img_res = image_manager:get(path)
    self.pos = Vec()
end

function Sprite:draw()
    lg.draw(self.img_res:get(), self.pos.x, self.pos.y)
end