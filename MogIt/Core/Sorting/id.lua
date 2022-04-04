local MogIt,mog = ...;
local L = mog.L;

local function dropdownTier1(self)
	mog:SortList("id");
end

local function displayIDSort(a, b)
	return mog:GetData("item", a[1], "id") > mog:GetData("item", b[1], "id");
end

mog:CreateSort("id",{
	label = L["Item ID"],
	Dropdown = function(dropdown,module,tier)
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Item ID"];
		info.value = "id";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "id";
		dropdown:AddButton(info,tier);
	end,
	Sort = function(args)
		table.sort(mog.list, displayIDSort);
	end,
});