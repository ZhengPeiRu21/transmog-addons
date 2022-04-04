local lib,old = LibStub:NewLibrary("LibAddonInfo-1.0",1);
if not lib then return end

local L = {};
local locale = GetLocale();
-- frFR
if locale == "frFR" then
	L["About"] = "à propos de";
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy";
-- deDE
elseif locale == "deDE" then
	L["About"] = "Über";
	L["Click and press Ctrl-C to copy"] = "Klicken und Strg-C drücken zum kopieren";
-- esES
elseif locale == "esES" then
	L["About"] = "Acerca de";
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy";
-- esMX
elseif locale == "esMX" then
	L["About"] = "Sobre";
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy";
-- koKR
elseif locale == "koKR" then
	L["About"] = "대하여";
	L["Click and press Ctrl-C to copy"] = "클릭 후 Ctrl-C 복사";
-- ruRU
elseif locale == "ruRU" then
	L["About"] = "Об аддоне";
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy";
-- zhCN
elseif locale == "zhCN" then
	L["About"] = "关于";
	L["Click and press Ctrl-C to copy"] = "点击并 Ctrl-C 复制";
-- zhTW
elseif locale == "zhTW" then
	L["About"] = "關於";
	L["Click and press Ctrl-C to copy"] = "左鍵點擊並按下 Ctrl-C 以複製字串";
-- enUS and non-localized
else
	L["About"] ="About";
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy";
end

function lib:CreateFrame(addon,parent,path)
	local frame = CreateFrame("Frame",nil,UIParent);
	frame:Hide();
	frame.addon = addon:gsub(" ","");	
	frame.name = parent and L["About"] or frame.addon;
	frame.parent = parent;
	frame.path = path;
	InterfaceOptions_AddCategory(frame);
	
	lib:CreateLayout(frame);
	return frame;
end

local editbox = CreateFrame('EditBox',nil,UIParent);
editbox:Hide();
editbox:SetAutoFocus(true);
editbox:SetHeight(32);
editbox:SetFontObject('GameFontHighlightSmall');

local left = editbox:CreateTexture(nil,"BACKGROUND");
left:SetSize(8,20);
left:SetPoint("LEFT",-5,0);
left:SetTexture("Interface\\Common\\Common-Input-Border");
left:SetTexCoord(0,0.0625,0,0.625);

local right = editbox:CreateTexture(nil,"BACKGROUND");
right:SetSize(8,20);
right:SetPoint("RIGHT",0,0);
right:SetTexture("Interface\\Common\\Common-Input-Border");
right:SetTexCoord(0.9375,1,0,0.625);

local center = editbox:CreateTexture(nil,"BACKGROUND");
center:SetHeight(20);
center:SetPoint("RIGHT",right,"LEFT",0,0);
center:SetPoint("LEFT",left,"RIGHT",0,0);
center:SetTexture("Interface\\Common\\Common-Input-Border");
center:SetTexCoord(0.0625,0.9375,0,0.625);

editbox:SetScript("OnEscapePressed",editbox.ClearFocus);
editbox:SetScript("OnEnterPressed",editbox.ClearFocus);
editbox:SetScript("OnEditFocusLost",editbox.Hide);
editbox:SetScript("OnEditFocusGained",editbox.HighlightText);
editbox:SetScript("OnTextChanged",function(self)
	self:SetText(self:GetParent().value);
	self:HighlightText();
end);

local function EditBoxEnter(self)
	GameTooltip:SetOwner(self,"ANCHOR_TOPRIGHT");
	GameTooltip:SetText(L["Click and press Ctrl-C to copy"]);
end

local function EditBoxLeave()
	GameTooltip:Hide();
end

local function EditBoxShow(self)
	editbox:SetText(self.value);
	editbox:SetParent(self);
	editbox:SetPoint("LEFT",self);
	editbox:SetPoint("RIGHT",self);
	editbox:Show();
end

