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
	debugger.assert(t.instanceIsA("Humanoid")(entity:FindFirstChild("Humanoid")))

	local tag = entityTag:Clone()
	tag.displayname.Text = entity.Name
	tag.Parent = entity.HumanoidRootPart
	tag.ExtentsOffsetWorldSpace = defaultOffset

	local updateHealth = function()
		local humanoid = entity.Humanoid
		local healthContainer = tag.health.container
		local percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		healthContainer.number.Text = number.abbreviate(math.max(humanoid.Health, 0), 2)
			.. "/"
			.. number.abbreviate(humanoid.MaxHealth, 2)
		if not healthContainer:FindFirstChild("new") then
			return
		end
		tween.instance(healthContainer.new, {
			Size = UDim2.fromScale(percent, 1),
		}, 0.3)
		task.wait(0.1)
		if not healthContainer:FindFirstChild("old") then
			return
		end
		tween.instance(healthContainer.old, {
			Size = UDim2.fromScale(percent, 1),
		}, 0.9)
	end

	updateHealth()
	local connection = entity.Humanoid.HealthChanged:Connect(updateHealth)
	local connection2
	connection2 = entity.AncestryChanged:Connect(function()
		if not entity:IsDescendantOf(workspace.gameFolders.entities) then
			connection:Disconnect()
			connection2:Disconnect()
			tag:Destroy()
		end
	end)

	return tag
end

return {
	new = new,
}
