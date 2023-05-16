--!strict
--[[
    FileName    > travel.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 25/04/2023
--]]
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
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

task.spawn(function()

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local intro = gui:WaitForChild("intro")

    local closed = false

    local close = function()
        if closed then return end
        closed = true
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        playerDataHandler.initialized = true
        tween.instance(intro.icon.scale, {
            Scale = 0
        }, .2,"ExitExpressive")
        tween.instance(intro.label.stroke, {
            Transparency = 1
        }, .2,"ExitExpressive")
        tween.instance(intro.label, {
            TextTransparency = 1
        }, .2, "ExitExpressive")
        tween.instance(intro.skip, {
            BackgroundTransparency = 1
        }, .2,"ExitExpressive")
        tween.instance(intro.skip.info.label, {
            TextTransparency = 1
        }, .2,"ExitExpressive")
        tween.instance(intro.skip.innerOutline.stroke, {
            Transparency = 1
        }, .2,"ExitExpressive")
        tween.instance(intro.progress.scale, {
            Scale = 0
        }, .2,"ExitExpressive")
        tween.instance(intro.background, {
            BackgroundTransparency = 1
        }, .2,"ExitExpressive")
        tween.instance(intro.bg, {
            ImageTransparency = 1
        }, .2,"ExitExpressive").Completed:Wait()
        intro.Enabled = false
        BridgeNet.CreateBridge("newbieFalse"):Fire()
        task.wait(.2)
        main.focus(gui.changelog)
    end

    intro.Enabled = true

    if playerDataHandler.getPlayer().data.isNew then
        intro.label.Text = `⚔️ Thank you for playing Anime Sword Heroes, {Players.LocalPlayer.Name}! A stunning experience is near 👺`
    else
        intro.label.Text = `⚔️ Hey {Players.LocalPlayer.Name}, welcome back to Anime Sword Heroes! A magnificant journey is just around 👺`
    end

    local things = {}

    for _, thing in pairs(gui:GetChildren()) do
        table.insert(things, thing)
    end
    for _, thing in pairs(ReplicatedStorage.resources:GetChildren()) do
        table.insert(things, thing)
    end

    local skipButton = intro.skip

    skipButton.Activated:Connect(function()
        close()
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tween.instance(skipButton.scale, {
                Scale = 1,
            }, .15)
        end
    end)
    skipButton.MouseButton1Down:Connect(function()
        tween.instance(skipButton.scale, {
            Scale = .97,
        }, .15)
    end)
    skipButton.MouseLeave:Connect(function()
        tween.instance(skipButton.scale, {
            Scale = 1,
        }, .15)
        tween.instance(skipButton.innerOutline.stroke, {
            Color = Color3.fromRGB(58, 58, 58)
        }, .15)
    end)
    skipButton.MouseEnter:Connect(function()
        tween.instance(skipButton.scale, {
            Scale = 1.03,
        }, .15)
        tween.instance(skipButton.innerOutline.stroke, {
            Color = Color3.fromRGB(135, 135, 135)
        }, .15)
    end)
    
    tween.instance(intro.icon.scale, {
        Scale = 1
    }, .15,"EntranceExpressive")
    tween.instance(intro.label.stroke, {
        Transparency = 0
    }, .15,"EntranceExpressive")
    tween.instance(intro.label, {
        TextTransparency = 0
    }, .15, "EntranceExpressive")
    
    --Players.LocalPlayer:WaitForChild("Character"):WaitForChild("HumanoidRootPart").Anchored = true

    local num = #things
    local loaded = 1

    task.delay(7, function()
        tween.instance(intro.skip, {
            BackgroundTransparency = 0
        }, .15,"EntranceExpressive")
        tween.instance(intro.skip.info.label, {
            TextTransparency = 0
        }, .15,"EntranceExpressive")
        tween.instance(intro.skip.innerOutline.stroke, {
            Transparency = 0
        }, .15,"EntranceExpressive")
    end)

    for _, thing in pairs(things) do
        ContentProvider:PreloadAsync({thing})
        local percentage = loaded/num
        intro.progress.bar.label.Text = `{math.round(percentage*100)}%`
        tween.instance(intro.progress.bar.innerBar, {
            Size = UDim2.fromScale(percentage, 1)
        })
        loaded += 1
    end

    close()
end)

