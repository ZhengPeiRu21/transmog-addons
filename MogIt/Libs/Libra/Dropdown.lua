local Libra = LibStub("Libra")
local Type, Version = "Dropdown", 9
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Dropdown = Libra.modules[Type]
Dropdown.Prototype = Dropdown.Prototype or CreateFrame("Frame")
Dropdown.MenuPrototype = Dropdown.MenuPrototype or setmetatable({}, {__index = Dropdown.Prototype})
Dropdown.FramePrototype = Dropdown.FramePrototype or setmetatable({}, {__index = Dropdown.Prototype})
Dropdown.objects = Dropdown.objects or {}
Dropdown.listData = Dropdown.listData or {}

local menuMT = {__index = Dropdown.MenuPrototype}
local frameMT = {__index = Dropdown.FramePrototype}

local Prototype = Dropdown.Prototype
local MenuPrototype = Dropdown.MenuPrototype
local FramePrototype = Dropdown.FramePrototype
local objects = Dropdown.objects
local listData = Dropdown.listData

local function UIDropDownMenu_GetButtonWidth(button)
  local width;
  local buttonName = button:GetName();
  local icon = _G[buttonName.."Icon"];
  local normalText = _G[buttonName.."NormalText"];
 
  if ( button.iconOnly and icon ) then
    width = icon:GetWidth();
  elseif ( normalText and normalText:GetText() ) then
    width = normalText:GetWidth() + 40;
   
    if ( button.icon ) then
      -- Add padding for the icon
      width = width + 10;
    end
  else
    return 0;
  end
 
  -- Add padding if has and expand arrow or color swatch
  if ( button.hasArrow or button.hasColorSwatch ) then
    width = width + 10;
  end
  if ( button.notCheckable ) then
    width = width - 30;
  end
  if ( button.padding ) then
    width = width + button.padding;
  end
 
  return width;
end

local function UIDropDownMenu_GetMaxButtonWidth(self)
  local maxWidth = 0;
  for i=1, self.numButtons do
    local button = _G[self:GetName().."Button"..i];
    if ( button:IsShown() ) then
      local width = UIDropDownMenu_GetButtonWidth(button);
      if ( width > maxWidth ) then
        maxWidth = width;
      end
    end
  end
  return maxWidth;
end

local function setHeight() end

local function constructor(self, type, parent, name)
	local dropdown
	if type == "Menu" then
		-- adding a SetHeight dummy lets us use a simple table instead of a frame, no side effects noticed so far
		dropdown = setmetatable({}, menuMT)
		dropdown:SetDisplayMode("MENU")
		dropdown.SetHeight = setHeight
	end
	if type == "Frame" then
		name = name or Libra:GetWidgetName(self.name)
		dropdown = setmetatable(CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate"), frameMT)
		dropdown:SetWidth(115)
		dropdown.label = dropdown:CreateFontString(name.."Label", "BACKGROUND", "GameFontNormalSmall")
		dropdown.label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
	end
	
	objects[dropdown] = true
	
	return dropdown
end


local methods = {
	Refresh = UIDropDownMenu_Refresh,
}

for k, v in pairs(methods) do
	Prototype[k] = v
end

function Prototype:AddButton(info, level)
	info.owner = self
	self.displayMode = self._displayMode
	self.selectedName = self._selectedName
	self.selectedValue = self._selectedValue
	self.selectedID = self._selectedID
	UIDropDownMenu_AddButton(info, level)
	self.displayMode = nil
	self.selectedName = nil
	self.selectedValue = nil
	self.selectedID = nil
	local listFrameName = "DropDownList"..(level or 1)
	local listFrame = _G[listFrameName]
	local button = _G[listFrameName.."Button"..(listFrame.numButtons)]
	button.icon = info.icon
	listFrame.maxWidth = UIDropDownMenu_GetMaxButtonWidth(listFrame)
end

function Prototype:ToggleMenu(value, anchorName, xOffset, yOffset, menuList, level, ...)
	ToggleDropDownMenu(level, value, self, anchorName, xOffset, yOffset, menuList, ...)
end

function Prototype:RebuildMenu(level)
	level = level or 1
	if self:IsMenuShown(level) then
		-- hiding a menu will also hide all deeper level menus, so we'll check which ones are open and restore them afterwards
		local maxLevel
		for i = level, UIDROPDOWNMENU_MENU_LEVEL do
			if _G["DropDownList"..i]:IsShown() then
				maxLevel = i
			else
				break
			end
		end
		self:HideMenu(level)
		for i = level, maxLevel do
			local listData = listData[i]
			-- set .rebuild to indicate that we don't want to reset the scroll offset on the next ToggleDropDownMenu
			self.rebuild = true
			self:ToggleMenu(listData.value, listData.anchorName, listData.xOffset, listData.yOffset, listData.menuList, i, listData.button, listData.autoHideDelay)
		end
	end
end

function Prototype:HideMenu(level)
	if UIDropDownMenu_GetCurrentDropDown() == self then
		HideDropDownMenu(level)
	end
end

function Prototype:CloseMenus(level)
	if UIDropDownMenu_GetCurrentDropDown() == self then
		CloseDropDownMenus(level)
	end
end

function Prototype:IsMenuShown(level)
	level = level or 1
	local listFrame = _G["DropDownList"..level]
	return UIDropDownMenu_GetCurrentDropDown() == self and listFrame and listFrame:IsShown()
end

function Prototype:SetSelectedName(name, useValue)
	self._selectedName = name
	self._selectedValue = nil
	self._selectedID = nil
	self.selectedName = name
	self:Refresh(useValue)
	self.selectedName = nil
end

function Prototype:SetSelectedValue(value, useValue)
	self._selectedValue = value
	self._selectedName = nil
	self._selectedID = nil
	self.selectedValue = value
	self:Refresh(useValue)
	self.selectedValue = nil
end

function Prototype:SetSelectedID(id, useValue)
	self._selectedID = id
	self._selectedName = nil
	self._selectedValue = nil
	self.selectedID = id
	self:Refresh(useValue)
	self.selectedID = nil
end

function Prototype:GetSelectedName()
	return self._selectedName
end

function Prototype:GetSelectedValue()
	return self._selectedValue
end

function Prototype:GetSelectedID()
	if self._selectedID then
		return self._selectedID
	else
		-- If no explicit selectedID then try to send the id of a selected value or name
		for i=1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]
			-- See if checked or not
			if self:GetSelectedName() then
				if button:GetText() == self:GetSelectedName() then
					return i
				end
			elseif self:GetSelectedValue() then
				if button.value == self:GetSelectedValue() then
					return i
				end
			end
		end
	end
