require "framework.class"
local imgui = require "cimgui"

-- <Resource>
Res = class()
function Res:new(manager, path)
    self.payload = manager.bank[path].res
    self.path = path
    self.manager = manager
    self.id = manager.bank[path].id
end

function Res:get()
    return self.payload
end

function Res:free()
    self.manager:_on_free(self.path)
end

-- <Resource manager>
ResManager = class()
function ResManager:new(load)
    self.load = function(path)
        return load(path)
    end
    self.bank = {}

    self.largest_id = 0
    self.free_ids = {}
end

function ResManager:get(path)
    if self.bank[path] == nil then
        self.bank[path] = {
            res = self.load(path),
            ref_count = 0            
        }
        -- Assign id, search for free id first, create new id if needed
        local free_id = self.free_ids[#self.free_ids]
        if free_id then
            self.bank[path].id = free_id
            self.free_ids[#self.free_ids] = nil
        else
            self.largest_id = self.largest_id + 1
            self.bank[path].id = self.largest_id
        end
    end

    self.bank[path].ref_count = self.bank[path].ref_count + 1
    return Res(self, path)
end

function ResManager:show_debug(name)
    imgui.Text(name.." manager:")
    imgui.Indent(16)
    for path, res in pairs(self.bank) do
        imgui.Text(path.." - ref "..tostring(res.ref_count)..", id "..tostring(res.id))
    end
    imgui.Unindent(16)
    imgui.NewLine()
end

function ResManager:_on_free(path)
    self.bank[path].ref_count = self.bank[path].ref_count - 1
    if self.bank[path].ref_count == 0 then
        self.bank[path] = nil
    end
end