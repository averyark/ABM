--!strict
--[[
    FileName    > spawnZones.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

local BridgeNet = require(ReplicatedStorage.Packages.BridgeNet)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Matter = require(ReplicatedStorage.Packages.Matter)
local Astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)

local entities = require(script.Parent.entities)
local entity = require(script.Parent.entity)

local spawnZones = {}

function spawnZones:load()
	local spawnEntityFolders = workspace.gameFolders.entitySpawnParts:GetChildren()

	for _, folder in pairs(spawnEntityFolders) do
		if folder:IsA("Folder") and entities[folder.Name] then
			local spawnParts = folder:GetChildren()
			local entityData = entities[folder.Name]

			local spawn
			spawn = function(spawnPart)
				local monster = entity.new(entityData.id, spawnPart.CFrame)

				monster.onDeath:Connect(function()
					task.wait(entityData.respawnTime)
					spawn(spawnPart)
				end)
			end

			for _, spawnPart in pairs(spawnParts) do
				spawn(spawnPart)
			end
		end
	end
end

return spawnZones
