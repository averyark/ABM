--[[
    FileName    > functions.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/05/2023
--]]

function deepCopy<T>(tableToClone: T & { [number]: any }, cache: {}): T | { [number]: any }?
	local result = {}

	cache = cache or {}

	for key, v in pairs(tableToClone) do
		if typeof(v) == "table" then
			if table.find(cache, v) then
				return
			end -- anti recursive
			table.insert(cache, v)
			result[key] = deepCopy(v, cache)
		else
			result[key] = v
		end
	end

	return result
end

local function fromPath(tb, path)
	local ntb = tb
	for i, key in pairs(path) do
		if typeof(ntb) ~= "table" then
			return
		end
		ntb = ntb[key]
	end
	return ntb
end

local function match(path, changes)
	for _, change in pairs(changes) do
		local matchRate = 0
		-- ancestry changed
		for i, pathKey in pairs(path) do
			if change.path[i] == pathKey then
				matchRate += 1
			end
		end
		if matchRate >= 1 then
			return true
		end
	end
	return false
end

local function absoluteMatch(path, changes)
	for _, change in pairs(changes) do
		local matchRate = 0
		-- ancestry changed
		for i, pathKey in pairs(path) do
			if change.path[i] == pathKey then
				matchRate += 1
			end
		end
		if matchRate == #path then
			return true
		end
	end
	return false
end

local function checkIfExist(path, changes)
	local total = #path
	for _, change in pairs(changes) do
		local matchRate = 0
		for i, pathKey in pairs(path) do
			if change.path[i] == pathKey then
				matchRate += 1
			end
		end
		if matchRate == total then
			return true
		end
	end
	return false
end

local function compare(
	tb1, -- new
	tb2 -- old
)
	local changes = {}

	local checkAndAddChange
	checkAndAddChange = function(
		tbr1, -- new
		tbr2, -- old
		previousPath,
		flip
	)
		-- input key, value1 and value2
		local add = function(k, v1, v2)
			local path = table.clone(previousPath)

			table.insert(path, k)

			if checkIfExist(path, changes) then
				return
			end

			table.insert(changes, {
				old = if flip then v1 else v2,
				new = if flip then v2 else v1,
				key = k,
				path = path,
				supertable = tb1,
			})
		end

		for key, value in pairs(tbr1) do
			if typeof(value) == "table" then
				local path = table.clone(previousPath)
				table.insert(path, key)

				if typeof(tbr2[key]) == "table" then
					checkAndAddChange(value, tbr2[key], path, flip)
				else
					add(key, value, tbr2[key])
				end
			elseif value ~= tbr2[key] then
				add(key, value, tbr2[key])
			end
		end

		return changes, #changes
	end

	checkAndAddChange(tb1, tb2, {})
	checkAndAddChange(tb2, tb1, {}, true)

	return changes, #changes
end

return {
	absoluteMatch = absoluteMatch,
	match = match,
	fromPath = fromPath,
	deepCopy = deepCopy,
	checkIfExist = checkIfExist,
	compare = compare,
}
