local Libra = LibStub("Libra")
local Type, Version = "Addon", 2
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local object = Libra.modules[Type]
object.frame = object.frame or CreateFrame("Frame")
object.addons = object.addons or {}
object.events = object.events or {}
object.onUpdates = object.onUpdates or {}

local function safecall(object, method, ...)
	if object[method] then
		object[method](object, ...)
	end
end

object.frame:RegisterEvent("ADDON_LOADED")
object.frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local addon = object.addons[...]
		if addon then
			safecall(addon, "OnInitialize")
			for k, module in pairs(addon.modules) do
				safecall(module, "OnInitialize")
				module.OnInitialize = nil
			end
		end
	end
	for module, eventHandler in pairs(object.events[event]) do
		eventHandler(module, ...)
	end
end)

local function onUpdate(self, elapsed)
	for module, update in pairs(object.onUpdates) do
		update(module, elapsed)
	end
end

setmetatable(object.events, {
	__index = function(table, key)
		local newTable = {}
		table[key] = newTable
		return newTable
	end
})

local AddonPrototype = {}
local ObjectPrototype = {}

local function AddonEmbed(target)
	for k, v in pairs(AddonPrototype) do
		target[k] = v
	end
end

local function ObjectEmbed(target)
	for k, v in pairs(ObjectPrototype) do
		target[k] = v
	end
end

function Libra:NewAddon(name, addonObject)
	if object.addons[name] then
		error(format("Addon '%s' already exists.", name), 2)
	end
	
	local addon = addonObject or {}
	addon.name = name
	addon.modules = {}
	AddonEmbed(addon)
	ObjectEmbed(addon)
	object.addons[name] = addon
	return addon, name
end

function Libra:GetAddon(name)
	return object.addons[name]
end

function AddonPrototype:NewModule(name, table)
	local module = table or {}
	ObjectEmbed(module)
	module.name = name
	self.modules[name] = module
	safecall(self, "OnModuleCreated", name, module)
	return module, name
end

function AddonPrototype:GetModule(name)
	return self.modules[name]
end

function AddonPrototype:IterateModules()
	return pairs(self.modules)
end

function ObjectPrototype:RegisterEvent(event, handler)
	if not next(object.events[event]) then
		object.frame:RegisterEvent(event)
	end
	if type(handler) ~= "function" then
		handler = self[handler] or self[event]
	end
	object.events[event][self] = handler
end

function ObjectPrototype:UnregisterEvent(event)
	object.events[event][self] = nil
	if not next(object.events[event]) then
		object.frame:UnregisterEvent(event)
	end
end

function ObjectPrototype:SetOnUpdate(handler)
	if not next(object.onUpdates) then
		object.frame:SetScript("OnUpdate", onUpdate)
	end
	if type(handler) ~= "function" then
		handler = self[handler]
	end
	object.onUpdates[self] = handler
end

function ObjectPrototype:RemoveOnUpdate()
	object.onUpdates[self] = nil
	if not next(object.onUpdates) then
		object.frame:SetScript("OnUpdate", nil)
	end
end

-- upgrade embeds
for k, v in pairs(object.addons) do
	AddonEmbed(v)
	ObjectEmbed(v)
	for k, v in pairs(v.modules) do
		ObjectEmbed(v)
	end
end

Libra:RegisterModule(Type, Version)