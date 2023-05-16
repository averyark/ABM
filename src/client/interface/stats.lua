--!strict
--[[
    FileName    > stats.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 15/03/2023
--]]
local LocalizationService = game:GetService("LocalizationService")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

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
local main = require(script.Parent.main)

local bridges = {
    retrieveLeaderboard = BridgeNet.CreateBridge("retrieveLeaderboard"),
    updateLeaderboard = BridgeNet.CreateBridge("updateLeaderboard")
}

local getCountryEmoji = function(country: string)
    local code = string.upper(country)
    local first = string.byte(string.sub(code, 1, 1)) - 0x41 + 0x1F1E6
    local second = string.byte(string.sub(code, 2, 2)) - 0x41 + 0x1F1E6
    return utf8.char(first) .. utf8.char(second)
end

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

local currentPage

local changePage = function(pageName: string)
    local statsUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("stats")

    if pageName == "stats" then
        statsUi.mainframe.upper.container.icon.Image = "rbxassetid://13239094651"
        statsUi.mainframe.upper.container.title.Text = "Stats"
    elseif pageName == "hoursSpent" then
        statsUi.mainframe.upper.container.icon.Image = "rbxassetid://13393115243"
        statsUi.mainframe.upper.container.title.Text = "Top Hours Spent"
    elseif pageName == "power" then
        statsUi.mainframe.upper.container.icon.Image = "rbxassetid://13393115243"
        statsUi.mainframe.upper.container.title.Text = "Top Power"
    elseif pageName == "capsulesOpened" then
        statsUi.mainframe.upper.container.icon.Image = "rbxassetid://13393115243"
        statsUi.mainframe.upper.container.title.Text = "Top Capsules Opened"
    end

    for _, object in pairs(statsUi.mainframe.lower:GetChildren()) do
        if object.Name == pageName then
            object.Visible = true
            continue
        end
        object.Visible = false
    end
end

