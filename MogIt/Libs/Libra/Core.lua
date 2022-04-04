local MAJOR, MINOR = "Libra", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

lib.modules = lib.modules or {}
lib.moduleVersions = lib.moduleVersions or {}
lib.widgets = lib.widgets or {}
lib.widgetEmbeds = lib.widgetEmbeds or {}
lib.namespaces = lib.namespaces or {}

function lib:RegisterModule(object, version, constructor)
	self.moduleVersions[object] = version
	if constructor then
		self.widgets[object] = constructor
		self["Create"..object] = constructor
		for k in pairs(self.widgetEmbeds) do
			k["Create"..object] = constructor
		end
	end
end

function lib:GetModuleVersion(module)
	return self.moduleVersions[module] or 0
end

function lib:Create(objectType, ...)
	return lib.widgets[objectType](self, ...)
end

function lib:GetWidgetName(name)
	name = name or "Generic"
	local namespace = self.namespaces[name]
	if not namespace then
		local n = 0
		namespace = function()
			n = n + 1
			return format("%sLibraWidget%d", name, n)
		end
		self.namespaces[name] = namespace
	end
	return namespace()
end

local mixins = {
	"Create",
}

function lib:EmbedWidgets(target)
	-- for i, v in ipairs(mixins) do
		-- target[v] = self[v]
	-- end
	for k, v in pairs(self.widgets) do
		target["Create"..k] = v
	end
	self.widgetEmbeds[target] = true
end

for k in pairs(lib.widgetEmbeds) do
	lib:EmbedWidgets(k)
end