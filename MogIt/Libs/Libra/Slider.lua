local Libra = LibStub("Libra")
local Type, Version = "Slider", 2
if Libra:GetModuleVersion(Type) >= Version then return end

local backdrop = {
	bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
	edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
	edgeSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6}
}

local function onEnter(self)
	if self:IsEnabled() then
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
		end
		if self.tooltipRequirement then
			GameTooltip:AddLine(self.tooltipRequirement, 1.0, 1.0, 1.0)
			GameTooltip:Show()
		end
	end
end

local function onLeave(self)
	GameTooltip:Hide()
end

local function constructor(self, parent)
	local slider = CreateFrame("Slider", nil, parent)
	slider:SetSize(144, 17)
	slider:SetBackdrop(backdrop)
	slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])
	slider:SetOrientation("HORIZONTAL")
	slider:SetObeyStepOnDrag(true)
	slider:SetScript("OnEnter", onEnter)
	slider:SetScript("OnLeave", onLeave)
	
	slider.label = slider:CreateFontString(nil, nil, "GameFontNormal")
	slider.label:SetPoint("BOTTOM", slider, "TOP")
	
	slider.min = slider:CreateFontString(nil, nil, "GameFontHighlightSmall")
	slider.min:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", -4, 3)
	
	slider.max = slider:CreateFontString(nil, nil, "GameFontHighlightSmall")
	slider.max:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 4, 3)
	
	slider.currentValue = slider:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	slider.currentValue:SetPoint("CENTER", 0, -15)
	
	return slider
end

Libra:RegisterModule(Type, Version, constructor)