return {
    load = function()
        local statsUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("stats")
        local statsFrame = statsUi.mainframe.lower:WaitForChild("stats")

        local changeStat = function(name, value)
            local frame = statsFrame.scroll:FindFirstChild(name)
            frame.number.Text = value
        end
        
        local stats = {
            xpMultiplier = function()
                playerDataHandler:connect({"upgrades"}, function()
                    changeStat("xpMultiplier", ("x%.2f"):format(getValueFromUpgrades("Fast Learner")))
                end)
            end,
            coinsMultiplier = function()
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
                    changeStat("coinsMultiplier", ("x%s"):format(
                        getValueFromUpgrades("Coin Magnet")
                        + getTotalMulti()
                        + levels[playerDataHandler.getPlayer().data.level].multiplier
                        + ascension.getPowerMultiplier(playerDataHandler.getPlayer().data.ascension)
                    ))
                end
                playerDataHandler:connect({"ascension"}, changed)
                playerDataHandler:connect({"upgrades"}, changed)
                playerDataHandler:connect({"level"}, changed)
                playerDataHandler:connect({"equipped", "hero"}, changed)
            end,
            capsulesOpened = function()
                playerDataHandler:connect({"stats", "capsulesOpened"}, function(changes)
                    changeStat("capsulesOpened", number.abbreviate(changes.new, 2))
                end)
            end,
            timeSpent = function()
                playerDataHandler:connect({"stats", "hoursSpent"}, function(changes)
                    changeStat("timeSpent", number.abbreviate(changes.new, 2))
                end)
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
                playerDataHandler:connect({"stats", "coinsCollected"}, function(changes)
                    changeStat("coinsCollected", number.abbreviate(changes.new, 2))
                end)
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
            statsFrame.level.Text = "Lv. " .. changes.new
        end)


        for _, button in pairs(statsUi.mainframe.buttons:GetChildren()) do
            if button:IsA("TextButton") then
                main:button(button).Activated:Connect(function()
                    changePage(button.Name)
                end)
            end
        end

        local frames = {
            power = statsUi.mainframe.lower:WaitForChild("power"),
            hoursSpent = statsUi.mainframe.lower:WaitForChild("hoursSpent"),
            capsulesOpened = statsUi.mainframe.lower:WaitForChild("capsulesOpened"),
        }

        local texts = {
            power = "POWER",
            hoursSpent = "HOURS SPENT",
            capsulesOpened = "CAPSULES OPENED"
        }

        local countryCode = LocalizationService:GetCountryRegionForPlayerAsync(Players.LocalPlayer)
        local countryEmoji = getCountryEmoji(countryCode)

        for _, frame in pairs(frames) do
            frame.buttons["local"].info.label.Text = countryEmoji .. " Local"
            for _, button in pairs(frame.buttons:GetChildren()) do
                if button:IsA("TextButton") then
                    main:button(button)
                end
            end
        end

        statsFrame.username.Text = countryEmoji .. " " .. Players.LocalPlayer.Name
        statsFrame.thumbnail.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

        local cache = {}

        local getValue = function(statName)
            local playerData = playerDataHandler.getPlayer().data
            
            if statName == "hoursSpent" then
                return number.abbreviate(math.round(playerData.stats.hoursSpent or 0), 2)
            elseif statName == "power" then
                return statsUi.Parent.hud.currencies.power.inner.label.Text
            elseif statName == "capsulesOpened" then
                return number.abbreviate(math.round(playerData.stats.capsulesOpened or 0), 2)
            end
        end

        local leaderboards = workspace.gameFolders.leaderboards:GetChildren()

        for _, leaderboard in pairs(leaderboards) do
            local gui = ReplicatedStorage.resources.leaderboardGui:Clone()
            gui.Adornee = leaderboard.display
            gui.Parent = statsUi.Parent.leaderboards
            gui.Name = leaderboard.Name
            gui.title.Text = "TOP 100 " .. texts[leaderboard.Name]
        end

        local lastUpdate = 0

        bridges.updateLeaderboard:Connect(function(_new)
            if not _new then return end
            if os.clock() - lastUpdate < 5 then
                return
            end
            lastUpdate = os.clock()
            cache = _new

            for name, instance in pairs(frames) do

                local leaderboard = statsUi.Parent.leaderboards:FindFirstChild(name)

                for _, object in pairs(instance.container.global.scroll:GetChildren()) do
                    if object:IsA("Frame") then
                        object:Destroy()
                    end
                end
                for _, object in pairs(leaderboard.container:GetChildren()) do
                    if object:IsA("Frame") then
                        object:Destroy()
                    end
                end
                for rank, data in pairs(_new[name] or {}) do
                    Promise.try(function()
                        local userid = data.key
                        local value = data.value
                        local region = data.region
                        local username = Players:GetNameFromUserIdAsync(userid)

                        local entryTemplate = ReplicatedStorage.resources.entryGui:Clone()
    
                        entryTemplate.LayoutOrder = rank
                        entryTemplate.Name = rank
                        entryTemplate.title.Text = "#" .. rank
                        entryTemplate.number.Text = number.abbreviate(value, 2)
                        entryTemplate.username.Text = username
                        entryTemplate.Parent = instance.container.global.scroll
                        if region then
                            entryTemplate.username.Text = (if tostring(userid) == "540209459" then "🪐" else getCountryEmoji(region)) .. " " .. username
                        end
                        entryTemplate.ImageLabel.Image = Players:GetUserThumbnailAsync(userid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

                        local entry3d = ReplicatedStorage.resources.entry:Clone()

                        entry3d.LayoutOrder = rank
                        entry3d.Name = rank
                        entry3d.title.Text = "#" .. rank
                        entry3d.number.Text = number.abbreviate(value, 2)
                        entry3d.username.Text = username
                        entry3d.Parent = leaderboard.container
                        if region then
                            entry3d.username.Text = (if tostring(userid) == "540209459" then "🪐" else getCountryEmoji(region)) .. " " .. username
                        end
                        entry3d.ImageLabel.Image = Players:GetUserThumbnailAsync(userid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    end)
                end
                local userid = tostring(Players.LocalPlayer.UserId)
                local rank
                local value = getValue(name)
                local region = LocalizationService:GetCountryRegionForPlayerAsync(Players.LocalPlayer)
                local username = Players.LocalPlayer.Name

                for _rank, data in pairs(_new[name] or {}) do
                    if data.key == userid then
                        rank = _rank
                    end
                end

                local entry = instance.container.global.entry
                local entry3d = leaderboard.entry

                entry.title.Text = rank and "#" .. rank or "#..."
                entry.number.Text = value
                entry.username.Text = username
                
                if region then
                    entry.username.Text = (if tostring(userid) == "540209459" then "🪐" else getCountryEmoji(region)) .. " " .. username
                end
                entry.ImageLabel.Image = Players:GetUserThumbnailAsync(userid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

                entry3d.title.Text = rank and "#" .. rank or "#..."
                entry3d.number.Text = value
                entry3d.username.Text = username
                
                if region then
                    entry3d.username.Text = (if tostring(userid) == "540209459" then "🪐" else getCountryEmoji(region)) .. " " .. username
                end
                entry3d.ImageLabel.Image = Players:GetUserThumbnailAsync(tostring(userid), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end
        
        end)

        local first = false
        playerDataHandler:connect({"stats"}, function(changes)
            if first then return end
            first = true
            bridges.retrieveLeaderboard:Fire()
        end)

        changePage("stats")
    end
}