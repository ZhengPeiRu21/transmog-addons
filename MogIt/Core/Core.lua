local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

local ItemInfo = LibStub("LibItemInfo-1.0");

LibStub("Libra"):EmbedWidgets(mog);

local character = DataStore_Containers and DataStore:GetCharacter();

mog.frame = CreateFrame("Frame","MogItFrame",UIParent,"ButtonFrameTemplate");
mog.list = {};

function mog:Error(msg)
	DEFAULT_CHAT_FRAME:AddMessage("MogIt: "..msg,0.9,0.5,0.9);
end

--// Slash Commands
function mog:ToggleFrame()
	ToggleFrame(mog.frame);
end

function mog:TogglePreview()
	ToggleFrame(mog.view);
end
--//


--// Bindings
SLASH_MOGIT1 = "/mog";
SLASH_MOGIT2 = "/mogit";
SlashCmdList["MOGIT"] = mog.ToggleFrame;

BINDING_HEADER_MogIt = "MogIt";
BINDING_NAME_MogIt = L["Toggle Mogit"];
BINDING_NAME_MogItPreview = L["Toggle Preview"];
--//


--// LibDataBroker
mog.LDBI = LibStub("LibDBIcon-1.0");
mog.mmb = LibStub("LibDataBroker-1.1"):NewDataObject("MogIt",{
	type = "launcher",
	icon = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	OnClick = function(self,btn)
		if btn == "RightButton" then
			mog:TogglePreview();
		else
			mog:ToggleFrame();
		end
	end,
	OnTooltipShow = function(self)
		if not self or not self.AddLine then return end
		self:AddLine("MogIt");
		self:AddLine(L["Left click to toggle MogIt"],1,1,1);
		self:AddLine(L["Right click to toggle the preview"],1,1,1);
	end,
});
--//


--// Module API
mog.moduleVersion = 2;
mog.modules = {};
mog.moduleList = {};

function mog:GetModule(name)
	return mog.modules[name];
end

function mog:GetActiveModule()
	return mog.active;
end

function mog:RegisterModule(name,version,data)
	if mog.modules[name] then
		--mog:Error(L["The \124cFFFFFFFF%s\124r module is already loaded."]:format(name));
		return mog.modules[name];
	elseif type(version) ~= "number" or version < mog.moduleVersion then
		mog:Error(L["The \124cFFFFFFFF%s\124r module needs to be updated to work with this version of MogIt."]:format(name));
		return;
	elseif version > mog.moduleVersion then
		mog:Error(L["The \124cFFFFFFFF%s\124r module requires you to update MogIt for it to work."]:format(name));
		return;
	end
	data = data or {};
	data.name = name;
	mog.modules[name] = data;
	table.insert(mog.moduleList,data);
	if mog.menu.active == mog.menu.modules then
		mog.menu:Rebuild(1);
	end
	return data;
end

function mog:SetModule(module,text)
	if mog.active and mog.active ~= module and mog.active.Unlist then
		mog.active:Unlist(module);
	end
	mog.active = module;
	mog:BuildList(true);
	mog:FilterUpdate();
	mog.frame.path:SetText(text or module.label or module.name or "");
end

