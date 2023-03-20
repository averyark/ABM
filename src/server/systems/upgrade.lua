--!strict
--[[
    FileName    > upgrade.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 13/03/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
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
local upgrades = require(ReplicatedStorage.shared.upgrades)

local bridges = {
    purchaseUpgrade = BridgeNet.CreateBridge("purchaseUpgrade"),
    playSound = BridgeNet.CreateBridge("playSound")
}

local getValueFromUpgrades = function(player, upgradeType)
    local playerData = playerDataHandler.getPlayer(player)
    local value = 0
    for worldIndex, upgradeContent in pairs(playerData.data.upgrades) do
        for upgradeId, upgradeLevel in pairs(upgradeContent) do
            local data = upgrades.contents[worldIndex][upgradeId]
            if data.type == upgradeType then
                value += data.values[upgradeLevel] or 0
            end
        end
    end
    return value
end


return {
    getValueFromUpgrades = getValueFromUpgrades,
    load = function()
        bridges.purchaseUpgrade:Connect(function(player, worldIndex, upgradeId)
            debugger.assert(t.number(worldIndex))
            debugger.assert(t.number(upgradeId))
            local playerData = playerDataHandler.getPlayer(player)
            local data = upgrades.contents[worldIndex][upgradeId]
            local nextLevel = playerData.data.upgrades[worldIndex][upgradeId]+1
            if data and playerData.data.unlockedWorlds[worldIndex] and data.cost[nextLevel] then
                if playerData.data.coins >= data.cost[nextLevel] then
                    playerData:apply(function()
                        playerData.data.coins -= data.cost[nextLevel]
                        playerData.data.upgrades[worldIndex][upgradeId] += 1
                    end)
                    bridges.playSound:FireTo(player, SoundService.purchase)
                else
                    BridgeNet.CreateBridge("notifError"):FireTo(player, ("Error: Insufficient Coins. You need %s Coins"):format(number.abbreviate(data.cost[nextLevel] - playerData.data.coins, 2)))
                end
            end
        end)

        Players.PlayerAdded:Connect(function(player)
            local maid = Janitor.new()
            local playerData = playerDataHandler.getPlayer(player)

            playerData:connect({"upgrades"}, function()
                local character = player.Character
                if character then
                    local humanoid = character:WaitForChild("Humanoid")
                    humanoid:SetAttribute("defaultWalkSpeed", 16 + getValueFromUpgrades(player, "Agility"))
                end
            end)

            --local data = upgrades.contents[worldIndex][upgradeId]

            local connectCharacter = function(character)
                local humanoid = character:WaitForChild("Humanoid")
                humanoid:SetAttribute("defaultWalkSpeed", 16 + getValueFromUpgrades(player, "Agility"))
            end

            maid:Add(player.AncestryChanged:Connect(function()
                if not player:IsDescendantOf(game) then
                    maid:Destroy()
                end
            end))
            maid:Add(player.CharacterAdded:Connect(connectCharacter))
            if player.Character then
                connectCharacter(player.Character)
            end
        end)
    end
}