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

	playerDataHandler:connect({"coins"}, function(data)
		--[[if data.old then
			--SoundService:PlayLocalSound(uiSounds["coin getter"])
		end]]
		update(data.new)
	end)
end

return currencies
