require "framework.ecs"
require "framework.drawable"

CHUNKSIZE = 16

Tilemap = class(Entity)
function Tilemap:new(texture_path, tilesize, tileposx, tileposy, width)
    Entity.new(self)

    self.texture_res = image_manager:get(texture_path)
    self.tiledata = {}

    self.tile_types = self.texture_res:get():getWidth() / tilesize
    self.tile_vars = self.texture_res:get():getHeight() / tilesize
    
    self.tilesize = tilesize
    self.tilewidth = width or CHUNKSIZE
    self.tilepos = Vec(tileposx or 0, tileposy or 0)

    self.drawing_quad = lg.newQuad(
        0, 0,
        tilesize, tilesize,
        tilesize * self.tile_types, tilesize * self.tile_vars
    )
end

function Tilemap:set_tile(x, y, type, variation)
    x = x - self.tilepos.x
    y = y - self.tilepos.y

    if type == -1 then
        self.tiledata[x + y*self.tilewidth] = nil
    end

    local variation = variation or (1 + lm.random() * self.tile_vars)
    self.tiledata[x + y*self.tilewidth] = {type, math.floor(variation)}
end

function Tilemap:set_tilev(pos, type, variation)
    self:set_tile(pos.x, pos.y, type, variation)
end

function Tilemap:_draw()
    lg.translate(self.tilepos.x * self.tilesize, self.tilepos.y * self.tilesize)
    for pos, tile in pairs(self.tiledata) do
        local pos = {pos % self.tilewidth, (pos - pos % self.tilewidth) / self.tilewidth}
        self.drawing_quad:setViewport(
            self.tilesize * (tile[1] - 1),
            self.tilesize * (tile[2] - 1),
            self.tilesize, self.tilesize
        )
        lg.draw(
            self.texture_res:get(), self.drawing_quad,
            pos[1] * self.tilesize, pos[2] * self.tilesize
        )
    end
    lg.translate(-self.tilepos.x * self.tilesize, -self.tilepos.y * self.tilesize)
end