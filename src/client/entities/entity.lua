--!strict
--[[
    FileName    > entityBehaviours.lua
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

local entities = require(ReplicatedStorage.shared.entities)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)

local entityTag = require(script.Parent.entityTag)

local entity = {}
local entityModule = {}

local states = {
	dead = 0,
	idle = 1,
	moving = 2,
	attacking = 3,
	stuned = 4,
}

function entity:attack()
	self:updateState(states.attacking)
    self._animationTracks.IdleAnimation:Stop()
    
end

function entity:move(position: Vector3)
	self:updateState(states.moving)
    self._animationTracks.IdleAnimation:Stop()
end

function entity:idle()
	self:updateState(states.idle)
	self._animationTracks.IdleAnimation:Play()
end

function entity:spawn()
	self.entity.Parent = workspace
	self.humanoid = self.entity:WaitForChild("Humanoid")
	self.animator = self.humanoid:WaitForChild("Animator")
	self.rootpart = self.entity:WaitForChild("HumanoidRootPart")

	for name, anim in pairs(self.data.animations) do
		if type(anim) == "table" then
			self._animationTracks[name] = {}
			for i, subanim in pairs(anim) do
				local animation = Instance.new("Animation")
				animation.AnimationId = subanim
				self._animationTracks[name][i] = self.animator:LoadAnimation(animation)
			end
		else
			local animation = Instance.new("Animation")
			animation.AnimationId = anim
			self._animationTracks[name] = self.animator:LoadAnimation(animation)
		end
	end

	self.humanoid.MaxHealth = self.data.maxHealth
	self.humanoid.Health = self.data.maxHealth

	Promise.try(entityTag.new, self)

	self:debug("Spawned entity", self.data.name, " to the world")

	self.onSpawn:Fire(self.entity)
	self:idle()
end

function entity:updateState(state: number)
	local currentState = self.state

	self.onStateChanged:Fire(state, currentState)
end

entity.__index = entity

local class = objects.new(entity, {
	id = t.number,
	state = t.integer,
	entity = t.instanceIsA("Model"),
	data = t.table,
})

local find = function<t>(id: t & number): typeof(entities[t])
	for _, data in pairs(entities) do
		if data.id == id then
			return data
		end
	end
	return nil
end

local new = function(id: number)
	local data = find(id)

	debugger.assert(data, "Provided id does not correlate to any entity in the database: " .. id)

	return class:new({
		id = id,
		data = data,
		state = states.dead,
		entity = data.model and data.model:Clone(),

		onSpawn = Signal.new(),
		onStateChanged = Signal.new(),

		_animationTracks = {},
	})
end

function entityModule:load()
	new(1):spawn()
end

return entityModule
