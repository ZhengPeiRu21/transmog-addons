local MogIt, mog = ...;
local L = mog.L;

mog.sorting = {};

function mog:CreateSort(name, data)
	data = data or {};
	data.name = name;
	mog.sorting[name] = data;
end

function mog:GetSort(name)
	return mog.sorting[name];
end

function mog:GetActiveSort()
	return mog.sorting.active;
end

function mog:SortList(new, update)
	if mog.active and mog.active.sorting and #mog.active.sorting > 0 then
		new = new or (mog.active.sorts[mog.sorting.active] and mog.sorting.active) or mog.active.sorting[1];
		if mog.sorting.active and (mog.sorting.active ~= new) and mog.sorting[mog.sorting.active].Unlist then
			mog.sorting[mog.sorting.active].Unlist();
		end
		mog.sorting.active = new;
		mog.sorting[new].Sort(mog.active.sorts[new]);
		if not update then
			mog.scroll:update();
		end
	end
end