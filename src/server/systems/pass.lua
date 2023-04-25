--!strict
--[[
    FileName    > pass.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 19/04/2023
--]]
local MarketplaceService = game:GetService("MarketplaceService")
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

local bridges = {
    hasPass = BridgeNet.CreateBridge("hasPass"),
    getPasses = BridgeNet.CreateBridge("getPasses"),
    passPurchased = BridgeNet.CreateBridge("passPurchased"),
    getOwnedPasses = BridgeNet.CreateBridge("getOwnedPasses")
}

local gamepasses = {
	["3HeroEquip"] = 165398550, -- 3 Hero Equip
	["3HeroUnlock"] = 165399434, -- 3 Hero Unlock
	["50SwordSlots"] = 165400164, -- +50 Sword Slots
	["25HeroSlots"] = 165400602, -- +25 Hero Inventory
	["2xAscension"] = 165401869, -- 2x Ascension
	["2xCoin"] = 165402296, -- 2x Coin
	["DualWield"] = 165402526, -- Dual Wield
	["InfiniteInventory"] = 165402887, -- Infinite Inventory
	["Luck"] = 165403482, -- Luck
	["PremiumSword"] = 165404341, -- Premium Sword
	["FastTrvel"] = 165404934, -- Fast Travel
	["VIP"] = 165405435, -- VIP
}

local TESTING = true
local TEST = {
	["3HeroEquip"] = true, -- 3 Hero Equip
	["3HeroUnlock"] = true, -- 3 Hero Unlock
	["50SwordSlots"] = false, -- +50 Sword Slots
	["25HeroSlots"] = false, -- +25 Hero Inventory
	["2xAscension"] = true, -- 2x Ascension
	["2xCoin"] = false, -- 2x Coin
	["DualWield"] = true, -- Dual Wield
	["InfiniteInventory"] = false, -- Infinite Inventory
	["Luck"] = true, -- Luck
	["PremiumSword"] = false, -- Premium Sword
	["FastTrvel"] = true, -- Fast Travel
	["VIP"] = true, -- VIP
}

local cache = {}
local loaded = false

local cacheOwnPass = {}
local handlers = {}

local hasPass = function(player: Player, passName: string)
    local passId = gamepasses[passName]
    assert(passId, "unexpected passName")

    if TESTING then
        return TEST[passName] or false
    end

    if MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId) then
        if not cacheOwnPass[player] then
            cacheOwnPass[player] = {}
        end
        table.insert(cacheOwnPass[player], passId)
        return true
    end

    if cacheOwnPass[player] and table.find(cacheOwnPass[player], passId) then
        return true
    end

    return false
end

local once = function(passName: string, handler: (Player) -> ())
    handlers[handler] = passName

    for _, player in pairs(Players:GetPlayers()) do
        if hasPass(player, passName) then
            Promise.try(handler, player)
        end
    end
end

local promptPassPurchase = function(player: Player, passName: string)
    local passId = gamepasses[passName]
    assert(passId, "unexpected passName")

    MarketplaceService:PromptGamePassPurchase(player, passId)
end

local passPurchased = Signal.new()

return {
    once = once,
    hasPass = hasPass,
    passPurchased = passPurchased,
    promptPassPurchase = promptPassPurchase,
    load = function()

        MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
            if wasPurchased then
                if not cacheOwnPass[player] then
                    cacheOwnPass[player] = {}
                end
                table.insert(cacheOwnPass[player], gamePassId)
                local n
                for name, id in pairs(gamepasses) do
                    if gamePassId == id then
                       n = name
                       break
                    end
                end
                if not n then return end
                passPurchased:Fire(player, n)
                bridges.passPurchased:FireTo(player, n)
            end
        end)

        Players.PlayerRemoving:Connect(function(player)
            if cacheOwnPass[player] then
                cacheOwnPass[player] = nil
            end
        end)

        task.spawn(function()
            for _, id in pairs(gamepasses) do
                local passData = MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
                cache[id] = passData
            end
            loaded = true
        end)
        
        bridges.getOwnedPasses:OnInvoke(function(player)
            local tb = {}
            for passName in pairs(gamepasses) do
                if hasPass(player, passName) then
                    table.insert(tb, passName)
                end
            end
            return tb
        end)
        bridges.hasPass:OnInvoke(hasPass)
        bridges.getPasses:OnInvoke(function()
            if loaded then
                return cache
            end
            repeat
                task.wait()
            until loaded
            return cache
        end)

        passPurchased:Connect(function(player, passName)
            for handler, _passName in pairs(handlers) do
                if _passName == passName then
                    Promise.try(handler)
                end
            end
        end)
    end
}