--!strict
--[[
    FileName    > animations.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/12/2022
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
local Astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local animations = { _objects = {} }
local animationClass = {}

local animator

animationClass.__DEBUG__ENABLED = false
animationClass.__index = animationClass

function animationClass:play()
	if not self.animationTrack then
		self:debugwarn("AnimationTrack not found")
		return
	end
	self.animationTrack:Play()
end

function animationClass:getAnimation()
	if not self.animationTrack then
		self:debugwarn("AnimationTrack not found")
		return
	end
	return self.animationTrack
end

local class = objects.new(animationClass, {
	animationObject = t.instanceIsA("Animation"),
	animationTrack = t.union(t.instanceIsA("AnimationTrack"), t.none),
	name = t.string,
})

local find = function(animationObject)
	for _, object in pairs(animations._objects) do
		if object.animationObject == animationObject then
			return object
		end
	end
end

local new = function(animationObject)
	local created = find(animationObject)
	if created then
		return created
	end

	local self = class:new({
		animationObject = animationObject,
		name = animationObject.Name,
	})
	self.animationTrack = animator and animator:LoadAnimation(self.animationObject)

	table.insert(animations._objects, self)
	return self
end

local get = function(animationObject)
	return find(animationObject) or new(animationObject)
end

local initializeCharacter = function(character)
	local humanoid = character:WaitForChild("Humanoid")
	animator = humanoid:WaitForChild("Animator")

	for _, object: typeof(class) in pairs(animations._objects) do
		if object.animationTrack then
			object:Destroy()
		end
		object.animationTrack = animator:LoadAnimation(object.animationObject)
	end
end

function animations:preload()
	local player = Players.LocalPlayer

	player.CharacterAdded:Connect(initializeCharacter)
	if player.Character then
		initializeCharacter(player.Character)
	end

	for _, animationObject in pairs(ReplicatedStorage.animations:GetDescendants()) do
		if t.instanceIsA("Animation")(animationObject) then
			new(animationObject)
		end
	end
end

animations.new = new
animations.get = get
animations.find = find

return animations
