local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local index = require(script.Parent.Parent.index)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

local consoleServerHandler = {}
local whitelisted = { 540209459 }

function consoleServerHandler:load(debugger)
	local exeuteCommand = BridgeNet.CreateBridge("__debug_console_executeCommnad")
	local builtInHandlers = index.builtinDebugModulesServer.handlers

	exeuteCommand:OnInvoke(function(player, rawArguments)
		local isWhitelisted = false
		for _, data in pairs(index.debugSettings.whitelisted) do
			if data.type == "userid" and player.UserId == data.value then
				isWhitelisted = true
				break
			end
		end
		assert(isWhitelisted, "[<debugger>(console:server)]: Denied request; Permission insufficient.")

		local customHandlers = index.debugSettings.debugCommandsHandlerFolder
		local commandName = tostring(rawArguments[1])

		local handler = builtInHandlers:FindFirstChild(commandName)
			or (customHandlers and customHandlers:FindFirstChild(commandName))

		--[[assert(
			handler,
			"[<debugger>(console:server)]: Missing command handler for " .. commandName .. " (Missing command)"
		)]]
		if not handler then
			return
		end

		local arguments = #rawArguments >= 2 and TableUtil.Array.Cut1D(rawArguments, 2, #rawArguments) or {}
		local commandModule = require(handler)

		debugger.log(
			commandModule.commandInvoked(arguments, index)
				or "[<debugger>(console:server)]: Command execution successful"
		)

		return true
	end)
end

return consoleServerHandler
