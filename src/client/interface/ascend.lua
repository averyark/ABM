--!strict
--[[
    FileName    > ascend.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 11/04/2023
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local ascension = require(ReplicatedStorage.shared.ascension)
local passHandler = require(script.Parent.Parent.passHandler)

local updateAscensionFrame = function()
    local ui = Players.LocalPlayer.PlayerGui.ascend.mainframe
    local data = playerDataHandler.getPlayer().data
    local r = data.ascension
    local coinMulti = ascension.getCoinMultiplier(r+1) -- ascension.getCoinMultiplier(r)
    local powerMulti = ascension.getPowerMultiplier(r+1) -- ascension.getPowerMultiplier(r)

    local cost = ascension.getCost(r+1)

    ui.lower.cost.label.Text = number.abbreviate(cost, 2)
    ui.lower.a2.coin.label.Text = `{coinMulti}x Coin`
    ui.lower.a2.power.label.Text = `{powerMulti}x Power`
    ui.lower.title.Text = `{number.suffix(r)} Ascension`
    ui.lower.progress.current.amount.Text = `{number.suffix(r)} Ascension`
    ui.lower.progress.next.amount.Text = passHandler.ownPass("2xAscension") and `{number.suffix(r+2)} Ascension (2x)` or `{number.suffix(r+1)} Ascension`
    ui.lower.progress.bar.label.req.label.Text = number.abbreviate(cost, 2)
    ui.lower.progress.bar.label.current.label.Text = number.abbreviate(data.coins, 2)
    tween.instance(ui.lower.progress.bar.innerBar, {
        Size = UDim2.fromScale(math.clamp(data.coins/cost, 0, 1), 1)
    })
end

return {
    load = function()
        playerDataHandler:connect({"ascension"}, function(changes)
            --[[Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").ascension.rebirth.Text = number.commaFormat(changes.new)]]
            updateAscensionFrame()
        end)
        playerDataHandler:connect({"coins"}, function(changes)
            local ui = Players.LocalPlayer.PlayerGui.ascend.mainframe
            local data = playerDataHandler.getPlayer().data
            local r = data.ascension
            local cost = ascension.getCost(r+1)

            ui.lower.progress.bar.label.req.label.Text = number.abbreviate(cost, 2)
            ui.lower.progress.bar.label.current.label.Text = number.abbreviate(data.coins, 2)
            tween.instance(ui.lower.progress.bar.innerBar, {
                Size = UDim2.fromScale(math.clamp(data.coins/cost, 0, 1), 1)
            })
        end)
        passHandler.once("2xAscension", updateAscensionFrame)

        local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ascend")

        ui.mainframe.lower.button.Activated:Connect(function()
            BridgeNet.CreateBridge("ascend"):Fire()
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(ui.mainframe.lower.button.scale, {
                    Scale = 1,
                }, .15)
            end
        end)
        ui.mainframe.lower.button.MouseButton1Down:Connect(function()
            tween.instance(ui.mainframe.lower.button.scale, {
                Scale = .95,
            }, .15)
        end)
        ui.mainframe.lower.button.MouseLeave:Connect(function()
            tween.instance(ui.mainframe.lower.button.innerOutline.stroke, {
                Color = Color3.fromRGB(65, 34, 122)
            }, .15)
        end)
        ui.mainframe.lower.button.MouseEnter:Connect(function()
            tween.instance(ui.mainframe.lower.button.innerOutline.stroke, {
                Color = Color3.fromRGB(109, 59, 211)
            }, .15)
        end)
    end
}