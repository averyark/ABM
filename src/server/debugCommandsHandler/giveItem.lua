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

		local playerName, id, level = unpack(arguments)


		local player = Players:FindFirstChild(playerName)
		debugger.assert(player, "player not found")

		local playerData = playerDataHandler.getPlayer(player)
		debugger.assert(player, "player data not found")

		debugger.assert(tonumber(id), "number expected for id")
		debugger.assert(tonumber(level), "number expected for level")

		local foundData

		for _, dat in pairs(weapons) do
			if dat.id == tonumber(id) then
				foundData = dat
				break
			end
		end

		debugger.assert(foundData, "the id given does not correlate with any item in the database")

		playerData:apply(function(f)
			table.insert(f.data.stats.obtainedItemIndex.weapon, tonumber(id))
			f.data.stats.itemsObtained.weapon += 1
			table.insert(f.data.inventory.weapon, {
				index = f.data.stats.itemsObtained.weapon,
				id = tonumber(id),
				level = tonumber(level),
			})
		end)
	end,
}
