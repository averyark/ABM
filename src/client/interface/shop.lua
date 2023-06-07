--!strict
--[[
    FileName    > shop.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 29/12/2022
--]]
local MarketplaceService = game:GetService("MarketplaceService")
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
local ascension = require(ReplicatedStorage.shared.ascension)
local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local passHandler = require(script.Parent.Parent.passHandler)
local main = require(script.Parent.main)

local shop = {}

-- handling buttons

local shopUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("shop")
local pageContainer = shopUi:WaitForChild("mainframe").lower.container
local pageLayout = pageContainer.page
local buttons = shopUi.mainframe.buttons

local buttonColorCache = {}
local buttonValueIncrement = 0.4

local selectedPage

local selectPage = function(pageName)
	if selectedPage then
		local button = selectedPage.button

		if t.instanceIsA("GuiButton")(button) then
			tween.instance(button.innerOutline.stroke, {
				Color = buttonColorCache[button].defaultColor,
			}, 0.2)
			tween.instance(button.icon, {
				Size = UDim2.fromOffset(32, 32),
			}, 0.2)
		end
	end
	local pageInstance = pageContainer:FindFirstChild(pageName)
	local button = buttons:FindFirstChild(pageName)

	debugger.assert(t.instanceIsA("GuiObject")(pageInstance))
	debugger.assert(t.instanceIsA("GuiButton")(button))

	pageLayout:JumpTo(pageInstance)

	tween.instance(button.innerOutline.stroke, {
		Color = buttonColorCache[button].hoveredColor,
	}, 0.3)
	tween.instance(button.icon, {
		Size = UDim2.fromOffset(32, 32),
	}, 0.15).Completed:Wait()
	tween.instance(button.icon, {
		Size = UDim2.fromOffset(38, 38),
	}, 0.2)

	selectedPage = { page = pageInstance, button = button }
end

local percentage = {
	[1] = 0.05,
	[2] = 0.21,
	[3] = 0.52,
	[4] = 0.73,
	[5] = 1.04,
	[6] = 1.55,
}

local productIds = {
	[1] = 1527695918,
	[2] = 1527696509,
	[3] = 1527696870,
	[4] = 1527697145,
	[5] = 1527697251,
	[6] = 1527697483,
}

