--!strict
--[[
    FileName    > dataHandler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/01/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

if RunService:IsClient() then
	return error("CANNOT BE CALLED ON THE CLIENT")
end

local BridgeNet = require(ReplicatedStorage.Packages.BridgeNet)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Matter = require(ReplicatedStorage.Packages.Matter)
local Astrax = require(ReplicatedStorage.Packages.Astrax)
local ProfileService = require(ReplicatedStorage.Packages.ProfileService)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)

local dataClass = {}
dataClass.__index = dataClass

local checkIfExist = function(path, changes)
	local total = #path
	for _, change in pairs(changes) do
		local matchRate = 0
		for i, pathKey in pairs(path) do
			if change.path[i] == pathKey then
				matchRate += 1
			end
		end
		if matchRate == total then
			return true
		end
	end
	return false
end

local compare = function(
	tb1, -- new
	tb2 -- old
)
	local changes = {}

	local checkAndAddChange
	checkAndAddChange = function(tbr1, -- new
		tbr2, -- old
		previousPath, flip)
		-- input key, value1 and value2
		local add = function(k, v1, v2)
			local path = table.clone(previousPath)

			table.insert(path, k)

			if checkIfExist(path, changes) then
				return
			end

			table.insert(changes, {
				old = if flip then v1 else v2,
				new = if flip then v2 else v1,
				key = k,
				path = path,
				supertable = tb1,
			})
		end

		for key, value in pairs(tbr1) do
			if typeof(value) == "table" then
				local path = table.clone(previousPath)
				table.insert(path, key)

				if typeof(tbr2[key]) == "table" then
					checkAndAddChange(value, tbr2[key], path, flip)
				else
					add(key, value, tbr2[key])
				end
			elseif value ~= tbr2[key] then
				add(key, value, tbr2[key])
			end
		end

		return changes, #changes
	end

	checkAndAddChange(tb1, tb2, {})
	checkAndAddChange(tb2, tb1, {}, true)

	return changes, #changes
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

function dataClass:apply(f)
	local snapchot = deepCopy(self.data)

	Promise.try(f, self)
		:andThen(function()
			local changes = compare(self.data, snapchot)

			self.changed:Fire(changes)

			for pathTable, connectedFunction in pairs(self.connectedFunctions) do
				if match(pathTable, changes) then
					Promise.try(connectedFunction, {
						new = fromPath(self.data, pathTable),
						old = fromPath(snapchot, pathTable),
					})
				end
			end
		end)
		:catch(debugger.warn)
end

function dataClass:Destroy()
	self.profile:Release()
end

function dataClass:connect(path, f: (changes: { new: any, old: any? }) -> ())
	debugger.assert(t.table(path))
	debugger.assert(t.callback(f))
	self.connectedFunctions[path] = f
	f({
		new = fromPath(self.data, path)
	})
end

local dataObject = objects.new(dataClass, {})

local new = function(key: string, datastore)
	local profile = datastore:LoadProfileAsync(key) :: typeof(ProfileService:GetProfileStore():LoadProfileAsync())

	if profile == nil then
		return
	end

	return dataObject:new({
		profile = profile,
		data = profile.Data,
		key = key,

		changed = Signal.new(),
		connectedFunctions = {},
	})
end

return {
	load = function() end,
	new = new,
}
