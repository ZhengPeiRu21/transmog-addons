local MogIt,mog = ...;
local L = mog.L;

local function dropdownTier1(self)
	mog:SortList("display");
end

local function displayIDSort(a, b)
	return mog:GetData("item", a[1], "display") > mog:GetData("item", b[1], "display");
end

mog:CreateSort("display",{
	label = L["Display ID"],
	Dropdown = function(dropdown,module,tier)
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Display ID"];
		info.value = "display";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "display";
		dropdown:AddButton(info,tier);
	end,
	Sort = function(args)
		table.sort(mog.list, displayIDSort);
	end,
});