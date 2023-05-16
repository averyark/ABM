local levels = {
	{ -- Star 1
		req = 3,
		multi = 1.5,
		txt = "1 Star",
        displayTxt = "Star",
		iconId = "rbxassetid://12333589554",
	},
	{ -- Star 2
		req = 3,
		multi = 2.1,
		txt = "2 Star",
        displayTxt = "Star",
		iconId = "rbxassetid://12333589554",
	},
	{ -- Star 3
		req = 5,
		multi = 2.8,
		txt = "3 Star",
        displayTxt = "Star",
		iconId = "rbxassetid://12333589554",
	},
	{ -- Star 4
		req = 7,
		multi = 3.6,
		txt = "4 Star",
        displayTxt = "Star",
		iconId = "rbxassetid://12333589554",
	},
	{ -- Star 5
		req = 7,
		multi = 5,
		txt = "5 Star",
        displayTxt = "Star",
		iconId = "rbxassetid://12333589554",
	},
	--[[-- Crown 1
	{
		req = 10,
		multi = 7,
		txt = "1 Crown",
		iconId = "rbxassetid://12333587940",
	},
	-- Crown 2
	{
		req = 10,
		multi = 10,
		txt = "2 Crown",
        displayTxt = "Crown",
		iconId = "rbxassetid://12333587940",
	},
	-- Crown 3
	{
		req = 10,
		multi = 14,
		txt = "3 Crown",
        displayTxt = "Crown",
		iconId = "rbxassetid://12333587940",
	},
	-- Crown 4
	{
		req = 10,
		multi = 19,
		txt = "4 Crown",
        displayTxt = "Crown",
		iconId = "rbxassetid://12333587940",
	},
	-- Crown 5
	{
		req = 10,
		multi = 25,
		txt = "5 Crown",
        displayTxt = "Crown",
		iconId = "rbxassetid://12333587940",
	},]]
}

local getMaxLevel = function()
	return #levels
end

local getRequiredDuplicateFromLevel = function(level)
	return levels[level + 1].req or 999
end

local getMultiFromLevel = function(level)
	return levels[level] and levels[level].multi or 1
end

return {
	maxLevel = getMaxLevel(),
	getMultiFromLevel = getMultiFromLevel,
	getRequiredDuplicateFromLevel = getRequiredDuplicateFromLevel,
	getLevelInfo = function(level)
		return levels[level]
	end,
}
