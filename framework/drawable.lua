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

local function draw_layer(layer)
    table.sort(layer, drawable_comparator)
    
    for j, drawable in ipairs(layer) do
        lg.push()
        lg.setColor(unpack(drawable.color))
        lg.setShader(drawable.shader_res:get())
        
        lg.translate(drawable.pos:get())
        
        lg.scale(drawable.scale.x * btoi2(not drawable.flipx), drawable.scale.y * btoi2(not drawable.flipy))
        lg.translate(drawable.offset:get())
        lg.rotate(drawable.angle)

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

function draw_UI_drawables()
    draw_layer(ui_draw_layer)
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
    self.color = {1, 1, 1, 1}

    self.pos = Vec()
    self.scale = Vec(1, 1)
    self.angle = 0
    self.offset = Vec()
    self.flipx = false
    self.flipy = false
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
function Sprite:new(path, centered)
    Drawable.new(self)
    self:set_texture(path)

    if centered or true then
        local img = self.img_res:get()
        self.offset:set(
            -img:getWidth() * 0.5,
            -img:getHeight() * 0.5
        )
    end
end

function Sprite:update_footprint()
    self.footprint = self.shader_res.id + 1000 * self.img_res.id
end

function Sprite:set_texture(path)
    self.img_res = image_manager:get(path)
    self:update_footprint()
end

function Sprite:_draw()
    lg.draw(self.img_res:get(), 0, 0)
end

Spritesheet = class(Drawable)
function Spritesheet:new(path, width, height, centered)
    Drawable.new(self)
    self:set_texture(path)

    self.framepos = Vec()

    self.width  = width
    self.height = height or width
    local img = self.img_res:get()
    self.quad = lg.newQuad(0, 0, width, height, img:getWidth(), img:getHeight())

    if centered or true then
        self.offset:set(
            -self.width  * 0.5,
            -self.height * 0.5
        )
    end
end

function Spritesheet:set_texture(path)
    self.img_res = image_manager:get(path)
    self:update_footprint()
end

function Spritesheet:update_footprint()
    self.footprint = self.shader_res.id + 1000 * self.img_res.id
end

function Spritesheet:_draw()
    self.quad:setViewport(self.framepos.x * 8, self.framepos.y * 8, 8, 8)
    lg.draw(self.img_res:get(), self.quad, 0, 0)
end