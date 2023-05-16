--!strict
--[[
    FileName    > chests.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 28/04/2023
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local bridges = {
    claimChest = BridgeNet.CreateBridge("claimChest"),
    claimGroup = BridgeNet.CreateBridge("claimGroup"),
}

local getCountdown = function(n)
    local h = math.floor(n/3600)
    local m = math.floor((n - h*3600)/60)
    local s = n%60
    
    return h, m, s
end

local getCountdownFormat = function(n: number)
    return string.format("%i:%02i:%02i", getCountdown(n))
end

return {
    load = function()
        local playerData = playerDataHandler.getPlayer()

        task.spawn(function()
            local groupChest = workspace.gameFolders.groupChest["1"]
            while true do
                task.wait(1)
                local worldIndex = playerData.data.currentWorld
                local lastGroupClaim = playerData.data.lastGroupChest
                if worldIndex == 1 then
                    
                    local character = Players.LocalPlayer.Character
                    if os.time() > lastGroupClaim+86400 then
                        groupChest.Part.Billboard.Rewarding.Text = "CLAIM NOW"

                        if character then
                            local distanceFromCentre = (character.HumanoidRootPart.CFrame.Position - groupChest.Hitbox.CFrame.Position).Magnitude

                            if distanceFromCentre < 10 then
                                bridges.claimGroup:Fire()
                            end
                        end
                    else
                        groupChest.Part.Billboard.Rewarding.Text = getCountdownFormat(lastGroupClaim+86400 - os.time())
                    end
                end

                local chest = workspace.gameFolders.chest:FindFirstChild(worldIndex)
                if not chest then return end

                local lastClaim = playerData.data.chests[worldIndex]
    
                if os.time() > lastClaim+3600 then
                    chest.Billboard.Rewarding.Text = "CLAIM NOW"

                    local character = Players.LocalPlayer.Character
                    if not character then
                        continue
                    end
                    local distanceFromCentre = (character.HumanoidRootPart.CFrame.Position - chest.Hitbox.CFrame.Position).Magnitude

                    if distanceFromCentre < 10 then
                        bridges.claimChest:Fire(worldIndex)
                    end
                else
                    chest.Billboard.Rewarding.Text = getCountdownFormat(lastClaim+3600 - os.time())
                end
            end
        end)

    end
}