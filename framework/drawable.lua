require "framework.class"
require "framework.resource_manager"

image_manager = ResManager(lg.newImage)
shader_manager = ResManager(lg.newShader)

Drawable = class()
function Drawable:new()
    self.shader = shader_manager:get("default.glsl")
    self.visible = true
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

function Drawable:draw()

end

Sprite = class(Drawable)
function Sprite:new(path)
    self.img_res = image_manager:get(path)
    self.pos = Vec()
end

function Sprite:draw()
    lg.draw(self.img_res:get(), math.round(self.pos.x), math.round(self.pos.y))
end