--!strict
--[[
    FileName    > quest.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 15/04/2023
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local quests = require(ReplicatedStorage.shared.quests)
local badge = require(script.Parent.badges)
local upgrade = require(script.Parent.upgrade)

local bridges = {
    notifMessage = BridgeNet.CreateBridge("notifMessage"),
    notifError = BridgeNet.CreateBridge("notifError"),
    startQuest = BridgeNet.CreateBridge("startQuest"),
    removeQuest = BridgeNet.CreateBridge("removeQuest"),
    playSound = BridgeNet.CreateBridge("playSound")
}

local names = {
    "averyark",
    "BOMBA_GOMBA",
    "dwargos",
    "obslain",
    "Gstooh"
}

local enemySlain_incrementQuestProgress = function(player: Player, enemy: string)
    local playerData = playerDataHandler.getPlayer(player)
    for worldid, q in pairs(quests) do
        for _, quest in pairs(q) do
            if quest.target ~= enemy then
                continue
            end
            if playerData.data.quest.name ~= quest.name then
                continue
            end
            playerData:apply(function()
                playerData.data.quest.progress += 1
                if playerData.data.quest.progress >= quest.amount then
                    -- finishedQuest
                    local reward =  quest.rewards.xp * (upgrade.getValueFromUpgrades(player, "Fast Learner") + 1)
                    badge.incrementProgress(player, "questsCompleted", 1)
                    bridges.notifMessage:FireTo(player, `Quest has been compelted: {names[worldid]}'s Lv. {quest.lvRequirement} quest. You were rewarded {number.abbreviate(reward, 2)} Xp!`)
                    playerData.data.xp += reward
                    playerData.data.stats.xpCollected += reward
                    playerData.data.quest.progress = 0
                    playerData.data.quest.name = nil
                    bridges.playSound:FireTo(player, SoundService.quest_complete)
                end
            end)
        end
    end
end

local startQuest = function(player: Player, questIdentifier: string)
    local playerData = playerDataHandler.getPlayer(player)

    if playerData.data.quest.name then
        return bridges.notifError:FireTo(player, "Error: You already in a quest.")
    end
    
    local quest
    local worldId

    for worldid, q in pairs(quests) do
        for _, d in pairs(q) do
            if d.name == questIdentifier then
                quest = d
                worldId = worldid
                break
            end
        end
    end

    if worldId == nil or quest == nil then
        return bridges.notifError:FireTo(player, "Error: An error occured.")
    end

    if not table.find(playerData.data.unlockedWorlds, worldId) then
        return bridges.notifError:FireTo(player, "Error: You haven't unlock this world.")
    end
    if playerData.data.level < quest.lvRequirement then
        return bridges.notifError:FireTo(player, `Error: You have to be Lv. {quest.lvRequirement} for this quest.`)
    end

    playerData:apply(function()
        playerData.data.quest.name = quest.name
        playerData.data.quest.progress = 0
    end)
end

return {
    enemySlain_incrementQuestProgress = enemySlain_incrementQuestProgress,
    load = function()
        bridges.startQuest:Connect(startQuest)
        bridges.removeQuest:Connect(function(player: Player)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then
                return
            end

            playerData:apply(function()
                playerData.data.quest.progress = 0
                playerData.data.quest.name = nil
            end)
        end)
    end
}