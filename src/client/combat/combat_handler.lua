--!strict
--[[
    FileName    > combat_handler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/12/2022
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
local RaycastHitbox = require(ReplicatedStorage.Packages.RaycastHitbox)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local weapons = require(ReplicatedStorage.shared.weapons)

local sprint = require(script.Parent.Parent.character.sprint)

local bridges = {
	changeWeapon = BridgeNet.CreateBridge("changeWeapon"),
	damageEntity = BridgeNet.CreateBridge("damageEntity"),
}

local combatHandler = {}

local resouces = ReplicatedStorage.resources.combat_resources

local clientWeaponTable = {}
clientWeaponTable.__index = clientWeaponTable

local animations = {
	single_wield = {
		idle = resouces.one_sword_idle,
		run = resouces.one_sword_run,
		walk = resouces.one_sword_walk,
		combo = {
			resouces.one_sword_verticalSlash1,
			resouces.one_sword_horizontalSlash,
			resouces.one_sword_diagonalSlash,
			resouces.one_sword_verticalSlash2,
		},
	},
}

function clientWeaponTable:equip()
	self.humanoid = self.character:WaitForChild("Humanoid") :: Humanoid
	self.animator = self.humanoid:WaitForChild("Animator") :: Animator

	local idle = animations[self.data.class].idle
	local walk = animations[self.data.class].walk
	local run = animations[self.data.class].run

	local characterAnimationScript = self.character:WaitForChild("Animate")

	characterAnimationScript.walk.WalkAnim.AnimationId = walk.AnimationId
	characterAnimationScript.run.RunAnim.AnimationId = run.AnimationId
	characterAnimationScript.idle.Animation1.AnimationId = idle.AnimationId
	characterAnimationScript.idle.Animation2.AnimationId = idle.AnimationId

	for name, anim in pairs(animations[self.data.class].combo) do
		self.animationsTracks.combo[name] = self.animator:LoadAnimation(anim)
		self.animationsTracks.combo[name].Looped = false
	end
end

function clientWeaponTable:activate()
	if self.basicAttackDebounce:isLocked() then
		return
	end

	if self.combo >= #self.animationsTracks.combo or self.comboExpired:isLocked() then
		self.combo = 0
	end
	self.combo += 1

	sprint.usingWeapon(true)

	local attackAnimation = self.animationsTracks.combo[self.combo]
	attackAnimation:Play()
	self.hitboxClass:HitStart()
	self.comboExpired:lock()
	self.basicAttackDebounce:lock(attackAnimation.Length)

	self.basicAttackIncrements += 1

	local cacheattackid = self.basicAttackIncrements

	self._maid:Add(attackAnimation.Ended:Once(function()
		if self.basicAttackIncrements ~= cacheattackid then
			return
		end
		sprint.usingWeapon(false)
		self.hitboxClass:HitStop()
		task.wait(0.3)
		if self.basicAttackIncrements ~= cacheattackid then
			return
		end
		self.comboExpired:unlock()
	end))
end

function clientWeaponTable:start()
	self.hitboxClass.RaycastParams = RaycastParams.new()
	self.hitboxClass.RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	self.hitboxClass.RaycastParams.FilterDescendantsInstances = { workspace.gameFolders.entities }
	self.hitboxClass.Visualizer = true
	self._maid:Add(self.weapon.Equipped:Connect(function()
		self:equip()
	end))
	self._maid:Add(self.weapon.Activated:Connect(function()
		self:activate()
	end))
	self.hitboxClass.OnHit:Connect(function(...)
		self.hit:Fire(...)
	end)

	local animator = self.character.Humanoid.Animator
	local walk = animations[self.data.class].walk
	local run = animations[self.data.class].run
	local walkAnim, runAnim = animator:LoadAnimation(walk), animator:LoadAnimation(run)
	local isRunPlaying = false

	walkAnim.Priority = Enum.AnimationPriority.Movement
	runAnim.Priority = Enum.AnimationPriority.Movement

	self.character.Humanoid.Running:Connect(function(speed)
		if speed > 18 then
			if isRunPlaying then
				return
			end
			walkAnim:Stop()
			runAnim:Play(0.5)
			isRunPlaying = true
		elseif speed <= 18 and speed > 0 then
			runAnim:Stop()
			walkAnim:Play(0.5)
			isRunPlaying = false
		else
			runAnim:Stop()
			walkAnim:Stop()
			isRunPlaying = false
		end
	end)
	self.character.Humanoid.StateChanged:Connect(function(old, new)
		if new ~= Enum.HumanoidStateType.Running or new ~= Enum.HumanoidStateType.RunningNoPhysics then
			runAnim:Stop()
			walkAnim:Stop()
			isRunPlaying = false
		end
	end)
	self._maid:Add(self.hitboxClass)
end

local clientWeaponClass = objects.new(clientWeaponTable, {
	weapon = t.instanceIsA("Tool"),
	data = t.table,
	character = t.instanceIsA("Model"),
})

local find = function<t>(id: t & number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
		end
	end
	return nil
end

function new(id: number, weaponTool: Tool)
	local data = find(id)

	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. id)

	return clientWeaponClass:new({
		id = id,
		weapon = weaponTool,
		data = data,
		character = Players.LocalPlayer.Character,

		basicAttackDebounce = debounce.new(debounce.type.Timer, data.basicAttackCooldown),
		comboExpired = debounce.new(debounce.type.Boolean),
		hitboxClass = RaycastHitbox.new(weaponTool),
		hit = Signal.new(),

		animationsTracks = { combo = {} },
		combo = 0,
		basicAttackIncrements = 0,
	})
end

function combatHandler:load()
	bridges.changeWeapon:Connect(function(...)
		local weapon = new(...)
		weapon:start()
		weapon.hit:Connect(function(target)
			if target.Parent:FindFirstChild("Humanoid") then
				bridges.damageEntity:Fire(target.Parent, weapon.id, weapon.character.HumanoidRootPart.CFrame)
				target.Parent.Humanoid:TakeDamage(weapon.data.baseDamage)
			end
		end)
	end)
end

combatHandler.new = new

return combatHandler
