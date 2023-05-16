--!strict
--[[
    FileName    > ascend.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 11/04/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local ascension = require(ReplicatedStorage.shared.ascension)
local weapons = require(ReplicatedStorage.shared.weapons)
local combat = require(script.Parent.Parent.combat.combat_handler)
local pass = require(script.Parent.Parent.systems.pass)
local worlds = require(ReplicatedStorage.shared.zones)

local bridges = {
    ascend = BridgeNet.CreateBridge("ascend"),
    onAscend = BridgeNet.CreateBridge("onAscend")
}

local find = function<t>(id: t & number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
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

return {
    load = function()
        bridges.ascend:Connect(function(player)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            local ascensionCost = ascension.getCost(playerData.data.ascension)

            local has2x = pass.hasPass(player, "2xAscension")

            if has2x then
                ascensionCost /= 2
            end

            if playerData.data.coins < ascensionCost then
                BridgeNet.CreateBridge("notifError"):FireTo(player, ("Error: Insufficient Coins. You need %s Coins"):format(number.abbreviate(ascensionCost - playerData.data.coins, 2)))
                return
            end

            playerData:apply(function()
                local highestWorldIndex = 1
                for _, index in pairs(playerData.data.unlockedWorlds) do
                    if index > highestWorldIndex then
                        highestWorldIndex = index
                    end
                end
                local defaultWeapon = worlds[highestWorldIndex].defaultWeapon
                local cache = playerData.data.ascension

                playerData.data.ascension += 1
                --playerData.data.level = 0
                --playerData.data.xp = 0
                playerData.data.coins = 0
                --playerData.data.quest.name = nil
                --playerData.data.quest.progress = 0

                --[[local soulboundSwords = {}
                --local soulboundHeros = {}

                for i, dat in pairs(playerData.data.inventory.weapon) do
                    local item = find(dat.id)
                    if item.soulbound then
                        table.insert(soulboundSwords, table.clone(dat))
                    end
                end]]
                --[[for i, dat in pairs(playerData.data.inventory.hero) do
                    local item = find(dat.id)
                    if item.soulbound then
                        table.insert(soulboundHeros, table.clone(dat))
                    end
                end]]

                --playerData.data.stats.itemsObtained.weapon += 1

                local index = playerData.data.stats.itemsObtained.weapon

                --[[table.insert(soulboundSwords, {
                    index = index,
                    id = defaultWeapon.id,
                    level = 0,
                })]]

                --table.clear(playerData.data.equipped.hero)
                
                --[[if not findItemWithIndexId(soulboundSwords, playerData.data.equipped.weapon) then
                    playerData.data.equipped.weapon = index
                    combat.loadPlayerWeapon(player, defaultWeapon.id)
                end
                if not findItemWithIndexId(soulboundSwords, playerData.data.equipped.weapon2) then
                    playerData.data.equipped.weapon2 =  nil
                    if player.Character:FindFirstChild("secondary") then
                        player.Character.secondary:Destroy()
                    end
                end]]

                for world, upgrades in pairs(playerData.data.upgrades) do
                    for upgrade in pairs(upgrades) do
                        playerData.data.upgrades[world][upgrade] = 0
                    end
                end

                --table.clear(playerData.data.equipped.hero)
                --table.clear(playerData.data.inventory.weapon)
                --table.clear(playerData.data.inventory.hero)
                --[[for i, v in pairs(soulboundSwords) do
                    playerData.data.inventory.weapon[i] = v
                end]]
                --[[for i, v in pairs(soulboundHeros) do
                    playerData.data.inventory.hero[i] = v
                end]]

                --[[for _, hero in pairs(workspace.gameFolders.heros:GetChildren()) do
                    local userId, heroIndexId = hero.Name:match("(%d+)-(%d+)")
            
                    if not userId or not heroIndexId then
                        continue
                    end
            
                    userId = tonumber(userId)
                    heroIndexId = tonumber(heroIndexId)
            
                    if not userId == player.UserId then
                        continue
                    end
            
                    if not table.find(playerData.data.equipped.hero, heroIndexId) then
                        hero:Destroy()
                    end
                end]]

                BridgeNet.CreateBridge("notifMessage"):FireTo(player, "You lost all your coins and upgrades but you felt more powerful than before.")
                return

                bridges.onAscend:FireTo(player, cache, playerData.data.ascension)
            end)
        end)
    end
}