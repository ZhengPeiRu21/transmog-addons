local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("level");
local minlvl;
local maxlvl;

f:SetHeight(35);

f.label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.label:SetPoint("RIGHT",f,"RIGHT",0,0);
f.label:SetText(LEVEL_RANGE..":");
f.label:SetJustifyH("LEFT");

f.min = CreateFrame("EditBox","MogItFiltersLevelMin",f,"InputBoxTemplate");
f.min:SetSize(25,16);
f.min:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT",8,-5);
f.min:SetNumeric(true);
f.min:SetMaxLetters(2);
f.min:SetAutoFocus(false);
f.min:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.min:SetScript("OnTabPressed",function(self)
	f.max:SetFocus();
end);
f.min:SetScript("OnTextChanged",function(self,user)
	if user then
		minlvl = self:GetNumber() or 0;
		mog:BuildList();
	end
end);

f.dash = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.dash:SetPoint("LEFT",f.min,"RIGHT",0,1);
f.dash:SetText("-");

f.max = CreateFrame("EditBox","MogItFiltersLevelMax",f,"InputBoxTemplate");
f.max:SetSize(25,16);
f.max:SetPoint("LEFT",f.min,"RIGHT",12,0);
f.max:SetNumeric(true);
f.max:SetMaxLetters(2);
f.max:SetAutoFocus(false);
f.max:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.max:SetScript("OnTabPressed",function(self)
	f.min:SetFocus();
end);
f.max:SetScript("OnTextChanged",function(self,user)
	if user then
		maxlvl = self:GetNumber() or PLAYER_MAX_LEVEL;
		mog:BuildList();
	end
end);

function f.Filter(lvl)
	lvl = lvl or 0;
	return (lvl >= minlvl) and (lvl <= maxlvl);
end

function f.Default()
	minlvl = 0;
	f.min:SetNumber(minlvl);
	maxlvl = UnitLevel("PLAYER");
	f.max:SetNumber(maxlvl);
end
f.Default();


--[[
f.min:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
	minlvl = self:GetNumber() or 0;
	mog:BuildList();
end);
f.min:SetScript("OnEscapePressed",function(self)
	self:ClearFocus();
	self:SetNumber(minlvl);
end);
f.min:SetScript("OnTabPressed",function(self)
	f.max:SetFocus();
	minlvl = self:GetNumber() or 0;
	mog:BuildList();
end);

f.max:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
	maxlvl = self:GetNumber() or MAX_PLAYER_LEVEL;
	mog:BuildList();
end);
f.max:SetScript("OnEscapePressed",function(self)
	self:ClearFocus();
	self:SetNumber(maxlvl);
end);
f.max:SetScript("OnTabPressed",function(self)
	f.min:SetFocus();
	maxlvl = self:GetNumber() or MAX_PLAYER_LEVEL;
	mog:BuildList();
end);
--]]