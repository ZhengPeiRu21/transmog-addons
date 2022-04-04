local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;


--// Useful Lists
L.source = {
	[1] = L["Drop"],
	[2] = PVP,
	[3] = L["Quest"],
	[4] = L["Vendor"],
	[5] = L["Crafted"],
	[6] = L["Achievement"],
	[7] = L["Code Redemption"],
};

L.diffs = {
	--[1] = PLAYER_DIFFICULTY1,
	[2] = PLAYER_DIFFICULTY2,
	[3] = L["10N"],
	[4] = L["25N"],
	[5] = L["10H"],
	[6] = L["25H"],
	--[7] = PLAYER_DIFFICULTY1,
	[8] = PLAYER_DIFFICULTY2,
	[9] = PLAYER_DIFFICULTY3,
	[10] = PLAYER_DIFFICULTY4,
};

L.difficulties = {
	[1] = DUNGEON_DIFFICULTY_5PLAYER;
	[2] = DUNGEON_DIFFICULTY_5PLAYER_HEROIC;
	[3] = RAID_DIFFICULTY_10PLAYER;
	[4] = RAID_DIFFICULTY_25PLAYER;
	[5] = RAID_DIFFICULTY_10PLAYER_HEROIC;
	[6] = RAID_DIFFICULTY_25PLAYER_HEROIC;
	[7] = PLAYER_DIFFICULTY1,
	[8] = PLAYER_DIFFICULTY2,
	[9] = PLAYER_DIFFICULTY3,
	[10] = PLAYER_DIFFICULTY4,
};

L.slots = {
	[1] = INVTYPE_WEAPON,
	[2] = INVTYPE_WEAPONMAINHAND,
	[3] = INVTYPE_WEAPONOFFHAND,
};

L.sheath = {
	[1] = "Back Downwards",
	[2] = "Back Upwards",
	[3] = "Side",
	[4] = "Shield",
	[5] = "Hidden",
};

L.professions = {
	[1] = GetSpellInfo(2259), -- Alchemy
	[2] = GetSpellInfo(2018), -- Blacksmithing
	[3] = GetSpellInfo(7411), -- Enchanting
	[4] = GetSpellInfo(4036), -- Engineering
	[5] = GetSpellInfo(45357), -- Inscription
	[6] = GetSpellInfo(25229), -- Jewelcrafting
	[7] = GetSpellInfo(2108), -- Leatherworking
	[8] = GetSpellInfo(3908), -- Tailoring

	[9] = GetSpellInfo(2366), -- Herbalism
	[10] = GetSpellInfo(2575), -- Mining
	[11] = GetSpellInfo(8613), -- Skinning

	[12] = GetSpellInfo(78670), -- Archaeology
	[13] = GetSpellInfo(2550), -- Cooking
	[14] = GetSpellInfo(3273), -- First Aid
	[15] = GetSpellInfo(7620), -- Fishing
};

L.quality = {
	0, -- Poor
	1, -- Common
	2, -- Uncommon
	3, -- Rare
	4, -- Epic
	5, -- Legendary
	6, -- Artifact
	7, -- Heirloom
};

L.classBits = {
	DEATHKNIGHT = 32,
	DRUID = 1024,
	HUNTER = 4,
	MAGE = 128,
	PALADIN = 2,
	PRIEST = 16,
	ROGUE = 8,
	SHAMAN = 64,
	WARLOCK = 256,
	WARRIOR = 1,
	MONK = 512,
};

L.bind = {
	[1] = NONE,
	[2] = ITEM_BIND_ON_EQUIP,
	[3] = ITEM_BIND_ON_PICKUP,
	[4] = ITEM_BIND_TO_BNETACCOUNT,
};
--//