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
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

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
    clientClicked = BridgeNet.CreateBridge("clientClicked")
}

return {
    load = function()
        local currentTween
        local clickFrame = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("click").frame

        UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
            if gameProcessed then return end
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                if currentTween then
                    currentTween:Destroy()
                end

                bridges.clientClicked:Fire()

                currentTween = tween.instance(clickFrame, {
                    BackgroundTransparency = .7,
                    Size = UDim2.fromOffset(50, 50)
                }, .1)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                if currentTween then
                    currentTween:Destroy()
                end
                currentTween = tween.instance(clickFrame, {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, 0)
                }, .2)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(inputObject, gameProcessed)
            if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                clickFrame.Position = UDim2.fromOffset(inputObject.Position.X, inputObject.Position.Y)
            end
        end)
    end
}