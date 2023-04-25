local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local frameworkFolder = script.Parent

local index = {
	["packages"] = script.Parent.Parent,
	["objects"] = frameworkFolder.objects,
	["module"] = frameworkFolder.module,
	["debugger"] = frameworkFolder.debugger,
	["workspaceDebugManifest"] = frameworkFolder.debugger.workspaceDebugManifest,

	["builtinDebugModulesClient"] = frameworkFolder.debugger.client.debugModules,
	["builtinDebugModulesServer"] = frameworkFolder.debugger.server.debugModules,

	["debugSettings"] = {
		enabledInLiveServers = false,
		enableForWhitelistedOnly = true,
		autoPositionCanvas = true,
		intervalFadeOutputMessage = 21,
		fadeOutputMessage = false,
		debugEnabled = true,
		serverDebugEnabled = true,
		debugConsoleEnabled = true,
		debugCommandsHandlerFolder = nil,
		whitelisted = {
			{ type = "userid", value = 540209459 },
		},
	},

	version = "0.3.6"
}

index.setDebugSettings = function(settings)
	for key, value in pairs(settings) do
		index.debugSettings[key] = value
	end
end

index.start = function()
	if not index.debugSettings.enabledInLiveServers and not RunService:IsStudio() then
		index.debugSettings.debugEnabled = false
		index.debugSettings.serverDebugEnabled = false
	end
	require(frameworkFolder.objects)
	require(frameworkFolder.module)
	require(frameworkFolder.debugger)
end

return index
