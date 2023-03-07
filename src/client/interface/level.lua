--!strict
--[[
    FileName    > level.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/03/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
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
local levels = require(ReplicatedStorage.shared.levels)

local xpAdded = function(added)
    local levelHud = Players.LocalPlayer.PlayerGui.hud.level
    local data = playerDataHandler.getPlayer().data

    if data.level == #levels then
        levelHud.bar.fill.Size = UDim2.fromScale(1, 1)
        levelHud.bar.xp.Text = "MAX"
        return
    end

    local levelupData = levels[data.level+1]

    levelHud.bar.xp.Text = ("%s/%s"):format(number.abbreviate(data.xp, 2), number.abbreviate(levelupData.requirement, 2))

    tween.instance(levelHud.bar.fill, {
        Size = UDim2.fromScale(math.clamp(data.xp/levelupData.requirement, 0, 1), 1)
    }, .1)

    local particle = ReplicatedStorage.resources.xpUiParticle:Clone()
    particle.Parent = levelHud.bar.fill.container
    particle.BackgroundTransparency = 0.2
    particle.Position = UDim2.fromOffset(math.random(-8,-2), math.random(-8, 8))
    particle.Rotation = math.random(-360, 360)
    particle.Visible = true
    tween.instance(particle, {
        BackgroundTransparency = 1
    }, .2).Completed:Wait()
    particle:Destroy()
end

return {
    load = function()
        local levelHud = Players.LocalPlayer:WaitForChild("PlayerGui").hud.level
        
        playerDataHandler:connect({"xp"}, function(changes)
            local n = playerDataHandler:findChanges(changes)
            if n then
                xpAdded(n)
            else
                local data = playerDataHandler.getPlayer().data
                if data.level == #levels then
                    levelHud.bar.fill.Size = UDim2.fromScale(1, 1)
                    levelHud.bar.xp.Text = "MAX"
                    return
                end
            
                local levelupData = levels[data.level+1]
            
                levelHud.bar.xp.Text = ("%s/%s"):format(number.abbreviate(data.xp, 2), number.abbreviate(levelupData.requirement, 2))
            
                levelHud.bar.fill.Size = UDim2.fromScale(math.clamp(data.xp/levelupData.requirement, 0, 1), 1)
            end
        end)
        playerDataHandler:connect({"level"}, function(changes)
            local n = playerDataHandler:findChanges(changes)
            local data = playerDataHandler.getPlayer().data
            if data.level == #levels then
                levelHud.bar.fill.Size = UDim2.fromScale(1, 1)
                levelHud.bar.xp.Text = "MAX"
                return
            end
        
            local levelupData = levels[data.level+1]
        
            levelHud.bar.xp.Text = ("%s/%s"):format(number.abbreviate(data.xp, 2), number.abbreviate(levelupData.requirement, 2))
        
            levelHud.bar.fill.Size = UDim2.fromScale(math.clamp(data.xp/levelupData.requirement, 0, 1), 1)
            if n and n > 0 then
                SoundService["Fire Emblem Echoes - Level Up"]:Play()
                local clone = ReplicatedStorage.resources.levelUp:Clone()
                clone.Position = UDim2.fromScale(.5, 1.5)
                clone.level.Text = "Lv. " .. number.commaFormat(changes.new)
                clone.Parent = levelHud.levelUpContainer
                local heartbeat = RunService.Heartbeat:Connect(function(dt)
                    clone.shine.Rotation = clone.shine.Rotation + dt * 60
                end)
                tween.instance(clone, {
                    Position = UDim2.fromScale(0.5, 0.5)
                }, .3)
                task.wait(2.9)
                heartbeat:Disconnect()
                tween.instance(clone.shine, {
                    ImageTransparency = 1
                }, .1).Completed:Wait()
                tween.instance(clone, {
                    Position = UDim2.fromScale(0.5, 1.5)
                }, .15).Completed:Wait()
                clone:Destroy()
            end
            levelHud.level.Text = "Lv. " .. number.commaFormat(changes.new)
        end)
    end
}