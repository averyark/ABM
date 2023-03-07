--!strict
--[[
    FileName    > entityBehaviours.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/12/2022
--]]
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
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
local SimplePath = require(ReplicatedStorage.shared.SimplePath)
local weapons = require(ReplicatedStorage.shared.weapons)

local entities = require(script.Parent.entities)

local entity = { __DEBUG__ENABLED = false }
local entityModule = {}

local bridges = {
	replicateEntityAnimation = BridgeNet.CreateBridge("replicateEntityAnimation"),
	initializeEntityOnClient = BridgeNet.CreateBridge("initializeEntityOnClient"),
	requestEntityAnimationIds = BridgeNet.CreateBridge("requestEntityAnimationIds"),
	entityDamaged = BridgeNet.CreateBridge("entityDamaged"),
	entityDied = BridgeNet.CreateBridge("entityDied"),
	playEntitySound = BridgeNet.CreateBridge("playEntitySound"),
}

local resources = ReplicatedStorage.resources.combat_resources
local sounds = {
	punch = {
		resources.sound_effects.punch1,
		resources.sound_effects["punch 2"],
	},
	punchHit = resources.sound_effects["punch hit"],
}

local states = {
	dead = 0,
	idle = 1,
	moving = 2,
	attacking = 3,
	stuned = 4,
}

local resetPathFindingRate = 10 / 30

local hugeVector = Vector3.new(1, 1, 1) * math.huge

local ap = workspace.AnimationProvider
local animationCache = {}
local getAnimationLength = function(animationId)
	if animationCache[animationId] and animationCache[animationId] ~= 0 then
		return animationCache[animationId]
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = ap.Humanoid.Animator:LoadAnimation(animation)

	animationCache[animationId] = track.Length

	track:Destroy()

	return track.Length
