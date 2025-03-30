Sprite = class(Drawable)
function Sprite:new(path, centered)
    Drawable.new(self)
    self:set_texture(path)

    if centered ~= false then
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

function Sprite:_draw(ox, oy)
    local ox = ox or 0
    local oy = oy or 0
    lg.draw(self.img_res:get(), ox, oy)
end

OutlineSprite = class(Sprite)
function OutlineSprite:new(path, centered)
    Sprite.new(self, path, centered)
    self.outline_color = EDG_BLACK
end

function OutlineSprite:_draw()
    lg.setColor(self.outline_color)
    Sprite._draw(self, -1,  0)
    Sprite._draw(self,  1,  0)
    Sprite._draw(self,  0,  1)
    Sprite._draw(self,  0, -1)

    lg.setColor(self.color)
    Sprite._draw(self)
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

    if centered or (centered == nil) then
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

function Spritesheet:_draw(ox, oy)
    local ox = ox or 0
    local oy = oy or 0

    self.quad:setViewport(self.framepos.x * 8, self.framepos.y * 8, 8, 8)
    lg.draw(self.img_res:get(), self.quad, ox, oy)
end

OutlineSpritesheet = class(Spritesheet)
function OutlineSpritesheet:new(path, width, height, centered)
    Spritesheet.new(self, path, width, height, centered)
    self.outline_color = EDG_BLACK
end

function OutlineSpritesheet:_draw()
    lg.setColor(self.outline_color)
    Spritesheet._draw(self, -1,  0)
    Spritesheet._draw(self,  1,  0)
    Spritesheet._draw(self,  0,  1)
    Spritesheet._draw(self,  0, -1)

    lg.setColor(self.color)
    Spritesheet._draw(self)
end