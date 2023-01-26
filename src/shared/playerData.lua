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
    datastoreDataChanged = BridgeNet.CreateBridge("datastoreDataChanged")
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

if RunService:IsServer() then
    local dataHandler = require(ReplicatedStorage.shared.dataHandler)
    local ProfileService = require(ReplicatedStorage.Packages.ProfileService)
    
    local TEMPLATE = {
        coins = 0,
        shards = 0,
        equipped = {
            weapon = 8
        },
        inventory = {
            weapon = {
                8,
            }
        },
        stats = {
            obtainedItemIndex = {
                weapon = {
                    8,
                }
            },
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
    
        function public:apply(f: (typeof(public)) -> ())
        end
    
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
        local _datastore = ProfileService.GetProfileStore("DEVELOPMENT_TEST_STORE_9", TEMPLATE)
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
        getPlayer = function(player) : typeof(TYPE())
            return playerDataCache[player]
        end,
    }
else
    local loaded = false
    local data
    
    local connectedFunctions = {}

    local changed = function(changes)
        local snapchot = deepCopy(data)
    
        for _, change in pairs(changes) do
            local pathUpper1 = #change.path == 1 and {} or TableUtil.Array.Cut1D(change.path, 1, #change.path-1)
            fromPath(data, pathUpper1)[change.key] = change.new
        end
    
        for pathTable, connectedFunction in pairs(connectedFunctions) do
            if match(pathTable, changes) then
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
        connect = function(self, path: {string}, f: (changes: {new: any, old: any}) -> ())
            connectedFunctions[path] = f
            task.spawn(f, {
                new = fromPath(data, path)
            })
        end,
        findChanges = function<tble>(self, changes: {new: tble, old: tble | any}): tble
            local classOfNew = typeof(changes.new)
            local classOfOld = typeof(changes.old)
            if classOfNew == classOfOld then
                if classOfNew == "number" then
                    return changes.new - changes.old
                elseif classOfNew == "table" then
                    local changesTable = {}
                    for key, value in pairs(changes.new) do
                        if not changes.old[key] then
                            changesTable[key] = value
                        end
                    end
                    return changesTable
                else
                    return changes.new
                end
            else
                return changes.new
            end
        end,
        getPlayer = function()
            return {
                data = data
            }
        end
    }
end
