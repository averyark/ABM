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
local ascension = require(ReplicatedStorage.shared.ascension)
local heros = require(ReplicatedStorage.shared.heros)

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
                local changed = function()
                    changeStat("coinsMultiplier", ("x%.2f"):format(1 + getValueFromUpgrades("Coin Magnet") + ascension.getCoinMultiplier(playerDataHandler.getPlayer().data.ascension)))
                end
                playerDataHandler:connect({"upgrades"}, changed)
                playerDataHandler:connect({"ascension"}, changed)
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
            ascension = function()
            end,
            damageMultiplier = function()
                local data = playerDataHandler.getPlayer().data
                local findItemWithIndexId = function(tbl, id)
                    for _, dat in pairs(tbl) do
                        if dat.index == id then
                            return dat
                        end
                    end
                end
                local find = function<t>(id: t & number): typeof(heros[t])
                    for _, dat in pairs(heros) do
                        if dat.id == id then
                            return dat
                        end
                    end
                    return nil
                end
                local getTotalMulti = function()
                    local m = 0
                    for _, indexId in pairs(data.equipped.hero) do
                        m += find(findItemWithIndexId(data.inventory.hero, indexId).id).multiplier 
                    end
                    return m
                end
                local changed = function()
                    changeStat("damageMultiplier", ("x%s"):format(
                        getValueFromUpgrades("Power Gain")
                        + getTotalMulti()
                        + levels[playerDataHandler.getPlayer().data.level].multiplier
                        + ascension.getPowerMultiplier(playerDataHandler.getPlayer().data.ascension)))
                end
                playerDataHandler:connect({"ascension"}, changed)
                playerDataHandler:connect({"upgrades"}, changed)
                playerDataHandler:connect({"level"}, changed)
                playerDataHandler:connect({"equipped", "hero"}, changed)
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