--!strict
--[[
    FileName    > upgrade.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 13/03/2023
--]]
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
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
local upgrades = require(ReplicatedStorage.shared.upgrades)
local notifications = require(script.Parent.notifications)
local zones = require(ReplicatedStorage.shared.zones)

local interface = require(script.Parent.main)

local selectedPage
local isInside = false
local enterDebounce = debounce.new(debounce.type.Timer, .6)
local hoveredColor = Color3.fromRGB(148, 179, 196)
local unhoveredColor = Color3.fromRGB(71, 86, 94)

local bridges = {
    purchaseUpgrade = BridgeNet.CreateBridge("purchaseUpgrade")
}

local enteredUpgradeHitbox = function()
    isInside = true
    local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("boost")
    interface.focus(ui, true)
end

local exitedUpgradeHitbox = function()
    isInside = false
    interface.unfocus()
end

local selectPage = function(pageName)
    local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("boost")
    local pageContainer = ui.mainframe.pages.lower
    local buttons =  ui.mainframe.buttons

    if selectedPage then
        local button = selectedPage.button

        if t.instanceIsA("GuiButton")(button) then
            tween.instance(button.innerOutline.stroke, {
                Color = unhoveredColor,
            }, 0.2)
            tween.instance(button.icon, {
                TextSize = 32,
            }, 0.2)
        end
    end
    local pageInstance = pageContainer:FindFirstChild(pageName)
    local button = buttons:FindFirstChild(pageName)

    debugger.assert(t.instanceIsA("GuiObject")(pageInstance))
    debugger.assert(t.instanceIsA("GuiButton")(button))

    for _, object in pairs(pageContainer:GetChildren()) do
        if object:IsA("GuiObject") then
            object.Visible = false
        end
    end
    pageInstance.Visible = true

    tween.instance(button.innerOutline.stroke, {
        Color = hoveredColor,
    }, 0.3)
    tween.instance(button.icon, {
        TextSize = 32,
    }, 0.15).Completed:Wait()
    tween.instance(button.icon, {
        TextSize = 38,
    }, 0.2)

    selectedPage = { page = pageInstance, button = button }
end

