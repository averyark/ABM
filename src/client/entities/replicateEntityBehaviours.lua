--!strict
--[[
    FileName    > replicateEntityBehaviours.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 10/12/2022
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

local entityTag = require(script.Parent.entityTag)

local bridges = {
	replicateEntityAnimation = BridgeNet.CreateBridge("replicateEntityAnimation"),
	initializeEntityOnClient = BridgeNet.CreateBridge("initializeEntityOnClient"),
	requestEntityAnimationIds = BridgeNet.CreateBridge("requestEntityAnimationIds"),
	entityDamaged = BridgeNet.CreateBridge("entityDamaged"),
}

local gameFolders = workspace.gameFolders

local combatResources = ReplicatedStorage.resources.combat_resources

local clientEntityClassTable = {}
clientEntityClassTable.__index = clientEntityClassTable

local clientEntityObjects = {}

function clientEntityClassTable:Destroy()
	clientEntityObjects[self.entity] = nil
	self._maid:Destroy()
end

function clientEntityClassTable:setup()
	clientEntityObjects[self.entity] = self
	self.humanoid = self.entity:WaitForChild("Humanoid")
	self.animator = self.humanoid:WaitForChild("Animator")

	local animationCacheReference = self.animationTracks
	for name, anim in pairs(self.animationIds) do
		if type(anim) == "table" then
			animationCacheReference[name] = {}
			for i, subanim in pairs(anim) do
				local animation = Instance.new("Animation")
				animation.AnimationId = subanim
				animationCacheReference[name][i] = self.animator:LoadAnimation(animation)
			end
		else
			local animation = Instance.new("Animation")
			animation.AnimationId = anim
			animationCacheReference[name] = self.animator:LoadAnimation(animation)
		end
	end

	local isWalking = false
	self._maid:Add(self.humanoid.Running:Connect(function(speed)
		if speed > 1 then
			animationCacheReference["WalkAnimation"]:AdjustSpeed(speed / self.humanoid.WalkSpeed)
			if isWalking then
				return
			end
			isWalking = true
			animationCacheReference["WalkAnimation"].Priority = Enum.AnimationPriority.Movement
			animationCacheReference["WalkAnimation"].Looped = true
			animationCacheReference["WalkAnimation"]:Play()
		else
			isWalking = false
			animationCacheReference["WalkAnimation"]:Stop()
		end
	end))

	self._maid:Add(self.entity.AncestryChanged:Connect(function()
		if not self.entity.Parent == gameFolders.entities then
			self:Destroy()
		end
	end))

	animationCacheReference["IdleAnimation"].Priority = Enum.AnimationPriority.Idle
	animationCacheReference["IdleAnimation"]:Play()

	self.damageBillboard.Parent = self.entity

	return self
end

local clientEntityClass = objects.new(clientEntityClassTable, {})

local new = function(entityModel)
	local animationsIds = bridges.requestEntityAnimationIds:InvokeServerAsync(entityModel)

	debugger.assert(t.table(animationsIds))

	return clientEntityClass
		:new({
			entity = entityModel,
			animationIds = animationsIds,
			damageBillboard = combatResources.damageBillboard:Clone(),

			entityTag = entityTag.new(entityModel),

			animationTracks = {},
		})
		:setup()
end

local random = Random.new()

return {
	load = function(self)
		bridges.replicateEntityAnimation:Connect(
			function(entityModel, requestType, animationName, animationSubName, ...)
				local clientEntityObject = clientEntityObjects[entityModel]
				if not clientEntityObject then
					return
				end

				if animationSubName then
					clientEntityObject.animationTracks[animationName][animationSubName][requestType or "Play"](
						clientEntityObject.animationTracks[animationName][animationSubName],
						...
					)
				else
					clientEntityObject.animationTracks[animationName][requestType or "Play"](
						clientEntityObject.animationTracks[animationName],
						...
					)
				end
			end
		)
		bridges.entityDamaged:Connect(function(entityModel, player, damage, damageType)
			print(damage, damageType)
			local clientEntityObject = clientEntityObjects[entityModel]
			if not clientEntityObject then
				return
			end

			local damageText = combatResources.damageTypes:FindFirstChild(damageType)
			if not damageText then
				return
			end

			local newPos = UDim2.fromScale(random:NextNumber(), random:NextNumber())
			damageText = damageText:Clone()
			damageText.Text = "-" .. tostring(number.abbreviate(damage, 2))
			damageText.Position = newPos
			damageText.Parent = clientEntityObject.damageBillboard.container

			damageText.TextTransparency = 0
			damageText.TextStrokeTransparency = 0

			tween.instance(damageText, {
				Position = newPos - UDim2.fromScale(0, 0.1),
			}, 0.3, "Back").Completed:Wait()
			tween.instance(damageText, {
				Position = newPos + UDim2.fromScale(0, 0.2),
			}, 0.35, "Back")
			task.wait(0.1)
			tween.instance(damageText, {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
			}, 0.35, "Back").Completed:Wait()
			--damageText:Destroy()
		end)

		gameFolders.entities.ChildAdded:Connect(new)
		for _, entityModel in pairs(gameFolders.entities:GetChildren()) do
			new(entityModel)
		end
	end,
}
