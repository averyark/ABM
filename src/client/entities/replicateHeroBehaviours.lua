--!strict
--[[
    FileName    > replicateHeroBehaviours.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 17/04/2023
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local bridges = {
	initializeHeroOnClient = BridgeNet.CreateBridge("initializeHeroOnClient"),
    readyToLoadHeroAnim = BridgeNet.CreateBridge("readyToLoadHeroAnim")
}

local animationIds = {
    idle = "rbxassetid://12147280656",
    walk = "rbxassetid://12147286437",
    jump =  "http://www.roblox.com/asset/?id=507765000",
    fall = "http://www.roblox.com/asset/?id=507767968"
}

local clientEntityClassTable = {}
clientEntityClassTable.__index = clientEntityClassTable

local clientEntityObjects = {}

function clientEntityClassTable:Destroy()
	self._maid:Destroy()
end

function clientEntityClassTable:setup()
	self.humanoid = self.entity:WaitForChild("Humanoid")
	self.animator = self.humanoid:WaitForChild("Animator")

	local animationCacheReference = self.animationTracks
	for name, anim in pairs(animationIds) do
		local animation = Instance.new("Animation")
		animation.AnimationId = anim
		animationCacheReference[name] = self.animator:LoadAnimation(animation)
	end

	local isWalking = false
	self._maid:Add(self.humanoid.Running:Connect(function(speed)
		if speed > 1 then
			animationCacheReference["walk"]:AdjustSpeed(speed / self.humanoid.WalkSpeed)
			if isWalking then
				return
			end
			isWalking = true
			animationCacheReference["walk"].Priority = Enum.AnimationPriority.Movement
			animationCacheReference["walk"].Looped = true
			animationCacheReference["walk"]:Play()
		else
			isWalking = false
			animationCacheReference["walk"]:Stop()
		end
	end))
    self._maid:Add(self.entity.AncestryChanged:Connect(function()
        self:Destroy()
    end))
    --[[self._maid:Add(self.humanoid.Jumping:Connect(function()
        animationCacheReference["jump"]:Play()
    end))
    self._maid:Add(self.humanoid.FreeFalling:Connect(function()
        animationCacheReference["fall"]:Play()
    end))]]

	animationCacheReference["idle"].Priority = Enum.AnimationPriority.Idle
	animationCacheReference["idle"]:Play()

	return self
end

local clientEntityClass = objects.new(clientEntityClassTable, {})


local new = function(player: Player, id: number, model: Model)

	return clientEntityClass
		:new({
            player = player,
            id = id,
			entity = model,

			animationTracks = {},
		})
		:setup()
end

return {
    load = function()
        bridges.initializeHeroOnClient:Connect(function(...)
            new(...)
        end)
        bridges.readyToLoadHeroAnim:Fire()
    end
}