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
local RunService = game:GetService("RunService")
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
local SimplePath = require(ReplicatedStorage.shared.SimplePath)

local entityTag = require(script.Parent.entityTag)

local entity = { __DEBUG__ENABLED = false }
local entityModule = {}

local states = {
	dead = 0,
	idle = 1,
	moving = 2,
	attacking = 3,
	stuned = 4,
}

local resetPathFindingRate = 10 / 30

function entity:attack()
	if self.attackDebounce:isLocked() then
		return
	end
	if not self._canUpdateState then
		return
	end
	if self.state == states.moving then
		return
	end

	self.onAttackBegin:Fire()

	table.clear(self._damagedPlayers)

	self:updateState(states.attacking)
	self._canUpdateState = false

	self._animationTracks.IdleAnimation:Stop()

	local animation: AnimationTrack = self._animationTracks.AttackAnimations[math.random(1, 2)]
	animation:Play()
	animation.Ended:Wait()

	self._canUpdateState = true
	self.attackDebounce:lock()
	self.onAttackEnded:Fire()
	self:idle()
end

function entity:playerHit(player)
	if table.find(self._damagedPlayers, player) then
		return
	end
	table.insert(self._damagedPlayers, player)
	self.onPlayerHit:Fire(player)
end

function entity:changeTarget(target)
	if target == nil then
		self.target = nil
		if self.pathfinding._status ~= "Idle" then
			self.pathfinding:Stop()
		end
		return
	end
	if not self.target or target ~= self.target then
		if not target:FindFirstChild("HumanoidRootPart") then
			return
		end
		self.target = target
	else
		return
	end

	self.resetPathFindingDebounce:lock()
	self.pathfinding:Run(self.target.HumanoidRootPart)
end

--[[
     local target = monsterEntity.target
            if target and target:FindFirstChild("HumanoidRootPart") then
                if monsterEntity.pathfinding then
                    monsterEntity.pathfinding:Run(target.HumanoidRootPart)
                end
            end
]]

function entity:playerInView(player)
	self.onPlayerEnterViewRange:Fire(player)
end

function entity:isValidTarget(character)
	local rootpart = character:FindFirstChild("HumanoidRootPart")
	if not rootpart then
		return false
	end

	local vector = rootpart.Position - self.rootpart.Position
	local magnitude = vector.Magnitude
	if magnitude >= self.data.visualDistance * 1.5 then
		return false
	elseif
		not self.aggressive
		and math.deg(math.acos(self.head.CFrame.LookVector:Dot(vector.Unit))) >= self.data.visualArcAngle
	then
		return false
	end

	return true
end

function entity:idle()
	if not self._canUpdateState then
		return
	end
	self:updateState(states.idle)
	self._animationTracks.WalkAnimation:Stop()
	self._animationTracks.IdleAnimation:Play()
end

function entity:spawn()
	self.entity.Parent = workspace
	self.humanoid = self.entity:WaitForChild("Humanoid")
	self.animator = self.humanoid:WaitForChild("Animator")
	self.rootpart = self.entity:WaitForChild("HumanoidRootPart")
	self.hitbox = self.entity:WaitForChild("Hitbox")
	self.head = self.entity:WaitForChild("Head")

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

	self._maid:Add(self.humanoid.Running:Connect(function(speed)
		if speed > 1 then
			self.state = states.moving
			self._animationTracks.WalkAnimation:AdjustSpeed(speed / self.data.walkSpeed)
			self._animationTracks["WalkAnimation"]:Play()
		else
			self:idle()
		end
	end))

	self.humanoid.WalkSpeed = self.data.walkSpeed
	self.humanoid.MaxHealth = self.data.maxHealth
	self.humanoid.Health = self.data.maxHealth

	-- pathfinding
	local pathfinding = SimplePath.new(self.entity, self.data.agentParameter, { JUMP_WHEN_STUCK = false })
	pathfinding.Visualize = true

	self._maid:Add(pathfinding.Blocked:Connect(function()
		if self.target then
			pathfinding:Run(self.target.HumanoidRootPart)
			self.resetPathFindingDebounce:lock()
		end
	end))
	self._maid:Add(pathfinding.Error:Connect(function(errorType)
		if errorType == "LimitReached" then
			return
		end
		--self:debugwarn(errorType)
		debugger.warn("OBJECT WARN [<" .. tostring(self) .. ">(pathfinding)]" .. " pathfindingError:", errorType)
		task.wait(0.2)
        if self.target then
            pathfinding:Run(self.target.HumanoidRootPart)
            self.resetPathFindingDebounce:lock()
        else
            if self.pathfinding._status ~= "Idle" then
                pathfinding:Stop()
            end
        end
	end))
	self._maid:Add(pathfinding.WaypointReached:Connect(function()
		pathfinding:Run(self.target.HumanoidRootPart)
		self.resetPathFindingDebounce:lock()
	end))
	if self.target then
		pathfinding:Run(self.target.HumanoidRootPart)
		self.resetPathFindingDebounce:lock()
	end

	self.pathfinding = pathfinding

	Promise.try(entityTag.new, self)

	self:debug("Spawned entity", self.data.name, " to the world")

	self.onSpawn:Fire(self)
	self:idle()

	return self
