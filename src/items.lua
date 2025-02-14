require "framework.drawables"

ItemData = class()
function ItemData:new(name, texture)
    self.name = name or "NULL"
    self.tex_res = image_manager:get(texture or "assets/nil.png")
end

function ItemData:copy()
    return ItemData:new(name, texture)
end