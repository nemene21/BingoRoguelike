require "framework.drawable"

font_manager = ResManager(function(path)
    return lg.newFont(path, 8)
end)
DEFAULT_FONT = "assets/nokia.ttf"

Label = class(Drawable)
function Label:new(text, x, y, centering, font)
    Drawable.new(self)
    self.layer = DrawLayers.UI
    self.font_res = font_manager:get(font or DEFAULT_FONT)
    self.centering = centering or Vec()
    self:set_text(text or "")

    self.pos:set(x or 0, y or 0)
end

function Label:set_text(text)
    self.text = text
    self:update_offset()
end

function Label:update_offset()
    self.offset:set(
        self.centering.x * self.font_res:get():getWidth (self.text),
        self.centering.y * self.font_res:get():getHeight(self.text)
    )
end

function draw_text_outline(text, font, x, y, color, outline_color)
    if outline_color then lg.setColor(unpack(outline_color)) else lg.setColor(0, 0, 0, 1) end
    lg.print(text, font, x - 1, y)
    lg.print(text, font, x + 1, y)
    lg.print(text, font, x, y + 1)
    lg.print(text, font, x, y - 1)

    if color then lg.setColor(unpack(color)) else lg.setColor(1, 1, 1, 1) end
    lg.print(text, font, x, y)
end

function Label:_draw()
    draw_text_outline(self.text, self.font_res:get(), 0, 0, self.color)
end