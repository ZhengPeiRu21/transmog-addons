local MogIt,mog = ...;
local L = mog.L;

local function temp(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.keepShownOnClick = true;
		info.notCheckable = true;
		info.func = mog.base.DropdownTier1;
		UIDropDownMenu_AddButton(info,tier);
	end
end

for i=1,GetNumAddOns() do
	local name,title,_,_,loadable = GetAddOnInfo(i);
	if loadable and (not mog:GetModule(name)) then
		local version = tonumber(GetAddOnMetadata(name,"X-MogItModuleVersion"));
		if version then
			mog:RegisterModule(name,version,{
				label = title:match("^MogIt_(.+)") or title,
				Dropdown = temp,
			});
		end
	end
end