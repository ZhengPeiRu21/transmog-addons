local Libra = LibStub("Libra")
local Type, Version = "OptionsFrame", 1
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local Options = Libra.modules[Type]

Options.Prototype = Options.Prototype or CreateFrame("Frame")
Options.ParentPrototype = Options.ParentPrototype or {}

local mt = {__index = Options.Prototype}
local parentMT = {__index = setmetatable(Options.ParentPrototype, {__index = Options.Prototype})}

local Prototype = Options.Prototype
local ParentPrototype = Options.ParentPrototype

local function createFrame(name, parent)
	local frame = CreateFrame("Frame")
	frame.name = name
	frame.parent = parent
	InterfaceOptions_AddCategory(frame)
	
	local title = frame:CreateFontString(nil, nil, "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetPoint("RIGHT", -16, 0)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(name)
	frame.title = title
	
	local desc = frame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	desc:SetHeight(32)
	desc:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8)
	desc:SetPoint("RIGHT", -31, 0)
	desc:SetJustifyH("LEFT")
	desc:SetJustifyV("TOP")
	desc:SetNonSpaceWrap(true)
	frame.desc = desc
	
	return frame
end

local function constructor(self, name)
	local frame = setmetatable(createFrame(name), parentMT)
	frame.controls = {}
	frame.allcontrols = {}
	return frame
end


function ParentPrototype:AddSubCategory(name, inherit)
	local frame = setmetatable(createFrame(name, self.name), mt)
	if inherit then
		frame.db = self.db
		frame.useProfile = self.useProfile
		frame.handler = self.handler
		frame.allcontrols = self.allcontrols
	else
		frame.allcontrols = {}
	end
	frame.inherit = inherit
	frame.controls = {}
	self.subCategories = self.subCategories or {}
	tinsert(self.subCategories, frame)
	return frame
end

function Prototype:SetDescription(text)
	self.desc:SetText(text)
end

function Prototype:SetDatabase(database, useProfile)
	self.db = database
	self.useProfile = useProfile
	if self.subCategories then
		for i, v in ipairs(self.subCategories) do
			if v.inherit then
				v.db = database
			end
		end
	end
end

function Prototype:SetHandler(tbl)
	self.handler = tbl
	if self.subCategories then
		for i, v in ipairs(self.subCategories) do
			if v.inherit then
				v.handler = tbl
			end
		end
	end
end


local function getTable(control)
	local tbl = control.parent.db
	if control.parent.useProfile then
		tbl = tbl.profile
	end
	if control.keyTable then
		tbl = tbl[control.keyTable]
	end
	return tbl
end

local function getFunc(control, method, value, key)
	local func = control[method]
	if func then
		local object = control
		if type(func) == "string" then
			object = control.parent.handler
			func = object[func]
		end
		if key then
			return true, func(object, key, value)
		else
			return true, func(object, value)
		end
		return true
	end
end

local function set(self, value, key)
	if not getFunc(self, "set", key, value) then
		local tbl = getTable(self)
		if tbl then
			tbl[key or self.key] = value
		end
	end
	getFunc(self, "func", key, value)
	for key, control in pairs(self.parent.allcontrols) do
		if control.disabled then
			control:SetEnabled(not control.disabled())
		end
	end
end

local function get(self, key)
	local hasFunc, value = getFunc(self, "get", key)
	if hasFunc then
		return value
	else
		local tbl = getTable(self)
		if tbl then
			return tbl[key or self.key]
		end
	end
end

local controls = {}

do
	local function onClick(self)
		local checked = self:GetChecked() ~= nil
		PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		set(self, checked)
	end
	
	controls.CheckButton = function(parent)
		local checkButton = CreateFrame("CheckButton", nil, parent, "OptionsBaseCheckButtonTemplate")
		checkButton:SetNormalFontObject("GameFontHighlight")
		checkButton:SetDisabledFontObject("GameFontDisable")
		checkButton:SetPushedTextOffset(0, 0)
		checkButton:SetScript("OnClick", onClick)
		checkButton.SetValue = checkButton.SetChecked
		
		checkButton.label = checkButton:CreateFontString()
		checkButton.label:SetPoint("LEFT", checkButton, "RIGHT", 0, 1)
		checkButton:SetFontString(checkButton.label)
		
		return checkButton
	end
