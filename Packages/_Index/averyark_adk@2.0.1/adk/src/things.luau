--[[
	FileName    > things.lua
	Author      > AveryArk
	Contact     > Twitter: https://twitter.com/averyark_
	Created     > 03/04/2023
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local symbols = require(script.Parent.symbols)

local pool = {
	version = "v2.0.1",
}

local commaFormat = function(number: number)
	local i, j, n, int, dec = tostring(number):find("([-]?)(%d+)([.]?%d*)")
	int = string.gsub(string.reverse(int), "(%d%d%d)", "%1,")
	return n .. string.gsub(string.reverse(int), "^,", "") .. dec
end

local function smallTimeUnit(number: number): string
	local unit
	local e = math.floor(math.log(number) / math.log(10))
	if e <= -9 then
		return `{math.round(number * 1e13) / 1e4}ns`
	elseif e <= -6 then
		return `{math.round(number * 1e10) / 1e4}μs`
	elseif e <= -3 then
		return `{math.round(number * 1e7) / 1e4}ms`
	end
	return `{math.round(number * 1e4) / 1e4}s`
end

local function typeStringTransform(value: any)
	local valueType = typeof(value)

	local function numberTransformation(number)
		local rounded = math.round(number * 10000) / 10000
		if math.abs(rounded) == 0 then
			return 0
		end
		return if rounded > 999 then commaFormat(rounded) else tostring(rounded)
	end

	local function tableTranslate(key, val, i, cache, str, nocomma)
		str = str and str .. "{" or str
		if table.find(cache, val) then
			return "[REC_T_REF_1]"
		end
		table.insert(cache, val)
		i = i and i + 1 or 1
		for k, v in pairs(val) do
			if table.find(cache, v) then
				return "[REC_T_REF_2]"
			end
			if typeof(v) == "table" then
				str =
					`{str}{nocomma and "" or ","}\n{("    "):rep(i or 0)}[{typeStringTransform(k)}] = {tableTranslate(k, v, i, cache, "", true)}`
				nocomma = false
			else
				str = if not str
					then "{\n" .. `{("    "):rep(i or 0)}[{typeStringTransform(k)}] = {typeStringTransform(v)}`
					else `{str}{nocomma and "" or ","}\n{("    "):rep(i or 0)}[{typeStringTransform(k)}] = {typeStringTransform(v)}`
				nocomma = false
			end
		end
		if not str then
			str = "{}"
		else
			str = str .. `\n{("    "):rep(i - 1 or 0)}}`
		end
		task.wait()
		return str
	end

	if valueType == "table" then
		return tableTranslate("", value, 0, {}, "", true)
	elseif valueType == "string" then
		return `"{value}"`
	elseif valueType == "number" then
		return numberTransformation(value)
	elseif valueType == "Vector3" then
		local x, y, z = value.X, value.Y, value.Z
		return `Vector3({numberTransformation(x)}, {numberTransformation(y)}, {numberTransformation(z)})`
	elseif valueType == "function" then
		return "function"
	elseif valueType == "Instance" then
		return `(class: {value.ClassName})[{value.Name})]`
	end
	return tostring(value)
end

local whitelistedPlayers = {}

local function isPlayerWhitelisted(player: Player)
	if whitelistedPlayers[player] == nil then
		local timeout = os.clock() + 5
		repeat
			task.wait()
		until (whitelistedPlayers[player] ~= nil) or os.clock() > timeout
	end

	return whitelistedPlayers[player]
end

pool.typeStringTransform = typeStringTransform
pool.isPlayerWhitelisted = isPlayerWhitelisted
pool.smallTimeUnit = smallTimeUnit

pool.symbols = symbols
pool.settings = if ReplicatedStorage:FindFirstChild("astraxSettings")
	then require(ReplicatedStorage.astraxSettings)
	else {
		EnabledInLiveServers = false,
		EnableForWhitelistedOnly = true,
		DebugEnabled = false,
		ModuleLoadAnalysisReport = true,
		UIDevelopmentResolution = Vector2.new(1280, 720),
		Whitelisted = {},
	}

pool.packages = script.Parent.Parent

pool.start = function()
	if RunService:IsServer() then
		Players.PlayerAdded:Connect(function(player)
			for _, whitelist in pairs(pool.settings.Whitelisted) do
				if whitelist.Type == "Group" then
					local minRank = whitelist.MinRank
					local rank = whitelist.Rank
					local groupid = whitelist.GroupId

					local playerRankInGroup = player:GetRankInGroup(groupid)

					if minRank and playerRankInGroup < minRank then
						continue
					end
					if rank and playerRankInGroup ~= rank then
						continue
					end

					whitelistedPlayers[player] = true
					return
				elseif whitelist.Type == "UserId" then
					if player.UserId == whitelist.Id then
						whitelistedPlayers[player] = true
						return
					end
				end
			end
			whitelistedPlayers[player] = false
		end)
		Players.PlayerRemoving:Connect(function(player)
			whitelistedPlayers[player] = nil
		end)
	elseif RunService:IsClient() then
		local player = Players.LocalPlayer
		for _, whitelist in pairs(pool.settings.Whitelisted) do
			if whitelist.Type == "Group" then
				local minRank = whitelist.MinRank
				local rank = whitelist.Rank
				local groupid = whitelist.GroupId

				local playerRankInGroup = player:GetRankInGroup(groupid)

				if minRank and playerRankInGroup < minRank then
					continue
				end
				if rank and playerRankInGroup ~= rank then
					continue
				end

				whitelistedPlayers[player] = true
				return
			elseif whitelist.Type == "UserId" then
				if player.UserId == whitelist.Id then
					whitelistedPlayers[player] = true
					return
				end
			end
		end
		whitelistedPlayers[player] = false
	end
end

return pool
