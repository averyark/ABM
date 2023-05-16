--!strict
--[[
    FileName    > click.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/03/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

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

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local weapons = require(ReplicatedStorage.shared.weapons)
local upgrade = require(script.Parent.upgrade)
local ascension = require(ReplicatedStorage.shared.ascension)
local pass = require(script.Parent.pass)
local heros = require(ReplicatedStorage.shared.heros)
local levels = require(ReplicatedStorage.shared.levels)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)

local bridges = {
    clientClicked = BridgeNet.CreateBridge("clientClicked")
}

local threashold = {}

local threasholdCheck = function(player)
    local list = threashold[player]

	if not list then
		threashold[player] = {}
		return true
	end
   
    if #list >= 7 then
        return false
    end
    return true
end

local find = function<t>(id: t & number): typeof(weapons[t])
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

local random = Random.new()

return {
    load = function()
        Players.PlayerAdded:Connect(function(player)
            threashold[player] = {}
        end)
        Players.PlayerRemoving:Connect(function(player)
            threashold[player] = nil
        end)
        bridges.clientClicked:Connect(function(player)
            if not threasholdCheck(player) then return end
            table.insert(threashold[player], os.clock())

            local playerData = playerDataHandler.getPlayer(player)
            local id

            local power
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
				
				local weaponData = find(equippedWeaponData.id)
				local weaponData2 = equippedWeaponData2 and find(equippedWeaponData2.id)
	
				local weaponPower = weaponData.power * (itemLevel.getMultiFromLevel(equippedWeaponData.level) or 1)
				local weaponPower2 = weaponData2 and weaponData2.power * (itemLevel.getMultiFromLevel(equippedWeaponData2.level) or 1)

				local baseDamage =  if weaponPower2 then (weaponPower2 + weaponPower) else weaponPower
				power = baseDamage *
				(
					getTotalMulti()
					+ upgrade.getValueFromUpgrades(player, "Coin Magnet")
					+ ascension.getPowerMultiplier(playerData.data.ascension)
					+ math.max(levels[playerData.data.level].multiplier, 1)
				) * (pass.hasPass(player, "2xCoin") and 2 or 1)

            playerData:apply(function()
				local num = power*random:NextNumber(.6, 1.2)
				playerData.data.stats.coinsCollected += num
                playerData.data.coins += num
            end)
        end)
        
        local cleanup = 1
        
        RunService.Heartbeat:Connect(function(deltaTime)
            -- Cleanup
            local nowClock = os.clock()
            for player, list in pairs(threashold) do
                for index, clock in pairs(list) do
                    if nowClock - clock >= cleanup then
                        table.remove(list, index)
                    end
                end
            end
        end)
    end
}