return {
    load = function()
        local fastTravelUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("fastTravel")

        local purchaseConfirmation = fastTravelUi.Parent.purchaseConfirmation
        local showing
        local fromFastTravel = false

        main.initUi(purchaseConfirmation)

        local portalActivated = function(worldIndex, fromWorldIndex)
            local playerData = playerDataHandler.getPlayer().data

            if playerDataHandler.getPlayer().data.currentWorld ~= fromWorldIndex then
                return notifications.new():error("Error: You're not supposed to be here.")
            end

            if not table.find(playerData.unlockedWorlds, worldIndex) then
                if showing then return end
                showing = worldIndex
                fromFastTravel = false
                purchaseConfirmation.mainframe.lower.desc.Text = `You're spending <font color="rgb(255, 186, 107)">{number.abbreviate(worlds[worldIndex].cost or 0, 2)}</font> coins to purchase the world {worlds[worldIndex].name}.`
                main.focus(purchaseConfirmation)
                
            else
                BridgeNet.CreateBridge("changeWorld"):Fire(worldIndex)
            end
        end

        for _, folder in pairs(workspace.gameFolders.teleporters:GetChildren()) do
            for _, tele in pairs(folder:GetChildren()) do
                local portal = tele:FindFirstChild("Portal")
                if not portal then continue end

                local worldIndex = tonumber(tele.Name)
                local worldData = worlds[worldIndex]

                if portal.Billboard:FindFirstChild("cost") then
                    portal.Billboard.cost.label.Text = number.abbreviate(worldData.cost) 
                end

                portal.Touched:Connect(function(part)
                    local character = Players.LocalPlayer.Character
                    if not character then return end
                    local hum = character:FindFirstChild("Humanoid")
                    if not hum then return end
                    if part:IsDescendantOf(Players.LocalPlayer.Character) then
                        portalActivated(worldIndex, tonumber(folder.Name))
                    end
                end)
            end
        end

        playerDataHandler:connect({"unlockedWorlds"}, function(changes)
            --if not changes.old then return end
            for _, worldFrame in pairs(fastTravelUi.mainframe.lower.scroll:GetChildren()) do
                if not worldFrame:IsA("TextButton") then
                    continue
                end
                if table.find(changes.new, tonumber(worldFrame.Name)) then
                    worldFrame.cost.Visible = false
                    worldFrame.desc.Visible = true
                    worldFrame.lock.Visible = false
                else
                    worldFrame.cost.Visible = true
                    worldFrame.desc.Visible = false
                    worldFrame.lock.Visible = true
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
                    passHandler.promptPass("FastTrvel")
                    return notifications.new():error("Error: You need the Fast Travel gamepass to use this feature!")
                end
                if playerDataHandler.getPlayer().data.currentWorld == worldIndex then
                    return notifications.new():error("Error: You cannot teleport to the world you're in!")
                end
                if not table.find(playerDataHandler.getPlayer().data.unlockedWorlds, worldIndex) then
                    if showing then return end
                    purchaseConfirmation.mainframe.lower.desc.Text = `You're spending <font color="rgb(255, 186, 107)">{number.abbreviate(worlds[worldIndex].cost or 0, 2)}</font> coins to purchase the world Attack on Titan.`
                    main.focus(purchaseConfirmation)
                    fromFastTravel = true
                    showing = worldIndex
                else
                    BridgeNet.CreateBridge("changeWorld"):Fire(worldIndex)
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
        end
        local confirm = purchaseConfirmation.mainframe.lower.confirm

        confirm.Activated:Connect(function(inputObject, clickCount)
            if not showing then return end
            if not fromFastTravel then
                main.unfocus()
            else
                main.focus(fastTravelUi)
            end
            BridgeNet.CreateBridge("purchaseWorld"):Fire(showing)
            showing = nil
        end)

        purchaseConfirmation.mainframe.close2.Activated:Connect(function()
            if not fromFastTravel then
                main.unfocus()
            else
                main.focus(fastTravelUi)
            end
            showing = nil
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
}