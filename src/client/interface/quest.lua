--!strict
--[[
    FileName    > quest.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 15/04/2023
--]]
local ProximityPromptService = game:GetService("ProximityPromptService")
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
local quests = require(ReplicatedStorage.shared.quests)
local main = require(script.Parent.main)

local showing
local identifier

local startDialog = function(worldId, proximity)
    local worldQuests = quests[worldId]

    local currentQuest
    local level = playerDataHandler.getPlayer().data.level

    for _, questData in pairs(worldQuests) do
        if level >= questData.lvRequirement then
            if currentQuest then
                if questData.lvRequirement > currentQuest.lvRequirement then
                    currentQuest = questData
                end
            else
                currentQuest = questData
            end
        end
    end

    if not currentQuest then
        return notifications.new():error("I don't have a quest for you.")
    end

    Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
    
    proximity.Enabled = false
    showing = proximity
    identifier = currentQuest.name

    main.unfocus()
    main.lock()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local hud = playerGui:WaitForChild("hud")
    local dialog = playerGui:WaitForChild("dialog")

    dialog.mainframe.Position = UDim2.new(0.5, 0, 1, 0)

    dialog.mainframe.lower.container.content.Text = `Defeat {currentQuest.amount} {currentQuest.target} for {currentQuest.rewards.xp} XP`
    dialog.mainframe.lower.info.label.Text = currentQuest.title

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

    tween.instance(dialog.mainframe, {
        Position = UDim2.new(0.5, 0, 0.6, 0)
    }, 0.35, "EntranceExpressive")
    tween.instance(workspace.CurrentCamera, {
		FieldOfView = 55,
	}, 0.4, "EntranceExpressive")
end

return {
    load = function()
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local dialog = playerGui:WaitForChild("dialog")
        local quest = playerGui:WaitForChild("quest")
        local hud = playerGui:WaitForChild("hud")
        local questUi = hud.right.quest

        local makeQuestSelectable = function(q, shouldSelect)
            local template = ReplicatedStorage.resources.questTemplate:Clone()
            template.content.Text = `Defeat {q.amount} {q.target}`
            template.title.Text = q.title
            template.lower.reward.label.Text = number.abbreviate(q.rewards.xp)
            template.lower.req.label.Text = `Lv. {q.lvRequirement}+`
            template.lock.label.Text = `(Reach Lv. {q.lvRequirement})`
            template.Name = q.name
            template.LayoutOrder = q.lvRequirement

            if playerDataHandler.getPlayer().data.level < q.lvRequirement then
                template.lock.Visible = true
            end
            template.MouseLeave:Connect(function()
                if showing == template then
                    return
                end
                tween.instance(template.stroke, {
                    Color = Color3.fromRGB(77, 71, 67)
                }, .15)
            end)
            template.MouseEnter:Connect(function()
                if showing == template then
                    return
                end
                tween.instance(template.stroke, {
                    Color = Color3.fromRGB(116, 107, 101)
                }, .15)

            end)
            template.Activated:Connect(function()
                if showing then
                    tween.instance(showing.stroke, {
                        Color = Color3.fromRGB(77, 71, 67)
                    }, .15)
                end
                if showing == template then
                    showing = nil
                    return
                end
                showing = template
                tween.instance(template.stroke, {
                    Color = Color3.fromRGB(132, 122, 115)
                }, .15)
            end)

            -- if shouldSelect then
            --     showing = template
            --     tween.instance(template.stroke, {
            --         Color = Color3.fromRGB(132, 122, 115)
            --     }, .15)
            -- else
                tween.instance(template.stroke, {
                    Color = Color3.fromRGB(77, 71, 67)
                }, .15)
            -- end
            template.Parent = quest.mainframe.lower.scroll
        end

        for _, char in pairs(workspace.gameFolders.quest:GetChildren()) do
            local proximity = Instance.new("ProximityPrompt")

            proximity.Parent = char
            proximity.ActionText = "Talk"
            proximity.Triggered:Connect(function(playerWhoTriggered)
                if playerWhoTriggered ~= Players.LocalPlayer then return end
                if playerDataHandler.getPlayer().data.quest.name then
                    --return notifications.new():error("You already have a quest.")
                end
                main.focus(quest,false, true)
                --startDialog(tonumber(char.Name), proximity)
            end)
    
            char.Humanoid.Animator:LoadAnimation(ReplicatedStorage.resources.Animation1):Play()
        end
        
        playerDataHandler:connect({"quest"}, function(changes)
            local currentQuest

            if not changes.new.name then
                questUi.Visible = false
                return
            end
        
            for worldid, q in pairs(quests) do
                for _, d in pairs(q) do
                    if d.name == changes.new.name then
                        currentQuest = d
                        break
                    end
                end
            end

            questUi.lower.rewards.xp.info.label.Text = number.abbreviate(currentQuest.rewards.xp, 2)
            questUi.lower.desc.Text = `Defeat {currentQuest.amount} {currentQuest.target}`
            questUi.lower.info.Text = currentQuest.title
            questUi.lower.buttons.progress.info.label.Text = `{changes.new.progress}/{currentQuest.amount}`

            questUi.Visible = true
        end)

        local getQuests = function(worlds)
            local hWorldIndex
            for _, worldIndex in pairs(worlds) do
                if not hWorldIndex then
                    hWorldIndex = worldIndex
                else
                    if worldIndex > hWorldIndex then
                        hWorldIndex = worldIndex
                    end
                end
            end
            return quests[hWorldIndex]
        end

        local update = function()
            showing = nil
            for _, qt in pairs(quest.mainframe.lower.scroll:GetChildren()) do
                if qt:IsA("TextButton") then
                    qt:Destroy()
                end
            end

            local data = playerDataHandler.getPlayer().data
            local qs = getQuests(data.unlockedWorlds)
            local level = data.level
            local currentQuest

            for _, questData in pairs(qs) do
                if level >= questData.lvRequirement then
                    if currentQuest then
                        if questData.lvRequirement > currentQuest.lvRequirement then
                            currentQuest = questData
                        end
                    else
                        currentQuest = questData
                    end
                end
            end

            for _, q in pairs(qs) do
                makeQuestSelectable(q, currentQuest == q and true or false)
            end
        end

        playerDataHandler:connect({"unlockedWorlds"}, update)
        playerDataHandler:connect({"level"}, update)

        main.initUi(quest)

        local beginButton = quest.mainframe.lower.start

        beginButton.Activated:Connect(function()
            if showing then
                BridgeNet.CreateBridge("startQuest"):Fire(showing.Name)
                tween.instance(showing.stroke, {
                    Color = Color3.fromRGB(77, 71, 67)
                }, .15)
                showing = nil
            else
                notifications.new():error("Error: Select a quest")
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(beginButton.scale, {
                    Scale = 1,
                }, .15)
            end
        end)
        beginButton.MouseButton1Down:Connect(function()
            tween.instance(beginButton.scale, {
                Scale = .95,
            }, .15)
        end)
        beginButton.MouseLeave:Connect(function()
            tween.instance(beginButton.innerOutline.stroke, {
                Color = Color3.fromRGB(108, 73, 48)
            }, .15)
        end)
        beginButton.MouseEnter:Connect(function()
            tween.instance(beginButton.innerOutline.stroke, {
                Color = Color3.fromRGB(181, 122, 80)
            }, .15)
        end)

    end
}