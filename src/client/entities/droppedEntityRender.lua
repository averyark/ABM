--!strict
--[[
    FileName    > droppedCurrencyRender.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 02/01/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
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
local debug3d = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local weapons = require(ReplicatedStorage.shared.weapons)
local rarities = require(ReplicatedStorage.shared.rarities)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local settings = require(script.Parent.Parent.interface.settings)
local pass = require(script.Parent.Parent.passHandler)
local notifications = require(script.Parent.Parent.interface.notifications)

local player = Players.LocalPlayer
local entityTemplate = ReplicatedStorage.resources.droppedEntity
local droppedCurrencyHolder = workspace.gameFolders.droppedCurrencies
local uiSounds = ReplicatedStorage.resources.ui_sound_effects

local hugeVector = Vector3.one * math.huge

local cleanupInterval = 1 / 2

local collectedBillboard = {}
local lastCollectedBillboardUpdate = {}
local droppedEntityObjects = {}
local droppedEntityClass = {
	expireInterval = 30,
	dispensePower = Vector3.new(0, 5, 0),
	powerInterval = 0.3,
	bounceInterval = { min = 5, max = 10 },
}

local bridges = {
	collectDroppedEntity = BridgeNet.CreateBridge("collectDroppedEntity"),
}

local icons = {
	coin = "rbxassetid://11895034615",
	xp = "rbxassetid://12688067279"
}

local color = {
	xp = Color3.fromRGB(255, 186, 102),
	coin = Color3.fromRGB(255, 255, 255)
}

droppedEntityClass.__index = droppedEntityClass

local find = function(id) : typeof(weapons["Katana"])
	for _, data in pairs(weapons) do
		if data.id == tonumber(id) then
			return data
		end
	end
end

function droppedEntityClass:render()
	local rType, id = unpack(self.type:split("/"))
	local data = if rType == "weapon" then find(id) else nil

	self.object = entityTemplate:Clone()
	self.object.orb.icon.Image = if data then data.iconId else icons[rType]
	self.object.orb.shine.ImageColor3 =
		if data then
			rarities[data.rarity].primaryColor
		elseif color[rType] then
			color[rType]
		else
			Color3.fromRGB(255, 255, 255)

	self.object.Name = self.id
	self.object.Position = self.pos
	self.object.orb.Enabled = true
	self.object.Parent = droppedCurrencyHolder
	self.object.CollisionGroup = "EntityDropped"

	self.spawnTick = os.clock()
	self.nextBounceInt = os.clock() + math.random(self.bounceInterval.min, self.bounceInterval.max)

	if rType == "weapon" then
		self.object.orb.Size = UDim2.fromScale(3, 3)
		self.defaultExtents = Vector3.new(0, 4, 0)
	else
		self.defaultExtents = Vector3.new(0, 2, 0)
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Parent = self.object
	bodyVelocity.MaxForce = hugeVector
	bodyVelocity.P = 1000
	bodyVelocity.Velocity = self.dispensePower

	task.spawn(function()
		task.wait(self.powerInterval)
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end)

	self._maid:Add(bodyVelocity)
	self._maid:Add(self.object)
	self._maid:Add(self.errDebounce)
	table.insert(droppedEntityObjects, self)

	local workspaceDebug = debug3d.new(self.object)

	workspaceDebug:linkMetatable(self, {"type", "amount"})

	--self._maid:Add(workspaceDebug)

end

function droppedEntityClass:bounce()
	self.nextBounceInt = os.clock() + math.random(self.bounceInterval.min, self.bounceInterval.max)
	tween.instance(self.object.orb, {
		ExtentsOffset = self.defaultExtents + Vector3.new(0, 5, 0),
	}, 0.2, "Sine").Completed:Wait()
	tween.instance(self.object.orb, {
		ExtentsOffset = self.defaultExtents,
	}, 0.5, "Bounce")
end

function droppedEntityClass:collect()
	if self.collected then
		return
	end

	local rType, id = unpack(self.type:split("/"))

	if rType == "weapon" then
		
		local playerData = playerDataHandler.getPlayer()

		local hasInfinite = pass.ownPass("InfiniteInventory")
		local hasSwordSpace = pass.ownPass("50SwordSlots")
		local hasVIP = pass.ownPass("VIP")
		local max = 20 +
			(hasSwordSpace and 50 or 0) +
			(hasVIP and 25 or 0)

		if not hasInfinite and #playerData.data.inventory.weapon+1 > max then
			if not self.errDebounce:isLocked() then
				self.errDebounce:lock()
			
				notifications.new():error(`Error: Insufficient Inventory Space! Trash { #playerData.data.inventory.hero - max} Sword(s) or purchase the gamepass.`)
				--[[pass.promptPassPurchase(self.ownership,
					if hasVIP and hasSwordSpace then "InfiniteInventory"
							elseif hasVIP then "VIP"
							else  "50SwordSlots"
				)]]
			end
			return
		end
	end

	debugger.assert(t.instanceIsA("Model")(player.Character))

	local clone = self.object:Clone()
	local amount = self.amount

	self.collected = true
	self:Destroy()
	self.object:Destroy()

	clone.orb.ExtentsOffset = Vector3.zero
	clone.orb.icon.ImageTransparency = 0
	clone.orb.shine.ImageTransparency = 0
	clone.CanCollide = false
	clone.Anchored = true
	clone.Parent = workspace.gameFolders.droppedCurrencies

	local connection
	local timeout = function(object)
		clone:Destroy()
		connection:Disconnect()
	end
	local reachedPlayer = function()
		clone:Destroy()
		connection:Disconnect()
		local reachPosition = player.Character.HumanoidRootPart.Position

		bridges.collectDroppedEntity:Fire(self.id)

		local expire
		expire = function(billboard)
			if
				lastCollectedBillboardUpdate[self.type]
				and os.clock() - lastCollectedBillboardUpdate[self.type] <= 2
			then
				task.wait(2)
				expire(billboard)
				return
			end

			lastCollectedBillboardUpdate[self.type] = nil
			collectedBillboard[self.type] = nil

			tween.instance(billboard.orb.icon, {
				ImageTransparency = 1,
			}, 0.35)
			tween.instance(billboard.orb.label, {
				TextTransparency = 1,
			}, 0.35)
			tween.instance(billboard.orb.label.stroke, {
				Transparency = 1,
			}, 0.35)
			task.wait(0.5)
			billboard:Destroy()
		end

		if collectedBillboard[self.type] then
			local billboard = collectedBillboard[self.type]
			billboard:SetAttribute("rawValue", billboard:GetAttribute("rawValue") + amount)
			billboard.orb.label.Text = number.abbreviate(billboard:GetAttribute("rawValue"))
			billboard.Position = reachPosition
			lastCollectedBillboardUpdate[self.type] = os.clock()
			billboard.orb.ExtentsOffset = Vector3.new(0, 0, 0)
			tween.instance(billboard.orb, {
				ExtentsOffset = Vector3.new(0, 3, 0),
			}, 2)
		else
			local billboard = ReplicatedStorage.resources.droppedEntityCollect:Clone()

			local rType, id = unpack(self.type:split("/"))
			local data = if rType == "weapon" then find(id) else nil

			if rType == "weapon" then
				billboard.orb.label.stroke.Color = Color3.fromRGB(29, 29, 29)
			elseif rType == "coin" then
				settings.playSound(uiSounds["coin getter"])
			end

			billboard.orb.icon.Image = if data then data.iconId else icons[rType]
			billboard.orb.label.Text = number.abbreviate(amount)
			billboard:SetAttribute("rawValue", amount)

			billboard.Position = reachPosition
			billboard.Parent = workspace.gameFolders.droppedCurrencies

			lastCollectedBillboardUpdate[self.type] = os.clock()
			collectedBillboard[self.type] = billboard
			tween.instance(billboard.orb, {
				ExtentsOffset = Vector3.new(0, 3, 0),
			}, 2).Completed:Wait()
			expire(billboard)
		end
	end

	local propulse = Instance.new("RocketPropulsion")

	propulse.CartoonFactor = 0
	propulse.ThrustP = 50 + (player.Character.Humanoid.WalkSpeed * 1.1)
	propulse.ThrustD = 10
	propulse.MaxSpeed = 50 + (player.Character.Humanoid.WalkSpeed * 1.5)

	propulse.Parent = clone
	propulse.Target = player.Character.HumanoidRootPart
	clone.Anchored = false
	propulse:Fire()

	connection = propulse.ReachedTarget:Connect(reachedPlayer)

	task.delay(0.5, timeout)
end

function droppedEntityClass:Destroy()
	local index = table.find(droppedEntityObjects, self)
	if index then
		table.remove(droppedEntityObjects, index)
	end
	self._maid:Cleanup()
	self._maid:Destroy()
end

local droppedEntityObject = objects.new(droppedEntityClass, {
	id = t.string,
	pos = t.Vector3,
	dispensePower = t.Vector3,

	collected = t.boolean,
})

local new = function(
	type: string,
	droppedEntityId: string,
	droppedEntityPos: Vector3,
	amount: number,
	droppedEntityDispensePower: Vector3,
	droppedEntityExpireInterval: number
)
	return droppedEntityObject:new({
		type = type,
		id = droppedEntityId,
		pos = droppedEntityPos,
		dispensePower = droppedEntityDispensePower,
		expireInterval = droppedEntityExpireInterval,
		amount = amount,

		errDebounce = debounce.new(debounce.type.Timer, 5),

		collected = false,
	})
end

return {
	new = new,
	load = function()
		local cleanupDebounce = debounce.new(debounce.type.Timer, cleanupInterval)
		RunService.Heartbeat:Connect(function(deltaTime)
			-- if cleanupDebounce:isLocked() then return end
			--cleanupDebounce:lock()

			local nowInt = os.clock()
			local character = player.Character
			local playerCharacterPosition = player.Character

			if character then
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if hrp then
					playerCharacterPosition = hrp.Position
				end
			end

			for _, entity in pairs(droppedEntityObjects) do
				task.spawn(function()
					local relative = nowInt - entity.spawnTick
					if relative > entity.expireInterval then
						entity:Destroy()
						return
					elseif relative > entity.expireInterval / 2 then
						entity.object.orb.icon.ImageTransparency = 0.5
						entity.object.orb.shine.ImageTransparency = 0.5
					end
					if playerCharacterPosition then
						local entityPosition = entity.object.Position
						local magnitude = (entityPosition - playerCharacterPosition).Magnitude

						if relative > 0.5 and magnitude < 12 then
							entity:collect()
						end
					else
						if entity.nextBounceInt and nowInt > entity.nextBounceInt then
							entity:bounce()
						end
					end
				end)
			end
		end)
		BridgeNet.CreateBridge("makeDroppedEntity"):Connect(function(...)
			new(...):render()
		end)
	end,
}
