local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	commandInvoked = function(arguments, index)
		local workspaceDebugManifest = require(index.workspaceDebugManifest)

		if arguments[1] == "true" then
			workspaceDebugManifest.enable()
		elseif arguments[1] == "false" then
			workspaceDebugManifest.disable()
		else
			error("Invalid arguments[1]")
		end
	end,
}
