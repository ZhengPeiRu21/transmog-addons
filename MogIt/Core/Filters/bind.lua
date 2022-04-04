local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("bind");
local selected;
local num;
local all;

f:SetHeight(41);

f.bind = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.bind:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.bind:SetPoint("RIGHT",f,"RIGHT",0,0);
f.bind:SetText(L["Bind"]..":");
f.bind:SetJustifyH("LEFT");

f.dd = CreateFrame("Frame","MogItFiltersBindDropdown",f,"UIDropDownMenuTemplate");
f.dd:SetPoint("TOPLEFT",f.bind,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(f.dd,125);
UIDropDownMenu_SetButtonWidth(f.dd,140);
UIDropDownMenu_JustifyText(f.dd,"LEFT");

function f.dd.SelectAll(self)
	num = 0;
	for k,v in ipairs(L.bind) do
		selected[k] = all;
		num = num + (all and 1 or 0);
	end
	all = not all;
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
	ToggleDropDownMenu(1,nil,f.dd);
	mog:BuildList();
end

function f.dd.Tier1(self)
	if selected[self.value] and (not self.checked) then
		num = num - 1;
	elseif (not selected[self.value]) and self.checked then
		num = num + 1;
	end
	selected[self.value] = self.checked;
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
	mog:BuildList();
end

function f.dd.initialize(self)
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	all and L["Select All"] or L["Select None"];
	info.func = f.dd.SelectAll;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	
	for k,v in ipairs(L.bind) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.value = k;
		info.func = f.dd.Tier1;
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = selected[k];
		UIDropDownMenu_AddButton(info);
	end
end

function f.Filter(bind)
	return ((not bind) and selected[1]) or selected[bind];
end

function f.Default()
	selected = {};
	num = 0;
	all = nil;
	for k,v in ipairs(L.bind) do
		selected[k] = true;
		num = num + 1;
	end
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
end
f.Default();