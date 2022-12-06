--!strict
--[[
    FileName    > init.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 26/11/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

local index = require(script.Parent.index)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

local object = {}
local inherit = {}

local objectDebugger = require(index.objects.debug)

function object:_check(metatable: { [any]: any })
	-- check for valid interface type, error otherwise
	assert(t.interface(self.types)(metatable._meta.newindexCache))
	return self
end

function object:new(tab: { [any]: any })
	local newself = setmetatable(
		{ _maid = Janitor.new(), _meta = { inherit = inherit, newindexCache = tab } },
		self._meta
	)
	self.created:Fire(newself)
	self:_check(newself)

	return newself
end

object.__index = object

local new = function(meta, types: { [any]: typeof(t.callback) }, methods: { [any]: typeof(t.callback) })
	local _object = setmetatable({
		created = Signal.new(),
		types = types,
		methods = methods,
		_meta = meta,
	}, object)
	t.strict(t.map(t.any, t.callback)(types))
	objectDebugger(_object)
	return _object
end

return {
	new = new,
}
