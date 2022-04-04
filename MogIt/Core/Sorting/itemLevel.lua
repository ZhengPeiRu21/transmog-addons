local MogIt,mog = ...;
local L = mog.L;

local function dropdownTier1(self)
	mog:SortList("itemLevel");
end

local function itemLevelSort(a, b)
	return mog:GetData("item", a[1], "itemLevel") > mog:GetData("item", b[1], "itemLevel");
end

mog:CreateSort("itemLevel",{
	label = L["Item Level"],
	Dropdown = function(dropdown,module,tier)
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Item Level"];
		info.value = "itemLevel";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "itemLevel";
		dropdown:AddButton(info,tier);
	end,
	Sort = function(args)
		table.sort(mog.list, itemLevelSort);
	end,
});