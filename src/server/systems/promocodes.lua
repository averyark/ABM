--!strict
--[[
    FileName    > promocodes.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/05/2023
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

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local codes = {
    ["LAUNCH516"] = function(player: Player)
        local playerData = playerDataHandler.getPlayer(player)
        playerData:apply(function(f)
			f.data.stats.itemsObtained.weapon += 1
			table.insert(f.data.inventory.weapon, {
				index = f.data.stats.itemsObtained.weapon,
				id = 28,
				level = 0,
			})
		end)
		BridgeNet.CreateBridge("itemObtained"):FireTo(player, "weapon", 28, 1)
        return true
    end
}

return {
    load = function()
        BridgeNet.CreateBridge("claimPromocode"):OnInvoke(function(player: Player, code: string)
            local playerData = playerDataHandler.getPlayer(player)
            if not playerData then return false, "An error occured 1-1" end

            local codeFunc = codes[code]
            if not codeFunc then return false, "Invalid code entered" end

            if table.find(playerData.data.usedCodes, code) then
                return false, "Already claimed"
            end

            if codeFunc(player) then
                playerData:apply(function()
                    table.insert(playerData.data.usedCodes, code)
                end)
            end

            return true
        end)
    end
}