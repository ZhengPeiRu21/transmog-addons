local MogIt,mog = ...;
local L = mog.L;

local useModel = {
	[0] = TARGET,
	[1] = PLAYER,
}

local myuseModel = UnitIsPlayer("PLAYER")
mog.playeruseModel = myuseModel;
mog.displayuseModel = myuseModel

local ModelFramePrototype = CreateFrame("Button")
local ModelFrame_MT = {__index = ModelFramePrototype}

--// mog.frame
mog.frame:SetPoint("CENTER");
mog.frame:SetSize(252,108);
mog.frame:SetToplevel(true);
mog.frame:SetClampedToScreen(true);
mog.frame:EnableMouse(true);
mog.frame:EnableMouseWheel(true);
mog.frame:SetMovable(true);
mog.frame:SetResizable(true);
mog.frame:SetDontSavePosition(true);
mog.frame:SetScript("OnMouseDown", mog.frame.StartMoving);
local function stopMovingOrSizing(self)
	self:StopMovingOrSizing();
	local profile = mog.db.profile;
	profile.point, profile.x, profile.y = select(3, self:GetPoint());
end
mog.frame:SetScript("OnMouseUp", stopMovingOrSizing);
mog.frame:SetScript("OnHide", stopMovingOrSizing);
tinsert(UISpecialFrames,"MogItFrame");

mog.frame.TitleText:SetText("MogIt");
mog.frame.TitleText:SetPoint("RIGHT",mog.frame,"RIGHT",-28,0);
mog.frame.portrait:SetTexture("Interface\\AddOns\\MogIt\\Images\\MogIt");
mog.frame.portrait:SetTexCoord(0,106/128,0,105/128);
MogItFrameBg:SetTexture("Interface\\AddOns\\MogIt\\FrameGeneral\\UI-Background-Rock",true);
MogItFrameBg:SetVertexColor(0.8,0.3,0.8);

mog.frame.resize = CreateFrame("Button",nil,mog.frame);
mog.frame.resize:SetSize(16,16);
mog.frame.resize:SetPoint("BOTTOMRIGHT",-4,3);
mog.frame.resize:SetHitRectInsets(0, -4, 0, -3)
mog.frame.resize:SetScript("OnMouseDown", function(self)
	mog.frame:SetMinResize(510,350);
	mog.frame:SetMaxResize(GetScreenWidth(), GetScreenHeight());
	mog.frame:StartSizing();
end);
local function stopMovingOrSizing()
	mog.frame:StopMovingOrSizing();
end
mog.frame.resize:SetScript("OnMouseUp", stopMovingOrSizing);
mog.frame.resize:SetScript("OnHide", stopMovingOrSizing);
mog.frame.resize:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]]);
mog.frame.resize:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
mog.frame.resize:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])

mog.frame.path = mog.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.frame.path:SetPoint("BOTTOMLEFT",mog.frame,"BOTTOMLEFT",17,10);

mog.frame.page = mog.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.frame.page:SetPoint("BOTTOMRIGHT",mog.frame,"BOTTOMRIGHT",-17,10);
--//


--// Model Frames
mog.models = {};
mog.modelBin = {};
mog.posX = 0;
mog.posY = 0;
mog.posZ = 0;
mog.face = 0;

function mog:CreateModelFrame(parent)
	if mog.modelBin[1] then
		local f = mog.modelBin[1];
		f.parent = parent;
		f:SetParent(parent);
		--f:Show();
		tremove(mog.modelBin,1);
		return f;
	end
	
	local f = setmetatable(CreateFrame("Button",nil,parent), ModelFrame_MT);
	f:Hide();
	
	f.parent = parent;
	f.data = {};
	f.indicators = {};
	
	f.model = CreateFrame("DressUpModel",nil,f);
	f.model:SetAllPoints(f);
	f.model:SetModelScale(2);
	f.model:SetUnit("PLAYER");
	f.model:SetPosition(0,0,0);
	
	f.bg = f:CreateTexture(nil,"BACKGROUND");
	f.bg:SetAllPoints(f);
	f.bg:SetTexture(0.3,0.3,0.3,0.2);
	
	f:RegisterForClicks("AnyUp");
	f:RegisterForDrag("LeftButton","RightButton");
	f:SetScript("OnShow",f.OnShow);
	f:SetScript("OnHide",f.OnHide);
	f:SetScript("OnUpdate",f.OnUpdate);
	f:SetScript("OnDragStart",f.OnDragStart);
	f:SetScript("OnDragStop",f.OnDragStop);
	
	return f;
