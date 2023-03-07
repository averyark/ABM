--!strict
--[[
    FileName    > init.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local index = require(script.Parent.index)
local debugger = require(index.debugger)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

local module = {}

module.__index = module

local moduleLoadFailHandler = function(err, identifier, desc)
	debugger.warn(
		"LOADER WARN",
		"[<module:" .. tostring(identifier) .. ">]:",
		desc .. ":\n",
		err.trace -- .. "\n\n" .. err.context
	)
end

local new = function<t>(table: t): t
	table._moduleMeta = setmetatable({}, module)

	return table
end

local loadDescendants = function(ancestry: Instance)
	local promises = {}
	local modules = {}

	for _, object in pairs(ancestry:GetDescendants()) do
		if t.instanceIsA("ModuleScript") then
			table.insert(
				promises,
				Promise.new(function(resolve, reject)
					modules[object] = require(object)
					resolve()
				end)
			)
		end
	end

	Promise.all(promises):awaitStatus()
	table.clear(promises)

	local isServer = RunService:IsServer()

	for object, moduleData in pairs(modules) do
		if moduleData.preload then
			local begin = os.clock()
			table.insert(
				promises,
				Promise.try(moduleData.preload)
					:catch(function(err)
						moduleLoadFailHandler(err, object.Name, "<handleFailure> Error caught in preload")
					end)
					:andThen(function()
						debugger.log(
							("MODULE LOAD [<%s>(%s)]: Successful preload (%.2fµs)"):format(
								object.Name,
								isServer and "server" or "client",
								(os.clock() - begin) * 10e5
							)
						)
					end)
			)
		end
	end

	Promise.all(promises):awaitStatus()
	table.clear(promises)

	for object, moduleData in pairs(modules) do
		if moduleData.load then
			local begin = os.clock()
			table.insert(
				promises,
				Promise.try(moduleData.load)
					:catch(function(err)
						moduleLoadFailHandler(err, object.Name, "<handleFailure> Error caught in load")
					end)
					:andThen(function()
						debugger.log(
							("MODULE LOAD [<%s>(%s)]: Successful initialization (%.2fµs)"):format(
								object.Name,
								isServer and "server" or "client",
								(os.clock() - begin) * 10e5
							)
						)
					end)
			)
		end
	end

	return
end

local loadChildren = function() end

return {
	new = new,
	loadDescendants = loadDescendants,
	loadChildren = loadChildren,
}
