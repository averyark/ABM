--!nonstrict
--[[
    FileName    > autoscaler.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/06/2023
--]]
local Players = game:GetService("Players")

local Packages = script.Parent.Parent.Parent
local Promise = require(Packages.Promise)
local Signal = require(Packages.Signal)
local things = require(script.Parent.Parent.things)
local Janitor = require(Packages.Janitor)
local Red = require(Packages.Red)
local t = require(Packages.t)
local class = require(script.Parent.Parent.class)

local default = {
    scalePropertySafeToOverwrite = false,
    scaleModifier = function(a: number): number
        return if a < 1 then a^.9 else a^.8
    end,
    useScaleModifier = false,
}

local autoscaler = {}

autoscaler.start = function()
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

    -- UI Development should be completed in 1280x720
    local standardResolution =  things.settings.UIDevelopmentResolution or Vector2.new(1280, 720)
    local scale = 1

    local function resolutionUpdated()
        local resolution = frame.AbsoluteSize
        local a = if resolution.Y > resolution.X then resolution.X/standardResolution.X else resolution.Y/standardResolution.Y

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
                mod = if scaler:FindFirstChild("modifier") then require(scaler.modifier) else default
            })
        end)
    end

    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(resolutionUpdated)
    resolutionUpdated()
end

return autoscaler