end

do
	local ColorPickerFrame = ColorPickerFrame
	
	local function setColor(self, color)
		self.swatch:SetVertexColor(color.r, color.g, color.b)
	end
	
	local function saveColor(self, r, g, b)
		self.swatch:SetVertexColor(r, g, b)
		local color = get(self)
		color.r = r
		color.g = g
		color.b = b
		set(self, color)
	end
	
	local function swatchFunc()
		saveColor(ColorPickerFrame.extraInfo, ColorPickerFrame:GetColorRGB())
	end
	
	local function cancelFunc(prev)
		saveColor(ColorPickerFrame.extraInfo, ColorPicker_GetPreviousValues())
	end
	
	local scripts = {
		OnClick = function(self)
			local info = UIDropDownMenu_CreateInfo()
			local color = get(self)
			info.r, info.g, info.b = color.r, color.g, color.b
			info.swatchFunc = swatchFunc
			info.cancelFunc = cancelFunc
			info.extraInfo = self
			OpenColorPicker(info)
		end,
		
		OnEnter = function(self)
			self.bg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			if self.tooltipText then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
			end
		end,
		
		OnLeave = function(self)
			self.bg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			GameTooltip:Hide()
		end,
		
		OnEnable = function(self)
			if self:IsMouseOver() then
				self:OnEnter()
			else
				self.bg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			end
		end,
		
		OnDisable = function(self)
			self.bg:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		end,
	}
	
	controls.ColorButton = function(parent, data)
		local colorButton = CreateFrame("Button", nil, parent)
		colorButton:SetSize(16, 16)
		colorButton:SetNormalFontObject("GameFontHighlight")
		colorButton:SetDisabledFontObject("GameFontDisable")
		colorButton:SetPushedTextOffset(0, 0)
		for script, handler in pairs(scripts) do
			colorButton:SetScript(script, handler)
			colorButton[script] = handler
		end
		colorButton.SetValue = setColor
		
		colorButton:SetNormalTexture([[Interface\ChatFrame\ChatFrameColorSwatch]])
		colorButton.swatch = colorButton:GetNormalTexture()
		
		colorButton.bg = colorButton:CreateTexture(nil, "BACKGROUND")
		colorButton.bg:SetSize(14, 14)
		colorButton.bg:SetPoint("CENTER")
		colorButton.bg:SetTexture(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		
		colorButton.label = colorButton:CreateFontString()
		colorButton.label:SetPoint("LEFT", colorButton, "RIGHT", 5, 1)
		colorButton:SetFontString(colorButton.label)
		
		return colorButton
	end
end

do
	local function onValueChanged(self, value, isUserInput)
		if isUserInput then
			set(self, value)
		end
		if self.isPercent then
			self.currentValue:SetFormattedText("%.0f%%", value * 100)
		else
			self.currentValue:SetText(value)
		end
	end
	
	local function onMinMaxChanged(self, min, max)
		if self.minText or not self.isPercent then
			self.min:SetText(self.minText or min)
		else
			self.min:SetFormattedText("%.0f%%", min * 100)
		end
		if self.maxText or not self.isPercent then
			self.max:SetText(self.maxText or max)
		else
			self.max:SetFormattedText("%.0f%%", max * 100)
		end
	end
	
	controls.Slider = function(parent, data)
		local slider = Libra:CreateSlider(parent)
		slider:SetScript("OnValueChanged", onValueChanged)
		slider:SetScript("OnMinMaxChanged", onMinMaxChanged)
		slider.isPercent = data.isPercent
		slider.minText = data.minText
		slider.maxText = data.maxText
		slider:SetMinMaxValues(data.min, data.max)
		slider:SetValueStep(data.step)
		return slider
	end
end

do
	local function getValue(dropdown, property, value)
		local properties = dropdown.properties
		local property = properties and properties[property]
		if not properties or not property then
			return value
		else
			if type(property) == "function" then
				return property(value)
			elseif type(property) == "table" then
				return property[value]
			else
				return property
			end
		end
	end
	
	local function setText(self, value)
		self:SetText(getValue(self, "text", value))
	end
	
	local copyProperties = {
		"text",
		"value",
		"arg1",
	}
	
	local function onClick(self, arg1, arg2, checked)
		if self.owner.multiSelect then
			set(self.owner, checked, arg1)
		else
			self.owner:SetText(self:GetText())
			set(self.owner, arg1)
		end
	end
	
	local function checked(self)
		if self.owner.multiSelect then
			return get(self.owner, self.arg1)
		else
			return self.arg1 == get(self.owner)
		end
	end
	
	local function initialize(self, level, menuList)
		menuList = menuList or self.menulist
		if type(menuList) == "function" then
			menuList = menuList()
		end
		for i, v in ipairs(menuList) do
			local info = UIDropDownMenu_CreateInfo()
			for i, propertyName in ipairs(copyProperties) do
				info[propertyName] = getValue(self, propertyName, v)
			end
			info.func = onClick
			info.checked = checked
			info.isNotRadio = self.multiSelect
			self:AddButton(info)
		end
	end
	
	controls.Dropdown = function(parent, data)
		local dropdown = Libra:CreateDropdown("Frame", parent)
		dropdown:JustifyText("LEFT")
		dropdown.SetValue = setText
		dropdown.initialize = data.initialize or initialize
		dropdown.menulist = data.menuList
		dropdown.multiSelect = data.multiSelect
		if data.properties then
			dropdown.properties = {}
			for k, v in pairs(data.properties) do
				dropdown.properties[k] = v
			end
		end
		return dropdown
	end
end

local objectData = {
	CheckButton = {
		x = -2,
		y = -16,
		bottomOffset = 8,
	},
	ColorButton = {
		x = 3,
		y = -21,
		bottomOffset = 3,
	},
	Slider = {
		x = 7,
		y = -27,
		bottomOffset = -5,
	},
	Dropdown = {
		x = -15,
		y = -32,
		bottomOffset = 8,
	},
}

function Prototype:CreateOptions(options)
	for i, option in ipairs(options) do
		local control = controls[option.type](self, option)
		local data = objectData[option.type]
		if i == 1 then
			control:SetPoint("TOPLEFT", self.desc, "BOTTOMLEFT", data.x, data.y + 8)
		elseif option.newColumn then
			control:SetPoint("TOPLEFT", self.desc, "BOTTOM", data.x - 2, data.y + 8)
		else
			local previousOption = options[i - 1]
			local previousData = objectData[previousOption.type]
			control:SetPoint("TOPLEFT", self.controls[i - 1], "BOTTOMLEFT", data.x - previousData.x, data.y + previousData.bottomOffset - (option.padding or 0))
		end
		if option.width then
			control:SetWidth(option.width)
		end
		control.parent = self
		control.label:SetText(option.text)
		control.tooltipText = option.tooltip
		control.key = option.key
		control.set = option.set
		control.get = option.get
		control.func = option.func
		control.disabled = option.disabled
		tinsert(self.controls, control)
		tinsert(self.allcontrols, control)
	end
end

function Prototype:SetupControls()
	for i, control in ipairs(self.allcontrols) do
		local value = get(control)
		control:SetValue(value)
		getFunc(control, "func", key, value)
		if control.disabled then
			control:SetEnabled(not control.disabled())
		end
	end
end

function Prototype:GetControlByKey(key, keyTable)
	for i, control in ipairs(self.allcontrols) do
		if control.key == key and control.keyTable == keyTable then
			return control
		end
	end
end

Libra:RegisterModule(Type, Version, constructor)