end

function mog:DeleteModelFrame(f)
	f:Hide();
	f:ClearAllPoints();
	f:SetScript("OnClick",nil);
	f:SetScript("OnEnter",nil);
	f:SetScript("OnLeave",nil);
	f:SetScript("OnMouseWheel",nil);
	f:EnableMouseWheel(false);
	for ind,frame in pairs(f.indicators) do
		frame:Hide();
	end
	wipe(f.data);
	f:SetAlpha(1);
	f:Enable();
	tinsert(mog.modelBin, f);
end

function mog:CreateCatalogueModel()
	local f = mog:CreateModelFrame(mog.frame);
	f.type = "catalogue";
	f:SetScript("OnClick", f.OnClick);
	f:SetScript("OnEnter", f.OnEnter);
	f:SetScript("OnLeave", f.OnLeave);
	tinsert(mog.models, f);
	return f;
end

function mog:DeleteCatalogueModel(n)
	mog:DeleteModelFrame(mog.models[n]);
	tremove(mog.models, n);
end


function ModelFramePrototype:OnClick(button, ...)
	if mog.active and mog.active.OnClick then
		mog.active:OnClick(self, button, self.data.value, ...);
	end
end

function ModelFramePrototype:OnEnter()
	if mog.active and mog.active.OnEnter then
		mog.active:OnEnter(self, self.data.value);
	end
end

function ModelFramePrototype:OnLeave(...)
	if mog.active and mog.active.OnLeave then
		mog.active:OnLeave(self, self.data.value, ...);
	else
		GameTooltip:Hide();
	end
end

function ModelFramePrototype:OnShow()
	local lvl = self:GetParent():GetFrameLevel();
	if self:GetFrameLevel() <= lvl then
		self:SetFrameLevel(lvl+1);
	end
	self:ResetModel();
	if self.type == "preview" then
		self:Undress();
		mog.DressFromPreview(self, self.parent);
	else
		if not self.data.value then
			-- hack for models becoming visible OnShow, only do this if the frame is supposed to be hidden
			self:SetAlpha(1)
			self:SetAlpha(0)
		end
		mog:ModelUpdate(self, self.data.value);
	end
end

function ModelFramePrototype:OnHide()
	if mog.modelUpdater.model == self then
		mog:StopModelUpdater();
	end
	self.model:SetPosition(0,0,0);
end

function ModelFramePrototype:OnUpdate()
	--56, 108, 237, 238, 239, 243, 249, 250, 251, 252, 253, 254, 255
	if mog.db.profile.noAnim then
		self.model:SetSequence(3);
	end
end

function ModelFramePrototype:OnDragStart(button)
	mog:StartModelUpdater(self, button);
end

function ModelFramePrototype:OnDragStop(button)
	mog:StopModelUpdater();
end

function ModelFramePrototype:ShowIndicator(name)
	if not mog.indicators[name] then return end;
	if not self.indicators[name] then
		self.indicators[name] = mog.indicators[name](self.model);
	end
	self.indicators[name]:Show();
end

function ModelFramePrototype:SetText(text)
	if not self.indicators.label then
		self.indicators.label = mog.indicators.label(self.model);
	end
	self.indicators.label:SetText(text);
end

local tryOnSlots = {
	MainHandSlot = "mainhand",
	SecondaryHandSlot = "offhand",
}

function ModelFramePrototype:TryOn(item, slot)
	self.model:TryOn(item, tryOnSlots[slot]);
end

function ModelFramePrototype:Undress()
	self.model:Undress()
end

function ModelFramePrototype:UndressSlot(slot)
	self.model:UndressSlot(slot)
end