local fields = {"Version", "Author", "X-Category", "X-License", "X-Email", "Email", "eMail", "X-Website", "X-Credits", "X-Localizations", "X-Donate"};
local haseditbox = {["X-Website"] = true, ["X-Email"] = true, ["Email"] = true, ["eMail"] = true, ["X-Donate"] = true};

local path;
local flags = {
	["enus"] = "English",
	["frfr"] = "French",
	["dede"] = "German",
	["eses"] = "Spanish",
	["esmx"] = "Latin American Spanish",
	["ruru"] = "Russian",
	["kokr"] = "Korean",
	["zhcn"] = "Simplified Chinese",
	["zhtw"] = "Traditional Chinese",
	["ptbr"] = "Brazilian Portuguese",
	["itit"] = "Italian",
};
local function FormatLocale(newline,str)
	local output;
	local flag = str:lower();
	if flags[flag] then
		if path then
			output = "|T"..path.."\\"..flag..":16|t ";
		else
			output = "";
		end
		output = output..flags[flag];
	end
	return (newline > "" and "\n" or "")..(output or str);
end

function lib:CreateLayout(frame)
	frame.title = frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge");
	frame.title:SetPoint("TOPLEFT",16,-16)
	frame.title:SetText(frame.name);
	
	local notes = "Notes";
	if (locale ~= "enUS") then
		notes = notes.."-"..locale;
	end
	notes = GetAddOnMetadata(frame.addon,notes) or GetAddOnMetadata(frame.addon,"Notes");
	frame.notes = frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
	frame.notes:SetHeight(32);
	frame.notes:SetPoint("TOPLEFT",frame.title,"BOTTOMLEFT",0,-8);
	frame.notes:SetPoint("RIGHT",frame,-32,0);
	frame.notes:SetNonSpaceWrap(true);
	frame.notes:SetJustifyH("LEFT");
	frame.notes:SetJustifyV("TOP");
	frame.notes:SetText(notes or "");
	
	frame.label = {};
	frame.info = {};
	
	local anchor;
	for _,field in ipairs(fields) do
		local value = GetAddOnMetadata(frame.addon,field);
		if value then
			frame.label[field] = frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
			frame.label[field]:SetWidth(75);
			frame.label[field]:SetJustifyH("RIGHT");
			frame.label[field]:SetText(field:gsub("X%-",""));
			if not anchor then
				frame.label[field]:SetPoint("TOPLEFT",frame.notes,"BOTTOMLEFT",-2,-12);
			else
				frame.label[field]:SetPoint("TOPRIGHT",anchor,"BOTTOMLEFT",-4,-10);
			end

			frame.info[field] = frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
			frame.info[field]:SetPoint("TOPLEFT",frame.label[field],"TOPRIGHT",4,0);
			frame.info[field]:SetPoint("RIGHT",frame,-16,0);
			frame.info[field]:SetJustifyH("LEFT");
			frame.info[field]:SetJustifyV("TOP");
			frame.info[field]:SetNonSpaceWrap(true);
			
			value = value:gsub("^%s*","");
			value = value:gsub("%s*$","");
			if field == "Author" then
				value = value:gsub("%s*[,&]%s*","\n");
			elseif field == "Version" then
				value = value:gsub("@project.revision@","Repository");
			elseif field == "X-Localizations" then
				path = frame.path;
				value = value:gsub("(,?)%s*([^,]+)%s*",FormatLocale);
				--value = value:gsub("%s*[,]%s*","\n");
			end
			value = (haseditbox[field] and "|cff9999ff" or "")..value;
			frame.info[field]:SetText(value);
			
			if haseditbox[field] then
				local button = CreateFrame("Button",nil,frame);
				button:SetAllPoints(frame.info[field]);
				button.value = value;
				button:SetScript("OnClick",EditBoxShow);
				button:SetScript("OnEnter",EditBoxEnter);
				button:SetScript("OnLeave",EditBoxLeave);
			end

			anchor = frame.info[field];
		end
	end
end






-- make work for 2nd pass layout
-- make work for frame as input in create
-- custom fields
-- function/str for fields and/or editboxes