end

function Prototype:SetDisplayMode(mode)
	self._displayMode = mode
end


local menuMethods = {
	Toggle = Prototype.ToggleMenu,
	Rebuild = Prototype.RebuildMenu,
	Hide = Prototype.HideMenu,
	Close = Prototype.CloseMenus,
	IsShown = Prototype.IsMenuShown,
}

for k, v in pairs(menuMethods) do
	MenuPrototype[k] = v
end


local frameMethods = {
	Enable = UIDropDownMenu_EnableDropDown,
	Disable = UIDropDownMenu_DisableDropDown,
	IsEnabled = UIDropDownMenu_IsEnabled,
	JustifyText = UIDropDownMenu_JustifyText,
	SetButtonWidth = UIDropDownMenu_SetButtonWidth,
	SetText = UIDropDownMenu_SetText,
	GetText = UIDropDownMenu_GetText,
}

for k, v in pairs(frameMethods) do
	FramePrototype[k] = v
end

local setWidth = Prototype.SetWidth

function FramePrototype:SetWidth(width, padding)
	_G[self:GetName().."Middle"]:SetWidth(width)
	local defaultPadding = 25
	if padding then
		setWidth(self, width + padding)
		_G[self:GetName().."Text"]:SetWidth(width)
	else
		setWidth(self, width + defaultPadding + defaultPadding)
		_G[self:GetName().."Text"]:SetWidth(width - defaultPadding)
	end
	self.noResize = 1
end

function FramePrototype:SetLabel(text)
	self.label:SetText(text)
end

function FramePrototype:SetEnabled(enable)
	if enable then
		self:Enable()
	else
		self:Disable()
	end
end


local numShownButtons

local function update(level)
	local scroll = listData[level].scroll
	for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..level.."Button"..i]
		local _, _, _, x, y = button:GetPoint()
		local y = -((button:GetID() - 1 - scroll) * UIDROPDOWNMENU_BUTTON_HEIGHT) - UIDROPDOWNMENU_BORDER_HEIGHT
		button:SetPoint("TOPLEFT", x, y)
		button:SetShown(i > scroll and i <= (numShownButtons + scroll))
	end
	Dropdown.scrollButtons[level].up:SetShown(scroll > 0)
	Dropdown.scrollButtons[level].down:SetShown(scroll < _G["DropDownList"..level].numButtons - numShownButtons)
end

local function scroll(self, delta)
	local level = self:GetID()
	local listData = listData[level]
	listData.scroll = listData.scroll - (type(delta) == "number" and delta or self.delta)
	listData.scroll = min(listData.scroll, (self.numButtons or self:GetParent().numButtons) - numShownButtons)
	listData.scroll = max(listData.scroll, 0)
	update(level)
