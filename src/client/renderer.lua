--!strict
--[[
    FileName    > renderer.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 27/04/2023
--]]
local ContentProvider = game:GetService("ContentProvider")
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
local loading = require(script.Parent.interface.loading)
local presets = ReplicatedStorage.lightingPresets

local loadLightingPreset = function(presetName: string)
    local preset = presets:FindFirstChild(presetName)

    assert(preset, "presetName> none")

    local lightingProperties = require(preset)
    local lightingEffects = preset:GetChildren()

    for _, object in pairs(Lighting:GetChildren()) do
        if object.Name:match("^_") then continue end
        object:Destroy()
    end

    for _, instance in pairs(lightingEffects) do
        instance:Clone().Parent = Lighting
    end

    for property, value in pairs(lightingProperties) do
        Lighting[property] = value
    end
end

local resetLighting = function()
    loadLightingPreset(`World{playerDataHandler.getPlayer().data.currentWorld}`)
end

return {
    resetLighting = resetLighting,
    loadLightingPreset = loadLightingPreset,
    load = function()
        local maps: {Folder} = {}

        for _, map in pairs(workspace.gameFolders.map:GetChildren()) do
            maps[tonumber(map.Name)] = map
        end

        Players.LocalPlayer.CharacterAdded:Connect(function(character)
            character:WaitForChild("HumanoidRootPart").CFrame = workspace.gameFolders.spawnPoints:FindFirstChild(playerDataHandler.getPlayer().data.currentWorld).CFrame + Vector3.new(0, 5, 0)
        end)

        playerDataHandler:connect({"currentWorld"}, function(changes)
            if changes.new and not changes.old then
                local map = maps[changes.new]
                loadLightingPreset(`World{changes.new}`)
                for mapIndex, _map in pairs(maps) do
                    if mapIndex == changes.new then
                        _map.Parent = workspace.gameFolders.map
                    else
                        _map.Parent = ReplicatedFirst.maps
                    end
                end
                Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.gameFolders.spawnPoints:FindFirstChild(changes.new).CFrame + Vector3.new(0, 5, 0)              
                return
            end
            for mapIndex, map in pairs(maps) do
                if mapIndex == changes.new then
                    loading.loadingTo(mapIndex)
                    loadLightingPreset(`World{mapIndex}`)
                    map.Parent = workspace.gameFolders.map
                    Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.gameFolders.spawnPoints:FindFirstChild(changes.new).CFrame + Vector3.new(0, 5, 0)
                    ContentProvider:PreloadAsync(map:GetChildren())
                    loading.loadingEnd()
                else
                    map.Parent = ReplicatedFirst.maps
                    print("reparenting")
                end
            end
        end)
    end
}