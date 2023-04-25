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
	playEntitySound = BridgeNet.CreateBridge("playEntitySound"),
	changeSecondaryWeapon = BridgeNet.CreateBridge("changeSecondaryWeapon"),
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
	dual_wield = {
		idle = resouces.dual_sword_idle,
		run = resouces.dual_sword_run,
		walk = resouces.dual_sword_walk,
		combo = {
			resouces.dual_sword_diagonalSlash,
			resouces.dual_sword_horizontalSlash,
		},
	},
}

local sounds = {
	attack = {
		resouces.sound_effects["sword 1"],
		resouces.sound_effects["sword 2"],
	},
	hit = {
		resouces.sound_effects["Sword Hit"],
	},
}

local find = function<t>(id: t & number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
		end
	end
	return nil
end

local playSound = function(id, parent)
	local sound = sounds[id][math.random(1, #sounds[id])]:Clone()
	sound.Parent = parent
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

local attackSpeed = 0.33

local current

function clientWeaponTable:Destroy()
	if current then
		current = nil
	end
	self._maid:Destroy()
end

function clientWeaponTable:updateAnim()
	self.humanoid = self.character:WaitForChild("Humanoid") :: Humanoid
	self.animator = self.humanoid:WaitForChild("Animator") :: Animator

	local idle = animations[self.class].idle
	local walk = animations[self.class].walk
	local run = animations[self.class].run

	local characterAnimationScript = self.character:WaitForChild("Animate")

	characterAnimationScript.walk.WalkAnim.AnimationId = walk.AnimationId
	characterAnimationScript.run.RunAnim.AnimationId = run.AnimationId
	characterAnimationScript.idle.Animation1.AnimationId = idle.AnimationId
	characterAnimationScript.idle.Animation2.AnimationId = idle.AnimationId

	table.clear(self.animationsTracks.combo)

	for name, anim in pairs(animations[self.class].combo) do
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
	local multi = attackAnimation.Length/attackSpeed--attackSpeed/attackAnimation.Length
	attackAnimation:Play()
	attackAnimation:AdjustSpeed(multi)

	self.hitboxClass:HitStart()
	if self.weapon2hitboxClass then
		self.weapon2hitboxClass:HitStart()
	end

	self.weapon.Handle.AttackTrail.Enabled = true
	if self.weapon2 then
		self.weapon2.Handle.AttackTrail.Enabled = true
	end
	self.comboExpired:lock()
	self.basicAttackDebounce:lock(attackSpeed)

	task.delay(attackSpeed/2, function()
		playSound("attack", self.weapon.Handle)
	end)

	self.basicAttackIncrements += 1

	local cacheattackid = self.basicAttackIncrements

	self._maid:Add(attackAnimation.Ended:Once(function()
		if self.basicAttackIncrements ~= cacheattackid then
			return
		end
		self.weapon.Handle.AttackTrail.Enabled = false
		if self.weapon2 then
			self.weapon2.Handle.AttackTrail.Enabled = false
		end
		sprint.usingWeapon(false)
		self.hitboxClass:HitStop()
		if self.weapon2hitboxClass then
			self.weapon2hitboxClass:HitStop()
		end
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
	self.hitboxClass.Visualizer = false

	self._maid:Add(self.weapon.Equipped:Connect(function()
		self:updateAnim()
	end))
	self._maid:Add(self.weapon.Activated:Connect(function()
		self:activate()
	end))
	self._maid:Add(self.hitboxClass.OnHit:Connect(function(...)
		self.hit:Fire(...)
	end), "Disconnect")

	local update = function()
		if self.character:FindFirstChild("secondary") then
			self.class = "dual_wield"
			self.weapon2 = self.character.secondary
			self.weapon2hitboxClass = RaycastHitbox.new(self.weapon2.Handle)
			self.weapon2hitboxClass.RaycastParams = RaycastParams.new()
			self.weapon2hitboxClass.RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
			self.weapon2hitboxClass.RaycastParams.FilterDescendantsInstances = { workspace.gameFolders.entities }
			self.weapon2hitboxClass.Visualizer = false
			self._maid:Add(self.weapon2hitboxClass)
		else
			if self.weapon2hitboxClass and self.weapon2hitboxClass.Destroy then
				self.weapon2hitboxClass:Destroy()
				self.weapon2hitboxClass = nil
			end
			self.class = "single_wield"
			self.weapon2 = nil
		end
		self:updateAnim()
	end

	self._maid:Add(BridgeNet.CreateBridge("changeSecondaryWeapon"):Connect(function(id, weapon)
		if self.weapon2hitboxClass and self.weapon2hitboxClass.Destroy then
			self.weapon2hitboxClass:Destroy()
		end
		self.class = "dual_wield"
		self.weapon2 = weapon
		self.weapon2hitboxClass = RaycastHitbox.new(self.weapon2.Handle)
		self.weapon2hitboxClass.RaycastParams = RaycastParams.new()
		self.weapon2hitboxClass.RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		self.weapon2hitboxClass.RaycastParams.FilterDescendantsInstances = { workspace.gameFolders.entities }
		self.weapon2hitboxClass.Visualizer = true
		self._maid:Add(self.weapon2hitboxClass)
		self:updateAnim()
	end), "Disconnect")

	self._maid:Add(self.character.ChildRemoved:Connect(function(child)
		if child.Name == "secondary" then
			if self.weapon2hitboxClass and self.weapon2hitboxClass.Destroy then
				self.weapon2hitboxClass:Destroy()
				self.weapon2hitboxClass = nil
			end
			if self.weapon2 == child then
				self.class = "single_wield"
				self.weapon2 = nil
			end
		end
		--update()
	end))

	update()

	self._maid:Add(self.hitboxClass)
end

local clientWeaponClass = objects.new(clientWeaponTable, {
	weapon = t.instanceIsA("Tool"),
	data = t.table,
	character = t.instanceIsA("Model"),
})

function new(id: number, weaponTool: Tool)
	local data = find(id)

	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. id)

	return clientWeaponClass:new({
		id = id,
		weapon = weaponTool,
		data = data,
		character = Players.LocalPlayer.Character,

		class = "single_wield",

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
	bridges.changeWeapon:Fire()
	bridges.changeWeapon:Connect(function(...)
		print(..., current)
		if current then
			current:Destroy()
			current = nil
		end
		local weapon = new(...)
		weapon:start()
		weapon._maid:Add(weapon.hit:Connect(function(target)
			if target.Parent:FindFirstChild("Humanoid") then
				playSound("hit", target)
				bridges.damageEntity:Fire(target.Parent, weapon.character.HumanoidRootPart.CFrame)
			end
		end))
	end)
	bridges.playEntitySound:Connect(function(part, sound)
		if sound:FindFirstChild("pitch") then
			sound.pitch = math.random(0.9, 1.1)
		end
		sound = sound:Clone()
		sound.Parent = part
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
	end)
end

combatHandler.new = new

return combatHandler
