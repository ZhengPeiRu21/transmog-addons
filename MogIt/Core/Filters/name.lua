local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("name");
local name;

f:SetHeight(35);

f.label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.label:SetPoint("RIGHT",f,"RIGHT",0,0);
f.label:SetText(NAME..":");
f.label:SetJustifyH("LEFT");

f.edit = CreateFrame("EditBox","MogItFiltersName",f,"SearchBoxTemplate");
f.edit:SetHeight(16);
f.edit:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT",8,-5);
f.edit:SetPoint("RIGHT",f.label,"RIGHT",-2,0);
f.edit:SetAutoFocus(false);
--[[f.edit:SetScript("OnFocusGained",function(self)
	
end);--]]
f.edit:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.edit:SetScript("OnTextChanged",function(self,user)
	if user then
		name = self:GetText() or "";
		name = name:lower();
		mog:BuildList();
	end
end);
function f.edit.clearFunc(self)
	name = "";
	mog:BuildList();
end

function f.Filter(item)
	item = item or "";
	return (name == "") or (item:lower():find(name,nil,true));
end

function f.Default()
	name = "";
	f.edit:SetText(name);
end
f.Default();