function ModelFramePrototype:ApplyDress()
	if mog.db.profile.gridDress == "equipped" then
		self:ResetModel();
	else
		self:Undress();
		if mog.db.profile.gridDress == "preview" then
			mog.DressFromPreview(self, mog.activePreview);
		end
	end
end

function ModelFramePrototype:ResetModel()
	local model = self.model;
	model:SetPosition(0, 0, 0);
	local info = self.type == "preview" and self.parent.data or mog;
	-- :Dress resets the custom race, and :SetCustomRace does :Dress, so if we're using a custom race, just :SetCustomRace again instead of :Dress
	if info.displayuseModel == myuseModel then
		model:SetUnit("PLAYER");
		model:Dress()
	elseif UnitIsPlayer("TARGET") then
		model:SetUnit("TARGET");
		model:Dress();
	end				 
	self:PositionModel();
end

function ModelFramePrototype:PositionModel()
	local model = self.model
	if model:IsVisible() then
		local sync = (mog.db.profile.sync or self.type == "catalogue");
		local modelData = sync and mog or self.parent.data
		model:SetPosition(modelData.posZ or 0, modelData.posX or 0, modelData.posY or 0);
		model:SetFacing(modelData.face or 0);
	end
end

function mog.DressFromPreview(model, previewFrame)
	if not previewFrame then
		return;
	end
	
	for id, slot in pairs(previewFrame.slots) do
		if slot.item then
			model:TryOn("item:" ..slot.item .. (previewFrame.data.weaponEnchant and ":" .. previewFrame.data.weaponEnchant or ""), slot.slot);
		end
	end
end
--//


--// Model Updater
mog.modelUpdater = CreateFrame("Frame",nil,UIParent);
mog.modelUpdater:Hide();
mog.modelUpdater:SetScript("OnUpdate",function(self,elapsed)
	local cX,cY = GetCursorPosition();
	local dX = (cX-self.pX)/50;
	local dY = (cY-self.pY)/50;
	
	if (mog.db.profile.sync or self.model.type == "catalogue") then
		if self.btn == "LeftButton" then
			mog.posZ = mog.posZ + dY;
			mog.face = mog.face + dX;
		elseif self.btn == "RightButton" then
			mog.posX = mog.posX + dX;
			mog.posY = mog.posY + dY;
		end
		for id,model in ipairs(mog.models) do
			model:PositionModel();
		end
		if mog.db.profile.sync then
			for id, preview in ipairs(mog.previews) do
				preview.model:PositionModel();
			end
		end
	else
		local modelData = self.model.parent.data
		if self.btn == "LeftButton" then
			modelData.posZ = (modelData.posZ or mog.posZ or 0) + dY;
			modelData.face = (modelData.face or mog.face or 0) + dX;
		elseif self.btn == "RightButton" then
			modelData.posX = (modelData.posX or mog.posX or 0) + dX;
			modelData.posY = (modelData.posY or mog.posY or 0) + dY;
		end
		self.model:PositionModel();
	end
	
	self.pX,self.pY = cX,cY;
end);

function mog:StartModelUpdater(model, btn)
	mog.modelUpdater.btn = btn;
	mog.modelUpdater.model = model;
	mog.modelUpdater.pX,mog.modelUpdater.pY = GetCursorPosition();
	mog.modelUpdater:Show();
end

function mog:StopModelUpdater()
	mog.modelUpdater:Hide();
	mog.modelUpdater.btn = nil;
	mog.modelUpdater.model = nil;
end
--//


--// Indicators
mog.indicators = {};

function mog:CreateIndicator(name,func)
	if mog.indicators[name] then return end;
	mog.indicators[name] = func;
end
--//


--// Scroll Frame
local updater = CreateFrame("Frame");
updater:Hide();
updater:SetScript("OnUpdate", function(self)
	self:Hide();
	mog:UpdateScroll();
	mog.doModelUpdate = nil;
end);

