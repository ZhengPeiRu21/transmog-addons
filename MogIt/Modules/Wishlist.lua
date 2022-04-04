local MogIt, mog = ...
local L = mog.L

local wishlist = mog:RegisterModule("Wishlist", mog.moduleVersion)
mog.wishlist = wishlist
wishlist.base = true

local function convertBowSlots()
	for i, set in ipairs(wishlist.db.profile.sets) do
		local offhand = set.items["SecondaryHandSlot"]
		local item = offhand and (select(9,GetItemInfo(offhand)))
		if item and (item.invType == "INVTYPE_RANGED" or item.invType == "INVTYPE_THROWN") then
			set.items["MainHandSlot"] = offhand
			set.items["SecondaryHandSlot"] = nil
		end
	end
end

--mog:AddItemCacheCallback("convertBowSlots", convertBowSlots)

local function onProfileUpdated(self, event)
	mog:BuildList(true, "Wishlist")
end

local defaults = {
	profile = {
		items = {},
		sets = {},
	}
}

function wishlist:MogItLoaded()
	local db = LibStub("AceDB-3.0"):New("MogItWishlist", defaults)
	self.db = db
	
	-- add alternate items table to sets
	for i, set in ipairs(db.profile.sets) do
		set.alternateItems = set.alternateItems or {}
	end
	
	-- convert all bows into main hand instead of off hand
	convertBowSlots()
	
	db.RegisterCallback(self, "OnProfileChanged", onProfileUpdated)
	db.RegisterCallback(self, "OnProfileCopied", onProfileUpdated)
	db.RegisterCallback(self, "OnProfileReset", onProfileUpdated)
end

local function setModule(self)
	mog:SetModule(wishlist, L["Wishlist"])
end

local function newSetOnClick(self)
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET")
	CloseDropDownMenus()
end

local setMenu = {
	{
		text = L["Rename set"],
		func = function(self)
			wishlist:RenameSet(self.value)
			CloseDropDownMenus()
		end,
	},
	{
		text = L["Delete set"],
		func = function(self)
			wishlist:DeleteSet(self.value)
			CloseDropDownMenus()
		end,
	},
}