end

function entity:updateState(state: number)
	local currentState = self.state
	self.state = state

	self.onStateChanged:Fire(state, currentState)
end

entity.__index = entity

local class = objects.new(entity, {
	id = t.number,
	state = t.integer,
	entity = t.instanceIsA("Model"),
	data = t.table,

	canDamage = t.boolean,
})

local find = function<t>(id: t & number): typeof(entities[t])
	for _, data in pairs(entities) do
		if data.id == id then
			return data
		end
	end
	return nil
end

local new = function(id: number, spawnPositon: Vector3)
	local data = find(id)

	debugger.assert(data, "Provided id does not correlate to any entity in the database: " .. id)

	return class:new({
		id = id,
		data = data,
		state = states.dead,
		entity = data.model and data.model:Clone(),

		onSpawn = Signal.new(),
		onStateChanged = Signal.new(),
		onPlayerHit = Signal.new(),
		onAttackBegin = Signal.new(),
		onAttackEnded = Signal.new(),
		onPlayerEnterViewRange = Signal.new(),

		attackDebounce = debounce.new(debounce.type.Timer, data.attackCooldown),
		resetPathFindingDebounce = debounce.new(debounce.type.Timer, resetPathFindingRate),

		aggressive = false,
		canDamage = false,
		target = nil,

		_animationTracks = {},
		_canUpdateState = true,
		_damagedPlayers = {},
		_spawnPosition = spawnPositon,
	})
end

local monsters = {}

entityModule.new = function(id)
	local monster = new(id)
	monster.onSpawn:Connect(function()
		table.insert(monsters, monster)
	end)
	monster.onPlayerHit:Connect(function(player)
		player.Character.Humanoid:TakeDamage(monster.data.baseDamage)
	end)
	monster.onAttackBegin:Connect(function()
		task.wait(0.2)
		monster.canDamage = true
	end)
	monster.onAttackEnded:Connect(function()
		monster.canDamage = false
	end)
	monster.onPlayerEnterViewRange:Connect(function(player)
		if monster.target and monster:isValidTarget(monster.target) then
			return
		end
		monster:changeTarget(player.Character)
	end)
	monster:spawn()
end

function entityModule:load()
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Whitelist

	local validCharacters = {}

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, monsterEntity in pairs(monsters) do
			if not monsterEntity.rootpart then
				continue
			end

			table.clear(validCharacters)

			if monsterEntity.target then
				if not monsterEntity.target:FindFirstChild("HumanoidRootPart") then
					monsterEntity:changeTarget(nil)
				else
					local vector = monsterEntity.target.HumanoidRootPart.Position - monsterEntity.rootpart.Position
					local magnitude = vector.Magnitude
					if magnitude >= monsterEntity.data.visualDistance * 1.5 then
						monsterEntity:changeTarget(nil)
					end
				end
			end

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if not character or not character:FindFirstChild("HumanoidRootPart") then
					return
				end
				table.insert(validCharacters, character)

				local rootpartPosition = player.Character.HumanoidRootPart.Position
				-- Determine if the target is within attack range, otherwise, check if the player is within visual distance
				local vector = rootpartPosition - monsterEntity.rootpart.Position
				local magnitude = (vector).Magnitude
				if magnitude < monsterEntity.data.rangeOfAttack then
					if monsterEntity.pathfinding._status ~= "Idle" then
						monsterEntity.pathfinding:Stop()
					end
					monsterEntity:attack()
				elseif
					monsterEntity.target
					and monsterEntity.pathfinding._status == "Idle"
					and monsterEntity.state ~= states.moving
					and not monsterEntity.resetPathFindingDebounce:isLocked()
				then
					monsterEntity.resetPathFindingDebounce:lock()
					monsterEntity.pathfinding:Run(monsterEntity.target.HumanoidRootPart)
				elseif magnitude < monsterEntity.data.visualDistance then
					if
						math.deg(math.acos(monsterEntity.head.CFrame.LookVector:Dot(vector.Unit)))
						< monsterEntity.data.visualArcAngle
					then
						monsterEntity:playerInView(player)
					end
				end

				--[[]]
			end

			--[[local target = monsterEntity.target
            if target and target:FindFirstChild("HumanoidRootPart") then
                local targetVec = target.HumanoidRootPart.Position - monsterEntity.rootpart.Position
                if targetVec.Magnitude > monsterEntity.data.rangeOfAttack then
                    if targetVec.Magnitude <= monsterEntity.data.visualDistance then
                        monsterEntity:changeTarget(target)
                    end
                end
            else
                monsterEntity:changeTarget(nil)
            end]]

			if monsterEntity.canDamage then
				overlap.FilterDescendantsInstances = validCharacters

				local overlaps = workspace:GetPartsInPart(monsterEntity.hitbox, overlap)

				for _, characterHit in pairs(overlaps) do
					local player = Players:GetPlayerFromCharacter(characterHit.Parent)
						or Players:GetPlayerFromCharacter(characterHit.Parent.Parent)
					if not player then
						continue
					end
					monsterEntity:playerHit(player)
				end
			end
		end
	end)
end

return entityModule