mog.scroll = CreateFrame("Slider","MogItScroll",mog.frame,"UIPanelScrollBarTrimTemplate");
mog.scroll:Hide();
mog.scroll:SetPoint("TOPRIGHT",mog.frame.Inset,"TOPRIGHT",1,-17);
mog.scroll:SetPoint("BOTTOMRIGHT",mog.frame.Inset,"BOTTOMRIGHT",1,16);
mog.scroll:SetValueStep(1);
mog.scroll:SetScript("OnValueChanged",function(self,value,isUserInput)
	if isUserInput then
		self:SetValue(value);
		value = self:GetValue();
	end
	self:update(nil,nil,value);
end);

mog.scroll.up = MogItScrollScrollUpButton;
mog.scroll.down = MogItScrollScrollDownButton;
mog.scroll.up:SetScript("OnClick",function(self)
	mog.scroll:update(nil,-1);
end);
mog.scroll.down:SetScript("OnClick",function(self)
	mog.scroll:update(nil,1);
end);

function mog.scroll.update(self, value, offset, onscroll)
	local models = #mog.models;
	local total = ceil(#mog.list/models);
	
	if onscroll then
		value = onscroll;
	else
		if total > 0 then
			self:SetMinMaxValues(1, total);
		end
		if total > 1 then
			self:Show();
		else
			self:Hide();
		end
		
		local old = self:GetValue();
		value = (value or old or 1) + (offset or 0);
		if value ~= old then
			self:SetValue(value);
			return;
		end
	end

	if value == 1 then
		self.up:Disable();
	else
		self.up:Enable();
	end
	if value == total then
		self.down:Disable();
	else
		self.down:Enable();
	end
	
	if mog.Item_Menu:IsShown() or mog.Set_Menu:IsShown() then
		HideDropDownMenu(1);
	end
	
	if mog.active and mog.active.OnScroll then
		mog.active:OnScroll();
	end
	
	for id, frame in ipairs(mog.models) do
		local index = ((value-1)*models)+id;
		local value = mog.list[index];
		wipe(frame.data);
		if value then
			frame.data.value = value;
			frame.data.frame = frame;
			frame.data.index = index;
			for k, v in pairs(frame.indicators) do
				v:Hide();
			end
			if frame:IsShown() then
				mog:ModelUpdate(frame, value);
				if GameTooltip:IsOwned(frame) then
					frame:OnEnter();
				end
			else
				frame:Show();
			end
			frame:SetAlpha(1);
			frame:Enable();
		else
			if mog.modelUpdater.model == frame then
				mog:StopModelUpdater();
			end
			frame:SetAlpha(0);
			frame:Disable();
		end
	end
	
	if total > 0 then
		mog.frame.page:SetText(MERCHANT_PAGE_NUMBER:format(value, total));
		mog.frame.page:Show();
	else
		mog.frame.page:Hide();
	end
	
	-- incorrect models may be tried on when items aren't cached, this queues another update if uncached items were found
	if mog.doModelUpdate then
		updater:Show();
	end					
end

mog.frame:SetScript("OnMouseWheel", function(self, offset)
	mog.scroll:update(nil, offset > 0 and -1 or 1);
end);

function mog:UpdateScroll(value, offset)
	mog.scroll:update(value, offset);
end

function mog:ModelUpdate(frame, value)
	if mog.active and mog.active.FrameUpdate and value then
		mog.active:FrameUpdate(frame, value);
	end
end
--//


--// GUI
function mog:GetModelSize()
	local x = floor((mog.db.profile.gridWidth+5-(4+10)-(10+18+4))/mog.db.profile.columns)-5;
	local y = floor((mog.db.profile.gridHeight+5-(60+10)-(10+26))/mog.db.profile.rows)-5;
	return x,y;
end

function mog:UpdateGUI(resize)
	local profile = mog.db.profile;
	local rows,columns = profile.rows,profile.columns;
	local total = rows*columns;
	local current = #mog.models;
	local modelWidth,modelHeight = mog:GetModelSize();
	
	if not resize then
		if current > total then
			for i=current,(total+1),-1 do
				mog:DeleteCatalogueModel(i);
			end
		elseif current < total then
			for i=(current+1),total,1 do
				mog:CreateCatalogueModel();
			end
		end
		mog.frame:SetPoint(profile.point, profile.x, profile.y);
		mog.frame:SetSize(profile.gridWidth,profile.gridHeight);
		if mog.frame:IsShown() then
			mog.scroll:update();
		end
	end
	
	for row=1,rows do
		for column=1,columns do
			local n = ((row-1)*columns)+column;
			if not resize then
				if n==1 then
					mog.models[n]:SetPoint("TOPLEFT",mog.frame.Inset,"TOPLEFT",10,-10);
				elseif column==1 then
					mog.models[n]:SetPoint("TOPLEFT",mog.models[n-columns],"BOTTOMLEFT",0,-5);
				else
					mog.models[n]:SetPoint("TOPLEFT",mog.models[n-1],"TOPRIGHT",5,0);
				end
			end
			mog.models[n]:SetSize(modelWidth,modelHeight);
		end
	end
end
--//


--// Toolbar
local function menuBarInitialize(self, level)
	if self.active and self.active.func then
		self.tier[level] = UIDROPDOWNMENU_MENU_VALUE;
		self.active.func(self, level);
	end
end

local function menuOnClick(self, btn)
	if self.menuBar.active ~= self then
		HideDropDownMenu(1);
	end
	self.menuBar.active = self;
	if self.func then
		self.menuBar:ToggleMenu(nil, self);
	end
end

local function menuOnEnter(self)
	if self.menuBar.active ~= self and self.menuBar:IsShown() then
		HideDropDownMenu(1);
		if self.func then
			self.menuBar.active = self;
			self.menuBar:ToggleMenu(nil, self);
		end
	end
	self.nt:SetTexture(1,0.82,0,1);
end

local function menuOnLeave(self)
	self.nt:SetTexture(0,0,0,0);
end

local function createMenu(menuBar, label, func)
	local f = CreateFrame("Button", nil, menuBar.parent);
	f:SetText(label);
	f:SetNormalFontObject(GameFontNormal);
	f:SetHighlightFontObject(GameFontBlack);
	f:SetSize(f:GetFontString():GetStringWidth()+10, f:GetFontString():GetStringHeight()+10);
	f.menuBar = menuBar
	f.menuBar.xOffset = 0
	f.menuBar.yOffset = 0
	
	f.nt = f:CreateTexture(nil,"BACKGROUND");
	--nt:SetTexture(0.8,0.3,0.8,1);
	f.nt:SetTexture(0,0,0,0);
	f.nt:SetAllPoints(f);
	f:SetNormalTexture(f.nt);
	
	f.func = func;
	f:SetScript("OnClick",menuOnClick);
	f:SetScript("OnEnter",menuOnEnter);
	f:SetScript("OnLeave",menuOnLeave);
	
	return f;
end

function mog.CreateMenuBar(parent)
	local menuBar = mog:CreateDropdown("Menu");
	menuBar.initialize = menuBarInitialize
	menuBar.CreateMenu = createMenu;
	menuBar.parent = parent
	menuBar.tier = {};
	return menuBar;
end

mog.menu = mog.CreateMenuBar(mog.frame);
--//


--// Module Menu
mog.menu.modules = mog.menu:CreateMenu(L["Modules"], function(self, tier)
	if tier == 1 then
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Base Modules"];
		info.isTitle = true;
		info.notCheckable = true;
		info.justifyH = "CENTER";
		UIDropDownMenu_AddButton(info,tier);
		
		for k,v in ipairs(mog.moduleList) do
			if v.base and v.Dropdown then
				v:Dropdown(tier);
			end
		end
		
		info = UIDropDownMenu_CreateInfo();
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info,tier);
		
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Extra Modules"];
		info.isTitle = true;
		info.notCheckable = true;
		info.justifyH = "CENTER";
		UIDropDownMenu_AddButton(info,tier);
		
		for k,v in ipairs(mog.moduleList) do
			if (not v.base) and v.Dropdown then
				v:Dropdown(tier);
			end
		end
	elseif self.tier[2] and self.tier[2].Dropdown then
		self.tier[2]:Dropdown(tier);
	end
end);
mog.menu.modules:SetPoint("TOPLEFT", mog.frame, "TOPLEFT", 62, -31);
--//


