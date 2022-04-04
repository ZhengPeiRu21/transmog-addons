local Libra = LibStub("Libra")
local Type, Version = "UIPanel", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local UIPanel = Libra.modules[Type]
UIPanel.Prototype = UIPanel.Prototype or CreateFrame("Frame")

local Prototype = UIPanel.Prototype
local mt = {__index = Prototype}

local function safecall(object, method, ...)
	if object[method] then
		object[method](object, ...)
	end
end

local function constructor(self, name)
	name = name or Libra:GetWidgetName(self.name)
	local panel = setmetatable(CreateFrame("Frame", name, UIParent, "ButtonFrameTemplate"), mt)
	
	tinsert(UISpecialFrames, name)
	UIPanelWindows[name] = {
		area = "left",
		pushable = 1,
		whileDead = true,
	}
	
	return panel
end


local methods = {
	ShowPortrait = ButtonFrameTemplate_ShowPortrait,
	HidePortrait = ButtonFrameTemplate_HidePortrait,
	ShowAttic = ButtonFrameTemplate_ShowAttic,
	HideAttic = ButtonFrameTemplate_HideAttic,
	ShowButtonBar = ButtonFrameTemplate_ShowButtonBar,
	
	GetSelectedTab = PanelTemplates_GetSelectedTab,
	UpdateTabs = PanelTemplates_UpdateTabs,
	EnableTab = PanelTemplates_EnableTab,
	DisableTab = PanelTemplates_DisableTab,
	-- GetTabWidth = PanelTemplates_GetTabWidth,
	-- TabResize = PanelTemplates_TabResize,
}

for k, v in pairs(methods) do
	Prototype[k] = v
end

function Prototype:SetTitleText(text)
	self.TitleText:SetText(text)
end

function Prototype:HideButtonBar()
	ButtonFrameTemplate_HideButtonBar(self)
	self.Inset:SetPoint("BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET + 2)
end


local function onClick(self)
	self:GetParent():SelectTab(self:GetID())
	PlaySound("igCharacterInfoTab")
end

function Prototype:CreateTab(name)
	self.tabs = self.tabs or {}
	if type(name) == "number" then
		error("Tab name may not be a number.", 2)
	end
	-- if type(name) == "number" then
		-- error(format("%s already has a tab named '%s'.", self:GetName(), name), 2)
	-- end
	local tabs = self.tabs
	local numTabs = #tabs + 1
	local tab = CreateFrame("Button", self:GetName().."Tab"..numTabs, self, "CharacterFrameTabButtonTemplate")
	if numTabs == 1 then
		tab:SetPoint("BOTTOMLEFT", 19, -30)
	else
		tab:SetPoint("LEFT", tabs[numTabs - 1], "RIGHT", -15, 0)
	end
	tab:SetID(numTabs)
	tab:SetScript("OnClick", onClick)
	tabs[numTabs] = tab
	self.numTabs = numTabs
	return tab
end

function Prototype:SelectTab(id)
	local selectedTab = self:GetSelectedTab()
	if selectedTab then
		safecall(self, "OnTabDeselected", selectedTab)
	end
	self.selectedTab = id
	self:UpdateTabs()
	safecall(self, "OnTabSelected", id)
end


Libra:RegisterModule(Type, Version, constructor)