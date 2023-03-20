--!strict
--[[
    FileName    > stats.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 15/03/2023
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

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local upgrades = require(ReplicatedStorage.shared.upgrades)
local levels = require(ReplicatedStorage.shared.levels)

local getValueFromUpgrades = function(upgradeType)
    local playerData = playerDataHandler.getPlayer()
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
    load = function()
        local statsUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("stats")
        local changeStat = function(name, value)
            local frame = statsUi.mainframe.lower.scroll:FindFirstChild(name)
            frame.number.Text = value
        end
        
        local stats = {
            xpMultiplier = function()
                playerDataHandler:connect({"upgrades"}, function()
                    changeStat("xpMultiplier", ("x%.2f"):format(getValueFromUpgrades("Fast Learner")))
                end)
            end,
            coinsMultiplier = function()
                playerDataHandler:connect({"upgrades"}, function()
                    changeStat("coinsMultiplier", ("x%.2f"):format(1 + getValueFromUpgrades("Coin Magnet")))
                end)
            end,
            jump = function()
                changeStat("jump", 2)
            end,
            jumpBoost = function()
                
            end,
            walkSpeed = function()
                playerDataHandler:connect({"upgrades"}, function()
                    changeStat("walkSpeed", ("%s"):format(getValueFromUpgrades("Agility") + 16))
                end)
            end,
            xpCollected = function()
                playerDataHandler:connect({"stats", "xpCollected"}, function(changes)
                    changeStat("xpCollected", number.abbreviate(changes.new, 2))
                end)
            end,
            coinsCollected = function()
                
            end,
            rebirth = function()
                
            end,
            damageMultiplier = function()
                local changed = function()
                    changeStat("damageMultiplier", ("x%s"):format(getValueFromUpgrades("Power Gain") + levels[playerDataHandler.getPlayer().data.level].multiplier ))
                end
                playerDataHandler:connect({"upgrades"}, changed)
                playerDataHandler:connect({"level"}, changed)
            end,
            luck = function()
                playerDataHandler:connect({"upgrades"}, function()
                    changeStat("luck", ("%s%%"):format(getValueFromUpgrades("Luck")*100))
                end)
            end,
            sprintSpeed = function()
                playerDataHandler:connect({"upgrades"}, function()
                    changeStat("sprintSpeed", ("%s"):format(getValueFromUpgrades("Agility") + 24))
                end)
            end,
        }

        for name, f in pairs(stats) do
            task.spawn(f)
        end

        playerDataHandler:connect({"level"}, function(changes)
            statsUi.mainframe.lower.level.Text = "Lv. " .. changes.new
        end)

        statsUi.mainframe.lower.username.Text = Players.LocalPlayer.Name
        statsUi.mainframe.lower.thumbnail.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end
}