--!strict
--[[
    FileName    > entityTag.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/12/2022
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

local entityTag = ReplicatedStorage.resources.entitytag

local defaultOffset = Vector3.new(0, 2, 0)

local new = function(entity)
	entity:assert(t.instanceIsA("Humanoid")(entity.humanoid))

	entity.entityTag = entityTag:Clone()
	entity.entityTag.displayname.Text = entity.data.name
	entity.entityTag.Parent = entity.rootpart
    entity.entityTag.ExtentsOffsetWorld = entity.entitytagOffset or defaultOffset

	local updateHealth = function()
		local humanoid = entity.humanoid
		local healthContainer = entity.entityTag.health.container
		local percent = humanoid.Health / humanoid.MaxHealth
		healthContainer.number.Text = number.abbreviate(humanoid.Health, 2)
			.. "/"
			.. number.abbreviate(humanoid.MaxHealth, 2)
		tween.instance(healthContainer.new, {
			Size = UDim2.fromScale(percent, 1),
		}, 0.3)
		task.wait(0.1)
		tween.instance(healthContainer.old, {
			Size = UDim2.fromScale(percent, 1),
		}, 0.9)
	end

	updateHealth()
	entity._maid:Add(entity.humanoid.HealthChanged:Connect(updateHealth))
end

return {
	new = new,
}
