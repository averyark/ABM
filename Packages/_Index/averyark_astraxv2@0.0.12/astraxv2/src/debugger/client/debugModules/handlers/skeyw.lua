local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)
		if arguments[1] then
			debugger.silence(arguments[1])
			debugger.log("Keyword \"" .. arguments[1] .. "\" silenced")
		else
			error("Invalid arguments[1]")
		end
	end,
}
