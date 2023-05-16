--!strict
--[[
    FileName    > gift.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 13/04/2023
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
local productHandler = require(script.Parent.productHandler)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local giftsData = require(ReplicatedStorage.shared.gifts)
local badges = require(script.Parent.badges)

local bridges = {
    updateGift = BridgeNet.CreateBridge("updateGift"),
    requestOpenGift = BridgeNet.CreateBridge("requestOpenGift"),
    giftOpened = BridgeNet.CreateBridge("giftOpened"),
    claimChest = BridgeNet.CreateBridge("claimChest"),
    notifError = BridgeNet.CreateBridge("notifError"),
    notifMessage = BridgeNet.CreateBridge("notifMessage"),
    claimGroup = BridgeNet.CreateBridge("claimGroup"),
}

local random = Random.new()

local getGifts = function(player: Player)
    local data = playerDataHandler.getPlayer(player).data

    local gifts = table.clone(data.gifts)

    if os.time() - data.lastDailyGift > 86400 then
        table.insert(gifts, "daily")
    end

    return gifts
end

local updateGift = function(player: Player)
    bridges.updateGift:FireTo(player, getGifts(player))
end

local getChoiceFromChancePool = function(chancePool)
    local randomNumber = math.random()
    local n = 0
    for i, chance in pairs(chancePool) do
        if chance + n > randomNumber then
            return i
        end
        n += chance
    end
end

local openGift = function(player: Player)
    local playerData = playerDataHandler.getPlayer(player)

    local gifts = getGifts(player)

    if #gifts < 1 then
        return
    end

    local giftType = gifts[1]
    local rewards = {
        default = {},
        streak = {}
    }

    local highest

    for _, world in pairs(playerData.data.unlockedWorlds) do
        if highest then
            if world > highest then
                highest = world
            end
        else
            highest = world
        end
    end

    if giftType == "daily" then
        local dat = giftsData[highest]

        local reward = function(type, tb)
            if type == "coin" then
                local value = playerData.data.coins * random:NextNumber(
                    dat.normal.coinReward.min,
                    dat.normal.coinReward.max
                )
                table.insert(tb, {
                    type = "coin",
                    value = value
                })
                playerData:apply(function()
                    playerData.data.stats.coinsCollected += value
                    playerData.data.coins += value
                end)
            elseif type == "sword" then
                local id = getChoiceFromChancePool(dat.normal.swordRewards)
                table.insert(tb, {
                    type = "sword",
                    value = id
                })
                playerData:apply(function()
                    table.insert(playerData.data.stats.obtainedItemIndex.weapon, id)
                    playerData.data.stats.itemsObtained.weapon += 1
                    table.insert(playerData.data.inventory.weapon, {
                        index = playerData.data.stats.itemsObtained.weapon,
                        id = id,
                        level = 0,
                    })
                end)
            end
        end

        playerData:apply(function()
            if os.time() - playerData.data.lastDailyGift > 2*86400 then
                playerData.data.dailyGiftStreak = 1
            else
                playerData.data.dailyGiftStreak += 1
            end
            playerData.data.lastDailyGift = os.time()
            
            badges.incrementProgress(player, "dailyGiftStreak", playerData.data.dailyGiftStreak)
        end)

        reward("coin", rewards.default)
        reward("sword", rewards.default)

        if playerData.data.dailyGiftStreak >= 14 then
            reward("sword", rewards.streak)
        end
        if playerData.data.dailyGiftStreak >= 7 then
            reward("sword", rewards.streak)
        end
        if playerData.data.dailyGiftStreak >= 3 then
            reward("coin", rewards.streak)
        end
        table.remove(gifts, 1)
    elseif giftType == "premium" then
        local dat = giftsData[highest]
        
        local reward = function(type, tb)
            if type == "coin" then
                local value = playerData.data.coins * random:NextNumber(
                    dat.premium.coinReward.min,
                    dat.premium.coinReward.max
                )
                table.insert(tb, {
                    type = "coin",
                    value = value
                })
                playerData:apply(function()
                    playerData.data.stats.coinsCollected += value
                    playerData.data.coins += value
                end)
            elseif type == "sword" then
                local id = getChoiceFromChancePool(dat.premium.swordRewards)
                table.insert(tb, {
                    type = "sword",
                    value = id
                })
                playerData:apply(function()
                    table.insert(playerData.data.stats.obtainedItemIndex.weapon, id)
                    playerData.data.stats.itemsObtained.weapon += 1
                    table.insert(playerData.data.inventory.weapon, {
                        index = playerData.data.stats.itemsObtained.weapon,
                        id = id,
                        level = 0,
                    })
                end)
            end
        end

        reward("coin", rewards.default)
        reward("coin", rewards.default)
        reward("sword", rewards.default)

        if playerData.data.dailyGiftStreak >= 14 then
            reward("sword", rewards.streak)
        end
        if playerData.data.dailyGiftStreak >= 7 then
            reward("sword", rewards.streak)
        end
        if playerData.data.dailyGiftStreak >= 3 then
            reward("coin", rewards.streak)
        end

        playerData:apply(function()
            table.remove(playerData.data.gifts, 1)
        end)
    end

    bridges.giftOpened:FireTo(player, giftType, rewards, playerData.data.dailyGiftStreak)
end

return {
    load = function()
        productHandler.productHandlers[1528159465] = function(player: Player, receipt: productHandler.receiptInfo, resolve, reject)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then
                return reject("playerData does not exist")
            end
            
            playerData:apply(function()
                table.insert(playerData.data.gifts, "premium")
                resolve()
            end)
        end
        bridges.claimChest:Connect(function(player: Player, worldIndex: number)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            local lastClaim = playerData.data.chests[worldIndex]
            if not lastClaim then return end

            if playerData.data.currentWorld ~= worldIndex then
                return bridges.notifError:FireTo(player, "Error: You cannot claim this chest from another world.")
            end

            if os.time() < lastClaim+3600 then
                return bridges.notifError:FireTo(player, "Error: Not time yet!")
            end

            local reward = playerData.data.coins* random:NextNumber(0.005, 0.02)+1500

            playerData:apply(function()
                playerData.data.stats.coinsCollected += reward
                playerData.data.coins += reward
                playerData.data.chests[worldIndex] = os.time()
            end)

            bridges.notifMessage:FireTo(player, `You found {number.abbreviate(reward, 2)} coins inside the chest!`)
        end)
        bridges.claimGroup:Connect(function(player: Player)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            local lastClaim = playerData.data.lastGroupChest
            if not lastClaim then return end

            if not player:IsInGroup(16352731) then
                return bridges.notifError:FireTo(player, "Join the group to claim this chest.")
            end

            if playerData.data.currentWorld ~= 1 then
                return bridges.notifError:FireTo(player, "Error: You cannot claim this chest from another world.")
            end

            if os.time() < lastClaim+86400 then
                return bridges.notifError:FireTo(player, "Error: Not time yet!")
            end

            local reward = playerData.data.coins* random:NextNumber(0.1, 0.15)+1400

            playerData:apply(function()
                playerData.data.stats.coinsCollected += reward
                playerData.data.coins += reward
                playerData.data.lastGroupChest = os.time()
            end)

            bridges.notifMessage:FireTo(player, `You found {number.abbreviate(reward, 2)} coins inside the chest!`)
        end)
        bridges.requestOpenGift:Connect(openGift)
        bridges.updateGift:Connect(updateGift)
    end
}