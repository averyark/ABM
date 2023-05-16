--!strict
--[[
    FileName    > productHandler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 26/04/2023
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
local ascension = require(ReplicatedStorage.shared.ascension)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local worlds = require(ReplicatedStorage.shared.zones)

export type receiptInfo = {
    PruchaseId: string,
    PlayerId: number,
    ProductId: number,
    PlaceIdWherePurchased: number,
    CurrencySpent: number,
}

local productHandlers = {}

local percentage = {
	[1] = 0.05,
	[2] = 0.21,
	[3] = 0.52,
	[4] = 0.73,
	[5] = 1.04,
	[6] = 1.55,
}

local coinProducts = {
	[1] = 1527695918,
	[2] = 1527696509,
	[3] = 1527696870,
	[4] = 1527697145,
	[5] = 1527697251,
	[6] = 1527697483,
}

local handleCoinProduct = function(player: Player, receipt: receiptInfo, resolve, reject)
    local index = table.find(coinProducts, receipt.ProductId)
    if not percentage[index] then
        return reject("invalid productid: index pointer null")
    end

    local playerData = playerDataHandler.getPlayer(player)
    if not playerData then
        return reject("playerData does not exist")
    end

    playerData:apply(function()
        local highestIndex = 0
        for _, indexj in pairs(playerData.data.unlockedWorlds) do
            if indexj > highestIndex then
                highestIndex = indexj
            end
        end
        local num = worlds[highestIndex].cost*percentage[index]

        playerData.data.coins += num
        playerData.data.stats.coinsCollected += num

        BridgeNet.CreateBridge("notifMessage"):FireTo(player, `You're rewarded {number.abbreviate(num, 0)} Coins!`)

        resolve()
    end)
end

return {
    productHandlers = productHandlers :: {(player: Player, receiptInfo: receiptInfo, resolve: () -> (), reject: () -> () ) -> ()},
    load = function()

        for _, productId in pairs(coinProducts) do
            productHandlers[productId] = handleCoinProduct
        end

        MarketplaceService.ProcessReceipt = function(receiptInfo: receiptInfo)
            warn("Receipt:", receiptInfo)
            local player
            for _, instance in pairs(Players:GetPlayers()) do
                if receiptInfo.PlayerId == instance.UserId then
                    player = instance
                end
            end


            if not player then
                return Enum.ProductPurchaseDecision.NotProcessedYet
            end
            if productHandlers[receiptInfo.ProductId] then

                local status = Promise.new(function(...)
                    productHandlers[receiptInfo.ProductId](player, receiptInfo, ...)
                end):awaitStatus()

                if status == "Resolved" then
                    BridgeNet.CreateBridge("notifMessage"):FireTo(player, "Product Purchase Granted. Thanks for purchasing! ")
                    return Enum.ProductPurchaseDecision.PurchaseGranted
                end
            end
            BridgeNet.CreateBridge("notifError"):FireTo(player, "Product Purchase Process Failure. Rejoining might fix this, if not, contact a Developer.")
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end
}