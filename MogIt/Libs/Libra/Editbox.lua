local Libra = LibStub("Libra")
local Type, Version = "Editbox", 2
if Libra:GetModuleVersion(Type) >= Version then return end

local function onEditFocusGained(self)
	self:SetTextColor(1, 1, 1)
end

local function onEditFocusLost(self)
	self:SetFontObject("ChatFontSmall")
	self:SetTextColor(0.5, 0.5, 0.5)
end

local function constructor(self, parent, isSearchBox)
	local name = Libra:GetWidgetName(self.name)
	local editbox = CreateFrame("EditBox", name, parent, isSearchBox and "SearchBoxTemplate" or "InputBoxTemplate")
	editbox:SetHeight(20)
	editbox:SetAutoFocus(false)
	editbox:SetFontObject("ChatFontSmall")
	if isSearchBox then
		editbox:SetTextColor(0.5, 0.5, 0.5)
		editbox:HookScript("OnEditFocusGained", onEditFocusGained)
		editbox:HookScript("OnEditFocusLost", onEditFocusLost)
	end
	_G[name] = nil
	return editbox
end

Libra:RegisterModule(Type, Version, constructor)