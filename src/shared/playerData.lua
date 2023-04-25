--!strict
--[[
    FileName    > clientDataHandler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 09/01/2023
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

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)

local bridges = {
	datastoreFailure = BridgeNet.CreateBridge("datastoreFailure"),
	datastoreOnline = BridgeNet.CreateBridge("datastoreOnline"),
	datastoreRetrieve = BridgeNet.CreateBridge("datastoreRetrieve"),
	datastoreDataChanged = BridgeNet.CreateBridge("datastoreDataChanged"),
}

function deepCopy<T>(tableToClone: T, cache): T
	local result: T = {}

	cache = cache or {}

	for key: number, v in pairs(tableToClone) do
		if typeof(v) == "table" then
			if table.find(cache, v) then
				return
			end -- anti recursive
			table.insert(cache, v)
			result[key] = deepCopy(v, cache)
		else
			result[key] = v
		end
	end

	return result
end

local fromPath = function(tb, path)
	local ntb = tb
	for i, key in pairs(path) do
		if typeof(ntb) ~= "table" then
			return
		end
		ntb = ntb[key]
	end
	return ntb
end

local match = function(path, changes)
	for _, change in pairs(changes) do
		local matchRate = 0
		-- ancestry changed
		for i, pathKey in pairs(path) do
			if change.path[i] == pathKey then
				matchRate += 1
			end
		end
		if matchRate >= 1 then
			return true
		end
	end
	return false
end

local absoluteMatch = function(path, changes)
	for _, change in pairs(changes) do
		local matchRate = 0
		-- ancestry changed
		for i, pathKey in pairs(path) do
			if change.path[i] == pathKey then
				matchRate += 1
			end
		end
		if matchRate == #path then
			return true
		end
	end
	return false
end

if RunService:IsServer() then
	local dataHandler = require(ReplicatedStorage.shared.dataHandler)
	local ProfileService = require(ReplicatedStorage.Packages.ProfileService)

	local TEMPLATE = {
		coins = 0,
		shards = 0,
		xp = 0,
		level = 0,
		rebirth = 0,
		ascension = 1,
		currentWorld = 1,
		lastDailyGift = 0,
		dailyGiftStreak = 0,

		quest = {
			name = nil,
			progress = 0,
		},
		equipped = {
			weapon = 1,
			hero = {},
		},
		unlockedWorlds = {
			1
		},
		upgrades = {
			[1] = {
				[1] = 0,
				[2] = 0,
				[3] = 0,
				[4] = 0,
				[5] = 0,
			},
		},
		inventory = {
			weapon = {
				{
					index = 1,
					id = 27,
					level = 0,
				},
			},
			hero = {

			}
		},
		gifts = {},
		stats = {
			obtainedItemIndex = {
				weapon = {
					27,
				},
			},
			itemsObtained = {
				weapon = 1,
				hero = 0,
			},
			xpCollected = 0,
			coinsCollected = 0,
		},
		settings = {
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = true,
			[5] = true,
			[6] = true
		}
	}

	local playerDataCache = {}
	local isDatastoreActive = false
	local datastore

	local loadPlayerData = function(player, store)
		local data = dataHandler.new("PLAYER/" .. player.UserId, store)

		data.profile:AddUserId(player.UserId)
		data.profile:Reconcile()

		if data == nil then
			return player:Kick("DATASTORE ERROR")
		end
		if player:IsDescendantOf(Players) then
			playerDataCache[player] = data
		end

		data._maid:Add(player.AncestryChanged:Connect(function()
			if not player:IsDescendantOf(Players) then
				data:Destroy()
				playerDataCache[player] = nil
			end
		end))
		data._maid:Add(data.changed:Connect(function(changes)
			bridges.datastoreDataChanged:FireTo(player, changes)
		end))

		return data.data
	end

	-- >> TYPE
	local TYPE = function()
		local public = {}

		public.profile = ProfileService.GetProfileStore():LoadProfileAsync()
		public.data = TEMPLATE
		public.changed = Signal.new()

		function public:apply(f: (typeof(public)) -> ()) end
		function public:connect(key: {string}, f: (changes: {new: any, old: any?}) -> ()) end

		return public
	end

	bridges.datastoreOnline:OnInvoke(function()
		return isDatastoreActive
	end)

	bridges.datastoreRetrieve:OnInvoke(function(player)
		assert(isDatastoreActive, "[datastore] Datastore is not online")
		return loadPlayerData(player, datastore)
	end)

	Promise.try(function()
		local _datastore = ProfileService.GetProfileStore("DEVELOPMENT_TEST_STORE_18_6", TEMPLATE)
		local isValid = t.table(_datastore)

		assert(isValid, "Datastore failed to load")

		return _datastore
	end)
		:andThen(function(store)
			datastore = store
			bridges.datastoreOnline:FireAll()
			isDatastoreActive = true
		end)
		:catch(function(...)
			debugger.warn(...)
			bridges.datastoreFailure:Fire(...)
			isDatastoreActive = false
		end)

	return {
		getPlayer = function(player): typeof(TYPE())
			if player:IsDescendantOf(Players) then
				if not playerDataCache[player] then
					repeat task.wait()
					until playerDataCache[player] or not player:IsDescendantOf(Players)
				end
				return playerDataCache[player]
			end
			return nil
		end,
	}
else
	local loaded = false
	local data

	local connectedFunctions = {}

	local changed = function(changes)
		local snapchot = deepCopy(data)

		for _, change in pairs(changes) do
			local pathUpper1 = #change.path == 1 and {} or TableUtil.Array.Cut1D(change.path, 1, #change.path - 1)
			fromPath(data, pathUpper1)[change.key] = change.new
		end

		for pathTable, connectedFunction in pairs(connectedFunctions) do
			if absoluteMatch(pathTable, changes) then
				Promise.try(connectedFunction, {
					new = fromPath(data, pathTable),
					old = fromPath(snapchot, pathTable),
				})
			end
		end
	end

	local initialize = function(_data)
		if loaded then
			return
		end

		data = _data
		loaded = true

		for pathTable, connectedFunction in pairs(connectedFunctions) do
			Promise.try(connectedFunction, {
				new = fromPath(data, pathTable),
			})
		end

		bridges.datastoreDataChanged:Connect(changed)

		return
	end

	if bridges.datastoreOnline:InvokeServerAsync() then
		initialize(bridges.datastoreRetrieve:InvokeServerAsync())
	else
		bridges.datastoreOnline:Connect(function()
			initialize(bridges.datastoreRetrieve:InvokeServerAsync())
		end)
	end

	return {
		connect = function(self, path: { string }, f: (changes: { new: any, old: any }) -> ())
			connectedFunctions[path] = f
			task.spawn(f, {
				new = fromPath(data, path),
			})
		end,
		findChanges = function<tble>(self, changes: { new: tble, old: tble | any }, returnAnyWhenNone: boolean?): tble
			local classOfNew = typeof(changes.new)
			local classOfOld = typeof(changes.old)
			if classOfNew == classOfOld then
				if classOfNew == "number" then
					return changes.new - changes.old
				elseif classOfNew == "table" then
					local changesTable = { added = {}, removed = {} }
					for key, value in pairs(changes.new) do
						if not changes.old[key] then
							changesTable.added[key] = value
						end
					end
					for key, value in pairs(changes.old) do
                        
						if not changes.new[key] then
							changesTable.removed[key] = value
						end
					end
					return changesTable
				else
					return { added = changes.new, removed = {} }
				end
			else
				if classOfNew == "nil" or classOfOld == "nil" then
					return if returnAnyWhenNone then { added = changes.new, removed = {} } else nil
				end
				return { added = changes.new, removed = {} }
			end
		end,
		getPlayer = function()
			return {
				data = data,
			}
		end,
	}
end
