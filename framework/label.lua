require "framework.drawable"

font_manager = ResManager(function(path)
    return lg.newFont(path, 8)
end)
DEFAULT_FONT = "assets/nokia.ttf"

Label = class(Drawable)
function Label:new(text, x, y, font)
    Drawable.new(self)
    self.layer = DrawLayers.UI
    self.text = text or ""
    self.font_res = font_manager:get(font or DEFAULT_FONT)

    self.pos:set(x or 0, y or 0)
end

function Label:_draw()
    lg.print(self.text, self.font_res:get(), 0, 0)
end