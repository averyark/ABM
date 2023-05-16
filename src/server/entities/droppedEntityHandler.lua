--!strict
--[[
    FileName    > droppedCurrencyHandler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 02/01/2023
--]]
local HttpService = game:GetService("HttpService")
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

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local weapons = require(ReplicatedStorage.shared.weapons)
local pass = require(script.Parent.Parent.systems.pass)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local badges = require(script.Parent.Parent.systems.badges)

local cleanupInterval = 0.5

local indexes = {}

local bridges = {
	makeDroppedEntity = BridgeNet.CreateBridge("makeDroppedEntity"),
	collectDroppedEntity = BridgeNet.CreateBridge("collectDroppedEntity"),
	notifError = BridgeNet.CreateBridge("notifError"),
	itemObtained = BridgeNet.CreateBridge("itemObtained")
}

local droppedEntityClass = {
	expireInterval = 30,
	power = 5,
	yPowerMultiplier = 4,
	__DEBUG__ENABLED = false,
}
droppedEntityClass.__index = droppedEntityClass

local findItem = function(id)
	for _, data in pairs(weapons) do
		if data.id == tonumber(id) then
			return data
		end
	end
end

function droppedEntityClass:register()
	self.spawnTick = os.clock()
	self.yPower = self.power * self.yPowerMultiplier
	self.negativePower = -self.power

	bridges.makeDroppedEntity:FireTo(self.ownership,
		self.type,
		self.id,
		self.position,
		self.amount,
		Vector3.new(
			math.random(self.negativePower, self.power),
			math.random(0, self.yPower),
			math.random(self.negativePower, self.power)
		),
		self.expireInterval
	)

	if not indexes[self.ownership] then
		indexes[self.ownership] = {}
	end

	table.insert(indexes[self.ownership], self)

	return self
end

function droppedEntityClass:collect()
	local rType, id = unpack(self.type:split("/"))

	if rType == "coin" then
		playerDataHandler.getPlayer(self.ownership):apply(function(f)
			f.data.coins += self.amount
			f.data.stats.coinsCollected += self.amount
		end)
	elseif rType == "xp" then
		playerDataHandler.getPlayer(self.ownership):apply(function(f)
			f.data.xp += self.amount
			f.data.stats.xpCollected += self.amount
		end)
	elseif rType == "weapon" then
		local itemData = findItem(id)

		local playerData = playerDataHandler.getPlayer(self.ownership)

		local hasInfinite = pass.hasPass(self.ownership, "InfiniteInventory")
		local hasSwordSpace = pass.hasPass(self.ownership, "50SwordSlots")
		local hasVIP = pass.hasPass(self.ownership, "VIP")
		local max = 20 +
			(hasSwordSpace and 50 or 0) +
			(hasVIP and 25 or 0)

		if not hasInfinite and #playerData.data.inventory.weapon+1 > max then
			bridges.notifError:FireTo(self.ownership, `Error: Insufficient Inventory Space! Trash { #playerData.data.inventory.hero - max} Sword(s) or purchase the gamepass.`)
			--[[pass.promptPassPurchase(self.ownership,
				if hasVIP and hasSwordSpace then "InfiniteInventory"
						elseif hasVIP then "VIP"
						else  "50SwordSlots"
			)]]
			return
		end

		if itemData.rarity == 4 then
			badges.incrementProgress(self.ownership, "legendarySwordUnlocked", 1)
		end

		playerDataHandler.getPlayer(self.ownership):apply(function(f)
			table.insert(f.data.stats.obtainedItemIndex.weapon, itemData.id)
			f.data.stats.itemsObtained.weapon += 1
			table.insert(f.data.inventory.weapon, {
				index = f.data.stats.itemsObtained.weapon,
				id = itemData.id,
				level = 0,
			})
			--print("test", playerDataHandler.getPlayer(self.ownership).data)
		end)
		bridges.itemObtained:FireTo(self.ownership, "weapon", itemData.id, self.percentage)
	end

	self:Destroy()
end

function droppedEntityClass:Destroy()
	local index = table.find(indexes[self.ownership], self)
	if index then
		table.remove(indexes[self.ownership], index)
	end
	self._maid:Destroy()
end

local droppedEntityObject = objects.new(droppedEntityClass, {
	position = t.Vector3,
	power = t.union(t.none, t.number),
	expireInterval = t.union(t.none, t.number),
})

local new =
	function(player: Player, type: string, amount: number, position: Vector3, power: number?, expireInterval: number?)
		return droppedEntityObject
			:new({
				id = HttpService:GenerateGUID(),
				position = position,
				power = power,
				expireInterval = expireInterval,
				ownership = player,
				amount = amount,
				type = type,
			})
			:register()
	end

local bulk = function(
	player: Player,
	type: string,
	count: number,
	amount: number,
	position: Vector3,
	power: number?,
	expireInterval: number?
)
	debugger.assert(t.integer(count))
	debugger.assert(t.number(amount))
	local list = {}

	for i = 1, count do
		table.insert(list, new(player, type, amount, position, power, expireInterval))
	end

	return list
end

return {
	load = function()
		local cleanupDebounce = debounce.new(debounce.type.Timer, cleanupInterval)
		local fountain = debounce.new(debounce.type.Timer, 0.1)

		Players.PlayerRemoving:Connect(function(player)
			local index = indexes[player]
			if index then
				for _, self in pairs(index) do
					Promise.try(function()
						self:Destroy()
					end)
				end
				indexes[player] = nil
			end
		end)

		bridges.collectDroppedEntity:Connect(function(player, id)
			if not indexes[player] then
				return
			end
			for _, self in pairs(indexes[player]) do
				if self.id == id then
					return self:collect()
				end
			end
		end)

		RunService.Heartbeat:Connect(function(deltaTime)
			if cleanupDebounce:isLocked() then
				return
			end
			cleanupDebounce:lock()

			for _, droppedEntityList in pairs(indexes) do
				for _, playerOwnedDroppedEntity in pairs(droppedEntityList) do
					if os.clock() - playerOwnedDroppedEntity.spawnTick > playerOwnedDroppedEntity.expireInterval then
						playerOwnedDroppedEntity:Destroy()
					end
				end
			end
		end)
	end,
	one = new,
	bulk = bulk,
}
