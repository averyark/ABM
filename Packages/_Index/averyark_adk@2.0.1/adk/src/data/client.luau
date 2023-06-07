--[[
    FileName    > client.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/05/2023
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Packages = script.Parent.Parent.Parent
local TableUtil = require(Packages.TableUtil)
local Promise = require(Packages.Promise)
local t = require(Packages.t)
local Red = require(Packages.Red)
local Signal = require(Packages.Signal)
local things = require(script.Parent.Parent.things)
local notify = require(script.Parent.Parent.debugger.modules.notify)

local helper = require(script.Parent.helper)
local absoluteMatch = helper.absoluteMatch
local match = helper.match
local fromPath = helper.fromPath
local deepCopy = helper.deepCopy
local checkIfExist = helper.checkIfExist
local compare = helper.compare

local net

local client = {}
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
	if data then
		return
	end

	data = _data

	for pathTable, connectedFunction in pairs(connectedFunctions) do
		Promise.try(connectedFunction, {
			new = fromPath(data, pathTable),
		})
	end

	net:On("dataChanged", changed)
	return
end

client.start = function()
	net = Red.Client("__data")

	local retrieveDataFromServer = function()
		if data then
			return
		end
		net:Call("updateData")
	end

	net:Call("datastoreOnline"):Then(function(status)
		if status == true then
			retrieveDataFromServer()
		end
	end)

	net:On("datastoreOffline", function(err)
		warn("DATASTORE IS OFFLINE", err.error)
		notify.new(things.symbols.notificationType.Warning, "Critical DataStore Incident", err.error)
	end)
	net:On("dataUpdated", initialize)
	net:On("datastoreOnline", retrieveDataFromServer)
end

client.connect = function(_, path: { string }, f: (changes: { new: any, old: any }) -> ())
	connectedFunctions[path] = f

	if data then
		Promise.try(f, {
			new = fromPath(data, path),
		})
	end
end

return client
