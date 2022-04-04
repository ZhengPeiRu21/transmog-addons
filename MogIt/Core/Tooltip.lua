local MogIt,mog = ...;
local L = mog.L;

local IsDressableItem = IsDressableItem;
local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;

local class = L.classBits[select(2,UnitClass("PLAYER"))];


--// Tooltip
mog.tooltip = CreateFrame("Frame","MogItTooltip",UIParent,"TooltipBorderedFrameTemplate");
mog.tooltip:Hide();
mog.tooltip:SetClampedToScreen(true);
mog.tooltip:SetFrameStrata("TOOLTIP");

mog.tooltip:SetScript("OnShow",function(self)
	if mog.db.profile.tooltipMouse and not InCombatLockdown() then
		SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELUP","MogIt_TooltipScrollUp");
		SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELDOWN","MogIt_TooltipScrollDown");
	end
end);

mog.tooltip:SetScript("OnHide",function(self)
	if not InCombatLockdown() then
		ClearOverrideBindings(mog.tooltip);
	end
end);

mog.tooltip:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		mog.tooltip.model:SetUnit("player");
	elseif event == "PLAYER_REGEN_DISABLED" then
		ClearOverrideBindings(mog.tooltip);
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self:IsShown() and mog.db.profile.tooltipMouse then
			SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELUP","MogIt_TooltipScrollUp");
			SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELDOWN","MogIt_TooltipScrollDown");
		end
	end
end);
mog.tooltip:RegisterEvent("PLAYER_LOGIN");
mog.tooltip:RegisterEvent("PLAYER_REGEN_DISABLED");
mog.tooltip:RegisterEvent("PLAYER_REGEN_ENABLED");
--//


--// Model
mog.tooltip.model = CreateFrame("DressUpModel",nil,mog.tooltip);
mog.tooltip.model:SetPoint("TOPLEFT",mog.tooltip,"TOPLEFT",5,-5);
mog.tooltip.model:SetPoint("BOTTOMRIGHT",mog.tooltip,"BOTTOMRIGHT",-5,5);
mog.tooltip.model:SetScript("OnShow",function(self)
	--[[
	if mog.db.profile.tooltipCustomModel then
		self:SetCustomRace(mog.db.profile.tooltipRace, mog.db.profile.tooltipGender);
		-- hack for hidden helm and cloak showing on models
		local showingHelm, showingCloak = ShowingHelm(), ShowingCloak();
		local helm, cloak = GetInventoryItemID("player", INVSLOT_HEAD), GetInventoryItemID("player", INVSLOT_BACK);
		if not showingHelm and helm then
			self:TryOn(helm);
			self:UndressSlot(INVSLOT_HEAD);
		end
		if not showingCloak and cloak then
			self:TryOn(cloak);
			self:UndressSlot(INVSLOT_BACK);
		end
		self:RefreshCamera();
	else
		self:Dress();
	end
	--]]
	self:Dress();
	if not mog.db.profile.tooltipDress then
		self:Undress();
	end
end);


function mog.tooltip.ShowItem(self)
	local _,itemLink = self:GetItem();
	if not itemLink then
		return;
	end
	local itemID = tonumber(itemLink:match("item:(%d+)"));
	
	local db = mog.db.profile
	local tooltip = mog.tooltip
	if db.tooltip and (not tooltip.mod[db.tooltipMod] or tooltip.mod[db.tooltipMod]()) then
		if not self[mog] then
			if tooltip.item ~= itemLink then
				tooltip.item = itemLink;
				local token = mog.tokens[itemID];
				if token then
					for item, classBit in pairs(token) do
						if bit.band(class, classBit) > 0 then
							itemLink = item;
							break;
						end
					end
				end
				local slot = select(9,GetItemInfo(itemLink));
				if (not db.tooltipMog ) and tooltip.slots[slot] and IsDressableItem(itemLink) then
					tooltip.model:SetFacing(tooltip.slots[slot]-(db.tooltipRotate and 0.5 or 0));
					tooltip:Show();
					tooltip.owner = self;
					--if mog.global.tooltipAnchor then
						tooltip.repos:Show();
					--else
					--	tooltip:ClearAllPoints();
					--	tooltip:SetPoint("BOTTOMRIGHT","UIParent","BOTTOMRIGHT",-CONTAINER_OFFSET_X - 13,CONTAINER_OFFSET_Y);
					--end
					tooltip.model:TryOn(itemLink);
				else
					tooltip:Hide();
				end
			end
		else
			-- tooltip:Hide();
		end
	end
	
	-- add wishlist info about this item
	if not self[mog] and mog.wishlist:IsItemInWishlist(itemID) then
		self:AddLine(" ");
		self:AddLine(L["This item is on your wishlist."], 1, 1, 0);
		self:AddTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
	end
