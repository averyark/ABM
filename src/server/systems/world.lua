--!strict
--[[
    FileName    > world.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 28/04/2023
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
local worlds = require(ReplicatedStorage.shared.zones)

local badges = require(script.Parent.badges)

local bridges = {
    changeWorld = BridgeNet.CreateBridge("changeWorld"),
    purchaseWorld = BridgeNet.CreateBridge("purchaseWorld"),
    notifError = BridgeNet.CreateBridge("notifError"),
    notifMessage = BridgeNet.CreateBridge("notifMessage"),
    newbieFalse = BridgeNet.CreateBridge("newbieFalse"),
    tutorialFinished = BridgeNet.CreateBridge("tutorialFinished")
}

return {
    load = function()
        bridges.newbieFalse:Connect(function(player: Player)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            if playerData.data.isNew then
                playerData.data.isNew = false
            end

            badges.incrementProgress(player, "thanksForPlaying", 1)
        end)
        bridges.tutorialFinished:Connect(function(player: Player)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            if not playerData.data.tutorial then
                playerData.data.tutorial = true
            end
        end)
        bridges.changeWorld:Connect(function(player: Player, worldIndex: number)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            local worldData = worlds[worldIndex]
            if not worldData then return end

            if not table.find(playerData.data.unlockedWorlds, worldIndex) then
                return bridges.notifError:FireTo(player, "Error: Unlock the world before teleporting.")
            end

            playerData:apply(function()
                playerData.data.currentWorld = worldIndex
            end)
        end)
        bridges.purchaseWorld:Connect(function(player: Player, worldIndex: number)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            local worldData = worlds[worldIndex]
            if not worldData then return end

            if table.find(playerData.data.unlockedWorlds, worldIndex) then
                return bridges.notifError:FireTo(player, "Error: You already own this world.")
            end
            if not table.find(playerData.data.unlockedWorlds, worldIndex-1) then
                return bridges.notifError:FireTo(player, "Error: Unlock the previous world.")
            end
            if not table.find(playerData.data.bossDefeated, worlds[worldIndex-1].bossId) then
                return bridges.notifError:FireTo(player, "Error: Defeat the boss.")
            end
            if playerData.data.coins < worldData.cost then
                return bridges.notifError:FireTo(player, ("Error: Insufficient Coins. You need %s Coins"):format(number.abbreviate(worldData.cost - playerData.data.coins, 2)))
            end

            playerData:apply(function()

                if worldIndex == 2 then
                    playerData.data.isTester = true
                    bridges.notifMessage:FireTo(player, "You just obtained a permanent Tester rank!")
                end

                playerData.data.coins -= worldData.cost
                table.insert(playerData.data.unlockedWorlds, worldIndex)
                playerData.data.currentWorld = worldIndex
            end)
        end)

    end
}