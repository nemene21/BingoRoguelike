require "framework.ecs"
require "framework.drawable"

TileRenderer = class(Drawable)
Tilemap = class(Entity)
function Tilemap:new(texture_path, tilesize, tileposx, tileposy, width)
    Entity.new(self)

    self.texture_res = image_manager:get(texture_path)
    self.tiledata = {}

    self.tile_types = self.texture_res:get():getWidth() / tilesize
    self.tile_vars = self.texture_res:get():getHeight() / tilesize
    
    self.tilesize = tilesize
    self.tilewidth = width
    self.tilepos = Vec(tileposx or 0, tileposy or 0)

    self:add_drawable("renderer", TileRenderer(self))
    self.renderer.layer = DrawLayers.BACKGROUND

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

function Tilemap:stringify()
    return class2string(self, {
        self.texture_res.path,
        self.tilesize,
        self.tilepos.x,
        self.tilepos.y,
        self.tilewidth
    }, "tiledata")
end

function TileRenderer:new(tilemap)
    Drawable.new(self)
    self.tilemap = tilemap
end

function TileRenderer:update_footprint()
    self.footprint = self.shader_res.id + 1000 * self.tilemap.texture_res..id
end

function TileRenderer:_draw()
    local tilemap = self.tilemap
    lg.translate(tilemap.tilepos.x * tilemap.tilesize, tilemap.tilepos.y * tilemap.tilesize)
    
    local tex = tilemap.texture_res:get()
    local x, y
    for pos, tile in pairs(tilemap.tiledata) do
        x, y = pos % tilemap.tilewidth, (pos - pos % tilemap.tilewidth) / tilemap.tilewidth
        
        tilemap.drawing_quad:setViewport(
            tilemap.tilesize * (tile[1] - 1),
            tilemap.tilesize * (tile[2] - 1),
            tilemap.tilesize, tilemap.tilesize
        )
        lg.draw(
            tex, tilemap.drawing_quad,
            x * tilemap.tilesize, y * tilemap.tilesize
        )
    end
    lg.translate(-tilemap.tilepos.x * tilemap.tilesize, -tilemap.tilepos.y * tilemap.tilesize)
end