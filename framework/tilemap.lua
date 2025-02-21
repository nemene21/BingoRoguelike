require "framework.ecs"
require "framework.drawable"

Tilenames = enum({
    "ROCK",
    "LOG",
    "PLANK",
    "COUNT"
})

local TileRenderer = class(Drawable)
local TileBreakRenderer = class(Drawable)
Tilemap = class(Entity)
function Tilemap:new(texture_path, tilesize, tileposx, tileposy, width)
    Entity.new(self)

    self.texture_res = image_manager:get(texture_path)
    self.break_texture_res = image_manager:get("assets/tilebreaksheet.png")
    self.tiledata = {}

    self.tile_types = self.texture_res:get():getWidth() / tilesize
    self.tile_vars = self.texture_res:get():getHeight() / tilesize
    
    self.tilesize = tilesize
    self.tilewidth = width
    self.tilepos = Vec(tileposx or 0, tileposy or 0)

    self:add_drawable("renderer", TileRenderer(self))
    self:add_drawable("break_renderer", TileBreakRenderer(self))

    self.drawing_quad = lg.newQuad(
        0, 0,
        tilesize, tilesize,
        tilesize * self.tile_types, tilesize * self.tile_vars
    )
end

function Tilemap:set_tile(x, y, type, variation, hp)
    x = x - self.tilepos.x
    y = y - self.tilepos.y

    if type == -1 then
        self.tiledata[x + y*self.tilewidth] = nil
    end

    local variation = variation or (1 + lm.random() * self.tile_vars)
    self.tiledata[x + y*self.tilewidth] = {type, math.floor(variation), hp or 1}
end

function Tilemap:set_tilev(pos, type, variation, hp)
    self:set_tile(pos.x, pos.y, type, variation, hp)
end

function Tilemap:get_tile(x, y)
    return self.tiledata[x + y*self.tilewidth]
end

function Tilemap:get_tilev(vec)
    return self:get_tile(vec.x, vec.y)
end

function Tilemap:damage_tile(x, y, damage)
    x = x - self.tilepos.x
    y = y - self.tilepos.y
    local tile = self.tiledata[x + y*self.tilewidth]
    if tile then
        tile[3] = tile[3] - damage

        if tile[3] < 0 then
            self.tiledata[x + y*self.tilewidth] = nil
        end
    end
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
    self.layer = DrawLayers.TILES
end

function TileRenderer:update_footprint()
    self.footprint = 0
end

local BREAK_STAGES = 6
function TileRenderer:_draw()
    local tilemap = self.tilemap
    lg.translate(tilemap.tilepos.x * tilemap.tilesize, tilemap.tilepos.y * tilemap.tilesize)
    
    local tex = tilemap.texture_res:get()
    local x, y

    tilemap.drawing_quad:setViewport(0, 0, tilemap.tilesize, tilemap.tilesize, tilemap.tilesize * tilemap.tile_types, tilemap.tilesize * tilemap.tile_vars)
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

function TileRenderer:update_footprint()
    self.footprint = 1
end

function TileBreakRenderer:new(tilemap)
    Drawable.new(self)
    self.tilemap = tilemap
    self.layer = DrawLayers.TILE_CRACKS
end

function TileBreakRenderer:_draw()
    local tilemap = self.tilemap
    lg.translate(tilemap.tilepos.x * tilemap.tilesize, tilemap.tilepos.y * tilemap.tilesize)

    local break_tex = tilemap.break_texture_res:get()
    local x, y

    tilemap.drawing_quad:setViewport(0, 0, tilemap.tilesize, tilemap.tilesize, BREAK_STAGES * tilemap.tilesize, tilemap.tilesize)
    for pos, tile in pairs(tilemap.tiledata) do
        -- tile[3] -> tile hp (1:0)
        if tile[3] ~= 1 then
            x, y = pos % tilemap.tilewidth, (pos - pos % tilemap.tilewidth) / tilemap.tilewidth
        
            tilemap.drawing_quad:setViewport(
                math.floor((1 - tile[3]) * (BREAK_STAGES - 1)) * tilemap.tilesize,
                0,
                tilemap.tilesize, tilemap.tilesize
            )
            lg.draw(
                break_tex, tilemap.drawing_quad,
                x * tilemap.tilesize, y * tilemap.tilesize
            )
        end
    end
    lg.translate(-tilemap.tilepos.x * tilemap.tilesize, -tilemap.tilepos.y * tilemap.tilesize)
end