end

local function onEnter(self)
	UIDropDownMenu_StopCounting(self:GetParent())
end

local function onLeave(self)
	UIDropDownMenu_StartCounting(self:GetParent())
end

local function onMouseDown(self)
	self.texture:SetPoint("CENTER", 1, -1)
end

local function onMouseUp(self)
	self.texture:SetPoint("CENTER")
end

local function onHide(self)
	self.texture:SetPoint("CENTER")
	-- explicitly hide so that they are hidden for unmanaged dropdowns
	self:Hide()
end

local function createScrollButton(listFrame)
	local level = listFrame:GetID()
	local button = CreateFrame("Button", nil, listFrame)
	button:SetSize(16, 16)
	button:SetScript("OnClick", scroll)
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)
	button:SetScript("OnHide", onHide)
	button:SetID(level)
	button.texture = button:CreateTexture()
	button.texture:SetSize(16, 16)
	button.texture:SetPoint("CENTER")
	button.texture:SetTexture([[Interface\Calendar\MoreArrow]])
	return button
end

local function createScrollButtons(listFrame)
	local scrollUp = listFrame.scrollUp or createScrollButton(listFrame)
	scrollUp:SetPoint("TOP")
	scrollUp.delta = 1
	scrollUp.texture:SetTexCoord(0, 1, 1, 0)
	listFrame.scrollUp = scrollUp
	
	local scrollDown = listFrame.scrollDown or createScrollButton(listFrame)
	scrollDown:SetPoint("BOTTOM")
	scrollDown.delta = -1
	listFrame.scrollDown = scrollDown
end

Dropdown.scrollButtons = Dropdown.scrollButtons or setmetatable({}, {
	__index = function(self, level)
		local listFrame = _G["DropDownList"..level]
		createScrollButtons(listFrame)
		self[level] = {
			up = listFrame.scrollUp,
			down = listFrame.scrollDown,
		}
		return self[level]
	end,
})

function Dropdown:ToggleDropDownMenuHook(level, value, dropdownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	level = level or 1
	if level ~= 1 then
		dropdownFrame = dropdownFrame or UIDROPDOWNMENU_OPEN_MENU
	end
	local listFrameName = "DropDownList"..level
	local listFrame = _G[listFrameName]
	if not objects[dropdownFrame] then
		listFrame:SetScript("OnMouseWheel", nil)
		return
	end
	if dropdownFrame and dropdownFrame._displayMode == "MENU" then
		_G[listFrameName.."Backdrop"]:Hide()
		_G[listFrameName.."MenuBackdrop"]:Show()
	end
	
	-- store all parameters per level so we can use them to rebuild the menu
	listData[level] = listData[level] or {}
	local listData = listData[level]
	listData.value = value
	listData.anchorName = anchorName
	listData.xOffset = xOffset
	listData.yOffset = yOffset
	listData.menuList = menuList
	listData.button = button
	listData.autoHideDelay = autoHideDelay
	
	numShownButtons = floor((UIParent:GetHeight() - UIDROPDOWNMENU_BORDER_HEIGHT * 2) / UIDROPDOWNMENU_BUTTON_HEIGHT)
	local scrollable = numShownButtons < listFrame.numButtons
	if scrollable then
		-- make scrollable
		listData.scroll = listData.scroll or 0
		if not dropdownFrame.rebuild then
			listData.scroll = 0
		end
		listFrame:SetScript("OnMouseWheel", scroll)
		listFrame:SetHeight((numShownButtons * UIDROPDOWNMENU_BUTTON_HEIGHT) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
		local point, anchorFrame, relativePoint, x, y = listFrame:GetPoint()
		local offTop = (GetScreenHeight() - listFrame:GetTop())-- / listFrame:GetScale()
		listFrame:SetPoint(point, anchorFrame, relativePoint, x, y + offTop)
		update(level)
	else
		if listFrame:GetTop() > GetScreenHeight() then
			local point, anchorFrame, relativePoint, x, y = listFrame:GetPoint()
			local offTop = (GetScreenHeight() - listFrame:GetTop())-- / listFrame:GetScale()
			listFrame:SetPoint(point, anchorFrame, relativePoint, x, y + offTop)
		end
		listFrame:SetScript("OnMouseWheel", nil)
		self.scrollButtons[level].up:Hide()
		self.scrollButtons[level].down:Hide()
	end
	dropdownFrame.rebuild = nil
end

if not Dropdown.hookToggleDropDownMenu then
	hooksecurefunc("ToggleDropDownMenu", function(...)
		Dropdown:ToggleDropDownMenuHook(...)
	end)
	Dropdown.hookToggleDropDownMenu = true
end

Libra:RegisterModule(Type, Version, constructor)