end

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

	--self:replicateAnimationToClient("Stop", "IdleAnimation")

	local num = math.random(1, #self.data.animations.AttackAnimations)
	self:replicateAnimationToClient("Play", "AttackAnimations", num)
	bridges.playEntitySound:FireAllInRange(self.rootpart.Position, 30, self.rootpart, sounds.punch[num])

	self._attackAnimationLengths[num] = getAnimationLength(self.data.animations.AttackAnimations[num])

	task.wait(self._attackAnimationLengths[num])
	self.attackDebounce:lock()
	self.onAttackEnded:Fire()
	self._canUpdateState = true
	self:idle()

	--task.wait(self.data.attackCooldown)
end

function entity:takeDamage(player, damage, damageType, knockback, playerCFrame)
	if knockback then
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Parent = self.rootpart
		bodyVelocity.MaxForce = hugeVector
		bodyVelocity.P = 1000
		bodyVelocity.Velocity = Vector3.new(
			playerCFrame.lookVector.X * knockback,
			knockback,
			playerCFrame.lookVector.Z * knockback
		)

		self.lastAttacker = player
		self.entity.Humanoid:TakeDamage(damage)
		bridges.entityDamaged:FireAllInRange(self.rootpart.Position, 100, self.entity, player, damage, damageType)
		
		local realKnockback = math.clamp(knockback - self.data.knockbackResistance, 0, 20)
		if realKnockback > 8 then
			local num = math.random(1, #self.data.animations.KnockbackAnimation)
			self:replicateAnimationToClient("Play", "KnockbackAnimation", num)
			self._canUpdateState = false
			self.humanoid.WalkSpeed = 0
		end
		task.wait(0.1)
		bodyVelocity:Destroy()
		task.wait(realKnockback / 50)

		self.humanoid.WalkSpeed = self.data.walkSpeed
		if self.target or self.movingLocation then
			self.pathfinding:Run(self.movingLocation or self.target.HumanoidRootPart)
			self.resetPathFindingDebounce:lock()
		else
			if self.pathfinding._status ~= "Idle" then
				self.pathfinding:Stop()
			end
		end
		self._canUpdateState = true
	end
	if not self.target then
		self:changeTarget(player.Character)
	end
end

function entity:playerHit(player)
	if self.state == states.attacking then
		if table.find(self._damagedPlayers, player) then
			return
		end
		table.insert(self._damagedPlayers, player)
		self.onPlayerHit:Fire(player)
	end
end

function entity:changeTarget(target)
	if not self._canUpdateState then
		return
	end
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
	self.movingLocation = nil
	self.resetPathFindingDebounce:lock()
	self.pathfinding:Run(self.target.HumanoidRootPart)
end

function entity:Destroy()
	self._maid:Destroy()
end

function entity:replicateAnimationToClient(requestType, animationName, animationSubName)
	bridges.replicateEntityAnimation:FireAllInRange(
		self.rootpart.Position,
		100,
		self.entity,
		requestType,
		animationName,
		animationSubName
	)
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

function entity:moveTo(position: Vector3)
	if not self._canUpdateState then
		return
	end
	self.movingLocation = position
	self.pathfinding:Run(position)
end

function entity:idle()
	if not self._canUpdateState then
		return
	end
	self:updateState(states.idle)
	self:replicateAnimationToClient("Stop", "WalkAnimation")
	self:replicateAnimationToClient("Play", "IdleAnimation")
end

function entity:spawn(spawnCFrame: CFrame)
	self.entity.Parent = workspace.gameFolders.entities
	self.humanoid = self.entity:WaitForChild("Humanoid")
	self.animator = self.humanoid:WaitForChild("Animator")
	self.rootpart = self.entity:WaitForChild("HumanoidRootPart")
	self.hitbox = self.entity:WaitForChild("Damagebox")
	self.head = self.entity:WaitForChild("Head")

	self.rootpart.CFrame = spawnCFrame
	self._spawnCFrame = spawnCFrame

	for _, part in pairs(self.entity:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Entity"
		end
	end

	self._maid:Add(self.entity.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "Entity"
		end
	end))

	for _, signal in pairs(self) do
		if Signal.Is(signal) then
			self._maid:Add(signal)
		end
	end

	self._maid:Add(self.entity)
	self._maid:Add(self.humanoid.Running:Connect(function(speed)
		if speed > 1 then
			self.gyro.Parent = nil
			self.state = states.moving
		else
			self.gyro.Parent = self.rootpart
			if not self._canUpdateState then
				return
			end
			self:updateState(states.idle)
		end
	end))

	self.humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	self.humanoid.WalkSpeed = self.data.walkSpeed
	self.humanoid.MaxHealth = self.data.maxHealth
	self.humanoid.Health = self.data.maxHealth

	-- pathfinding
	local pathfinding = SimplePath.new(self.entity, self.data.agentParameter, { JUMP_WHEN_STUCK = false })
	pathfinding.Visualize = false

	self._maid:Add(pathfinding.Blocked:Connect(function()
		if self.target or self.movingLocation then
			pathfinding:Run(self.movingLocation or self.target.HumanoidRootPart)
			self.resetPathFindingDebounce:lock()
		end
	end))
	self._maid:Add(pathfinding.Error:Connect(function(errorType)
		if errorType == "LimitReached" then
			return
		end
		--self:debugwarn(errorType)
		--debugger.warn("OBJECT WARN [<" .. tostring(self) .. ">(pathfinding)]" .. " pathfindingError:", errorType)
		task.wait(0.2)
		if self.target or self.movingLocation then
			pathfinding:Run(self.movingLocation or self.target.HumanoidRootPart)
			self.resetPathFindingDebounce:lock()
		else
			if self.pathfinding._status ~= "Idle" then
				pathfinding:Stop()
			end
		end
	end))
	self._maid:Add(pathfinding.WaypointReached:Connect(function()
		if not self._canUpdateState then
			return
		end
		if not self.target and not self.movingLocation then
			return
		end
		pathfinding:Run(self.movingLocation or self.target.HumanoidRootPart)
		self.resetPathFindingDebounce:lock()
	end))
	self._maid:Add(self.humanoid.Died:Connect(function()
		self.onDeath:Fire(self.lastAttacker)
	end))
	if self.target then
		pathfinding:Run(self.target.HumanoidRootPart)
		self.resetPathFindingDebounce:lock()
	end

	self.pathfinding = pathfinding

	local gyro = Instance.new("BodyGyro")
	gyro.D = 150
	gyro.P = 4000
	gyro.MaxTorque = Vector3.new(0, 10000, 0)
	gyro.CFrame = self._spawnCFrame
	gyro.Parent = nil

	self.gyro = gyro

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
		onPlayerHit = Signal.new(),
		onAttackBegin = Signal.new(),
		onAttackEnded = Signal.new(),
		onPlayerEnterViewRange = Signal.new(),
		onDeath = Signal.new(),

		attackDebounce = debounce.new(debounce.type.Timer, data.attackCooldown),
		resetPathFindingDebounce = debounce.new(debounce.type.Timer, resetPathFindingRate),

		aggressive = false,
		canDamage = false,
		target = nil,

		_attackAnimationLengths = {},
		_canUpdateState = true,
		_damagedPlayers = {},
	})
end

local monsters = {}

local droppedEntityHandler = require(script.Parent.droppedEntityHandler)

