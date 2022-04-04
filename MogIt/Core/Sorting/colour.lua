local MogIt,mog = ...;
local L = mog.L;

local colourCache = {};
local cR,cG,cB = 255,255,255;
local function colourScore(id,args)
	if not colourCache[id] then
		local distance = 195075;
		local colours = args and args(id);
		if colours then
			for k,v in pairs(colours) do
				local r,g,b = v:match("^(..)(..)(..)$");
				r = tonumber(r,16);
				g = tonumber(g,16);
				b = tonumber(b,16);
				local dist = ((cR-r)^2)+((cG-g)^2)+((cB-b)^2);
				if dist < distance then
					distance = dist;
				end
			end
		end
		colourCache[id] = distance;
	end
	return colourCache[id];
end

local function dropdownTier1(self)
	mog:SortList("colour");
end

local function swatchFunc()
	if not ColorPickerFrame:IsShown() then
		local r,g,b = ColorPickerFrame:GetColorRGB();
		cR,cG,cB = r*255,g*255,b*255;
		mog:SortList("colour");
	end
end

mog:CreateSort("colour",{
	label = L["Approximate Colour"],
	Dropdown = function(dropdown,module,tier)
		local info = UIDropDownMenu_CreateInfo();
		info.text =	L["Approximate Colour"];
		info.value = "colour";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "colour";
		info.hasColorSwatch = true;
		info.r = cR/255;
		info.g = cG/255;
		info.b = cB/255;
		info.swatchFunc = swatchFunc;
		dropdown:AddButton(info,tier);
	end,
	Sort = function(args)
		wipe(colourCache);
		table.sort(mog.list,function(a,b)
			return colourScore(a,args) < colourScore(b,args);
		end);
	end,
	Unlist = function()
		wipe(colourCache);
	end,
});