return {
    load = function()
        local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("boost")
        local pageContainer = ui.mainframe.pages.lower
        local buttons =  ui.mainframe.buttons

        interface.initUi(ui)

        local tweens = {}

        for _, button : TextButton in pairs(ui.mainframe.buttons:GetChildren()) do
            if button:IsA("GuiButton") then
                button.Activated:Connect(function()
                    if not table.find(playerDataHandler.getPlayer().data.unlockedWorlds, tonumber(button.Name)) then
                        notifications.new():error(("ERROR: Unlock World \"%s\""):format(zones[tonumber(button.Name)].name))
                        return
                    end
                    selectPage(button.Name)
                end)
            end
        end
        selectPage("1")

        playerDataHandler:connect({"upgrades"}, function(changes)
            if not changes.old then
                for worldIndex, upgradesContents in pairs(changes.new) do
                    for upgradeId, upgradeLevel in pairs(upgradesContents) do
                        local data = upgrades.contents[worldIndex][upgradeId]
                        local frame =  pageContainer[tostring(worldIndex)][tostring(upgradeId)]
                        frame.bar.fill.Size = UDim2.fromScale(math.clamp(upgradeLevel/5, 0, 1), 1)
                        frame.desc.Text = if data.values[upgradeLevel+1] then ("%s > %s"):format(
                                    data.getTxt(data.values[upgradeLevel] or 0),
                                    data.getTxt(data.values[upgradeLevel+1])
                                )
                            else
                                data.getTxt(data.values[upgradeLevel] or 0)
                        frame.button.cost.amount.Text = if data.cost[upgradeLevel+1] then number.abbreviate(data.cost[upgradeLevel+1], 2) else "MAX"
                    end
                end
            else
                for worldIndex, upgradesContents in pairs(changes.new) do
                    for upgradeId, upgradeLevel in pairs(upgradesContents) do
                        if changes.old[worldIndex][upgradeId] == upgradeLevel then
                            continue
                        end
                        local data = upgrades.contents[worldIndex][upgradeId]
                        local frame=  pageContainer[tostring(worldIndex)][tostring(upgradeId)]
                        tween.instance(frame.bar.fill, {
                            Size = UDim2.fromScale(math.clamp(upgradeLevel/5, 0, 1), 1),
                        }, .35)
                        frame.desc.Text = if data.values[upgradeLevel+1] then ("%s > %s"):format(data.getTxt(data.values[upgradeLevel] or 0), data.getTxt(data.values[upgradeLevel+1])) else data.getTxt(data.values[upgradeLevel] or 0)
                        frame.button.cost.amount.Text = if data.cost[upgradeLevel+1] then number.abbreviate(data.cost[upgradeLevel+1], 2) else "MAX"
                        for i = 5, 1, -1 do
                            task.spawn(function()
                                local particle = ReplicatedStorage.resources.xpUiParticle:Clone()
                                particle.BackgroundColor3 = Color3.fromRGB(103, 204, 247)
                                particle.Parent = frame.bar.fill
                                particle.BackgroundTransparency = 0.2
                                particle.Position = UDim2.new(1, math.random(-8,-2), 0, math.random(-8, 8))
                                particle.ZIndex = 6
                                particle.Rotation = math.random(-360, 360)
                                particle.Visible = true
                                tween.instance(particle, {
                                    BackgroundTransparency = 1
                                }, .2).Completed:Wait()
                                particle:Destroy()
                            end)
                        end
                    end
                end
            end
        end)

        ContentProvider:PreloadAsync({"rbxassetid://12784077167"})

        --[[ReplicatedStorage.test1.Event:Connect(function(worldIndex)
            local frame = ui.mainframe.buttons:FindFirstChild(worldIndex)
            if not frame then return end
            frame.lock.unlock.ImageTransparency = 1
            frame.lock.unlock.Visible = true
            frame.lock.lock.Size = UDim2.fromOffset(64, 64)
            frame.lock.BackgroundTransparency = 0.4
            frame.lock.lock.ImageTransparency = 0
            frame.lock.unlock.ImageTransparency = 1
            frame.innerOutline.TextLabel.TextTransparency = 1
            frame.innerOutline.TextLabel.stroke.Transparency = 1
            frame.innerOutline.TextLabel.Visible = true
            frame.Visible = true
            tween.instance(frame.lock.unlock, {
                ImageTransparency = 0
            }, .3)
            tween.instance(frame.lock.lock, {
                ImageTransparency = 1,
                Size = UDim2.fromOffset(84, 84)
            }, .5).Completed:Wait()
            task.wait(.1)
            tween.instance(frame.innerOutline.TextLabel, {
                TextTransparency = 0,
            }, .2)
            tween.instance(frame.innerOutline.TextLabel.stroke, {
                Transparency = 0,
            }, .2)
            tween.instance(frame.lock.unlock, {
                ImageTransparency = 1
            }, .15)
            tween.instance(frame.lock, {
                BackgroundTransparency = 1,
            }, .2).Completed:Wait()
            frame.lock.Visible = false
        end)]]

        playerDataHandler:connect({"unlockedWorlds"}, function(changes)
            if not changes.old then
                for index, worldIndex in pairs(changes.new) do
                    local frame = ui.mainframe.buttons:FindFirstChild(worldIndex)
                    if not frame then continue end
                    frame.innerOutline.TextLabel.Visible = true
                    frame.lock.Visible = false
                end
            else
                for index, worldIndex in pairs(changes.new) do
                    local frame = ui.mainframe.buttons:FindFirstChild(worldIndex)
                    if not frame then continue end
                    frame.lock.unlock.ImageTransparency = 1
                    frame.lock.unlock.Visible = true
                    frame.lock.lock.Size = UDim2.fromOffset(64, 64)
                    frame.lock.BackgroundTransparency = 0.4
                    frame.lock.lock.ImageTransparency = 0
                    frame.lock.unlock.ImageTransparency = 1
                    frame.innerOutline.TextLabel.TextTransparency = 1
                    frame.innerOutline.TextLabel.stroke.Transparency = 1
                    frame.innerOutline.TextLabel.Visible = true
                    frame.Visible = true
                    tween.instance(frame.lock.unlock, {
                        ImageTransparency = 0
                    }, .3)
                    tween.instance(frame.lock.lock, {
                        ImageTransparency = 1,
                        Size = UDim2.fromOffset(84, 84)
                    }, .5).Completed:Wait()
                    task.wait(.1)
                    tween.instance(frame.innerOutline.TextLabel, {
                        TextTransparency = 0,
                    }, .2)
                    tween.instance(frame.innerOutline.TextLabel.stroke, {
                        Transparency = 0,
                    }, .2)
                    tween.instance(frame.lock.unlock, {
                        ImageTransparency = 1
                    }, .15)
                    tween.instance(frame.lock, {
                        BackgroundTransparency = 1,
                    }, .2).Completed:Wait()
                    frame.lock.Visible = false
                end
            end
        end)

        for _, world in pairs(pageContainer:GetChildren()) do
            if world:IsA("GuiObject") then
                for _, upgrade in pairs(world:GetChildren()) do
                    if upgrade:IsA("GuiObject") then
                        upgrade.button.Activated:Connect(function()
                            bridges.purchaseUpgrade:Fire(tonumber(world.Name), tonumber(upgrade.Name))
                        end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                tween.instance(upgrade.button, {
                                    Position = UDim2.new(1, -84, 0, 6),
                                    Size = UDim2.fromOffset(80, 24)
                                }, .15, "Back")
                            end
                        end)
                        upgrade.button.MouseButton1Down:Connect(function()
                            tween.instance(upgrade.button, {
                                Position = UDim2.new(1, -80, 0, 8),
                                Size = UDim2.fromOffset(72, 21)
                            }, .1)
                        end)
                    end
                end
            end
        end

        local hitboxes = {}

        for _, upgradeStation in pairs(workspace.gameFolders.upgrade:GetChildren()) do
            if upgradeStation:FindFirstChild("Hitbox") then
                hitboxes[tonumber(upgradeStation.Name)] = upgradeStation.Hitbox
            end
        end

        local isShowing = false

        local data = playerDataHandler.getPlayer().data

        RunService.RenderStepped:Connect(function(deltaTime)
            local character = Players.LocalPlayer.Character
            if not character then return end
            local charPos = character:GetPivot().Position

            local currentWorld = data.currentWorld

            local hitbox = hitboxes[currentWorld]
            local center = hitbox.Position
            local distanceFromCenter = (center - charPos).Magnitude
            local radius = hitbox.Size.Y/2
            
            if distanceFromCenter < radius and not isShowing then
                isShowing = true
                interface.focus(ui, true)
            elseif distanceFromCenter > radius+5 and isShowing then
                isShowing = false
                interface.unfocus()
            end
        end)
    end
}