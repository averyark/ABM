--!strict
--[[
    FileName    > click.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/03/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
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
local weapons = require(ReplicatedStorage.shared.weapons)
local upgrade = require(script.Parent.upgrade)

local bridges = {
    clientClicked = BridgeNet.CreateBridge("clientClicked")
}

local threashold = {}

local threasholdCheck = function(player)
    local list = threashold[player]
   
    if #list >= 7 then
        return false
    end
    return true
end

return {
    load = function()
        Players.PlayerAdded:Connect(function(player)
            threashold[player] = {}
        end)
        Players.PlayerRemoving:Connect(function(player)
            threashold[player] = nil
        end)
        bridges.clientClicked:Connect(function(player)
            if not threasholdCheck(player) then return end
            table.insert(threashold[player], os.clock())

            local p = playerDataHandler.getPlayer(player)
            local id

            for _, dat in pairs(p.data.inventory.weapon) do
                if dat.index == p.data.equipped.weapon then
                    id = dat.id
                end
            end

            local a

            for _, dat in pairs(weapons) do
                if dat.id == id then
                    a = dat
                    break
                end
            end

            p:apply(function()
                p.data.coins += math.random(1, 3) * a.coin * (1 + upgrade.getValueFromUpgrades(player, "Coin Magnet"))
            end)
        end)
        
        local cleanup = 1
        
        RunService.Heartbeat:Connect(function(deltaTime)
            -- Cleanup
            local nowClock = os.clock()
            for player, list in pairs(threashold) do
                for index, clock in pairs(list) do
                    if nowClock - clock >= cleanup then
                        table.remove(list, index)
                    end
                end
            end
        end)
    end
}