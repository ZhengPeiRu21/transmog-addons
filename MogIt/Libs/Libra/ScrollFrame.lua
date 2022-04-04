local Libra = LibStub("Libra")
local Type, Version = "ScrollFrame", 3
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local ScrollFrame = Libra.modules[Type]

ScrollFrame.FauxPrototype = ScrollFrame.FauxPrototype or CreateFrame("ScrollFrame")
ScrollFrame.HybridPrototype = ScrollFrame.HybridPrototype or CreateFrame("ScrollFrame")

local fauxMT = {__index = ScrollFrame.FauxPrototype}
local hybridMT = {__index = ScrollFrame.HybridPrototype}

local HybridPrototype = ScrollFrame.HybridPrototype

local function fauxOnVerticalScroll(self, offset)
	self.Scrollbar:SetValue(offset)
	self.offset = floor((offset / self.buttonHeight) + 0.5)
	self:Update()
end

local function constructor(self, type, parent, name)
	local scrollFrame
	if type == "Faux" then
		scrollFrame = setmetatable(CreateFrame("ScrollFrame", name, parent, "FauxScrollFrameTemplate"), fauxMT)
		scrollFrame:SetScript("OnVerticalScroll", fauxOnVerticalScroll)
	end
	if type == "Hybrid" then
		name = name or Libra:GetWidgetName(self.name)
		scrollFrame = setmetatable(CreateFrame("ScrollFrame", name, parent, "HybridScrollFrameTemplate"), hybridMT)
		scrollFrame.scrollBar = CreateFrame("Slider", nil, scrollFrame, "HybridScrollBarTemplate")
	end
	
	return scrollFrame
end


local fauxMethods = {
	Update = FauxScrollFrame_Update,
	SetOffset = FauxScrollFrame_SetOffset,
	GetOffset = FauxScrollFrame_GetOffset,
}

for k, v in pairs(fauxMethods) do
	ScrollFrame.FauxPrototype[k] = v
end

local hybridMethods = {
	-- Update = HybridScrollFrame_Update,
	-- SetOffset = HybridScrollFrame_SetOffset,
	GetOffset = HybridScrollFrame_GetOffset,
	CollapseButton = HybridScrollFrame_CollapseButton,
}

for k, v in pairs(hybridMethods) do
	ScrollFrame.HybridPrototype[k] = v
end

local function setHeader(self)
	self:SetHeight(self.parent.headerHeight)
end

local function resetHeight(self)
	self:SetHeight(self.parent.buttonHeightReal)
end

function HybridPrototype:CreateButtons()
	self.buttons = self.buttons or {}
	local scrollChild = self.scrollChild
	local numButtons = ceil(self:GetHeight() / self.buttonHeightReal) + 1
	for i = #self.buttons + 1, numButtons do
		local button = self.createButton(scrollChild)
		if i == 1 then
			button:SetPoint(self.initialPoint or "TOPLEFT", scrollChild, self.initialRelative or "TOPLEFT", self.initialOffsetX, self.initialOffsetY)
		else
			button:SetPoint(self.point or "TOPLEFT", self.buttons[i - 1], self.relativePoint or "BOTTOMLEFT", self.offsetX, self.offsetY)
		end
		button:SetHeight(self.buttonHeightReal)
		button.SetHeader = setHeader
		button.ResetHeight = resetHeight
		button.parent = self
		self.buttons[i] = button
	end
	
	self.buttonHeight = self.buttonHeightReal - (offsetY or 0)
	
	scrollChild:SetWidth(self:GetWidth())
	scrollChild:SetHeight(numButtons * self.buttonHeightReal)
	self:SetVerticalScroll(0)
	self:UpdateScrollChildRect()
	
	local scrollBar = self.scrollBar
	scrollBar:SetMinMaxValues(0, numButtons * self.buttonHeightReal)
	scrollBar.buttonHeight = self.buttonHeightReal
	scrollBar:SetValueStep(self.buttonHeightReal)
	scrollBar:SetStepsPerPage(numButtons - 2)
	scrollBar:SetValue(0)
end

function HybridPrototype:SetButtonHeight(height)
	self.buttonHeightReal = height
end

function HybridPrototype:SetHeaderHeight(height)
	self.headerHeight = height
end

function HybridPrototype:ExpandButton(numButtons)
	HybridScrollFrame_ExpandButton(self, numButtons * self.buttonHeight, self.headerHeight)
end

Libra:RegisterModule(Type, Version, constructor)