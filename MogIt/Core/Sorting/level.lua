local MogIt, mog = ...;
local L = mog.L;

local itemCache = {};

local function minItem(items)
	local minLevel
	for i, v in ipairs(items) do
		local reqLevel = itemCache[v] or mog:GetData("item", v, "level");
		if reqLevel then
			itemCache[v] = reqLevel;
			minLevel = min(reqLevel, minLevel or reqLevel);
		end
	end
	return minLevel or 0;
end

local function dropdownTier1(self)
	mog:SortList("level");
end

local function levelSort(a, b)
	local aLv, bLv = minItem(a), minItem(b);
	if aLv == bLv then
		return mog:GetData("item", a[1], "id") > mog:GetData("item", b[1], "id");
	else
		return aLv > bLv;
	end
end

mog:CreateSort("level", {
	label = LEVEL,
	Dropdown = function(dropdown,module,tier)
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = LEVEL;
		info.value = "level";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "level";
		dropdown:AddButton(info, tier);
	end,
	Sort = function()
		table.sort(mog.list, levelSort);
	end,
});