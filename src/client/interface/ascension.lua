--!strict
--[[
    FileName    > ascension.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 16/03/2023
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
local main = require(script.Parent.main)

local blur = Instance.new("BlurEffect")
blur.Name = "__ASCENSION_BLUR"
blur.Enabled = false
blur.Size = 0
blur.Parent = Lighting

return {
    load = function()
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

        local ascension = playerGui:WaitForChild("ascension")
        local hud = playerGui:WaitForChild("hud")
        local activated = false

        ReplicatedStorage.test2.Event:Connect(function(old, new)
            main.unfocus()
            tween.instance(hud.currencies, {
                Position = UDim2.new(0, -250, 0.5, -40),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.buttons, {
                Position = UDim2.new(0, -231, 0.5, 60),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.level, {
                Position = UDim2.new(0.5, 0, 1, 0),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.rebirth, {
                Position = UDim2.new(1, -28, 1, 0),
            }, 0.3, "ExitExpressive")

            blur.Size = 0
            blur.Enabled = true
            activated = true
            tween.instance(blur, {
                Size = 13,
            }, .4, "EntranceExpressive")
            ascension.background.BackgroundTransparency = 1
            ascension.background.Visible = true
            tween.instance(ascension.background, {
                BackgroundTransparency = 0.6
            }, .4, "EntranceExpressive")
            ascension.icon.Position = UDim2.fromScale(0.5, 1.5)
            ascension.icon.Visible = true
            ascension.icon.number1.Text = old
            ascension.icon.number1.Visible = true
            ascension.icon.number1.TextTransparency = 0
            ascension.icon.number1.stroke.Transparency = 0
            ascension.icon.number2.Text = new
            ascension.icon.number2.TextTransparency = 1
            ascension.icon.number2.stroke.Transparency = 1
            ascension.icon.number2.Visible = true
            ascension.icon.number1.TextSize = 76
            tween.instance(ascension.icon, {
                Position = UDim2.fromScale(0.5, 0.5)
            }, .4, "EntranceExpressive").Completed:Wait()

            task.wait(.6)

            tween.instance(ascension.icon.number2, {
                TextTransparency = 0
            }, .3)
            tween.instance(ascension.icon.number2.stroke, {
                Transparency = 0
            }, .3)
            tween.instance(ascension.icon.number1.stroke, {
                Transparency = 1,
            }, .3)
            tween.instance(ascension.icon.number1, {
                TextTransparency = 1,
                TextSize = 96
            }, .5).Completed:Wait()
            
            task.wait(1)

            tween.instance(ascension.background, {
                BackgroundTransparency = 1
            }, .4, "ExitExpressive")
            tween.instance(blur, {
                Size = 0
            }, .4, "ExitExpressive")
            tween.instance(ascension.icon, {
                Position = UDim2.fromScale(0.5, 1.5)
            }, .4, "ExitExpressive")

            tween.instance(hud.currencies, {
                Position = UDim2.new(0, 0, 0.5, -40),
            }, 0.3, "EntranceExpressive")
            tween.instance(hud.buttons, {
                Position = UDim2.new(0, 8, 0.5, 66),
            }, 0.3, "EntranceExpressive")
            tween.instance(hud.level, {
                Position = UDim2.new(0.5, 0, 1, -48),
            }, 0.3, "EntranceExpressive")
            tween.instance(hud.rebirth, {
                Position = UDim2.new(1, -28, 1, -32),
            }, 0.3, "EntranceExpressive")
            task.wait(.4)
            activated = false
        end)

        RunService.RenderStepped:Connect(function(deltaTime)
            if not activated then return end
            ascension.icon.rays.Rotation = ascension.icon.rays.Rotation + 150*deltaTime
        end)

        playerDataHandler:connect({"rebirth"}, function(changes)
            playerGui.hud.rebirth.rebirth.Text = changes.new
        end)
    end
}