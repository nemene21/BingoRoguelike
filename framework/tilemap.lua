require "framework.enum"

local TILE_DATA
Tilenames = enum({
    "ROCK",
    "LOG",
    "PLANK",
    "IRON_ORE",
    "COAL_ORE",
    "FURNACE",
    "VASE",
    "TORCH",
    "REFINER",
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
    self.tileents = {}

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
    local x = x - self.tilepos.x
    local y = y - self.tilepos.y
    local tileindex = x + y*self.tilewidth

    local data = self.tiledata[tileindex]
    if data then
        if tileents[tileindex] then
            tileents[tileindex]:_destroyed()
        end
    end

    if type == -1 then
        self.tiledata[tileindex] = nil
    end

    local variation = variation or (1 + lm.random() * self.tile_vars)
    data = {type, math.floor(variation), hp or 1}
    self.tiledata[x + y*self.tilewidth] = data

    if TILE_DATA[type] then
        local tile_entity = TILE_DATA[type].tile_entity
        if tile_entity then
            tile_entity = tile_entity(x + self.tilepos.x, y + self.tilepos.y, data)
            current_scene:add_entity(tile_entity)
        end
    end
end

function Tilemap:set_tilev(pos, type, variation, hp)
    self:set_tile(pos.x, pos.y, type, variation, hp)
end

function Tilemap:get_tile(x, y)
    local x = x - self.tilepos.x
    local y = y - self.tilepos.y
    return self.tiledata[x + y*self.tilewidth]
end

function Tilemap:get_tilev(vec)
    return self:get_tile(vec.x, vec.y)
end

function Tilemap:register_tile_entity(x, y, entity)
    local tx = x - self.tilepos.x
    local ty = y - self.tilepos.y
    local tileindex = tx + ty*self.tilewidth

    self.tileents[tileindex] = entity
end

function Tilemap:damage_tile(x, y, damage)
    local tx = x - self.tilepos.x
    local ty = y - self.tilepos.y
    local tileindex = tx + ty*self.tilewidth
    local tile = self.tiledata[tileindex]

    if not tile then return end
    tile[3] = tile[3] - damage

    if tile[3] > 0 then return end

    if self.tileents[tileindex] then self.tileents[tileindex]:_destroyed() end
    self.tiledata[tileindex] = nil

    local data = TILE_DATA[tile[1]]
    if not data then return end
    if not data.loot_table then return end
    loot_table_data[data.loot_table]:drop(x*self.tilesize + self.tilesize*0.5, y*self.tilesize + self.tilesize*0.5)
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

return function()
    TILE_DATA = {}
    TILE_DATA[Tilenames.ROCK] = {
        loot_table = LootTables.ROCK
    }
    TILE_DATA[Tilenames.IRON_ORE] = {
        loot_table = LootTables.IRON_ORE
    }
    TILE_DATA[Tilenames.COAL_ORE] = {
        loot_table = LootTables.COAL_ORE
    }
    TILE_DATA[Tilenames.FURNACE] = {
        loot_table = LootTables.FURNACE,
        tile_entity = Furnace
    }
    TILE_DATA[Tilenames.REFINER] = {
        loot_table = LootTables.REFINER,
        tile_entity = Refiner
    }
end