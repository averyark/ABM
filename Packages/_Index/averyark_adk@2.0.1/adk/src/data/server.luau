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

local Packages = script.Parent.Parent.Parent
local helper = require(script.Parent.helper)
local TableUtil = require(Packages.TableUtil)
local Promise = require(Packages.Promise)
local t = require(Packages.t)
local Red = require(Packages.Red)
local ProfileService = require(Packages.ProfileService)
local Signal = require(Packages.Signal)
local dataHandler = require(script.Parent.dataHandler)
local things = require(script.Parent.Parent.things)

local net = Red.Server("__data")

local server = {}

local playerDataCache = {}
local isDatastoreActive = false
local datastoreError
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
		net:Fire(player, "dataChanged", changes)
	end))

	return data.data
end

-- >> TYPE
local TYPE = function()
	local public = {}

	local astraxSettings = require(ReplicatedStorage.astraxSettings)

	public.profile = ProfileService.GetProfileStore():LoadProfileAsync()
	public.data = astraxSettings.DataTemplate
	public.changed = Signal.new()

	function public:apply(f: (typeof(astraxSettings.DataTemplate)) -> ()) end
	function public:connect(key: { string }, f: (changes: { new: any, old: any? }) -> ()) end

	return public
end

server.waitForDataStore = function()
	if isDatastoreActive then
		return
	end
	repeat
		task.wait()
	until isDatastoreActive
	return
end

server.start = function()
	net:On("dataChanged", function() end)
	net:On("datastoreOffline", function() end)
	net:On("dataUpdated", function() end)
	net:On("datastoreOnline", function(player)
		if datastoreError then
			net:Fire(player, "datastoreOffline", datastoreError)
		end
		return isDatastoreActive
	end)

	net:On("updateData", function(player)
		server.waitForDataStore()

		local data = loadPlayerData(player, datastore)

		net:Fire(player, "dataUpdated", data)
	end)

	Promise.try(function()
		local _datastore = ProfileService.GetProfileStore(things.settings.DataScope, things.settings.DataTemplate)
		local isValid = t.table(_datastore)

		assert(isValid, "Datastore failed to load")

		local profile = ProfileService.GetProfileStore(things.settings.DataScope, things.settings.DataTemplate)

		return _datastore
	end)
		:andThen(function(store)
			datastore = store
			net:FireAll("datastoreOnline")
			isDatastoreActive = true
		end)
		:catch(function(err)
			warn(err.error)
			net:FireAll("datastoreOffline", err)
			isDatastoreActive = false
			datastoreError = err
		end)
end

server.getPlayer = function(player): typeof(TYPE())?
	if player:IsDescendantOf(Players) then
		if not playerDataCache[player] then
			repeat
				task.wait()
			until playerDataCache[player] or not player:IsDescendantOf(Players)
		end
		return playerDataCache[player]
	end
	return nil
end

return server
