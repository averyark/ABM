--!strict
--[[
    FileName    > leaderboard.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 09/05/2023
--]]
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local DataStoreService = game:GetService("DataStoreService")

local BridgeNet = require(ReplicatedStorage.Packages.BridgeNet)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Matter = require(ReplicatedStorage.Packages.Matter)
local Astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local version = "Live_1"

local stores = {
    power = DataStoreService:GetOrderedDataStore(`{version}/power`),
    capsulesOpened = DataStoreService:GetOrderedDataStore(`{version}/capsulesOpened`),
    hoursSpent = DataStoreService:GetOrderedDataStore(`{version}/hoursSpent`),
    coinsAccumulated = DataStoreService:GetOrderedDataStore(`{version}/coinsAccumulated`),
}

local regionStore = DataStoreService:GetDataStore(`{version}/playerRegion`)

local bridges = {
    retrieveLeaderboard = BridgeNet.CreateBridge("retrieveLeaderboard"),
    updateLeaderboard = BridgeNet.CreateBridge("updateLeaderboard")
}

local levels = require(ReplicatedStorage.shared.levels)
local ascension = require(ReplicatedStorage.shared.ascension)
local weapons = require(ReplicatedStorage.shared.weapons)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)
local heros = require(ReplicatedStorage.shared.heros)
local upgrade = require(script.Parent.upgrade)

local leaderbordCache = {}

local findSword = function<t>(id: t & number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
		end
	end
	return nil
end
local findHero = function<t>(id: t & number): typeof(heros[t])
	for _, dat in pairs(heros) do
		if dat.id == id then
			return dat
		end
	end
	return nil
end
local findItemWithIndexId = function(tbl, id)
	for _, dat in pairs(tbl) do
		if dat.index == id then
			return dat
		end
	end
end

local getPlayerPower = function(player: Player)
	local playerData = playerDataHandler.getPlayer(player)
			
	local equippedWeaponData = findItemWithIndexId(
		playerData.data.inventory.weapon,
		playerData.data.equipped.weapon
	)
	local equippedWeaponData2
	if playerData.data.equipped.weapon2 then
		equippedWeaponData2 = findItemWithIndexId(
			playerData.data.inventory.weapon,
			playerData.data.equipped.weapon2
		)
	end
	
	local getTotalMulti = function()
		local m = 0
		for _, indexId in pairs(playerData.data.equipped.hero) do
			m += findHero(findItemWithIndexId(playerData.data.inventory.hero, indexId).id).multiplier
		end
		return m
	end
	
	local weaponData = findSword(equippedWeaponData.id)
	local weaponData2 = equippedWeaponData2 and findSword(equippedWeaponData2.id)

	local weaponPower = weaponData.power * (itemLevel.getMultiFromLevel(equippedWeaponData.level) or 1)
	local weaponPower2 = weaponData2 and weaponData2.power * (itemLevel.getMultiFromLevel(equippedWeaponData2.level) or 1)

	local basePower =  if weaponPower2 then (weaponPower2 + weaponPower) else weaponPower
	return basePower *
	(
		getTotalMulti()
		+ upgrade.getValueFromUpgrades(player, "Power Gain")
		+ ascension.getPowerMultiplier(playerData.data.ascension)
		+ math.max(levels[playerData.data.level].multiplier, 1)
	)
end

local updateStat = function(player: Player, statName: string, value: number)
    local store = stores[statName]
    if not store then
        return
    end

    return Promise.new(function(resolve)
        store:UpdateAsync(player.UserId, function(old)
            return math.round(value)
        end)
        resolve()
    end)
end

local countryCache = {}

local workerDone = false

local updateTop = function(statName: string)
    local store = stores[statName]
    if not store then
        return
    end

    leaderbordCache[statName] = {}

    local page = store:GetSortedAsync(false, 100)
    local top100 = page:GetCurrentPage()

    local workers = {}

    for rank, data in pairs(top100) do
        table.insert(workers, Promise.try(function()
            data.region = countryCache[data.key] or regionStore:GetAsync(data.key)
        end):andThen(function()
            leaderbordCache[statName][rank] = data
            countryCache[data.key] = data.region
        end):catch(function()
            leaderbordCache[statName][rank] = data
        end))
    end

    return workers
end

local updateLeaderboards = function()
    local workers = {}
    for name, store in pairs(stores) do
        for _, worker in pairs(updateTop(name)) do
            table.insert(workers, worker)
        end
    end
    Promise.all(workers):finally(function()
        workerDone = true
        bridges.updateLeaderboard:FireAll(leaderbordCache)
    end)
end

local updatePlayerStats = function(player: Player)
    local playerData = playerDataHandler.getPlayer(player)

    if not playerData then return end

    updateStat(player, "capsulesOpened", playerData.data.stats.capsulesOpened)
    updateStat(player, "coinsCollected", playerData.data.stats.coinsCollected)
    updateStat(player, "hoursSpent", playerData.data.stats.hoursSpent)
    updateStat(player, "power", getPlayerPower(player))

    local region = LocalizationService:GetCountryRegionForPlayerAsync(player)

    countryCache[player.UserId] = region

    if countryCache[player.UserId] then
        regionStore:SetAsync(player.UserId, region)
    end
    return
end

return {
    updatePlayerPower = function(player: Player, power: number)
        
    end,
    load = function()
        bridges.retrieveLeaderboard:Connect(function(player)
            repeat task.wait() until workerDone
            bridges.updateLeaderboard:FireTo(player, leaderbordCache)
        end)
        Players.PlayerRemoving:Connect(function(player)
            updatePlayerStats(player)
        end)
        Promise.try(function()
            task.wait(5)
            while true do
                for _, player in pairs(Players:GetPlayers()) do
                    Promise.try(updatePlayerStats, player)
                end
                task.wait(5)
                updateLeaderboards()
                task.wait(120)
            end
        end)
    end
}