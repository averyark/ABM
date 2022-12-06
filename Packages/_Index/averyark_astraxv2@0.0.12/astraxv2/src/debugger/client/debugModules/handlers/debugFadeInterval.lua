local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)
		--[[local module = require(index.module)
		local objects = require(index.objects)
		
		local BridgeNet = require(index.packages.BridgeNet)
		local Janitor = require(index.packages.Janitor)
		local Promise = require(index.packages.Promise)
		local Signal = require(index.packages.Signal)
		local TestEZ = require(index.packages.TestEZ)]]
		local t = require(index.packages.t)

		local TableUtil = require(index.packages.TableUtil)

		local inteval = tonumber(arguments[1])
		if t.number(inteval) then
			index.debugSettings.intervalFadeOutputMessage = inteval
			require(index.debugger).waitIntervalAndClear(inteval)
		else
			error("Invalid arguments[1]")
		end
	end,
}
