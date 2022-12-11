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
		local t = require(index.packages.t)
		local TestEZ = require(index.packages.TestEZ)
		local TableUtil = require(index.packages.TableUtil)
		]]

		if arguments[1] == "true" then
			index.debugSettings.debugEnabled = true
		elseif arguments[1] == "false" then
			index.debugSettings.debugEnabled = false
			debugger.clearMessages()
		else
			error("Invalid arguments[1]")
		end
	end,
}
