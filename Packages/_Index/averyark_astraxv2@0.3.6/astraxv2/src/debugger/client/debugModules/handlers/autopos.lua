local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)

		if arguments[1] == "true" then
			index.debugSettings.autoPositionCanvas = true
		elseif arguments[1] == "false" then
			index.debugSettings.autoPositionCanvas = false
		else
			error("Invalid arguments[1]")
		end
	end,
}
