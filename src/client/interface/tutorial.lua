--!strict
--[[
    FileName    > tutorial.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 02/05/2023
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

local images = {
    flex = "rbxassetid://6515890613",
    proud = "rbxassetid://6515889653",
    wave = "rbxassetid://6515626443",
    point = "rbxassetid://6515890613"
}

local order = {
    {
        msg = "⚔️ Welcome to Anime Sword Heroes! Train to become the most powerful swordsperson and slice through every monster im your way! 👺",
        img = "wave"
    },
    {
        msg = "🔥 This is where you upgrade your character. Boost your character's stats and become stronger than ever 💪",
        img = "proud"
    },
    {
        msg = "🎭 This is where you obtain heroes. Heroes will boost your power and coin multiplier, unlock the best heroes and become stronger! 👤",
        img = "flex"
    },
    {
        msg = "💬 This is where you get your quest. Complete quests and level up to become stronger; unlock better quest when you level up ❗️",
        img = "point"
    },
    {
        msg = "⚔️ Defeat enemies for a chance to get a better sword. Enemies will fight back when you become a threat to them, make sure you're strong enough to fight them 👺",
        img = "proud"
    },
    {
        msg = "🛸 Obtain enough coins and slay the boss to unlock the portal to the next world. That is it, good luck on your adventure, Traveller! 🌌",
        img = "wave"
    },
}

local initiateTutorial = function()
    repeat
        task.wait()
    until playerDataHandler.initialized
    local main = require(script.Parent.main)
    
    main.lock()

    local index = 1
    local cameraCFrameParts = workspace.gameFolders.tutorial
    local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local tutorial = gui:WaitForChild("tutorial")
    local hud = gui:WaitForChild("hud")

    tween.instance(hud.right, {
        Position = UDim2.new(1, 0, 0.5, 0),
    }, 0.3, "ExitExpressive")
    tween.instance(hud.smallButtons, {
        Position = UDim2.new(0, -231, 0.5, -112),
    }, 0.3, "ExitExpressive")
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
    tween.instance(tutorial.background, {
        BackgroundTransparency = 0
    }, .2, "EntranceExpressive").Completed:Wait()
    tutorial.gradient.Visible = true
    tutorial.mainframe.Visible = true

    local nextButton = tutorial.mainframe.buttons.next
    local skipButton = tutorial.mainframe.buttons.skip

    local close = function()
        BridgeNet.CreateBridge("tutorialFinished"):Fire()
        tween.instance(tutorial.background, {
            BackgroundTransparency = 0
        }, .27, "EntranceExpressive").Completed:Wait()
        tween.instance(hud.right, {
            Position = UDim2.new(1, -258, 0.5, 0),
        }, 0.3, "EntranceExpressive")
        tween.instance(hud.currencies, {
            Position = UDim2.new(0, 0, 0.5, -40),
        }, 0.3, "EntranceExpressive")
        tween.instance(hud.buttons, {
            Position = UDim2.new(0, 8, 0.5, 66),
        }, 0.3, "EntranceExpressive")
        tween.instance(hud.smallButtons, {
            Position = UDim2.new(0, 8, 0.5, -112),
        }, 0.3, "EntranceExpressive")
        tween.instance(hud.level, {
            Position = UDim2.new(0.5, 0, 1, -48),
        }, 0.3, "EntranceExpressive")
        tween.instance(hud.rebirth, {
            Position = UDim2.new(1, -28, 1, -32),
        }, 0.3, "EntranceExpressive")
        tutorial.gradient.Visible = false
        tutorial.mainframe.Visible = false
        tween.instance(tutorial.background, {
            BackgroundTransparency = 1
        }, .2, "ExitExpressive")
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        main.unlock()
    end

    nextButton.Activated:Connect(function()
        if index >= #order then
            return close()
        end
        index += 1
        workspace.CurrentCamera.CFrame = cameraCFrameParts[index].CFrame
        tutorial.mainframe.img.Image = images[order[index].img]
        tutorial.mainframe.label.Text = order[index].msg
    end)
    skipButton.Activated:Connect(function()
        close()
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tween.instance(nextButton.scale, {
                Scale = 1,
            }, .15)
            tween.instance(skipButton.scale, {
                Scale = 1,
            }, .15)
        end
    end)
    nextButton.MouseButton1Down:Connect(function()
        tween.instance(nextButton.scale, {
            Scale = .97,
        }, .15)
    end)
    nextButton.MouseLeave:Connect(function()
        tween.instance(nextButton.scale, {
            Scale = 1,
        })
        tween.instance(nextButton.innerOutline.stroke, {
            Color = Color3.fromRGB(0, 130, 170)
        }, .15)
    end)
    nextButton.MouseEnter:Connect(function()
        tween.instance(nextButton.scale, {
            Scale = 1.03,
        })
        tween.instance(nextButton.innerOutline.stroke, {
            Color = Color3.fromRGB(0, 180, 235)
        }, .15)
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

    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    workspace.CurrentCamera.CFrame = cameraCFrameParts["1"].CFrame

    tutorial.mainframe.img.Image = images[order[1].img]
    tutorial.mainframe.label.Text = order[1].msg

    ContentProvider:PreloadAsync({
        "rbxassetid://6515890613",
        "rbxassetid://6515889653",
        "rbxassetid://6515626443",
        "rbxassetid://6515890613"
    })

    tween.instance(tutorial.background, {
        BackgroundTransparency = 1
    }, .15, "ExitExpressive")
    
end

return {
    load = function()
        local data = playerDataHandler.getPlayer().data
        local main = require(script.Parent.main)

        task.delay(5, function()
            if not data.tutorial then
                initiateTutorial()
            end
        end)

    end
}