--// Catalogue Menu
local function setWeaponEnchant(self, enchant)
	mog.weaponEnchant = enchant;
	mog.menu:Rebuild(2);
	mog.scroll:update();
end

local function setDisplayModel(self, arg1, value)
	mog[arg1] = value;
	for i, model in ipairs(mog.models) do
		-- reset positions first since they tend to go nuts when manipulating the model
		local modelData = model.parent.data
		mog.posX = 0;
		mog.posY = 0;
		mog.posZ = 0;
		model:ResetModel();
		if model:IsEnabled() then
			mog:ModelUpdate(model, model.data.value);
		end
	end
	CloseDropDownMenus(1);
end

function mog:CreateuseModelMenu(dropdown, level, func, selecteduseModel)
	for i = 0, 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.text = useModel[i];
		info.func = func;
		info.checked = selecteduseModel == i;
		info.arg1 = "displayuseModel";
		info.arg2 = i;
		dropdown:AddButton(info, level);
	end
end
local dressOptions = {
	none = NONE,
	preview = L["Preview"],
	equipped = L["Equipped"],
}

local function setGridDress(self)
	mog.db.profile.gridDress = self.value;
	for i, model in ipairs(mog.models) do
		model.model:SetPosition(0, 0, 0)
	end
	mog.scroll:update();
	for i, model in ipairs(mog.models) do
		model:PositionModel()
	end
	CloseDropDownMenus(1);
