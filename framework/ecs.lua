require "framework.class"
require "framework.misc"
require "framework.signal"
require "framework.drawable"

-- <Scene>
local function register_comp(scene, comp)
    -- If component is registered for the first time create it's table
    if scene.comps[comp.name] == nil then
        scene.comps[comp.name] = {}
    end
    table.insert(scene.comps[comp.name], comp)

    -- Add comp's entity to any archetypes with that component
    local types = scene.comp_to_archetypes[comp.name]
    if types then
        for i = 1, #types do
            types[i]:attempt_register(comp.entity)
        end
    end
end

local function unregister_comp(scene, comp)
    local comps = scene.comps[comp.name]

    -- Remove from comp array
    for key, value in ipairs(comps) do
        if value == comp then
            table.remove(comps, key)
            break
        end
    end

    -- Remove comp's entity from any archetypes it was in
    local types = scene.comp_to_archetypes[comp.name]
    if types then
        for i = 1, #types do
            types[i]:attempt_unregister(comp.entity)
        end
    end
end

current_scene = nil
function set_current_scene(scene)
    assert(scene.entities ~= nil, "Scene didn't initialise properly, did you forget to call Scene.new(self) in it's constructor?")
    current_scene = scene
end

largest_ent_id = 1
free_ent_ids = {}

Scene = class()
function Scene:new()
    self.entities = {}
    self.comps = {}
    self.comp_to_archetypes = {}
end

function Scene:add_entity(entity)
    assert(self.entities ~= nil, "Scene didn't initialise properly, did you forget to call Scene.new(self) in it's constructor?")
    assert(entity.alive ~= nil, "Entity didn't initialise properly, did you forget to call Entity.new(self) in it's constructor?")
    assert(entity.scene == nil, "Entity already in scene.")
    
    for name, comp in pairs(entity.comps) do
        register_comp(self, comp)
    end
    self.entities[entity.id] = entity
    entity.scene = self
end

function Scene:process_entities(delta)
    local max = 0
    for i, entity in pairs(self.entities) do
        if not entity.paused then
            entity:_process(delta)
            entity:_process_comps(delta)
        end

        -- Remove entity and it's comps if necesarry
        if not entity.alive then
            Scene:remove_entity(entity)
        end
    end
end

function Scene:_process(delta) end

function Scene:remove_entity(entity)
    for name, comp in pairs(entity.comps) do
        entity:remove(name)
    end
    self.entities[entity.id] = nil
end

function Scene:draw_entities(delta)
    for i, entity in pairs(self.entities) do
        if entity.visible then
            entity:_push_drawables()
        end
    end
end

function Scene:query_comp(name)
    return self.comps[name]
end

-- <Component>
Comp = class()
function Comp:new(name)
    self.name = name
end
function Comp:_process() end
function Comp:_draw() end

-- <Archetype>
Archetype = class()
function Archetype:new(scene, ...)
    self.entities = {}
    self.comps = {...}

    -- Add in all valid entities
    local potential_comps = scene.comps[self.comps[1]]
    for i = 1, #potential_comps do
        self:attempt_register(potential_comps[i].entity)
    end

    -- Insert archetype into the component to archetype lookup table
    for i = 1, #self.comps do
        local types = scene.comp_to_archetypes[self.comps[i]]
        if types == nil then
            scene.comp_to_archetypes[self.comps[i]] = {}
            types = scene.comp_to_archetypes[self.comps[i]]
        end
        table.insert(types, self)
    end
end

-- Will add entity to the archetype if it's a valid entry
function Archetype:attempt_register(entity)
    if not entity:is(self) then return end
    table.insert(self.entities, entity)
end

function Archetype:attempt_unregister(entity)
    for i, checking in ipairs(self.entities) do
        if checking == entity then
            table.remove(self.entities, i)
            return
        end
    end
end

function Archetype:iterate()
    local i = 0
    return function()
        i = i + 1
        if i <= #self.entities then
            return self.entities[i]
        end
    end
end

-- <Entity>
Entity = class()

function Entity:new()
    self.comps = {}
    self.drawables = {}
    self.scene = nil
    self.alive = true
    self.paused = false
    self.visible = true

    local free_id_count = #free_ent_ids
    if free_id_count == 0 then
        largest_ent_id = largest_ent_id + 1
        self.id = largest_ent_id
    else
        self.id = free_ent_ids[free_id_count]
        free_ent_ids[free_id_count] = nil
    end
end

function Entity:kill()
    self.alive = false
end

function Entity:show()
    self.visible = true
end

function Entity:hide()
    self.visible = false
end

function Entity:_process(delta) end

function Entity:_push_drawables()
    if not self.visible then return end
    
    for i, drawable in ipairs(self.drawables) do
        drawable:_push_to_layer()
    end
end

function Entity:add_drawable(name, drawable)
    table.insert(self.drawables, drawable)
    self[name] = drawable
end

function Entity:add(comp)
    self.comps[comp.name] = comp
    self[comp.name] = comp

    comp.entity = self

    if self.scene then
        register_comp(self.scene, comp)
    end
    return comp
end

function Entity:get(comp_name)
    return self.comps[comp_name]
end

function Entity:remove(name)
    if self.scene then
        unregister_comp(self.scene, self.comps[name])
    end
    self.comps[name] = nil
    self[name] = nil
end

function Entity:has(comp_name)
    return self.comps[comp_name] ~= nil
end

function Entity:is(type)
    for i = 1, #type.comps do
        if not self:has_comp(type.comps[i]) then
            return false
        end
    end
    return true
end

function Entity:_process_comps(delta)
    for name, comp in pairs(self.comps) do
        comp:_process(delta)
    end
end

function Entity:stringify()
    return class2string(self, {})
end