require "framework.drawable"

Label = class(Drawable)
function Label:new(text, x, y)
    self.layer = DrawLayers.UI
end