end

function mog.tooltip.HideItem(self)
	mog.tooltip.check:Show();
end
--//


--// GameTooltip
mog.tooltip.check = CreateFrame("Frame");
mog.tooltip.check:Hide();
mog.tooltip.check:SetScript("OnUpdate",function(self)
	if (mog.tooltip.owner and not (mog.tooltip.owner:IsShown() and mog.tooltip.owner:GetItem())) or not mog.tooltip.owner then
		mog.tooltip:Hide();
		mog.tooltip.item = nil;
	end
	self:Hide();
end);

mog.tooltip.repos = CreateFrame("Frame");
mog.tooltip.repos:Hide();
mog.tooltip.repos:SetScript("OnUpdate",function(self)
	local x,y = mog.tooltip.owner:GetCenter();
	if x and y then
		mog.tooltip:ClearAllPoints();
		local mogpoint,ownerpoint;
		if y/GetScreenHeight() > 0.5 then
			mogpoint = "TOP";
			ownerpoint = "BOTTOM";
		else
			mogpoint = "BOTTOM";
			ownerpoint = "TOP";
		end
		if x/GetScreenWidth() > 0.5 then
			mogpoint = mogpoint.."LEFT";
			ownerpoint = ownerpoint.."LEFT";
		else
			mogpoint = mogpoint.."RIGHT";
			ownerpoint = ownerpoint.."RIGHT";
		end
		mog.tooltip:SetPoint(mogpoint,mog.tooltip.owner,ownerpoint);
		self:Hide();
	end
end);

GameTooltip:HookScript("OnTooltipSetItem",mog.tooltip.ShowItem);
GameTooltip:HookScript("OnHide",mog.tooltip.HideItem);
--//


--// Auto-Rotate
mog.tooltip.rotate = CreateFrame("Frame",nil,mog.tooltip);
mog.tooltip.rotate:Hide();
mog.tooltip.rotate:SetScript("OnUpdate",function(self,elapsed)
	mog.tooltip.model:SetFacing(mog.tooltip.model:GetFacing() + elapsed);
end);
--//


--// Tables
mog.tooltip.slots = {
	INVTYPE_HEAD = 0,
	INVTYPE_SHOULDER = 0,
	INVTYPE_CLOAK = 3.4,
	INVTYPE_CHEST = 0,
	INVTYPE_ROBE = 0,
	INVTYPE_WRIST = 0,
	INVTYPE_2HWEAPON = 1.6,
	INVTYPE_WEAPON = 1.6,
	INVTYPE_WEAPONMAINHAND = 1.6,
	INVTYPE_WEAPONOFFHAND = -0.7,
	INVTYPE_SHIELD = -0.7,
	INVTYPE_HOLDABLE = -0.7,
	INVTYPE_RANGED = 1.6,
	INVTYPE_RANGEDRIGHT = 1.6,
	INVTYPE_THROWN = 1.6,
	INVTYPE_HAND = 0,
	INVTYPE_WAIST = 0,
	INVTYPE_LEGS = 0,
	INVTYPE_FEET = 0,
};

mog.tooltip.mod = {
	Shift = IsShiftKeyDown,
	Ctrl = IsControlKeyDown,
	Alt = IsAltKeyDown,
};
--//