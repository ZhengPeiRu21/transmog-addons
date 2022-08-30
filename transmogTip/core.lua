local select, UnitBuff, UnitDebuff, UnitAura, tonumber, strfind, hooksecurefunc =
	select, UnitBuff, UnitDebuff, UnitAura, tonumber, strfind, hooksecurefunc

local function addLine(self,id)
	self:AddLine("|cfff194f7New Appearance")
	self:Show()
end
-- Item Hooks -----------------------------------------------------------------
hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if id then addLine(ItemRefTooltip,id) end
end)

local function attachItemTooltip(self)
	local link = select(2,self:GetItem())
	if not link then return end
	local id = select(3,strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)"))
	itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(id)
	if itemEquipLoc == "INVTYPE_AMMO" or itemEquipLoc == "INVTYPE_NECK" or itemEquipLoc == "INVTYPE_FINGER" or itemEquipLoc == "INVTYPE_TRINKET" or itemEquipLoc == "INVTYPE_BAG" or itemEquipLoc == "INVTYPE_QUIVER" or tContains(TransmogTipList, tonumber(id)) then 
    return
  end
	if IsEquippableItem(id) then 
    addLine(self,id,true)
  end
end

function getItemIdFromLink(link)
end


local TransmogTip = CreateFrame("Frame")
TransmogTip:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
TransmogTip:RegisterEvent("ADDON_LOADED")
TransmogTip:SetScript("OnEvent", function(self, event, arg1, ...) onEvent(self, event, arg1, ...) end);

function onEvent(self, event, arg1, ...)
  if event == "ADDON_LOADED" then
    if TransmogTipList == nill then
      TransmogTipList = {}
    end
  end
  if event== "PLAYER_EQUIPMENT_CHANGED" then
    itemID = GetInventoryItemID("player", arg1)
    if itemID then
      if not tContains(TransmogTipList, itemID) then
        table.insert(TransmogTipList, itemID)
      end
    end
  end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg, ...)
  if msg:find("TRANSMOG_SYNC:") then
    itemIDStr = string.gsub(msg, "TRANSMOG_SYNC:", "")
    itemID = tonumber(itemIDStr)
    if not tContains(TransmogTipList, itemID) then
      table.insert(TransmogTipList, itemID)
    end
    return true
  end
end)
GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
