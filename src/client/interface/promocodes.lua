--!strict
--[[
    FileName    > promocodes.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/05/2023
--]]
local ContentProvider = game:GetService("ContentProvider")
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
local notifications = require(script.Parent.notifications)

local gif = require(script.Parent.Parent.gif)

return {
    load = function()
        local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("promocodes")
        local claimButton = ui.mainframe.lower.claim

        local loadingGif = gif.new({{
            image = "rbxassetid://13265772173",
            columns = 5,
            frames = 30
        }}, 48)
        loadingGif:play()
        loadingGif:addContainer(ui.mainframe.lower.content.loading)

        ui.mainframe.lower.content.loading.Visible = false

        local locked = false

        claimButton.Activated:Connect(function()
            if locked then return end
            local input = ui.mainframe.lower.content.box.Text

            if input == "" or input:match("^%W+$") then
                return notifications.new():error("Error: Promocode cannot be empty or completely whitespace")
            end

            locked = true
            ui.mainframe.lower.content.loading.Visible = true
            ui.mainframe.lower.content.box.TextEditable = false
            local result, errorMessage = BridgeNet.CreateBridge("claimPromocode"):InvokeServerAsync(input)
            task.wait(1)
            if result then
                ui.mainframe.lower.content.loading.Visible = false
                ui.mainframe.lower.content.stroke.Color = Color3.fromRGB(137, 226, 77)
                ui.mainframe.lower.content.box.TextColor3 = Color3.fromRGB(137, 226, 77)
            else
                ui.mainframe.lower.content.box.Text = errorMessage or "An error occured"
                ui.mainframe.lower.content.loading.Visible = false
                ui.mainframe.lower.content.stroke.Color = Color3.fromRGB(220, 42, 45)
                ui.mainframe.lower.content.box.TextColor3 = Color3.fromRGB(220, 42, 45)
            end
            task.wait(1)
            ui.mainframe.lower.content.box.TextEditable = true
            ui.mainframe.lower.content.box.Text = ""
            ui.mainframe.lower.content.box.TextColor3 = Color3.fromRGB(255, 255, 255)
            ui.mainframe.lower.content.stroke.Color = Color3.fromRGB(77, 82, 86)
            locked = false
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(claimButton.scale, {
                    Scale = 1,
                }, .15)
            end
        end)
        claimButton.MouseButton1Down:Connect(function()
            tween.instance(claimButton.scale, {
                Scale = .97,
            }, .15)
        end)
        claimButton.MouseLeave:Connect(function()
            tween.instance(claimButton.scale, {
                Scale = 1,
            })
            tween.instance(claimButton.innerOutline.stroke, {
                Color = Color3.fromRGB(105, 112, 117)
            }, .15)
        end)
        claimButton.MouseEnter:Connect(function()
            tween.instance(claimButton.scale, {
                Scale = 1.03,
            })
            tween.instance(claimButton.innerOutline.stroke, {
                Color = Color3.fromRGB(162, 172, 180)
            }, .15)
        end)
    end
}