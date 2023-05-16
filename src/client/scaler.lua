--!strict
--[[
    FileName    > scaler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 26/04/2023
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
local debug3d = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local default = {
    scalePropertySafeToOverwrite = false,
    scaleModifier = function(a: number): number
        return if a < 1 then a^.9 else a^.8
    end,
    useScaleModifier = false,
}

local db: typeof(debug3d.new())?

local initDebug = function(char)
    db = debug3d.new(char:WaitForChild("HumanoidRootPart"))
    db:linkVariable("__AIS_resolution", "0x0")
    db:linkVariable("__AIS_scalerAlpha", 1)
    db:linkVariable("__AIS_defaultAlphaModifier", 1)
end

return {
    load = function()

        Players.LocalPlayer.CharacterAdded:Connect(initDebug)
        if Players.LocalPlayer.Character then
            initDebug(Players.LocalPlayer.Character)
        end

        local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local resolutionGui = Instance.new("ScreenGui")
        resolutionGui.Name = "__resolution"
        resolutionGui.IgnoreGuiInset = true
        resolutionGui.Parent = gui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.AnchorPoint = Vector2.new(.5 , .5)
        frame.Position = UDim2.fromScale(.5, .5)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Parent = resolutionGui

        local scalers = {}

        local standardResolution = Vector2.new(1280, 720)
        local scale = 1

        local resolutionUpdated = function()
            local resolution = frame.AbsoluteSize
            local a =  resolution.X/standardResolution.X
            scale = if a < 1 then a^.5 else a^.8

            if db then
                db:changeValue("__AIS_resolution", `{resolution.X}x{resolution.Y}`)
                db:changeValue("__AIS_scalerAlpha", a)
                db:changeValue("__AIS_defaultAlphaModifier", scale)
            end

            for _, meta: {
                scaler: UIScale,
                mod: typeof(default)
            } in pairs(scalers) do
                local useScale = scale
                if meta.mod.useScaleModifier then
                    useScale = meta.mod.scaleModifier(a)
                end
                if meta.mod.scalePropertySafeToOverwrite then
                    meta.scaler.Scale = useScale
                end
                meta.scaler:SetAttribute("__SCALE", useScale)
            end
        end

        for _, screenGui in pairs(gui:GetChildren()) do
            Promise.try(function()
                if not screenGui:IsA("ScreenGui") then return end

                local scaler = screenGui:FindFirstChild("scaler")
                if not scaler then return end
    
                table.insert(scalers, {
                    scaler = scaler,
                    mod = if scaler:FindFirstChild("modifier") then
                            require(scaler.modifier)
                        else default
                })
            end)
        end

        frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(resolutionUpdated)
        resolutionUpdated()
    end
}