function shop:load()
	for id, passData in pairs(BridgeNet.CreateBridge("getPasses"):InvokeServerAsync()) do
		local template = ReplicatedStorage.resources.passTemplate:Clone()

		template.Name = passData.Name
		template.passName.Text = passData.Name
		template.icon.Image = `rbxassetid://{passData.IconImageAssetId}`
		template.passDesc.Text = passData.Description
		template.passCost.label.Text = passData.PriceInRobux
		template.Parent = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("shop").mainframe.lower.container.passes
		template.MouseLeave:Connect(function(x, y)
			tween.instance(template.stroke, {
				Color = Color3.fromRGB(139, 91, 57)
			}, .2)
		end)
		template.MouseEnter:Connect(function(x, y)
			tween.instance(template.stroke, {
				Color = Color3.fromRGB(200, 129, 82)
			}, .2)
		end)
		template.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, id)
		end)
	end
	for _, button in pairs(buttons:GetChildren()) do
		if button:IsA("GuiButton") then
			if not buttonColorCache[button] then
				local defaultColor = button.innerOutline.stroke.Color
				local h, s, v = defaultColor:ToHSV()
				local color = Color3.fromHSV(h, s, v + buttonValueIncrement)

				buttonColorCache[button] = { defaultColor = defaultColor, hoveredColor = color }
			end
			button.Activated:Connect(function()
				selectPage(button.Name)
			end)
			button.MouseEnter:Connect(function()
				tween.instance(button.innerOutline.stroke, {
					Color = buttonColorCache[button].hoveredColor,
				}, 0.3)
				tween.instance(button.icon, {
					Size = UDim2.fromOffset(38, 38),
				}, 0.2)
			end)
			button.MouseLeave:Connect(function()
				if selectedPage and selectedPage.button == button then
					return
				end
				tween.instance(button.innerOutline.stroke, {
					Color = buttonColorCache[button].defaultColor,
				}, 0.2)
				tween.instance(button.icon, {
					Size = UDim2.fromOffset(32, 32),
				}, 0.2)
			end)
		end
	end
	for _, button in pairs(pageContainer.coins:GetChildren()) do
		if not button:IsA("GuiObject") then continue end

		local p = percentage[tonumber(button.Name)]
		if not p then continue end

		UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                tween.instance(button.scale, {
                    Scale = 1,
                }, .15, "Back")
            end
        end)
        button.MouseButton1Down:Connect(function()
            tween.instance(button.scale, {
                Scale = .97,
            }, .15, "Back")
        end)
        button.MouseLeave:Connect(function()
            tween.instance(button.stroke, {
                Color = Color3.fromRGB(126, 84, 42)
            }, .15)
			tween.instance(button.scale, {
                Scale = 1,
            }, .15, "Back")
        end)
        button.MouseEnter:Connect(function()
            tween.instance(button.stroke, {
                Color = Color3.fromRGB(177, 118, 59)
            }, .15)
			tween.instance(button.scale, {
                Scale = 1.03,
            }, .15, "Back")
        end)
        button.Activated:Connect(function()
            MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productIds[tonumber(button.Name)])
        end)
	end
	
	local vipBanner = pageContainer.featured["VIP"]
	vipBanner.Activated:Connect(function()
		passHandler.promptPass("VIP")
	end)
	local doubleAscension = pageContainer.featured["2xAscension"]
	doubleAscension.Activated:Connect(function()
		passHandler.promptPass("2xAscension")
	end)
	local coin2 = pageContainer.featured["2"]
	coin2.Activated:Connect(function()
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productIds[2])
	end)
	
	local coin5 = pageContainer.featured["5"]
	coin5.Activated:Connect(function()
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productIds[5])
	end)

	playerDataHandler:connect({"ascension"}, function(changes)
		for _, button in pairs(pageContainer.coins:GetChildren()) do
			if not button:IsA("GuiObject") then continue end

			local p = percentage[tonumber(button.Name)]
			if not p then continue end

			local reward = ascension.getCost(changes.new+1)*p

			button.reward.label.Text = number.abbreviate(reward, 0)
		end
		coin5.reward.label.Text = number.abbreviate(ascension.getCost(changes.new+1)*percentage[5], 0)
		coin2.reward.label.Text = number.abbreviate(ascension.getCost(changes.new+1)*percentage[2], 0)
	end)

	local buyCoin = shopUi.Parent.hud.currencies.coins.button
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			tween.instance(buyCoin.scale, {
				Scale = 1,
			}, .15, "Back")
		end
	end)
	buyCoin.MouseButton1Down:Connect(function()
		tween.instance(buyCoin.scale, {
			Scale = .95,
		}, .15, "Back")
	end)
	buyCoin.MouseLeave:Connect(function()
		tween.instance(buyCoin.scale, {
			Scale = 1,
		}, .15, "Back")
	end)
	buyCoin.MouseEnter:Connect(function()
		tween.instance(buyCoin.scale, {
			Scale = 1.05,
		}, .15, "Back")
	end)
	buyCoin.Activated:Connect(function(inputObject, clickCount)
		selectPage("coins")
		main.focus(shopUi)
	end)

	local h = 35
	local s = 149
	local v = 240
	local positive = true

	RunService.RenderStepped:Connect(function(deltaTime)
		if s >= 149 then
			positive = false
		elseif s <= 80 then
			positive = true
		end
		if positive then
			s += 80*deltaTime
		else
			s -= 80*deltaTime
		end
		for _, button in pairs(pageContainer.coins:GetChildren()) do
			if button.Name == "5" or button.Name == "6" then
				button.bonus.TextColor3 = Color3.fromHSV(h/360, s/255, v/255)
			end
		end
		coin5.bonus.TextColor3 = Color3.fromHSV(h/360, s/255, v/255)
	end)

	selectPage("featured")
end

return shop
