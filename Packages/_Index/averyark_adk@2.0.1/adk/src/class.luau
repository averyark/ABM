--!nocheck
--[[
    FileName    > objects.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 04/04/2023
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = script.Parent.Parent.Parent.Parent
local Signal = require(Packages.Signal)
local things = require(script.Parent.things)
local Janitor = require(Packages.Janitor)
local Red = require(Packages.Red)
local t = require(Packages.t)

local objects = {}
local methods = {}

function methods:log(...: any)
	print(`log <object: {self.class.identifier}>({self._id}): `, ...)
end

function methods:warn(...: any)
	warn(`warn <object: {self.class.identifier}>({self._id}): `, ...)
end

function methods:error(...: any)
	error(`error <object: {self.class.identifier}>({self._id}): `, ...)
end

function methods:assert(condition: boolean, errorMessage: string)
	assert(condition, `assert <object: {self.class.identifier}>({self._id}): {errorMessage}`)
end

local main = {}

local com = if RunService:IsServer() then Red.Server("__class") else nil

main.onObjectAdded = Signal.new()
main.onObjectDestroyed = Signal.new()

function deepCopy<T>(tableToClone: T & { [number]: any }, cache: {}): T | { [number]: any }?
	local result = {}

	cache = cache or {}

	for key, v in pairs(tableToClone) do
		if typeof(v) == "table" then
			if table.find(cache, v) then
				continue
			end -- anti recursive
			table.insert(cache, v)
			result[key] = deepCopy(v, cache)
		else
			result[key] = v
		end
	end

	return result
end

local getTypeString = function(value)
	local type = typeof(value)
	if type == "Instance" then
		local instanceClass = value.ClassName
		return instanceClass
	else
		return type
	end
end

function main.construct<T, M>(rawtable: T, meta: M): ({ _maid: typeof(Janitor.new()) } & T & M & { Destroy: () -> () })
	assert(t.table(rawtable))
	assert(t.table(meta))
	assert(t.string(meta.identifier))
	assert(t.integer(meta.max))
	assert(t.table(meta.tb))

	meta.max += 1

	local self = setmetatable({
		props = rawtable,
		methods = meta.tb,
		class = meta,

		_id = meta.max,
		_maid = Janitor.new(),
		_log = {},
		_debugModifiedFunctions = {},
		_isServerObject = RunService:IsServer() and true or false,

		__DEBUG = meta.tb.__DEBUG or false,
	}, {
		__index = function(self, index)
			if index == "Destroy" then
				return function(...)
					self._maid:Destroy()
					if things.settings.DebugEnabled then
						table.insert(self._log, {
							uptrace = debug.traceback("", 2):match("[%w%p ]+"),
							type = things.symbols.debugClassType.Destroy,
							timestamp = DateTime.now(),
						})
						--objects[self.class.identifier][self._id] = nil
						if self._debugModifiedFunctions then
							for _, debugCon in pairs(self._debugModifiedFunctions) do
								if debugCon.refCache then
									local i = table.find(debugCon.refCache, self)
									if i then
										table.remove(debugCon.refCache, i)
									end
								end
							end
						end
						local pos = table.find(objects, self)
						if pos then
							table.remove(objects, pos)
						end
						if things.settings.DebugEnabled and com then
							com:FireWithFilter(things.isPlayerWhitelisted, "serverObjectDestroyed", self)
						end
						main.onObjectDestroyed:Fire(self)
					end
					local destroyMethod = rawget(self, "methods")["Destroy"]
					if destroyMethod then
						destroyMethod(...)
					end
				end
			end

			local default = rawget(self, index)
			if default then
				if rawget(self, "__DEBUG") then
					--methods.log(self, `read: {index} <value: {default}>({getTypeString(default)})`)
					table.insert(self._log, {
						uptrace = debug.traceback("", 2):match("[%w%p ]+"),
						type = things.symbols.debugClassType.Read,
						timestamp = DateTime.now(),
						collection = { key = index, value = default },
					})
				end
				return default
			end

			local prop = rawget(self, "props")[index]
			if prop then
				if things.settings.DebugEnabled then
					--methods.log(self, `read: {index} <value: {prop}>({getTypeString(prop)})`)
					table.insert(self._log, {
						uptrace = debug.traceback("", 2):match("[%w%p ]+"),
						type = things.symbols.debugClassType.Read,
						timestamp = DateTime.now(),
						collection = { key = index, value = prop },
					})
				end
				return prop
			end

			local method = rawget(self, "methods")[index]
			if method then
				if things.settings.DebugEnabled then
					--methods.log(self, `read: {index} <value: {method}>({getTypeString(method)})`)
					table.insert(self._log, {
						uptrace = debug.traceback("", 2):match("[%w%p ]+"),
						type = things.symbols.debugClassType.Read,
						timestamp = DateTime.now(),
						collection = { key = index, value = method },
					})
				end
				return method
			end

			local mainMethod = methods[index]
			if mainMethod then
				if things.settings.DebugEnabled then
					--methods.log(self, `read: {index} <value: {mainMethod}>({getTypeString(mainMethod)})`)
					table.insert(self._log, {
						uptrace = debug.traceback("", 2):match("[%w%p ]+"),
						type = things.symbols.debugClassType.Read,
						timestamp = DateTime.now(),
						collection = { key = index, value = mainMethod },
					})
				end
				return mainMethod
			end

			return
		end,
		__newindex = function(self, key, new)
			local old = self.props[key]

			self.props[key] = new

			if things.settings.DebugEnabled then
				local debugModifiedFunctions = rawget(self, "_debugModifiedFunctions")
				if debugModifiedFunctions then
					for _, debugCon in pairs(debugModifiedFunctions) do
						debugCon:__metatableUpdated(key, new)
					end
				end
				if self.props[key] then
					table.insert(self._log, {
						uptrace = debug.traceback("", 2):match("[%w%p ]+"),
						type = things.symbols.debugClassType.Modified,
						timestamp = DateTime.now(),
						collection = {
							key = key,
							value = { new = new, old = old },
						},
					})
				else
					table.insert(self._log, {
						uptrace = debug.traceback("", 2):match("[%w%p ]+"),
						type = things.symbols.debugClassType.Append,
						timestamp = DateTime.now(),
						collection = {
							key = key,
							value = new,
						},
					})
				end
			end
		end,
	})

	local __init__ = self.__init__

	if __init__ then
		table.insert(self._log, {
			type = things.symbols.debugClassType.Initialize,
			timestamp = DateTime.now(),
		})
		__init__(self)
	end

	if things.settings.DebugEnabled and com then
		local cache = {}

		local tb = deepCopy(self)

		com:FireWithFilter(things.isPlayerWhitelisted, "serverObjectCreated", tb)
	end
	main.onObjectAdded:Fire(self)

	table.insert(objects, self)

	return self
end

function main.new<T>(identifier: string, tb: T): T
	return {
		identifier = identifier,
		max = 0,
		tb = tb,
	}
end

main.objects = objects

if com then
	com:On("serverObjectCreated", function() end)
	com:On("serverObjectDestroyed", function() end)

	com:On("getServerObjects", function(player: Player)
		if not things.settings.DebugEnabled then
			return {}
		end
		if things.isPlayerWhitelisted(player) then
			return objects
		end
		return {}
	end)
	com:On("getServerObject", function(player: Player, identifier: string, _id: number)
		if things.isPlayerWhitelisted(player) then
			for _, object in pairs(objects) do
				if object.identifier == identifier and object._id == _id then
					return object
				end
			end
		end
		return
	end)
end

return main
