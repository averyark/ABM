--!strict
--[[
    FileName    > capsules.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/04/2023
--]]
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
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

local capsuleOpening = require(script.Parent.capsuleOpening)
local interface = require(script.Parent.main)
local capsules = require(ReplicatedStorage.shared.capsules)
local heros = require(ReplicatedStorage.shared.heros)
local rarities = require(ReplicatedStorage.shared.rarities)

local displayCapsule = function(capsuleId)
    local ui = Players.LocalPlayer.PlayerGui.capsule
    local capsule = capsules[capsuleId]

    for _, object in pairs(ui.mainframe.lower:GetChildren()) do
        if object:IsA("TextButton") then
            object:Destroy()
        end
    end

    if capsule.premium then
        ui.mainframe.buttons.Buy.Visible = true
        ui.mainframe.buttons.Auto.Visible = false
        ui.mainframe.coins.Visible = false
        ui.mainframe.robux.Visible = true
        ui.mainframe.keys.Visible = true
        ui.mainframe.robux.inner.label.Text = number.commaFormat(capsule.cost)
    else
        ui.mainframe.buttons.Buy.Visible = false
        ui.mainframe.buttons.Auto.Visible = true
        ui.mainframe.coins.Visible = true
        ui.mainframe.robux.Visible = false
        ui.mainframe.keys.Visible = false
        ui.mainframe.coins.inner.label.Text = number.abbreviate(capsule.cost, 2)
    end

    for heroId, percentage in pairs(capsule.rewards) do
        local heroData = heros[heroId]
        local rarityData = rarities[heroData.rarity]
        local template = ReplicatedStorage.resources.capsuleItemTemplate:Clone()
        template.Name = heroData.name
        template.container.content.Image = heroData.iconId
        template.container.rarityLabel.Text = rarityData.name
        template.container.stroke.Color = rarityData.primaryColor
        template.container.rarity.ImageColor3 = rarityData.primaryColor
        template.container.percentage.Text = `{percentage*100}%`
        template.LayoutOrder = -rarityData.order
        template.Parent = ui.mainframe.lower
    end
end

