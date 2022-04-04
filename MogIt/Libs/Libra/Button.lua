local Libra = LibStub("Libra")
local Type, Version = "Button", 1
if Libra:GetModuleVersion(Type) >= Version then return end

local function onMouseDown(self)
	if not self:IsEnabled() then
		self.leftArrow:SetPoint("LEFT",  5, 0)
		self.rightArrow:SetPoint("RIGHT", -5, 0)
	end
end

local function onEnable(self)
	self.leftArrow:SetDesaturated(false)
	self.rightArrow:SetDesaturated(false)
end

local function onDisable(self)
	self.leftArrow:SetDesaturated(true)
	self.rightArrow:SetDesaturated(true)
end

local function constructor(self, parent)
	local button = CreateFrame("Button", Libra:GetWidgetName(self.name), parent, "UIMenuButtonStretchTemplate")
	button:HookScript("OnMouseDown", onMouseDown)
	button:SetScript("OnEnable", onEnable)
	button:SetScript("OnDisable", onDisable)
	return button
end

Libra:RegisterModule(Type, Version, constructor)