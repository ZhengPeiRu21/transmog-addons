local MAJOR, MINOR = "LibItemInfo-1.0", 3
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local GetItemInfo = GetItemInfo
local rawget = rawget
local type = type
local tonumber = tonumber
local strmatch = strmatch

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

lib.cache = lib.cache or {}
lib.queue = lib.queue or {}

setmetatable(lib, {__index = lib.cache})

local function onUpdate(self)
	for itemID in pairs(lib.queue) do
		if lib.cache[itemID] then
			-- lib.callbacks:Fire("OnItemInfoReceived", itemID)
			lib.queue[itemID] = nil
		end
	end
	lib.callbacks:Fire("OnItemInfoReceivedBatch")
	if not next(lib.queue) then
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
		self:Hide()
	end
end

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:SetScript("OnEvent", lib.frame.Show)
lib.frame:SetScript("OnUpdate", onUpdate)
lib.frame:Hide()

setmetatable(lib.cache, {
	__index = function(self, item)
		local itemID = item
		if type(item) == "string" then
			itemID = strmatch(item, "item:(%d+)")
			if not itemID then return end
			itemID = tonumber(itemID)
			if rawget(self, itemID) then
				self[item] = self[itemID]
				return self[itemID]
			end
		end
		local name, link, quality, itemLevel, reqLevel, class, subClass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID)
		if not name then
			lib.queue[itemID] = true
			lib.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
			return
		end
		local itemInfo = {
			name = name,
			quality = quality,
			itemLevel = itemLevel,
			reqLevel = reqLevel,
			type = class,
			subType = subClass,
			invType = equipSlot,
			stackSize = maxStack,
		}
		self[item] = itemInfo
		self[itemID] = itemInfo
		return itemInfo
	end,
})