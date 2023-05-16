--!strict
--[[
    FileName    > badges.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 02/05/2023
--]]
local BadgeService = game:GetService("BadgeService")
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

local badges = {
    ["thanksForPlaying"] = 2145016612, -- done
    ["metADev"] = 2145016629, -- done
    ["firstLegendarySword"] = 2145016720, -- done
    ["firstQuestCompleted"] = 2145016734, -- done
    ["legendaryCollector"] = 2145016774, -- done
    ["100Streak"] = 2145017690, -- done
    ["emptiedTheShop"] = 2145017695, -- done
    ["firstCpsule"] = 2145017704, -- done
    ["100Capsule"] = 2145017710, -- done
    ["100kCapsule"] = 2145017713, -- done
    ["1mCapsule"] = 2145017726,  -- done
    ["10Hour"] = 2145017736,
    ["50Hour"] = 2145017742,
    ["1kHours"] = 2145017749,
    --["touchedGrass"] = 2145017763,
}

local names = {
    ["thanksForPlaying"] = "Thanks for playing!", -- done
    ["metADev"] = "Met a Developer", -- done
    ["firstLegendarySword"] = "First Legendary Sword", -- done
    ["firstQuestCompleted"] = "First Quest Completed", -- done
    ["legendaryCollector"] = "Legendary Collector", -- done
    ["100Streak"] = "100% The Best", -- done
    ["emptiedTheShop"] = "Emptied the Shop", -- done
    ["firstCpsule"] = "First Capsule Opened", -- done
    ["100Capsule"] = "100th Capsule Opened", -- done
    ["100kCapsule"] = "100k Capsule Opened", -- done
    ["1mCapsule"] = "1m Capsule Opened",  -- done
    ["10Hour"] = "10 Hours Played",
    ["50Hour"] = "50 Hours Played",
    ["1kHours"] = "1,000 Hours played",
    --["touchedGrass"] = 2145017763,
}

local awardBadge = function(player: Player, badgeName: string)
    local playerData = playerDataHandler.getPlayer(player)
    Promise.try(function()
        BadgeService:AwardBadge(player.UserId, badges[badgeName])
    end):andThen(function()
        if not playerData.data.badges[tostring(badges[badgeName])] then
            BridgeNet.CreateBridge("message"):FireAll(`{player.Name} Unlocked the badge "{names[badgeName]}"`)
        end
        playerData.data.badges[tostring(badges[badgeName])] = true
        local state = true
        for _, badge in pairs(badges) do
            if not playerData.data.badges[tostring(badge)] and badge ~= badges["legendaryCollector"] then
                state = false
                break
            end
        end
        print(playerData.data.badges, state)
        if state then
            BadgeService:AwardBadge(player.UserId, badges["legendaryCollector"])
        end
    end)
end

local funcs = {
    ["questsCompleted"] = function(player: Player, increment: number)
        local playerData = playerDataHandler.getPlayer(player)

        playerData:apply(function()
            playerData.data.stats.questsCompleted += increment

            if playerData.data.stats.questsCompleted >= 1 then
                awardBadge(player, "firstQuestCompleted")
            end
        end)
    end,
    ["dailyGiftStreak"] = function(player: Player, set: number)
        local playerData = playerDataHandler.getPlayer(player)

        playerData:apply(function()
            if playerData.data.dailyGiftStreak > playerData.data.stats.longestDailyStreak then
                playerData.data.stats.longestDailyStreak = playerData.data.dailyGiftStreak
            end

            if playerData.data.stats.longestDailyStreak >= 100 then
                awardBadge(player, "100Streak")
            end
        end)
    end,
    ["capsulesOpened"] = function(player: Player, increment: number)
        local playerData = playerDataHandler.getPlayer(player)

        playerData:apply(function()
            playerData.data.stats.capsulesOpened += increment

            if playerData.data.stats.capsulesOpened >= 1 then
                awardBadge(player, "firstCpsule")
            end
            if playerData.data.stats.capsulesOpened >= 100 then
                awardBadge(player, "100Capsule")
            end
            if playerData.data.stats.capsulesOpened >= 100000 then
                awardBadge(player, "100kCapsule")
            end
            if playerData.data.stats.capsulesOpened >= 1000000 then
                awardBadge(player, "1mCapsule")
            end
        end)
    end,
    ["hoursSpent"] = function(player: Player, set: number)
        local playerData = playerDataHandler.getPlayer(player)

        playerData:apply(function()
            playerData.data.stats.hoursSpent = set

            if playerData.data.stats.hoursSpent >= 10 then
                awardBadge(player, "10Hour")
            end
            if playerData.data.stats.hoursSpent >= 50 then
                awardBadge(player, "50Hour")
            end
            if playerData.data.stats.hoursSpent >= 1000 then
                awardBadge(player, "1000Hour")
            end
        end)
    end,
    ["legendarySwordUnlocked"] = function(player: Player, increment: number)
        local playerData = playerDataHandler.getPlayer(player)

        playerData:apply(function()
            playerData.data.stats.legendarySwordUnlocked += increment

            if playerData.data.stats.legendarySwordUnlocked >= 1 then
                awardBadge(player, "firstLegendarySword")
            end
        end)
    end,
}

local types = {
    ["firstLegendarySword"] = "legendarySwordUnlocked",
    ["firstQuestCompleted"] = "questsCompleted",
    ["100Streak"] = "dailyGiftStreak",
    ["firstCpsule"] = "capsulesOpened",
    ["100Capsule"] = "capsulesOpened",
    ["100kCapsule"] = "capsulesOpened",
    ["1mCapsule"] = "capsulesOpened",
    ["10Hour"] = "hoursSpent",
    ["50Hour"] = "hoursSpent",
    ["1kHours"] = "hoursSpent",
}

local incrementProgress = function(player: Player, badgeName: string, param: number)
    
    if badgeName == "thanksForPlaying" then
        return awardBadge(player, "thanksForPlaying")
    elseif badgeName == "metADev" then
        return awardBadge(player, "metADev")
    elseif badgeName == "emptiedTheShop" then
        return awardBadge(player, "emptiedTheShop")
    elseif badgeName == "legendaryCollector" then
        return awardBadge(player, "legendaryCollector")
    end

    return funcs[badgeName](player, param)
end

return {
    incrementProgress = incrementProgress,
}