return {
    load = function()
        local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("capsule")

        local isShowing = false
        local displayingCapsuleId
        local displayingCapsule: Model?
        local buttonColorCache = {}
        local buttonValueIncrement = 0.3
        local openDebounce = debounce.new(debounce.type.Timer, 5)

        interface.initUi(ui)

        local auto = false

        local cancelButton = Players.LocalPlayer.PlayerGui.capsuleOpening.cancel

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(cancelButton.scale, {
                    Scale = 1,
                }, .15)
            end
        end)
        cancelButton.MouseButton1Down:Connect(function()
            tween.instance(cancelButton.scale, {
                Scale = .95,
            }, .15)
        end)
        cancelButton.MouseLeave:Connect(function()
            tween.instance(cancelButton.innerOutline.stroke, {
                Color = Color3.fromRGB(44, 115, 150)
            }, .15)
        end)
        cancelButton.MouseEnter:Connect(function()
            tween.instance(cancelButton.innerOutline.stroke, {
                Color = Color3.fromRGB(62, 165, 212)
            }, .15)
        end)
        cancelButton.Activated:Connect(function()
            Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
            auto = false
            cancelButton.Position = UDim2.fromScale(.5, 1.5)
        end)

        BridgeNet.CreateBridge("capsuleOpened"):Connect(function(_, _, type)
            --openDebounce:lock()
            if type == "Auto" then
                task.wait(6)
                if auto then
                    if not displayingCapsuleId then
                        auto = false
                        return
                    end
                    if not BridgeNet.CreateBridge("openCapsule"):InvokeServerAsync(displayingCapsuleId, "Auto") then
                        auto = false
                    end
                end
            else
                auto = false
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if openDebounce:isLocked() then
                return
            end
            if auto then return end
            if input.KeyCode == Enum.KeyCode.E and isShowing and displayingCapsuleId then
                openDebounce:lock()
                if not BridgeNet.CreateBridge("openCapsule"):InvokeServerAsync(displayingCapsuleId, "Open1") then
                    openDebounce:unlock()
                end
            elseif input.KeyCode == Enum.KeyCode.Q and isShowing and displayingCapsuleId then
                openDebounce:lock()
                if not BridgeNet.CreateBridge("openCapsule"):InvokeServerAsync(displayingCapsuleId, "Open3") then
                    openDebounce:unlock()
                end
            elseif input.KeyCode == Enum.KeyCode.R and isShowing and displayingCapsule then
                openDebounce:lock()
                if not BridgeNet.CreateBridge("openCapsule"):InvokeServerAsync(displayingCapsuleId, "Auto") then
                    openDebounce:unlock()
                else
                    auto = true
                end
            end
        end)

        for _, button in pairs(ui.mainframe.buttons:GetChildren()) do
			if button:IsA("GuiButton") then
				if not buttonColorCache[button] then
					local defaultColor = button.innerOutline.stroke.Color
					local h, s, v = defaultColor:ToHSV()
					local color = Color3.fromHSV(h, s, v + buttonValueIncrement)

					buttonColorCache[button] = { defaultColor = defaultColor, hoveredColor = color }
				end
				button.Activated:Connect(function()
                    if button.Name == "Buy" then
                        MarketplaceService:PromptProductPurchase(Players.LocalPlayer, capsules[displayingCapsuleId].productId)
                        return
                    end
                    if openDebounce:isLocked() then
                        return
                    end
                    if auto then return end
                    openDebounce:lock()
					if not BridgeNet.CreateBridge("openCapsule"):InvokeServerAsync(displayingCapsuleId, button.Name) then
                        openDebounce:unlock()
                    else
                        if button.Name == "Auto" then
                            auto = true
                        end
                    end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						tween.instance(button, {
							Size = UDim2.fromOffset(70, 70)
						}, .15, "Back")
					end
				end)
                local tweens = {}
				button.MouseButton1Down:Connect(function()
					tween.instance(button, {
						Size = UDim2.fromOffset(60, 60)
					}, .1)
				end)
                button.MouseEnter:Connect(function()
					table.insert(tweens, tween.instance(button.innerOutline.stroke, {
						Color = buttonColorCache[button].hoveredColor,
					}, 0.3))
					table.insert(tweens, tween.instance(button.icon, {
						Size = UDim2.fromOffset(38, 38),
					}, 0.2))
				end)
				button.MouseLeave:Connect(function()
                    for _, object in pairs(tweens) do
                        object:Destroy()
                    end
                    table.clear(tweens)
					tween.instance(button.innerOutline.stroke, {
						Color = buttonColorCache[button].defaultColor,
					}, 0.2)
					tween.instance(button.icon, {
						Size = UDim2.fromOffset(32, 32),
					}, 0.2)
				end)
			end
		end

        local _capsules = {}

        for _, capsulesFolder in pairs(workspace.gameFolders.capsules:GetChildren()) do
            _capsules[tonumber(capsulesFolder.Name)] = {}
            if capsulesFolder:IsA("Folder") then
                for _, capsule in pairs(capsulesFolder:GetChildren()) do
                    _capsules[tonumber(capsulesFolder.Name)][tonumber(capsule.Name)] = capsule
                end
            end
        end

        playerDataHandler:connect({"premiumKey"}, function(changes)
            ui.mainframe.keys.inner.label.Text = changes.new
        end)

        local data = playerDataHandler.getPlayer().data
        local policy = PolicyService:GetPolicyInfoForPlayerAsync(Players.LocalPlayer)

        print(policy)

        RunService.Heartbeat:Connect(function(deltaTime)
            local character = Players.LocalPlayer.Character
            if not character then return end

            local currentWorld = data.currentWorld

            local closestCapsule
            local charPos = character:GetPivot().Position

            for _, capsule in pairs(_capsules[tonumber(currentWorld)]) do
                local center = capsule.centre.Position
                local distanceFromCenter = (center - charPos).Magnitude
                if distanceFromCenter < 15 then
                    if closestCapsule then
                        if (closestCapsule.centre.Position - charPos).Magnitude < distanceFromCenter then
                            closestCapsule = capsule
                        end
                    else
                        closestCapsule = capsule
                    end
                end
            end

            if policy.ArePaidRandomItemsRestricted then
                return
            end
            
            if closestCapsule and not isShowing then
                isShowing = true
                displayingCapsuleId = tonumber(closestCapsule.Name)
                displayingCapsule = closestCapsule
                displayCapsule(tonumber(closestCapsule.Name))
                interface.focus(ui, true)
            elseif not closestCapsule and isShowing then
                local center = displayingCapsule.centre.Position
                local distanceFromCenter = (center - charPos).Magnitude

                if distanceFromCenter > 20 then
                    isShowing = false
                    displayingCapsuleId = nil
                    displayingCapsule = nil
                    interface.unfocus()
                end
            elseif closestCapsule and isShowing and closestCapsule ~= displayingCapsule then
                local cacheId = tonumber(closestCapsule.Name)
                displayingCapsuleId = cacheId
                displayingCapsule = closestCapsule
                
                --interface.unfocus()
                --[[task.delay(.4, function()
                    isShowing = true]]
                    displayCapsule(cacheId)
                    --interface.focus(ui, true)
                --end)
                
                
            end
        end)
    end
}