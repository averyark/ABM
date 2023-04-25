local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	commandInvoked = function(arguments, index)
		local workspaceDebugManifest = require(index.workspaceDebugManifest)

		if tonumber(arguments[1]) then
			workspaceDebugManifest.setTransparency(tonumber(arguments[1]))
		else
			error("Invalid arguments[1]")
		end
	end,
}
