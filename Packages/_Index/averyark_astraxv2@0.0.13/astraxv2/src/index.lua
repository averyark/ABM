local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

local frameworkFolder = script.Parent

return {
	["packages"] = script.Parent.Parent,
	["objects"] = frameworkFolder.objects,
	["module"] = frameworkFolder.module,
	["debugger"] = frameworkFolder.debugger,

	["builtinDebugModulesClient"] = frameworkFolder.debugger.client.debugModules,
	["builtinDebugModulesServer"] = frameworkFolder.debugger.server.debugModules,

	["debugSettings"] = {
		intervalFadeOutputMessage = 21,
		fadeOutputMessage = false,
		debugEnabled = true,
		serverDebugEnabled = true,
		debugConsoleEnabled = true,
		debugCommandsHandlerFolder = nil,
	},
	start = function()
		require(frameworkFolder.objects)
		require(frameworkFolder.module)
		require(frameworkFolder.debugger)
	end,
}
