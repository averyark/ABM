local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)

		if arguments[1] == "true" then
			Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").Enabled = false
		elseif arguments[1] == "false" then
			Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").Enabled = true
		else
			error("Invalid arguments[1]")
		end
	end,
}
