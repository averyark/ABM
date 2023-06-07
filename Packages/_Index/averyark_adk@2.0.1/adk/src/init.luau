--[[
    FileName    > init.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/04/2023
--]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Packages = script.Parent
local Promise = require(Packages.Promise)
local things = require(script.things)

local astrax = {
	class = require(script.class),
	tween = require(script.tween),
	number = require(script.number),

	dataServer = if RunService:IsServer() then require(script.data.server) else nil,
	dataClient = if RunService:IsClient() then require(script.data.client) else nil,

	module = require(script.module),

	notify = if RunService:IsClient() then require(script.debugger.modules.notify) else nil,

	symbols = require(script.symbols),
}

astrax.start = function()
	if RunService:IsClient() then
		return Promise.new(function(resolve)
			things.start()

			local parameterVisualPanel = require(script.debugger.modules.parameterVisualPanel)
			local objectListPanel = require(script.debugger.modules.objectListPanel)
			local objectVisualPanel = require(script.debugger.modules.objectVisualPanel)

			astrax.notify.start()
			astrax.dataClient.start()
			objectListPanel.start()
			astrax.module.start()
			resolve()
		end)
	elseif RunService:IsServer() then
		return Promise.new(function(resolve)
			things.start()

			local Red = require(Packages.Red)

			Red.Server("__class")

			astrax.dataServer.start()
			astrax.module.start()
			resolve()
		end)
	end
	return
end

return astrax
