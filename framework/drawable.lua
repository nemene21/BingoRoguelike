require "framework.class"
require "framework.resource_manager"
require "framework.enum"

DrawLayers = enum({
    "BACKGROUND",
    "TILES",
    "TILE_CRACKS",
    "DEFAULT",
    "COUNT",
    "UI"
})

local ui_draw_layer = {}
local draw_layers = {}
for i = 1, DrawLayers.COUNT do
    draw_layers[i] = {}
end

local function drawable_comparator(a, b)
    return a.footprint > b.footprint
end

function draw_drawables()
    for i, layer in ipairs(draw_layers) do
        table.sort(layer, drawable_comparator)
        for j, drawable in ipairs(layer) do
            lg.setShader(drawable.shader_res:get())
            drawable:_draw()
            layer[j] = nil
        end
    end
    lg.setShader()
end

function draw_UI_drawables()
    for j, drawable in ipairs(ui_draw_layer) do
        lg.setShader(drawable.shader_res:get())
        drawable:_draw()
        ui_draw_layer[j] = nil
    end
    lg.setShader()
end

image_manager = ResManager(lg.newImage)
shader_manager = ResManager(lg.newShader)

Drawable = class()
function Drawable:new()
    self.shader_res = shader_manager:get("assets/default.glsl")
    self.visible = true
    self.layer = DrawLayers.DEFAULT
    self.footprint = 0
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

function Drawable:_draw() end

Sprite = class(Drawable)
function Sprite:new(path)
    Drawable.new(self)
    self:set_texture(path)
    self.pos = Vec()
end

function Sprite:update_footprint()
    self.footprint = self.shader_res.id + 1000 * self.img_res.id
end

function Sprite:set_texture(path)
    self.img_res = image_manager:get(path)
    self:update_footprint()
end

function Sprite:_draw()
    lg.draw(self.img_res:get(), self.pos.x, self.pos.y)
end