--!strict
--[[
    FileName    > debug.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 29/11/2022
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

local index = require(script.Parent.Parent.index)
local debugger = require(index.debugger)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)

local objectDebugger = { _cache = {} }

local totalObjects = 0

local inheritDebugMethods = {}

function inheritDebugMethods:debug(...: string)
	debugger.log("OBJECT DEBUG", "[" .. tostring(self) .. "]:", ...)
end

function inheritDebugMethods:debugwarn(...: string)
	debugger.warn("OBJECT WARN", "[" .. tostring(self) .. "]:", ..., debug.traceback("\n", 2))
end

function inheritDebugMethods:assert(condition: boolean, err: string?)
	debugger.assert(
		condition,
		"OBJECT ERROR" .. " [" .. tostring(self) .. "]:" .. (err or "") .. debug.traceback("\n", 2)
	)
end

function inheritDebugMethods:__getRawTable()
	local raw = {}
	for k, v in pairs(self) do
		raw[k] = v
	end
	return raw
end

objectDebugger.new = function(_table)
	--[[
        ref = refernece
        rep = replacement
        call = on call
        new = new
    --]]

	t.strict(t.table)(_table)

	local metatable = getmetatable(_table)

	totalObjects += 1

	objectDebugger._cache[metatable] = {
		metaId = 0,
		objectId = totalObjects,
	}

	local ids = objectDebugger._cache[metatable]

	-- Referencing varaibles to prevent them from getting gced
	local ref_typecheckMethods = _table.methods or {}
	local ref_typecheck = _table.types
	local ref_index = _table._meta.__index
	local ref_newindex = _table._meta.__newindex

	-- __index value are typically functions/tables
	local new_index = function(self, key)
		-- Inheritance
		if inheritDebugMethods[key] then
			return inheritDebugMethods[key]
		end

		-- Check cache registry
		if rawget(self, "_meta").newindexCache[key] then -- safe
			return self._meta.newindexCache[key]
		end

		if rawget(self, "_meta").inherit[key] then -- safe
			return self._meta.inherit[key]
		end

		-- Logging
		-- TODO: work with function pass __DEBUG__ENABLED as the index
		if
			rawget(self, "__DEBUG__ENABLED") or (type(ref_index) == "table" and rawget(ref_index, "__DEBUG__ENABLED"))
		then
			self:debug(("fromIndex: %s"):format(tostring(key)))
		end

		-- Perform the appropiate procedure depending on types
		if type(ref_index) == "function" then
			return ref_index(key)
		elseif type(ref_index) == "table" then
			if type(ref_index[key]) == "function" then
				-- returns a wrapper funciton
				-- Sanitize passed parameters according to definitions provided in the :as() method (if present).
				-- Only works if the __index value is a table type
				return function(...)
					if ref_typecheckMethods[key] then
						assert(ref_typecheckMethods[key](...))
					end
					return ref_index[key](...)
				end
			end
			return ref_index[key]
		end

		return ref_index
	end

	-- Perform the appropiate procedure depending on types
	-- __newindex value are typically functions/tables, or nil
	local new_newindex = function(self, key, value)
		if index.debugSettings.debugEnabled then
			for _, meta in pairs(self._debugFunctions) do
				meta:__metatableUpdated(key, value)
			end
		end
		if
			(type(ref_newindex) == "table" or type(ref_newindex) == "nil")
			and self._meta.newindexCache[key] == value
		then
			return
		end

		if self.__DEBUG__ENABLED then
			self:debug(("Overwrite: %s: %s"):format(tostring(key), tostring(value)))
		end
		if ref_typecheck[key] then
			local success, result = ref_typecheck[key](value)
			if not success then
				self:debugwarn(result)
				return
			end
		end

		-- Sanitize property overwrites according to definition provided in the :as() method (if present).
		-- Only works if the __newindex value is a table type
		if type(ref_newindex) == "function" then
			return ref_newindex(self, key, value)
		elseif type(ref_newindex) == "table" or type(ref_newindex) == "nil" then
			self._meta.newindexCache[key] = value
		end
	end

	-- Assign the wrapper
	_table._meta.__index = new_index
	_table._meta.__newindex = new_newindex

	_table.created:Connect(function(newMeta)
		ids.metaId += 1
		newMeta._meta.id = ids.metaId
		if newMeta.__DEBUG__ENABLED then
			newMeta:debug("Created Object")
		end
	end)

	if not _table._meta.__tostring then
		_table._meta.__tostring = function(self)
			return ("<object:%s>(%s)"):format(ids.objectId, self._meta.id)
		end
	end

	return _table
end

return objectDebugger.new
