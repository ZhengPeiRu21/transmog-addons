local MogIt,mog = ...;
local L = mog.L;

mog.base = {};
local LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();
local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local tinsert = table.insert;
local sort = table.sort;
local ipairs = ipairs;
local select = select;


--// Input Functions
function mog.base.AddSlot(slot,addon)
	local module = mog:GetModule(addon);
	if not module.slots[slot] then
		module.slots[slot] = {
			label = LBI[slot] or slot,
			list = {},
		};
		tinsert(module.slotList,slot);
	end
	local list = module.slots[slot].list;
	
	return function(id,display,itemname,itemLevel,quality,lvl,faction,class,bind,slot,sheath,source,sourceid,zone,sourceinfo)
		tinsert(list,id);
		mog:AddData("item", id, "id", id);
		mog:AddData("item", id, "display", display);
		mog:AddData("item", id, "itemname", itemname);
		mog:AddData("item", id, "itemLevel", itemLevel);
		mog:AddData("item", id, "quality", quality);
		mog:AddData("item", id, "level", lvl);
		mog:AddData("item", id, "faction", faction);
		mog:AddData("item", id, "class", class);
		mog:AddData("item", id, "bind", bind);
		mog:AddData("item", id, "slot", slot);
		mog:AddData("item", id, "sheath", sheath);
		mog:AddData("item", id, "source", source);
		mog:AddData("item", id, "sourceid", sourceid);
		mog:AddData("item", id, "sourceinfo", sourceinfo);
		mog:AddData("item", id, "zone", zone);
		tinsert(mog:GetData("display",display,"items") or mog:AddData("display",display,"items",{}),id);
	end
end

function mog.base.AddColours(display,c1,c2,c3)
	--mog:AddData("display",display,"colours",colours);
	mog:AddData("display",display,"colour1",c1);
	mog:AddData("display",display,"colour2",c2);
	mog:AddData("display",display,"colour3",c3);
end

function mog.base.AddNPC(id,name)
	mog:AddData("npc", id, "name", LBB[name] or name);
end

--[=[
function mog.base.AddObject(id,name)
	mog:AddData("object", id, "name", LBB[name] or name);
end
--]=]
--//


--// Base Functions
local list = {};

function mog.base.DropdownTier1(self)
	if self.value.loaded then
		self.value.active = nil;
		mog:SetModule(self.value,self.value.label);
	else
		LoadAddOn(self.value.name);
	end
end

function mog.base.DropdownTier2(self)
	self.arg1.active = self.value;
	mog:SetModule(self.arg1,self.arg1.label.." - "..self.value.label);
	CloseDropDownMenus();
end

