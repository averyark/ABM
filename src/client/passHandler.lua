--!strict
--[[
    FileName    > passHandler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 20/04/2023
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
    getOwnedPasses = BridgeNet.CreateBridge("getOwnedPasses"),
    getPasses = BridgeNet.CreateBridge("getPasses"),
    passPurchased = BridgeNet.CreateBridge("passPurchased")
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

local cache = {}
local handlers = {}

local once = function(passName: string, handler: () -> ())
    handlers[handler] = passName

    if table.find(cache, passName) then
        handler()
    end
end

local ownPass = function(passName: string)
    if table.find(cache, passName) then
        return true
    end
    return false
end

local promptPass = function(passName: string)
    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gamepasses[passName])
end

return {
    promptPass = promptPass,
    once = once,
    ownPass = ownPass,
    load = function()
        task.spawn(function()
            for _, passName in pairs(bridges.getOwnedPasses:InvokeServerAsync()) do
                if not table.find(cache, passName) then
                    table.insert(cache, passName)
                end
                for handler, _passName in pairs(handlers) do
                    if _passName == passName then
                        Promise.try(handler)
                    end
                end
            end
        end)
        bridges.passPurchased:Connect(function(passName: string)
            if not table.find(cache, passName) then
                table.insert(cache, passName)
            end
            for handler, _passName in pairs(handlers) do
                if _passName == passName then
                    Promise.try(handler)
                end
            end
        end)
    end
}