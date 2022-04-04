local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("itemLevel");
local minlvl;
local maxlvl;

f:SetHeight(35);

f.label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.label:SetPoint("RIGHT",f,"RIGHT",0,0);
f.label:SetText("Item level"..":");
f.label:SetJustifyH("LEFT");

f.min = CreateFrame("EditBox","MogItFiltersItemLevelMin",f,"InputBoxTemplate");
f.min:SetSize(32,16);
f.min:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT",8,-5);
f.min:SetNumeric(true);
f.min:SetMaxLetters(3);
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

f.max = CreateFrame("EditBox","MogItFiltersItemLevelMax",f,"InputBoxTemplate");
f.max:SetSize(32,16);
f.max:SetPoint("LEFT",f.min,"RIGHT",12,0);
f.max:SetNumeric(true);
f.max:SetMaxLetters(3);
f.max:SetAutoFocus(false);
f.max:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.max:SetScript("OnTabPressed",function(self)
	f.min:SetFocus();
end);

f.max:SetScript("OnTextChanged",function(self,user)
	if user then
		maxlvl = self:GetNumber() or 0;
		mog:BuildList();
	end
end);

function f.Filter(lvl)
	local lvl = lvl or 0;
	return (minlvl <= 0 or lvl >= minlvl) and (maxlvl <= 0 or lvl <= maxlvl);
end

function f.Default()
	minlvl = 0;
	f.min:SetNumber(minlvl);
	maxlvl = 0;
	f.max:SetNumber(maxlvl);
end
f.Default();