function wishlist:Dropdown(level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo()
		info.text = L["Wishlist"]
		info.value = self
		info.colorCode = YELLOW_FONT_COLOR_CODE
		info.notCheckable = true
		info.func = setModule
		UIDropDownMenu_AddButton(info, level)
	end
end

function wishlist:FrameUpdate(frame, value, index)
	local data = frame.data
	if type(value) == "table" then
		data.name = value.name
		data.items = value.items
		mog.Set_FrameUpdate(frame, data)
	else
		data.item = value
		if mog:HasItem(value) then
			frame:ShowIndicator("hasItem")
		end
		local displayIDs = mog:GetData("display", mog:GetData("item", value, "display"), "items")
		if displayIDs and #displayIDs > 1 then
			for i, item in ipairs(displayIDs) do
				if mog:HasItem(item) then
					frame:ShowIndicator("hasItem")
				end
			end
		end
		mog.Item_FrameUpdate(frame, data)
	end
end

function wishlist:OnEnter(frame, value)
	if type(value) == "table" then
		mog.ShowSetTooltip(frame, value.items, value.name)
	else
		mog.ShowItemTooltip(frame, value, mog:GetData("display", mog:GetData("item", value, "display"), "items"))
	end
end

function wishlist:OnClick(frame, button, value)
	if type(value) == "table" then
		mog.Set_OnClick(frame, button, frame.data, true)
	else
		mog.Item_OnClick(frame, button, frame.data, true)
	end
end

local function sortAlpha(a, b)
	return a.name < b.name
end

local list = {}

function wishlist:BuildList()
	wipe(list)
	local db = self.db.profile
	for i, v in ipairs(db.sets) do
		list[#list + 1] = v
	end
	if mog.db.profile.sortWishlist then
		sort(list, sortAlpha)
	end
	for i, v in ipairs(db.items) do
		list[#list + 1] = v
	end
	return list
end

wishlist.Help = {
	L["Right click for additional options"],
	L["Shift-left click to link"],
	L["Shift-right click for item URL"],
	L["Ctrl-left click to try on in dressing room"],
	L["Ctrl-right click to preview with MogIt"],
}

local t = {}

-- returns a sorted array of existing wishlist profiles
function wishlist:GetProfiles()
	self.db:GetProfiles(t)
	sort(t)
	return t
end

function wishlist:GetCurrentProfile()
	return self.db:GetCurrentProfile()
end

function wishlist:AddItem(itemID, setName, slot, isAlternate)
	-- don't add single items that are already on the wishlist
	if not setName and self:IsItemInWishlist(itemID, true) then
		return false
	end
	-- if a valid set name was provided, the item is supposed to go into the set, otherwise be added as a single item
	local set = self:GetSet(setName)
	if set then
		slot = slot or mog.slotsType[select(9, GetItemInfo(itemID))]
		if isAlternate then
			local altItems = set.alternateItems[slot] or {}
			set.alternateItems[slot] = altItems
			tinsert(altItems, itemID)
		else
			set.items[slot] = itemID
		end
	else
		tinsert(self.db.profile.items, itemID)
	end
	return true
end

-- deletes an item from the database
-- if setName not provided, will look for a single item
-- if isAlternate is not true, will look among the primary items
function wishlist:DeleteItem(itemID, setName, isAlternate)
	if setName then
		local set = assert(self:GetSet(setName), format("Set '%s' does not exist.", setName))
		if isAlternate then
			for slot, items in pairs(set.alternateItems) do
				for i, item in ipairs(items) do
					if item == itemID then
						tremove(items, i)
						if #items == 0 then
							set.alternateItems[slot] = nil
						end
						return
					end
				end
			end
		else
			for slot, item in pairs(set.items) do
				if item == itemID then
					set.items[slot] = nil
					return slot
				end
			end
		end
	else
		local items = self.db.profile.items
		for i = 1, #items do
			local v = items[i]
			if v == itemID then
				tremove(items, i)
				break
			end
		end
	end
end

function wishlist:CreateSet(name)
	if self:GetSet(name) then
		return false
	end
	tinsert(self.db.profile.sets, {
		name = name,
		items = {},
		alternateItems = {},
	})
	return true
end

function wishlist:RenameSet(set)
	StaticPopup_Show("MOGIT_WISHLIST_RENAME_SET", nil, nil, self:GetSet(set))
end

function wishlist:DeleteSet(setName, noConfirm)
	if noConfirm then
		local sets = wishlist:GetSets()
		for i, set in ipairs(sets) do
			if set.name == setName then
				tremove(sets, i)
				break
			end
		end
		mog:BuildList(nil, "Wishlist")
	else
		StaticPopup_Show("MOGIT_WISHLIST_DELETE_SET", setName, nil, setName)
	end
end

local function tableFind(tbl, value, token)
	for i, v in pairs(tbl) do
		if v == value or (token and token[v]) then
			return true
		end
	end
end

function wishlist:IsItemInWishlist(itemID, noSet)
	local token = mog.tokens[itemID]
	if tableFind(self.db.profile.items, itemID, token) then return true end
	if not noSet then
		for i, set in ipairs(self:GetSets()) do
			if tableFind(set.items, itemID, token) then return true end
			for slot, items in pairs(set.alternateItems) do
				if tableFind(items, itemID, token) then return true end
			end
		end
	end
	return false
end

function wishlist:GetSets(profile)
	if profile then
		assert(self.db.profiles[profile], format("Profile '%s' does not exist.", profile))
		return self.db.profiles[profile].sets
	else
		return self.db.profile.sets
	end
end

function wishlist:GetSet(name, profile)
	for i, set in ipairs(self:GetSets(profile)) do
		if set.name == name then
			return set
		end
	end
end

function wishlist:GetSetItems(setName, profile)
	return self:GetSet(setName, profile).items
end

local setFuncs = {
	addItem = function(self, set, item)
		if wishlist:AddItem(item, set, select(9, GetItemInfo(item)) == "INVTYPE_WEAPON" and IsShiftKeyDown() and "SecondaryHandSlot" or nil) then
			mog:BuildList(nil, "Wishlist")
		end
		CloseDropDownMenus()
	end,
}

function wishlist:AddSetMenuItems(level, func, arg2, profile)
	local sets = self:GetSets(profile)
	if not sets then
		return
	end
	
	local onehand
	if type(func) ~= "function" then
		func = setFuncs[func]
		if select(9, GetItemInfo(arg2)) == "INVTYPE_WEAPON" then
			onehand = true
		end
	end
	for i, set in ipairs(sets) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = set.name
		info.func = func
		info.notCheckable = true
		info.arg1 = set.name
		info.arg2 = arg2
		if onehand then
			info.tooltipTitle = "|cffffd200"..L["Shift-click to add to off hand"].."|r"
			info.tooltipOnButton = true
		end
		UIDropDownMenu_AddButton(info, level)
	end
end

do
	local function onAccept(self, data)
		local text = self.editBox:GetText()
		local create = wishlist:CreateSet(text)
		if not create then
			print("MogIt: A set with this name already exists.")
			return
		end
		if data then
			if type(data) == "table" then
				for slot, v in pairs(data.items) do
					wishlist:AddItem(v, text, slot)
				end
			else
				wishlist:AddItem(data, text)
			end
		end
		mog:BuildList(nil, "Wishlist")
	end

	StaticPopupDialogs["MOGIT_WISHLIST_CREATE_SET"] = {
		text = L["Enter set name"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = true,
		OnAccept = onAccept,
		EditBoxOnEnterPressed = function(self, data)
			local parent = self:GetParent()
			onAccept(parent, data)
			parent:Hide()
		end,
		OnShow = function(self)
			self.editBox:SetText("Set "..(#wishlist:GetSets() + 1))
			self.editBox:HighlightText()
		end,
		whileDead = true,
		timeout = 0,
	}
end

do
	local function onAccept(self, data)
		local text = self.editBox:GetText()
		local set = wishlist:GetSet(text)
		if set then
			print("MogIt: A set with this name already exists.")
			return
		end
		data.name = text
		mog:BuildList(nil, "Wishlist")
	end
	
	StaticPopupDialogs["MOGIT_WISHLIST_RENAME_SET"] = {
		text = L["Enter new set name"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = true,
		OnAccept = onAccept,
		EditBoxOnEnterPressed = function(self, data)
			local parent = self:GetParent()
			onAccept(parent, data)
			parent:Hide()
		end,
		OnShow = function(self, data)
			self.editBox:SetText(data.name)
			self.editBox:HighlightText()
		end,
		whileDead = true,
		timeout = 0,
	}
end

StaticPopupDialogs["MOGIT_WISHLIST_DELETE_SET"] = {
	text = L["Delete set '%s'?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		wishlist:DeleteSet(data, true)
	end,
	whileDead = true,
	timeout = 0,
}

StaticPopupDialogs["MOGIT_WISHLIST_OVERWRITE_SET"] = {
	text = L["Overwrite set '%s'?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		-- first clear all items since every slot might not be used
		wipe(wishlist:GetSet(data.name).items)
		for slot, v in pairs(data.items) do
			wishlist:AddItem(v, data.name, slot)
		end
		mog:BuildList(nil, "Wishlist")
	end,
	whileDead = true,
	timeout = 0,
}