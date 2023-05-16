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

		local playerName, number = unpack(arguments)

		local player = Players:FindFirstChild(playerName)
		debugger.assert(player, "player not found")

		local playerData = playerDataHandler.getPlayer(player)
		debugger.assert(player, "player data not found")

		debugger.assert(tonumber(number), "number expected for amount")

        playerData:apply(function(f)
			f.data.coins += number
            f.data.stats.coinsCollected += number
		end)
	end,
}
