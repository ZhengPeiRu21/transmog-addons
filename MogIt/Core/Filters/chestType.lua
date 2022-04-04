local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("chestType");
local selected;

f:SetHeight(41);
f.slot = "Chest";

f.chestType = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.chestType:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.chestType:SetPoint("RIGHT",f,"RIGHT",0,0);
f.chestType:SetText(L["Chest type"]..":");
f.chestType:SetJustifyH("LEFT");

local function onClick(self, invType)
	selected = invType;
	f.dd:SetText(self.value);
	mog:BuildList();
end

local labels = {
	L["Any"],
	L["Tunic"],
	L["Robe"],
}

local invTypes = {
	nil,
	"INVTYPE_CHEST",
	"INVTYPE_ROBE",
}

f.dd = mog:CreateDropdown("Frame", f);
f.dd:SetPoint("TOPLEFT",f.chestType,"BOTTOMLEFT",-16,-2);
f.dd:SetWidth(125);
f.dd:SetButtonWidth(140);
f.dd:JustifyText("LEFT");
f.dd.initialize = function(self)
	for i,v in ipairs(labels) do
		local info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.func = onClick;
		info.arg1 = invTypes[i]
		info.checked = invTypes[i] == selected;
		UIDropDownMenu_AddButton(info);
	end
end

function f.Filter(item)
	if not selected then
		return true;
	end
	local item = mog:GetItemInfo(item, "BuildList");
	return not item or selected == item.invType;
end

function f.Default()
	selected = nil;
	f.dd:SetText(L["Any"]);
end
f.Default();