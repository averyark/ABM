--!strict
--[[
    FileName    > health.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/05/2023
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
local upgrade = require(script.Parent.Parent.systems.upgrade)

return {
    load = function()
        local registerCharacter = function(player, character)
            character:WaitForChild("Humanoid").MaxHealth = 100 + upgrade.getValueFromUpgrades(player, "Armored") or 0
        end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                registerCharacter(player, character)
            end)
            if player.Character then
                registerCharacter(player, player.Character)
            end
            playerDataHandler.getPlayer(player):connect({"upgrades"}, function()
                local value = upgrade.getValueFromUpgrades(player, "Armored")
                
                if player.Character then
                    player.Character:WaitForChild("Humanoid").MaxHealth = 100 + value or 0
                end
            end)
        end)
    end
}