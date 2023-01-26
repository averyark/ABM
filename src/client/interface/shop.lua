--!strict
--[[
    FileName    > shop.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 29/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
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

function shop:load()
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
	selectPage("featured")
end

return shop
