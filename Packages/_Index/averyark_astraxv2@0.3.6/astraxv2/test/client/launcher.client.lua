local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(astrax.module)
local objects = require(astrax.objects)
local debugger = require(astrax.debugger)
local workspaceDebugManifest = require(astrax.workspaceDebugManifest)

astrax.debugSettings.debugCommandsHandlerFolder = script.Parent.debugCommandsHandler
astrax.start()

module.loadDescendants(script.Parent)

local class = {}
class.__index = {}

function class:foo() end

local constructor = objects.new(class, {})

local new = function(player)
	local aTable = {}
	aTable.aTable = aTable
	aTable.intergerValue = 1
	return constructor:new({
		player = player,
		someValue = 10,
		data = {
			recursiveTable = aTable,
			intergerValue = 1,
			stringValue = "averyark is a great developer!",
			table = {
				intergerValue = 1,
				floatValue = 10.5,
				stringValue = "averyark is a great developer!",
			},
			vector3Value = Vector3.new(1, 0.5, 2.5),
		},
	})
end

local regChar = function(character, player, object)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local workspaceDebug = workspaceDebugManifest.new(rootPart)
	workspaceDebug:linkProperty(humanoid, "Health")
	workspaceDebug:linkProperty(rootPart, "Position")
	workspaceDebug:linkProperty(rootPart, "AssemblyLinearVelocity")
	workspaceDebug:linkVariable("cost", 1000)
	task.spawn(function()
		while true do
			task.wait(1)
			workspaceDebug:changeValue("cost", math.random(1, 9) ^ math.random(4, 9))
		end
	end)
	workspaceDebug:linkMetatable(object)
end

local regPlayer = function(player)
	local object = new(player)
	player.CharacterAdded:Connect(function(character)
		regChar(character, player, object)
	end)
	if player.Character then
		regChar(player.Character, player, object)
	end
end

Players.PlayerAdded:Connect(regPlayer)

for _, player in pairs(Players:GetPlayers()) do
	regPlayer(player)
end
