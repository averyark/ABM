--!strict
--[[
    FileName    > currencies.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 22/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
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

local uiSounds = ReplicatedStorage.resources.ui_sound_effects

local currencies = {}

function currencies:load()
	local currenciesObject = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").currencies
	local earnCurrency = Players.LocalPlayer.PlayerGui:WaitForChild("earnCurrency")

	local coins = currenciesObject.coins.inner.label
	local otween
	local update = function(value)
		local abbreviated = value > 999
		if otween then
			otween:Destroy()
			otween = nil
		end
		otween = tween.instance(coins, {
			TextSize = math.min(coins.TextSize + 3, 29),
			--Rotation = math.random(-5, 5),
		}, 0.1).Completed:Wait()
		coins.Text = number.abbreviate(value, 2) .. (abbreviated and "+" or "")
		otween = tween.instance(coins, {
			TextSize = 21,
			--Rotation = 0,
		}, 0.1)
	end

	playerDataHandler:connect({ "coins" }, function(data)
		local n = playerDataHandler:findChanges(data)
		if n then
			task.spawn(function()
				local clone = ReplicatedStorage.resources.coinObtained:Clone()
				clone.label.Text = number.abbreviate(n, 2)
				clone.Parent = earnCurrency

				clone.icon.ImageTransparency = 1
				clone.label.TextTransparency = 1

				tween.instance(clone.icon, {
					ImageTransparency = 0
				}, .15)
				tween.instance(clone.label, {
					TextTransparency = 0
				}, .15)

				local pos = UDim2.fromScale(math.random(), math.random())
				
				clone.Position = pos

				tween.instance(clone, {
					Position = pos - UDim2.fromScale(0, 0.1)
				}, 1).Completed:Wait()
				tween.instance(clone.icon, {
					ImageTransparency = 1
				}, .5)
				tween.instance(clone.label, {
					TextTransparency = 1
				}, .5)
				tween.instance(clone.label.stroke, {
					Transparency = 1
				}, .5).Completed:Wait()
				clone:Destroy()
			end)
		end
		update(data.new)
	end)
end

return currencies