function mog.base.Dropdown(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.hasArrow = module.loaded;
		info.keepShownOnClick = not module.loaded;
		info.notCheckable = true;
		info.func = mog.base.DropdownTier1;
		UIDropDownMenu_AddButton(info,tier);
	elseif tier == 2 then
		for _,slot in ipairs(module.slotList) do
			info = UIDropDownMenu_CreateInfo();
			info.text = module.slots[slot].label;
			info.value = module.slots[slot];
			info.notCheckable = true;
			info.func = mog.base.DropdownTier2;
			info.arg1 = module;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

function mog.base:FrameUpdate(frame, value)
	frame.data.items = value;
	frame.data.cycle = 1;
	frame.data.item = value[frame.data.cycle];
	for i, item in ipairs(value) do
		if mog:HasItem(item) then
			frame:ShowIndicator("hasItem");
		end
		if mog.wishlist:IsItemInWishlist(item) then
			frame:ShowIndicator("wishlist");
		end
	end
	mog.Item_FrameUpdate(frame, frame.data);
end

function mog.base:OnEnter(frame, value)
	local data = frame.data;
	mog.ShowItemTooltip(frame, data.item, data.items, data.cycle);
end

function mog.base:OnClick(frame, btn, value)
	mog.Item_OnClick(frame, btn, frame.data);
end

function mog.base.Unlist(module)
	wipe(list);
end

local function itemSort(a, b)
	local aLevel = mog:GetData("item", a, "level") or 0;
	local bLevel = mog:GetData("item", b, "level") or 0;
	if aLevel == bLevel then
		return a < b;
	else
		return aLevel < bLevel;
	end
end

local function buildList(module, slot, list, items)
	for _, item in ipairs(slot) do
		if mog:CheckFilters(module,item) then
			local display = mog:GetData("item", item, "display");
			if not items[display] then
				items[display] = {};
				tinsert(list, items[display]);
			end
			tinsert(items[display], item);
		end
	end
end

function mog.base.BuildList(module)
	wipe(list);
	local items = {};
	if module.active then
		buildList(module, module.active.list, list, items);
	else
		for _, data in pairs(module.slots) do
			buildList(module, data.list, list, items);
		end
	end
	for _,tbl in ipairs(list) do
		sort(tbl, itemSort);
	end
	items = nil;
	return list;
end

mog.base.Help = {
	L["Left click to cycle through items"],
	L["Right click for additional options"],
	L["Shift-left click to link"],
	L["Shift-right click for item URL"],
	L["Ctrl-left click to try on in dressing room"],
	L["Ctrl-right click to preview with MogIt"],
}

function mog.base.GetFilterArgs(filter,item)
	if filter == "hasItem" or filter == "chestType" then
		return item;
	elseif filter == "name" then
		return GetItemInfo(item) or mog:GetData("item", item, "itemname");
	elseif filter == "itemLevel" then
		return select(4,GetItemInfo(item)) or mog:GetData("item", item, "itemLevel");
	elseif filter == "source" then
		return mog:GetData("item", item, "source"),mog:GetData("item", item, "sourceinfo");	
	else
		return mog:GetData("item", item, filter);
	end
end

function mog.base.SortLevel(items)
	return items;
end

function mog.base.SortColour(items)
	local display = mog:GetData("item", items[1], "display");
	return {mog:GetData("display", display, "colour1"), mog:GetData("display", display, "colour2"), mog:GetData("display", display, "colour3")};
	--return mog:GetData("display", display, "colours");
end
--//


--// Register Modules
local addons = {
	"MogIt_Cloth",
	"MogIt_Leather",
	"MogIt_Mail",
	"MogIt_Plate",
	"MogIt_OneHanded",
	"MogIt_TwoHanded",
	"MogIt_Ranged",
	"MogIt_Other",
	"MogIt_Accessories",
};

for _, addon in ipairs(addons) do
	local _, title, _, _, loadable = GetAddOnInfo(addon);
	if loadable then
		local module = mog:RegisterModule(addon, tonumber(GetAddOnMetadata(addon, "X-MogItModuleVersion")), {
			label = title:match("MogIt_(.+)") or title,
			base = true,
			slots = {},
			slotList = {},
			Dropdown = mog.base.Dropdown,
			BuildList = mog.base.BuildList,
			FrameUpdate = mog.base.FrameUpdate,
			OnEnter = mog.base.OnEnter,
			OnClick = mog.base.OnClick,
			Unlist = mog.base.Unlist,
			Help = mog.base.Help,
			GetFilterArgs = mog.base.GetFilterArgs,
			filters = {
				"name",
				"level",
				"itemLevel",
				"faction",
				"class",
				"source",
				"quality",
				"bind",
				"chestType",
				"sheath",
				(addon == "MogIt_OneHanded" and "slot") or nil,
			},
			sorting = {
				"level",
				"itemLevel",
				"display",
				"id",				
				"colour",
			},
			sorts = {
				level = mog.base.SortLevel,
				colour = mog.base.SortColour,
			},
		});
		-- dirty fix for now - if the "slot" filter is not present the array is broken unless we do this
		tinsert(module.filters, "hasItem");
	end
end
--//