end

function mog:ToggleFilters()
	if not mog.filt:IsShown() then mog.filt:Show() else mog.filt:Hide() end
	--mog.filt:SetShown(not mog.filt:IsShown());
end

mog.sorting = {};

mog.menu.catalogue = mog.menu:CreateMenu(L["Catalogue"], function(self, tier)
	if tier == 1 then
		local info = UIDropDownMenu_CreateInfo();
		info.text = mog.filt:IsShown() and L["Hide Filters"] or L["Show Filters"];
		info.notCheckable = true;
		info.func = mog.ToggleFilters;
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Sorting"];
		info.value = "sorting";
		info.notCheckable = true;
		info.hasArrow = true;
		info.disabled = not (mog.active and mog.active.sorting and #mog.active.sorting > 0);
		UIDropDownMenu_AddButton(info,tier);
			
		local info = UIDropDownMenu_CreateInfo();
		info.text = "Use Model";
		info.value = "useModel";
		info.notCheckable = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Dress models"];
		info.value = "gridDress";
		info.notCheckable = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Weapon enchant"];
		info.value = "weaponEnchant";
		info.notCheckable = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info,tier);
		
	elseif self.tier[2] == "sorting" then
		if tier == 2 then
			if mog.active and mog.active.sorting then
				for k,v in ipairs(mog.active.sorting) do
					if mog.sorting[v] and mog.sorting[v].Dropdown then
						mog.sorting[v].Dropdown(self,mog.active,tier);
					end
				end
			end
		elseif self.tier[3] and self.tier[3].Dropdown then
			self.tier[3].Dropdown(mog.active,tier);
		end
	elseif self.tier[2] == "useModel" then
		mog:CreateuseModelMenu(self, tier, setDisplayModel, mog.displayuseModel)
	elseif self.tier[2] == "weaponEnchant" then
		if tier == 2 then
			local info = UIDropDownMenu_CreateInfo();
			info.text = NONE;
			info.func = setWeaponEnchant;
			info.arg1 = nil;
			info.checked = mog.weaponEnchant == nil;
			info.keepShownOnClick = true;
			self:AddButton(info, tier);
			
			for i, enchantCategory in ipairs(mog.enchants) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = enchantCategory.name;
				info.value = enchantCategory;
				info.notCheckable = true;
				info.hasArrow = true;
				info.keepShownOnClick = true;
				self:AddButton(info, tier);
			end
		elseif tier == 3 then
			for i, enchant in ipairs(self.tier[3]) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = enchant.name;
				info.func = setWeaponEnchant;
				info.arg1 = enchant.id;
				info.checked = mog.weaponEnchant == enchant.id;
				info.keepShownOnClick = true;
				self:AddButton(info, tier);
			end
		end
	elseif self.tier[2] == "gridDress" then
		if tier == 2 then
			for k, v in pairs(dressOptions) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = v;
				info.value = k;
				info.func = setGridDress;
				info.checked = mog.db.profile.gridDress == k;
				info.keepShownOnClick = true;
				self:AddButton(info,tier);
			end
		end
	end
end);
mog.menu.catalogue:SetPoint("LEFT", mog.menu.modules, "RIGHT", 5, 0);
--//


