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