entityModule.new = function(id: number, cf: CFrame)
	debugger.assert(t.integer(id))
	debugger.assert(t.CFrame(cf))
	debugger.assert(t.table(find(id)))

	return Promise.try(function()
		local monster = new(id)
		monster.onSpawn:Connect(function()
			table.insert(monsters, monster)
		end)
		monster.onPlayerHit:Connect(function(player)
			if monster.isDead then return end
			bridges.playEntitySound:FireAllInRange(
				monster.rootpart.Position,
				30,
				player.Character.HumanoidRootPart,
				sounds.punchHit
			)
			player.Character.Humanoid:TakeDamage(monster.data.baseDamage)
		end)
		monster.onAttackBegin:Connect(function()
			if monster.isDead then return end
			monster.canDamage = true
		end)
		monster.onAttackEnded:Connect(function()
			monster.canDamage = false
		end)
		monster.onPlayerEnterViewRange:Connect(function(player)
			if monster.isDead then return end
			if monster.target and monster:isValidTarget(monster.target) then
				return
			end
			monster:changeTarget(player.Character)
		end)
		monster.onDeath:Connect(function(killer)
			monster.isDead = true
			local xpReward = math.random(monster.data.expDrop.min, monster.data.expDrop.max)
			droppedEntityHandler.bulk(killer, "xp", 10, xpReward/10, monster.entity.HumanoidRootPart.Position)
			if math.random() < 0.4 then
				local chance = math.random() * 100
				local v = 0
				local selected

				local clone = table.clone(monster.data.drops)

				table.sort(clone, function(a, b)
					return a < b
				end)

				for name, dropChance in pairs(monster.data.drops) do
					if chance <= v + dropChance then
						selected = name
						break
					end
					v += dropChance
				end

				local dropId = weapons[selected].id
				droppedEntityHandler.one(killer, "weapon/" .. dropId, 1, monster.entity.HumanoidRootPart.Position)
			end
			monster.entity.HumanoidRootPart.Anchored = true
			for _, object in pairs(monster.entity:GetDescendants()) do
				if object:IsA("BasePart") then
					object.CanCollide = false
				end
			end
			bridges.entityDied:FireAllInRange(monster.rootpart.Position, 100, monster.entity)
			task.wait(1)
			table.remove(monsters, table.find(monsters, monster))
			monster:Destroy()
		end)
		monster:spawn(cf)

		monster.hitbox.Touched:Connect(function(touchPart)
			if monster.isDead then return end
			if monster.canDamage then
				local player = Players:GetPlayerFromCharacter(touchPart.Parent)
					or Players:GetPlayerFromCharacter(touchPart.Parent.Parent)
				if not player then
					return
				end
				monster:playerHit(player)
			end
		end)

		return monster
	end)
		:catch(function(...)
			debugger.warn(...)
		end)
		:expect()
end

entityModule.getMonster = function(model)
	for _, monster in pairs(monsters) do
		if monster.entity == model then
			return monster
		end
	end
end

function entityModule:load()
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Whitelist

	local validCharacters = {}

	bridges.requestEntityAnimationIds:OnInvoke(function(player, model)
		for _, monsterEntity in pairs(monsters) do
			if monsterEntity.entity == model then
				return monsterEntity.data.animations
			end
		end
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, monsterEntity in pairs(monsters) do
			if not monsterEntity.rootpart then
				continue
			end

			table.clear(validCharacters)

			if monsterEntity.target then
				if not monsterEntity.target:FindFirstChild("Humanoid") then
					monsterEntity:changeTarget(nil)
				else
					if monsterEntity.target.Humanoid.Health <= 0 then
						monsterEntity:changeTarget(nil)
					end
				end
			end
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

			if monsterEntity.target then
				local rootpartPosition = monsterEntity.target.HumanoidRootPart.Position
				local playerDistanceFromEntitySpawn = (rootpartPosition - monsterEntity._spawnCFrame.Position).Magnitude

				if playerDistanceFromEntitySpawn > monsterEntity.data.maximumDistanceFromSpawn then
					monsterEntity:changeTarget(nil)
				end
			end

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if not character or not character:FindFirstChild("HumanoidRootPart") then
					return
				end
				table.insert(validCharacters, character)

				local rootpartPosition = player.Character.HumanoidRootPart.Position
				-- Determine if the target is inside of the detection range (relative to spawnPosition of the entity)
				local playerDistanceFromEntitySpawn = (rootpartPosition - monsterEntity._spawnCFrame.Position).Magnitude

				if playerDistanceFromEntitySpawn > monsterEntity.data.maximumDistanceFromSpawn then
					continue
				end

				-- Determine if the target is within attack range, otherwise, check if the player is within visual distance
				local vector = rootpartPosition - monsterEntity.rootpart.Position
				local magnitude = vector.Magnitude

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
				if monsterEntity.gyro.Parent ~= nil and monsterEntity.target then
					monsterEntity.gyro.CFrame = CFrame.lookAt(
						monsterEntity.rootpart.Position,
						monsterEntity.target.HumanoidRootPart.Position
					)
				end
			end

			if not monsterEntity.target and not monsterEntity.movingLocation then
				task.spawn(monsterEntity.moveTo, monsterEntity, monsterEntity._spawnCFrame.Position)
			end
		end
	end)
end



return entityModule