function mog:BuildList(top,module)
	if (module and mog.active and mog.active.name ~= module) then return end;
	mog.list = mog.active and mog.active.BuildList and mog.active:BuildList() or {};
	mog:SortList(nil,true);
	mog.scroll:update(top and 1);
	mog.filt.models:SetText(#mog.list);
end
--//

--// Item Cache
local itemCacheCallbacks = {
	BuildList = mog.BuildList;
	ModelOnEnter = function()
		local owner = GameTooltip:GetOwner();
		if owner and GameTooltip[mog] then
			owner:OnEnter();
		end
	end,
	ItemMenu = function()
		mog.Item_Menu:Rebuild(1);
	end,
	SetMenu = function()
		mog.Set_Menu:Rebuild(1);
	end,
};

local pendingCallbacks = {};

for k in pairs(itemCacheCallbacks) do
	pendingCallbacks[k] = {};
end

function mog:AddItemCacheCallback(name, func)
	itemCacheCallbacks[name] = func;
	pendingCallbacks[name] = {};
end

function mog:GetItemInfo(id, type)
	if not type then return ItemInfo[id] end
	if ItemInfo[id] then
		-- clear pending items when they are cached
		pendingCallbacks[type][id] = nil;
		return ItemInfo[id];
	elseif itemCacheCallbacks[type] then
		-- add to pending items for this callback if not cached
		pendingCallbacks[type][id] = true;
	end
end

function mog.ItemInfoReceived()
	for k, callback in pairs(pendingCallbacks) do
		-- execute the callback if any items are pending for it
		if next(callback) then
			itemCacheCallbacks[k]();
		end
	end
end

ItemInfo.RegisterCallback(mog, "OnItemInfoReceivedBatch", "ItemInfoReceived");
--//

function mog:HasItem(itemID)
  return TransmogTipList and tContains(TransmogTipList, itemID)
	  -- return GetItemCount(itemID, true) > 0 or (character and select(3, DataStore:GetContainerItemCount(character, itemID)) > 0)
end


--// Events
local defaults = {
	profile = {
		sortWishlist = false,
		dressupPreview = false,
		singlePreview = false,
		previewUIPanel = false,
		previewFixedSize = false,
		noAnim = false,
		minimap = {},
		url = "Battle.net",
		
		point = "CENTER",
		gridWidth = 600,
		gridHeight = 400,
		rows = 2;
		columns = 3,
		gridDress = "preview",
		sync = true,
		previewProps = {
			["*"] = {
				w = 335,
				h = 385,
				point = "CENTER",
			}
		},
		
		tooltip = true,
		tooltipWidth = 300,
		tooltipHeight = 300,
		tooltipMouse = false,
		tooltipDress = false,
		tooltipRotate = true,
		tooltipMog = true,
		tooltipMod = "None",
		tooltipCustomModel = false,
	}
}

function mog.LoadSettings()
	mog:UpdateGUI();
	
	if mog.db.profile.minimap.hide then
		mog.LDBI:Hide("MogIt");
	else
		mog.LDBI:Show("MogIt");
	end
	
	mog.tooltip:SetSize(mog.db.profile.tooltipWidth, mog.db.profile.tooltipHeight);
	if mog.db.profile.tooltipRotate then mog.tooltip.rotate:Show() else mog.tooltip.rotate:Hide() end
	
	mog.scroll:update();
	
	mog:SetSinglePreview(mog.db.profile.singlePreview);
end

mog.frame:RegisterEvent("ADDON_LOADED");
mog.frame:RegisterEvent("PLAYER_LOGIN");
mog.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
mog.frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
mog.frame:SetScript("OnEvent", function(self, event, ...)
	return mog[event] and mog[event](mog, ...)
end);

function mog:ADDON_LOADED(addon)
	if addon == MogIt then
		local AceDB = LibStub("AceDB-3.0")
		mog.db = AceDB:New("MogItDB", defaults, true)
		mog.db.RegisterCallback(mog, "OnProfileChanged", "LoadSettings")
		mog.db.RegisterCallback(mog, "OnProfileCopied", "LoadSettings")
		mog.db.RegisterCallback(mog, "OnProfileReset", "LoadSettings")

		if not mog.db.global.version then
		end
		mog.db.global.version = GetAddOnMetadata(MogIt,"Version");
		
		mog.LDBI:Register("MogIt",mog.mmb,mog.db.profile.minimap);
		
		
		for name,module in pairs(mog.moduleList) do
			if module.MogItLoaded then
				module:MogItLoaded()
			end
		end
	elseif mog.modules[addon] then
		mog.modules[addon].loaded = true;
		if mog.menu.active == mog.menu.modules then
			mog.menu:Rebuild(1)
		end
	end
end

function mog:PLAYER_LOGIN()
	mog:LoadSettings()
	self.frame:SetScript("OnSizeChanged", function(self, width, height)
		mog.db.profile.gridWidth = width;
		mog.db.profile.gridHeight = height;
		mog:UpdateGUI(true);
	end)
end

function mog:PLAYER_EQUIPMENT_CHANGED(slot, hasItem)
	-- don't do anything if the slot is not visible (necklace, ring, trinket)
	if mog.db.profile.gridDress == "equipped" then
		for i, frame in ipairs(mog.models) do
			local item = frame.data.item
			if item then
				local slotName = mog.mogSlots[slot];
				if hasItem then
					if (slot ~= INVSLOT_HEAD or ShowingHelm()) and (slot ~= INVSLOT_BACK or ShowingCloak()) then
						frame:TryOn(mog.mogSlots[slot] and select(6, GetTransmogrifySlotInfo(slot)) or GetInventoryItemID("player", slot), slotName);
					end
				else
					frame:UndressSlot(slot);
				end
				frame:TryOn(item);
			end
		end
	end
end
--//


--// Data API
mog.data = {};

function mog:AddData(data,id,key,value)
	if not data and id and key then return end;
	if not mog.data[data] then
		mog.data[data] = {};
	end
	if not mog.data[data][key] then
		mog.data[data][key] = {};
	end
	mog.data[data][key][id] = value;
	return value;
end

function mog:DeleteData(data,id,key)
	if not mog.data[data] then return end;
	if id and key then
		mog.data[data][key][id] = nil;
	elseif id then
		for k,v in pairs(mog.data[data]) do
			v[id] = nil;
		end
	elseif key then
		mog.data[data][key] = nil;
	else
		mog.data[data] = nil;
	end
end

function mog:GetData(data,id,key)
	return mog.data[data] and mog.data[data][key] and mog.data[data][key][id];
end
--//


--// Slot Conversion
mog.slots = {
	"HeadSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
};

mog.slotsType = {
	INVTYPE_HEAD = "HeadSlot",
	INVTYPE_SHOULDER = "ShoulderSlot",
	INVTYPE_CLOAK = "BackSlot",
	INVTYPE_CHEST = "ChestSlot",
	INVTYPE_ROBE = "ChestSlot",
	INVTYPE_BODY = "ShirtSlot",
	INVTYPE_TABARD = "TabardSlot",
	INVTYPE_WRIST = "WristSlot",
	INVTYPE_HAND = "HandsSlot",
	INVTYPE_WAIST = "WaistSlot",
	INVTYPE_LEGS = "LegsSlot",
	INVTYPE_FEET = "FeetSlot",
	INVTYPE_2HWEAPON = "MainHandSlot",
	INVTYPE_WEAPON = "MainHandSlot",
	INVTYPE_WEAPONMAINHAND = "MainHandSlot",
	INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot",
	INVTYPE_RANGED = "MainHandSlot",
	INVTYPE_RANGEDRIGHT = "MainHandSlot",
	INVTYPE_SHIELD = "SecondaryHandSlot",
	INVTYPE_HOLDABLE = "SecondaryHandSlot",
	INVTYPE_THROWN = "MainHandSlot"
};

-- all slot IDs that can be transmogrified
mog.mogSlots = {
	[INVSLOT_HEAD] = "HeadSlot",
	[INVSLOT_SHOULDER] = "ShoulderSlot",
	[INVSLOT_BACK] = "BackSlot",
	[INVSLOT_CHEST] = "ChestSlot",
	[INVSLOT_BODY] = "ShirtSlot",
	[INVSLOT_TABARD] = "TabardSlot",
	[INVSLOT_WRIST] = "WristSlot",
	[INVSLOT_HAND] = "HandsSlot",
	[INVSLOT_WAIST] = "WaistSlot",
	[INVSLOT_LEGS] = "LegsSlot",
	[INVSLOT_FEET] = "FeetSlot",
	[INVSLOT_MAINHAND] = "MainHandSlot",
	[INVSLOT_OFFHAND] = "SecondaryHandSlot",
}

function mog:GetSlot(id)
	return mog.slots[id] or mog.slotsType[id];
end
--//
