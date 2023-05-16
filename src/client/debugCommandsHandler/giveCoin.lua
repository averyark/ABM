local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local weapons = require(ReplicatedStorage.shared.weapons)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)
	end,
}
