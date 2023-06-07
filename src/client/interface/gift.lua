--!strict
--[[
    FileName    > gift.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 13/04/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
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
local weapons = require(ReplicatedStorage.shared.weapons)
local rarities = require(ReplicatedStorage.shared.rarities)
local main = require(script.Parent.main)
local notifications = require(script.Parent.notifications)

local bridges = {
    updateGift = BridgeNet.CreateBridge("updateGift"),
    requestOpenGift = BridgeNet.CreateBridge("requestOpenGift"),
    giftOpened = BridgeNet.CreateBridge("giftOpened")
}

local giftDatas = {
    ["normal"] = {
        ["64px"] = "rbxassetid://13110797638",
        ["512px"] = "rbxassetid://13111926114",
        order = 1
    },
    ["daily"] = {
        ["64px"] = "rbxassetid://13110797638",
        ["512px"] = "rbxassetid://13111926114",
        order = 1
    },
    ["premium"] = {
        ["64px"] = "rbxassetid://13112783989",
        ["512px"] = "rbxassetid://13112781731",
        order = 2,
    },
}

local showCountdown = false

local updateGiftButton = function(gifts: {"gift" | "normal" | "premium"})
    local giftButton = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").right.gift
    if #gifts < 1 then
        giftButton.icon.Image = giftDatas["normal"]["64px"]
        giftButton.shadow.Image = giftDatas["normal"]["64px"]
        showCountdown = true
        giftButton.icon.ImageColor3 = Color3.fromRGB(50, 50, 50)
        return
    end

    local rarest

    for _, giftType in pairs(gifts) do
        rarest = if not rarest then giftDatas[giftType] else rarest
        if giftDatas[giftType].order > rarest.order then
            rarest = giftDatas[giftType]
        end
    end

    giftButton.icon.Image = rarest["64px"]
    giftButton.shadow.Image = rarest["64px"]
    giftButton.tip.Text = `OPEN GIFT`
    giftButton.icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    showCountdown = false
end

local openGift = function(
        giftType: "normal" | "premium",
        rewards: {
            default: {
                {
                    type: "item" | "coin",
                    value: number
                }?
            },
            streak: {
                {
                    type: "item" | "coin",
                    value: number
                }?
            },
        },
        streak: number
    )
    local giftUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("gift")

    for _, fr in pairs(giftUi.mainframe.lower.scroll:GetChildren()) do
        if fr:IsA("GuiObject") then
            fr:Destroy()
        end
    end

    giftUi.mainframe.icon.Image = giftDatas[giftType]["512px"]
    giftUi.mainframe.upper.container.icon.Image = giftDatas[giftType]["64px"]
    
    local coinReward = function(amount: number, order)
        local frame = giftUi.templates.coinTemplate:Clone()
        frame.Name = "coin" .. amount
        frame.inner.label.Text = number.abbreviate(amount, 2)
        frame.LayoutOrder = order
        frame.Visible = true
        frame.Parent = giftUi.mainframe.lower.scroll
    end

    local itemReward = function(itemId: number, order)
        local data
        for _, dat in pairs(weapons) do
            if dat.id == itemId then
                data = dat
                break
            end
        end
        local rarityData = rarities[data.rarity]
        local frame = giftUi.templates.itemTemplate:Clone()
        frame.Name = "item" .. itemId
        frame.inner.icon.Image = data.iconId
        frame.inner.label.Text = data.name
        frame.stroke.Color = rarityData.primaryColor
        frame.inner.label.TextColor3 = rarityData.primaryColor
        frame.LayoutOrder = order
        frame.Visible = true
        frame.Parent = giftUi.mainframe.lower.scroll
    end

    local text = function(text: string, order)
        local frame = giftUi.templates.infoTemplate:Clone()
        frame.Name = "txt" .. order
        frame.Text = text
        frame.LayoutOrder = order
        frame.Visible = true
        frame.Parent = giftUi.mainframe.lower.scroll
    end

    local order = 0

    local reward = function(dat)
        if dat.type == "sword" then
            itemReward(dat.value, order)
        elseif dat.type == "coin" then
            coinReward(dat.value, order)
        end
        order += 1
    end

    print(rewards)

    for _, rewardData in pairs(rewards.default) do
        reward(rewardData)
    end

    if streak > 1 then
        text(`{streak} Days Streak Bonuses`, order)
        order += 1
        for _, rewardData in pairs(rewards.streak) do
            reward(rewardData)
        end
    end


    --[[coinReward(math.random(5000, 8000), 1)
    itemReward(6, 2)
    if streak > 3 then
        text(`{streak} Days Streak Bonuses`, 3)
        itemReward(27, 4)
        coinReward(math.random(8000, 12000), 5)
    end
    ]]
    SoundService:PlayLocalSound(SoundService.crate_open)
    main.focus(giftUi, true)
end

local getCountdown = function(n)
    local h = math.floor(n/3600)
    local m = math.floor((n - h*3600)/60)
    local s = n%60
    
    return h, m, s
end

local getCountdownFormat = function(n: number)
    return string.format("%i:%02i:%02i", getCountdown(n))
end

return {
    load = function()
        local giftButton = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").right.gift
        local giftUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("gift")

        task.spawn(function()
            while true do
                if showCountdown then
                    local lastGift = playerDataHandler.getPlayer().data.lastDailyGift
                    if os.time() - lastGift <= 86400 then
                        giftButton.tip.Text = getCountdownFormat(lastGift - os.time() + 86400)
                    else
                        giftButton.tip.Text = "0:00:00"
                        updateGiftButton({"daily"})
                    end
                end
                task.wait(1)
            end
        end)

        giftButton.MouseEnter:Connect(function()
            tween.instance(giftButton.shadow, {
                ImageTransparency = 0.3
            }, .2)
        end)

        giftButton.MouseLeave:Connect(function()
            tween.instance(giftButton.shadow, {
                ImageTransparency = 1
            }, .2)
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(giftButton.icon, {
                    Size = UDim2.fromScale(1, 1)
                }, .15, "Back")
                tween.instance(giftButton.shadow, {
                    Size = UDim2.new(1, 2, 1, 2)
                }, .15, "Back")
            end
        end)
        giftButton.MouseButton1Down:Connect(function()
            tween.instance(giftButton.icon, {
                Size = UDim2.fromScale(.95, .95)
            }, .15, "Back")
            tween.instance(giftButton.shadow, {
                Size = UDim2.new(.95, 2, .95, 2)
            }, .15, "Back")
        end)
        giftButton.Activated:Connect(function()
            if showCountdown then
                local lastGift = playerDataHandler.getPlayer().data.lastDailyGift
                local h, m, s = getCountdown(lastGift - os.time() + 86400)
                notifications.new():error(`Next daily gift in {h} Hours {m} Minutes and {s} Seconds. Come back later!`)
            end
            bridges.requestOpenGift:Fire()
        end)

        bridges.updateGift:Connect(function(...)
            updateGiftButton(...)
        end)

        playerDataHandler:connect({"gifts"}, function(changes)
            updateGiftButton(changes.new)
        end)

        playerDataHandler:connect({"lastDailyGift"}, function(changes)
            updateGiftButton(playerDataHandler.getPlayer().data.gifts)
        end)

        bridges.giftOpened:Connect(function(...)
            openGift(...)
        end)
        
        bridges.updateGift:Fire()

        local okayButton = giftUi.mainframe.buttons.okay
        local extraButton = giftUi.mainframe.buttons.extra

        okayButton.Activated:Connect(function()
            main.unfocus()
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(okayButton.scale, {
                    Scale = 1,
                }, .15)
                tween.instance(extraButton.scale, {
                    Scale = 1,
                }, .15)
            end
        end)
        okayButton.MouseButton1Down:Connect(function()
            tween.instance(okayButton.scale, {
                Scale = .95,
            }, .15)
        end)
        okayButton.MouseLeave:Connect(function()
            tween.instance(okayButton.innerOutline.stroke, {
                Color = Color3.fromRGB(183, 77, 77)
            }, .15)
        end)
        okayButton.MouseEnter:Connect(function()
            tween.instance(okayButton.innerOutline.stroke, {
                Color = Color3.fromRGB(229, 96, 96)
            }, .15)
        end)

        extraButton.MouseButton1Down:Connect(function()
            tween.instance(extraButton.scale, {
                Scale = .95,
            }, .15)
        end)

        local mouseIn = false
        
        extraButton.MouseLeave:Connect(function()
            tween.instance(extraButton.innerOutline.stroke, {
                Color = Color3.fromRGB(100, 38, 208)
            }, .15)
            tween.instance(extraButton.info.icon.icon, {
                Rotation = 0
            }, .1)
            mouseIn = false
        end)
        extraButton.MouseEnter:Connect(function()
            tween.instance(extraButton.innerOutline.stroke, {
                Color = Color3.fromRGB(117, 46, 250)
            }, .2)

            mouseIn = true
            while mouseIn do
                if not mouseIn then break end
                tween.instance(extraButton.info.icon.icon, {
                    Rotation = -15
                }, .3, "Cubic").Completed:Wait()
                if not mouseIn then break end
                tween.instance(extraButton.info.icon.icon, {
                    Rotation = 15
                }, .3, "Cubic").Completed:Wait()
                task.wait()
            end
            tween.instance(extraButton.info.icon.icon, {
                Rotation = 0
            }, .05)
        end)

        --updateGiftButton()
        main.initUi(giftUi)
    end
}