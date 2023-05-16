--!strict
--[[
    FileName    > capsules.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/04/2023
--]]
local MarketplaceService = game:GetService("MarketplaceService")
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
local pass = require(script.Parent.pass)
local capsules = require(ReplicatedStorage.shared.capsules)
local productHandler = require(script.Parent.productHandler)
local badge = require(script.Parent.badges)

local bridges = {
    capsuleOpened = BridgeNet.CreateBridge("capsuleOpened"),
    openCapsule = BridgeNet.CreateBridge("openCapsule"),
    playSound = BridgeNet.CreateBridge("playSound"),
    notifError = BridgeNet.CreateBridge("notifError")
}

local debounces = {}

return {
    
    load = function()
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

        Players.PlayerRemoving:Connect(function(player)
            debounces[player] = nil
        end)

        productHandler.productHandlers[1528675915] = function(player, receiptInfo, resolve, reject)
            local playerData = playerDataHandler.getPlayer(player)
            playerData:apply(function()
                playerData.data.premiumKey += 1
                resolve()
            end)
        end

        bridges.openCapsule:OnInvoke(function(player, id, type)
            if debounces[player] and os.clock() - debounces[player] < 4 then
                return bridges.notifError:FireTo(player, "Error: Ratelimited; You're sending too much requests.")
            end
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return end

            local capsule = capsules[id]

            local rewards = {}

            if type == "Open1" then
                if capsule.premium then
                    if playerData.data.premiumKey < 1 then
                        MarketplaceService:PromptProductPurchase(player, 1528675915)
                        bridges.notifError:FireTo(player, ("Error: You need a Premium Key to unlock."))
                        return
                    end
                else
                    if playerData.data.coins < capsule.cost then
                        bridges.notifError:FireTo(player, ("Error: Insufficient Coins. You need %s Coins"):format(number.abbreviate(capsule.cost - playerData.data.coins, 2)))
                        return
                    end
                end

                local hasInfinite = pass.hasPass(player, "InfiniteInventory")
                local hasHeroSpace = pass.hasPass(player, "25HeroSlots")
                local hasVIP = pass.hasPass(player, "VIP")
                local max = 15 +
                    (hasHeroSpace and 25 or 0) +
                    (hasVIP and 25 or 0)

                if not hasInfinite and #playerData.data.inventory.hero+1 > max then
                    bridges.notifError:FireTo(player, `Error: Insufficient Inventory Space! Trash { #playerData.data.inventory.hero - max} Hero(s) or purchase the gamepass.`)
                    pass.promptPassPurchase(player,
                        if hasVIP and hasHeroSpace then "InfiniteInventory"
                                elseif hasVIP then "VIP"
                                else  "25HeroSlots"
                    )
                    return
                end

                badge.incrementProgress(player, "capsulesOpened", 1)

                bridges.playSound:FireTo(player, SoundService.purchase)

                local reward = getChoiceFromChancePool(capsule.rewards)

                table.insert(rewards, reward)

                playerData:apply(function()
                    if capsule.premium then
                        playerData.data.premiumKey -= 1
                    else
                        playerData.data.coins -= capsule.cost
                    end
                    playerData.data.stats.itemsObtained.hero += 1
                    table.insert(playerData.data.inventory.hero, {
                        index = playerData.data.stats.itemsObtained.hero,
                        id = reward,
                        level = 1,
                    })
                end)
            elseif type == "Open3" then
                if not pass.hasPass(player, "3HeroUnlock") then
                    bridges.notifError:FireTo(player, "Error: Purchase \"Unlock 3 Hero\" to use this feature")
                    pass.promptPassPurchase(player, "3HeroUnlock")
                    return
                end
                if capsule.premium then
                    if playerData.data.premiumKey < 3 then
                        MarketplaceService:PromptProductPurchase(player, 1528675915)
                        bridges.notifError:FireTo(player, ("Error: You need 3 Premium Key to unlock."))
                        return
                    end
                else
                    if playerData.data.coins < capsule.cost*3 then
                        bridges.notifError:FireTo(player, ("Error: Insufficient Coins. You need %s Coins"):format(number.abbreviate(capsule.cost*3 - playerData.data.coins, 2)))
                        return
                    end
                end
                local hasInfinite = pass.hasPass(player, "InfiniteInventory")
                local hasHeroSpace = pass.hasPass(player, "25HeroSlots")
                local hasVIP = pass.hasPass(player, "VIP")
                local max = 15 +
                    (hasHeroSpace and 25 or 0) +
                    (hasVIP and 25 or 0)

                if not hasInfinite and #playerData.data.inventory.hero+3 > max then
                    bridges.notifError:FireTo(player, `Error: Insufficient Inventory Space! Trash { #playerData.data.inventory.hero - max} Hero(s) or purchase the gamepass.`)
                    pass.promptPassPurchase(player,
                        if hasVIP and hasHeroSpace then "InfiniteInventory"
                                elseif hasVIP then "VIP"
                                else  "25HeroSlots"
                    )
                    return
                end

                badge.incrementProgress(player, "capsulesOpened", 3)

                bridges.playSound:FireTo(player, SoundService.purchase)

                local selected1 = getChoiceFromChancePool(capsule.rewards)
                local selected2 = getChoiceFromChancePool(capsule.rewards)
                local selected3 = getChoiceFromChancePool(capsule.rewards)

                table.insert(rewards, selected1)
                table.insert(rewards, selected2)
                table.insert(rewards, selected3)

                playerData:apply(function()
                    if capsule.premium then
                        playerData.data.premiumKey -= 3
                    else
                        playerData.data.coins -= capsule.cost*3
                    end
                    playerData.data.stats.itemsObtained.hero += 1
                    table.insert(playerData.data.inventory.hero, {
                        index = playerData.data.stats.itemsObtained.hero,
                        id = selected1,
                        level = 1,
                    })
                    playerData.data.stats.itemsObtained.hero += 1
                    table.insert(playerData.data.inventory.hero, {
                        index = playerData.data.stats.itemsObtained.hero,
                        id = selected2,
                        level = 1,
                    })
                    playerData.data.stats.itemsObtained.hero += 1
                    table.insert(playerData.data.inventory.hero, {
                        index = playerData.data.stats.itemsObtained.hero,
                        id = selected3,
                        level = 1,
                    })
                end)
            elseif type == "Auto" then
                if capsule.premium then
                    return bridges.notifError:FireTo(player, "An error occured")
                end

                if not player:IsInGroup(16352731) then
                    bridges.notifError:FireTo(player, "Error: Join the group to unlock Auto opening!")
                    return
                end
                if playerData.data.coins < capsule.cost then
                    bridges.notifError:FireTo(player, ("Error: Insufficient Coins. You need %s Coins"):format(number.abbreviate(capsule.cost - playerData.data.coins, 2)))
                    return
                end

                local hasInfinite = pass.hasPass(player, "InfiniteInventory")
                local hasHeroSpace = pass.hasPass(player, "25HeroSlots")
                local hasVIP = pass.hasPass(player, "VIP")
                local max = 15 +
                    (hasHeroSpace and 25 or 0) +
                    (hasVIP and 25 or 0)

                if not hasInfinite and #playerData.data.inventory.hero+1 > max then
                    bridges.notifError:FireTo(player, `Error: Insufficient Inventory Space! Trash { #playerData.data.inventory.hero - max} Hero(s) or purchase the gamepass.`)
                    pass.promptPassPurchase(player,
                        if hasVIP and hasHeroSpace then "InfiniteInventory"
                                elseif hasVIP then "VIP"
                                else  "25HeroSlots"
                    )
                    return
                end

                badge.incrementProgress(player, "capsulesOpened", 1)

                bridges.playSound:FireTo(player, SoundService.purchase)

                local reward = getChoiceFromChancePool(capsule.rewards)

                table.insert(rewards, reward)

                playerData:apply(function()
                    playerData.data.coins -= capsule.cost
                    playerData.data.stats.itemsObtained.hero += 1
                    table.insert(playerData.data.inventory.hero, {
                        index = playerData.data.stats.itemsObtained.hero,
                        id = reward,
                        level = 1,
                    })
                end)
            end

            debounces[player] = os.clock()

            bridges.capsuleOpened:FireTo(player, rewards, id, type)
            return true
        end)
    end
}