--// Preview Menu
local function newPreview()
	mog:CreatePreview();
	ShowUIPanel(mog.view);
end

local function syncPreviews()
	mog.db.profile.sync = not mog.db.profile.sync;
end

mog.menu.preview = mog.menu:CreateMenu(L["Preview"], function(self, tier)
	if not mog.db.profile.singlePreview then
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["New Preview"];
		info.notCheckable = true;
		info.func = newPreview;
		UIDropDownMenu_AddButton(info,tier);
	end
	
	local info = UIDropDownMenu_CreateInfo();
	info.text = mog.view:IsShown() and L["Hide Previews"] or L["Show Previews"];
	info.notCheckable = true;
	info.func = mog.TogglePreview;
	UIDropDownMenu_AddButton(info,tier);
	
	local info = UIDropDownMenu_CreateInfo();
	info.text = L["Synchronize Positioning"];
	info.checked = mog.db.profile.sync;
	info.func = syncPreviews;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info,tier);
end);
mog.menu.preview:SetPoint("LEFT", mog.menu.catalogue, "RIGHT", 5, 0);
--//


--// Options Menu
function mog:ToggleOptions()
	if not mog.options then
		mog.createOptions();
	end
	InterfaceOptionsFrame_OpenToCategory(MogIt);
end

mog.menu.options = mog.menu:CreateMenu(L["Options"]);
mog.menu.options:SetScript("OnClick", mog.ToggleOptions);
mog.menu.options:SetPoint("LEFT", mog.menu.preview, "RIGHT", 5, 0);
--//

local help = mog.menu:CreateMenu(L["Help"])
-- help:SetNormalFontObject(GameFontHighlight)
help:SetPoint("LEFT", mog.menu.options, "RIGHT", 5, 0)
help:SetScript("OnClick", nil);
help:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(L["How to use"]);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["Model controls"]);
	GameTooltip:AddLine(L["Left click and drag horizontally to rotate"], 1, 1, 1);
	GameTooltip:AddLine(L["Left click and drag vertically to zoom"], 1, 1, 1);
	GameTooltip:AddLine(L["Right click and drag to move"], 1, 1, 1);
	local info = mog.active and mog.active.Help
	if info then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(L["Module controls"]);
		for i, v in ipairs(info) do
			GameTooltip:AddLine(v, 1, 1, 1);
		end
	end
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("Alt + Mouseover item = GameTooltip");
	GameTooltip:Show()
	self.nt:SetTexture(1, 0.82, 0, 1);
end);
help:SetScript("OnLeave", function(self)
	GameTooltip_Hide()
	self.nt:SetTexture(0, 0, 0, 0);
end);


--// Default Indicators
mog:CreateIndicator("label", function(model)
	local label = model:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3");
	label:SetPoint("TOPLEFT", 12, -12);
	label:SetPoint("BOTTOMRIGHT", -12, 12);
	label:SetJustifyV("BOTTOM");
	label:SetJustifyH("CENTER");
	label:SetNonSpaceWrap(true);
	return label;
end)

mog:CreateIndicator("hasItem", function(model)
	local hasItem = model:CreateTexture(nil, "OVERLAY");
	hasItem:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");
	hasItem:SetSize(32, 32);
	hasItem:SetPoint("BOTTOMRIGHT", -8, 8);
	return hasItem;
end)

mog:CreateIndicator("wishlist", function(model)
	local wishlist = model:CreateTexture(nil, "OVERLAY");
	wishlist:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
	wishlist:SetSize(32, 32);
	wishlist:SetPoint("TOPRIGHT", -8, -8);
	return wishlist;
end)
--//