local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("source");
local selected;
local sub;
local num;
local all;

f:SetHeight(41);

f.source = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.source:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.source:SetPoint("RIGHT",f,"RIGHT",0,0);
f.source:SetText(L["Source"]..":");
f.source:SetJustifyH("LEFT");

f.dd = CreateFrame("Frame","MogItFiltersSourceDropdown",f,"UIDropDownMenuTemplate");
f.dd:SetPoint("TOPLEFT",f.source,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(f.dd,125);
UIDropDownMenu_SetButtonWidth(f.dd,140);
UIDropDownMenu_JustifyText(f.dd,"LEFT");

function f.dd.SelectAll(self)
	num = 0;
	for k,v in ipairs(L.source) do
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

function f.dd.Tier2(self)
	sub[self.arg1][self.value] = self.checked;
	if selected[self.arg1] then
		mog:BuildList();
	end
end

function f.dd.initialize(self,tier)
	local info;
		if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text =	all and L["Select All"] or L["Select None"];
		info.func = f.dd.SelectAll;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
		
		for k,v in ipairs(L.source) do
			info = UIDropDownMenu_CreateInfo();
			info.text =	v;
			info.value = k;
			info.func = f.dd.Tier1;
			info.keepShownOnClick = true;
			info.isNotRadio = true;
			info.checked = selected[k];
			info.hasArrow = sub[k] and true;
			UIDropDownMenu_AddButton(info);
		end
	elseif tier == 2 then
		local parent = UIDROPDOWNMENU_MENU_VALUE;
		if parent == 1 then
			for k,v in ipairs(L.difficulties) do
				info = UIDropDownMenu_CreateInfo();
				info.text =	v;
				info.value = k;
				info.func = f.dd.Tier2;
				info.keepShownOnClick = true;
				info.isNotRadio = true;
				info.checked = sub[parent][k];
				info.arg1 = parent;
				UIDropDownMenu_AddButton(info,tier);
			end
		end
	end
end

function f.Filter(src1,sub1)
	if not src1 then
		return true;
	elseif selected[src1] then
		if src1 == 1 then
			if not sub1 then
				return sub[1][8];
			elseif sub1 == 7 then
				return sub[1][3] or sub[1][5];
			elseif sub1 == 8 then
				return sub[1][4] or sub[1][6];
			elseif sub1 == 9 then
				return sub[1][7];
			else
				return sub[1][sub1];
			end
		end
		return true;
	end
end

function f.Default()
	selected = {};
	sub = {
		[1] = {},
	};
	num = 0;
	all = nil;
	for k,v in ipairs(L.source) do
		selected[k] = true;
		num = num + 1;
	end
	for k,v in ipairs(L.difficulties) do
		sub[1][k] = true;
	end
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
end
f.Default();