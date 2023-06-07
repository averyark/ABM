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

local Packages = script.Parent.Parent.Parent
local Janitor = require(Packages.Janitor)
local Promise = require(Packages.Promise)
local Signal = require(Packages.Signal)
local t = require(Packages.t)
local TableUtil = require(Packages.TableUtil)
local ProfileService = require(Packages.ProfileService)
local Red = require(Packages.Red)
local class = require(script.Parent.Parent.class)

local helper = require(script.Parent.helper)

local absoluteMatch = helper.absoluteMatch
local match = helper.match
local fromPath = helper.fromPath
local deepCopy = helper.deepCopy
local checkIfExist = helper.checkIfExist
local compare = helper.compare

local methods = {}
methods.__index = methods

function methods.apply(self: dataClass, f)
	local snapchot = deepCopy(self.data)

	Promise.try(f, self.data)
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
		:catch(warn)
end

function methods.Destroy(self: dataClass)
	self.profile:Release()
end

function methods.connect(self: dataClass, path, f: (changes: { new: any, old: any? }) -> ())
	assert(t.table(path))
	assert(t.callback(f))
	self.connectedFunctions[path] = f
	f({
		new = fromPath(self.data, path),
	})
end

local dataClass = class.new("dataClass", methods)

local function new(key: string, datastore)
	local profile =
		datastore:LoadProfileAsync(key) :: typeof(ProfileService.GetProfileStore("", {}):LoadProfileAsync(""))

	local metatable = {
		profile = profile,
		data = profile.Data,
		key = key,

		changed = Signal.new(),
		connectedFunctions = {},
	}

	local object = class.construct(metatable, dataClass)

	return object --:: typeof(object) & typeof(metatable) & typeof(class)
end

type dataClass = typeof(new(""))

return {
	new = new,
}
