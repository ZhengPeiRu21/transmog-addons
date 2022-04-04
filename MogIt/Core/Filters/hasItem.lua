local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("hasItem");
local enabled;

f:SetHeight(41);

f.label = f:CreateFontString(nil,nil,"GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT");
f.label:SetPoint("RIGHT");
f.label:SetText(L["Owned items"]..":");
f.label:SetJustifyH("LEFT");

f.hasItem = CreateFrame("CheckButton","MogItCoreFiltersHasItem",f,"UICheckButtonTemplate");
f.hasItem.text = MogItCoreFiltersHasItemText
f.hasItem.text:SetText(L["Only items you own"]);
f.hasItem:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT");
f.hasItem:SetScript("OnClick",function(self)
	enabled = self:GetChecked() == 1;
	mog:BuildList();
end);

function f.Filter(itemID)
	return not enabled or mog:HasItem(itemID);
end

function f.Default()
	f.hasItem:SetChecked(false);
	enabled = false;
end
f.Default();