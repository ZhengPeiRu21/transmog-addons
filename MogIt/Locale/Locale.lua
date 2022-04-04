local MogIt,mog = ...;
mog.L = setmetatable({},{__index = function(tbl,key)
	return key;
end});