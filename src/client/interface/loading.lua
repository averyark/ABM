--!strict
--[[
    FileName    > loading.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 27/04/2023
--]]
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")

local worlds = require(ReplicatedStorage.shared.zones)

local gif = require(script.Parent.Parent.gif)

local loadingTo = function(world)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    local ui = Players.LocalPlayer:WaitForChild("PlayerGui").loading
    ui.preview.Image = worlds[world].imageId
    ui.label.Text = "Traveling to " .. worlds[world].name
    ui.Enabled = true
    ui.smallSpinner.Visible = true
end

local loadingEnd = function()
    local ui = Players.LocalPlayer:WaitForChild("PlayerGui").loading
    ui.Enabled = false
    ui.smallSpinner.Visible = false
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
task.spawn(function()
    local loadingGif = gif.new({{
        image = "rbxassetid://13265772173",
        columns = 5,
        frames = 30
    }}, 48)
    loadingGif:play()
    local ui = Players.LocalPlayer:WaitForChild("PlayerGui").loading
    loadingGif:addContainer(ui.smallSpinner)

    for _, world in pairs(worlds) do
        ContentProvider:PreloadAsync({world.imageId})
    end
end)

return {
    loadingTo = loadingTo,
    loadingEnd = loadingEnd,
}