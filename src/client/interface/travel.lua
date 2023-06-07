--!strict
--[[
    FileName    > travel.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 25/04/2023
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
local passHandler = require(script.Parent.Parent.passHandler)
local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)
local notifications = require(script.Parent.notifications)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local worlds = require(ReplicatedStorage.shared.zones)
local main = require(script.Parent.main)

return {
    load = function()
        local fastTravelUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("fastTravel")

        local purchaseConfirmation = fastTravelUi.Parent.purchaseConfirmation

        main.initUi(purchaseConfirmation)

        playerDataHandler:connect({"unlockedWorlds"}, function(changes)
            for _, worldIndex in pairs(changes.new) do
                local frame = fastTravelUi.mainframe.lower.scroll:FindFirstChild(worldIndex)
                if frame then
                    frame.cost.Visible = false
                    frame.desc.Visible = true
                    frame.lock.Visible = false
                end
            end
        end)
        for _, frame in pairs(fastTravelUi.mainframe.lower.scroll:GetChildren()) do
            if not frame:IsA("TextButton") then continue end
            local worldIndex = tonumber(frame.Name)

            frame.cost.label.Text = number.abbreviate(worlds[worldIndex].cost or 0, 2)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    tween.instance(frame.scale, {
                        Scale = 1,
                    }, .15, "Back")
                end
            end)
            frame.Activated:Connect(function()
                if not passHandler.ownPass("FastTrvel") then
                    passHandler.promptPass("FastTravel")
                    return notifications.new():error("Error: You need the Fast Travel gamepass to use this feature!")
                end
                if playerDataHandler.getPlayer().data.currentWorld == worldIndex then
                    return notifications.new():error("Error: You cannot teleport to the world you're in!")
                end
                if not table.find(playerDataHandler.getPlayer().data.unlockedWorlds, worldIndex) then
                    purchaseConfirmation.mainframe.lower.desc.Text = `You're spending <font color="rgb(255, 186, 107)">{number.abbreviate(worlds[worldIndex].cost or 0, 2)}</font> coins to purchase the world Attack on Titan.`
                    main.focus(purchaseConfirmation)
                end
            end)
            frame.MouseButton1Down:Connect(function()
                tween.instance(frame.scale, {
                    Scale = .98,
                }, .15, "Back")
            end)
            frame.MouseLeave:Connect(function()
                tween.instance(frame.stroke, {
                    Color = Color3.fromRGB(66, 79, 108)
                }, .15, "Back")
                tween.instance(frame.scale, {
                    Scale = 1,
                }, .15, "Back")
            end)
            frame.MouseEnter:Connect(function()
                tween.instance(frame.stroke, {
                    Color = Color3.fromRGB(121, 145, 197)
                }, .15, "Back")
                tween.instance(frame.scale, {
                    Scale = 1.02,
                }, .15, "Back")
            end)

            local confirm = purchaseConfirmation.mainframe.lower.confirm

            confirm.Activated:Connect(function(inputObject, clickCount)
                main.focus(fastTravelUi)
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    tween.instance(confirm.scale, {
                        Scale = 1,
                    }, .15, "Back")
                end
            end)
            confirm.MouseButton1Down:Connect(function()
                tween.instance(confirm.scale, {
                    Scale = .95,
                }, .15, "Back")
            end)
            confirm.MouseLeave:Connect(function()
                tween.instance(confirm.innerOutline.stroke, {
                    Color = Color3.fromRGB(108, 73, 48)
                }, .15, "Back")
                tween.instance(confirm.scale, {
                    Scale = 1,
                }, .15, "Back")
            end)
            confirm.MouseEnter:Connect(function()
                tween.instance(confirm.innerOutline.stroke, {
                    Color = Color3.fromRGB(181, 122, 80)
                }, .15, "Back")
                tween.instance(confirm.scale, {
                    Scale = 1.05,
                }, .15, "Back")
            end)

        end
    end
}