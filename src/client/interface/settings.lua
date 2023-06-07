--!strict
--[[
    FileName    > settings.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 15/03/2023
--]]
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

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local bridges = {
    changeSetting = BridgeNet.CreateBridge("changeSetting")
}

local cacheLocal = {}

return {
    playSound = function(object)
        local playerData = playerDataHandler.getPlayer().data
        if object.Name ~= "music" and not playerData.settings[1] then
            return
        end
        if object.Name == "music" and not playerData.settings[2] then
            return
        end
        SoundService:PlayLocalSound(object)
    end,
    load = function()
        local settings = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("settings")
        
        for _, frame in pairs(settings.mainframe.lower.scroll:GetChildren()) do
            if frame:IsA("Frame") then
                frame.button.Activated:Connect(function()
                    local id = tonumber(frame.Name)
                    if cacheLocal[id] == nil then
                        return
                    end
                    cacheLocal[id] = not cacheLocal[id]
                    bridges.changeSetting:Fire(id, cacheLocal[id])
                    if cacheLocal[id] then
                        frame.button.boolean.Text = "ON"
                        tween.instance(frame.button, {
                            BackgroundColor3 = Color3.fromRGB(66, 255, 66)
                        }, .25)
                    else
                        frame.button.boolean.Text = "OFF"
                        tween.instance(frame.button, {
                            BackgroundColor3 = Color3.fromRGB(255, 66, 72)
                        }, .25)
                    end
                    if id == 2 then
                        if cacheLocal[id] then
                            SoundService.music.Volume = 0.5
                        else
                            SoundService.music.Volume = 0
                        end
                    end
                end)
            end
        end

        playerDataHandler:connect({"settings"}, function(changes)
            if not changes.old then
                for id, state in pairs(changes.new) do
                    local frame = settings.mainframe.lower.scroll:FindFirstChild(id)
                    if frame then
                        if state then
                            frame.button.boolean.Text = "ON"
                            tween.instance(frame.button, {
                                BackgroundColor3 = Color3.fromRGB(66, 255, 66)
                            }, .25)
                        else
                            frame.button.boolean.Text = "OFF"
                            tween.instance(frame.button, {
                                BackgroundColor3 = Color3.fromRGB(255, 66, 72)
                            }, .25)
                        end
                    end
                    cacheLocal[id] = state
                end
            end
        end)
    end
}