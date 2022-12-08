local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)

		local id = tonumber(arguments[1])

		if id then
			require(ServerScriptService.server.entities.entity).new(id)
		else
			error("Invalid arguments[1]")
		end
	end,
}
