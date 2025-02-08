require "framework.class"
local imgui = require "cimgui"

-- <Resource>
Res = class()
function Res:new(manager, path)
    self.payload = manager.bank[path]
    self.path = path
    self.manager = manager
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
    self.ref_counts = {}
    self.bank = {}
end

function ResManager:get(path)
    if self.bank[path] == nil then
        self.bank[path] = self.load(path)
        self.ref_counts[path] = 0
    end

    self.ref_counts[path] = self.ref_counts[path] + 1
    return Res(self, path)
end

function ResManager:show_debug(name)
    imgui.Text("Resource manager ("..name.."):")
    imgui.Indent(16)
    for path, count in pairs(self.ref_counts) do
        imgui.Text(path.."("..tostring(count)..")")
    end
    imgui.Unindent(16)
end

function ResManager:_on_free(path)
    self.bank[path] = self.bank[path] - 1
end