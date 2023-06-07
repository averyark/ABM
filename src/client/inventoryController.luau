--!nonstrict
--[[
    FileName    > inventoryController.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/06/2023
--]]
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Red = require(ReplicatedStorage.Packages.Red)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local astrax = require(ReplicatedStorage.Packages.Astrax)

local class = astrax.class
local module = astrax.module
local data = astrax.dataClient
local number = astrax.number
local tween = astrax.tween

local player = Players.LocalPlayer
local inventoryController = { isInventoryOpened = false }

local gui = player:WaitForChild("PlayerGui") :: typeof(game.StarterGui)
local inventory = gui:WaitForChild("inventory")

local function freezeMovements(state)
    local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule") :: ModuleScript)
	local control = playerModule:GetControls()
    if state then
        control:Disable()
    else
        control:Enable()
    end
end

local function animateInventoryManifestation(state)
	local cameraController = require(script.Parent.cameraController)
	if state then
		tween.instance(inventory.canvas.Frame, {
			Position = UDim2.new(0.5, 8, 0.5, 0),
		}, 0.4, "EntranceExpressive")
		tween.instance(inventory.canvas.Frame.scale, {
			Scale = 1,
		}, 0.4, "EntranceExpressive")
		tween.instance(Lighting.WorldEffect_DepthOfField, {
			FarIntensity = 0.3,
			InFocusRadius = 10,
		}, 0.4, "EntranceExpressive")
	else
		tween.instance(Lighting.WorldEffect_DepthOfField, {
			FarIntensity = 0.15,
			InFocusRadius = 25,
		}, 0.25, "ExitExpressive")
		tween.instance(inventory.canvas.Frame, {
			Position = UDim2.fromScale(-1, 0.5),
		}, 0.25, "ExitExpressive")
		tween.instance(inventory.canvas.Frame.scale, {
			Scale = 0.9,
		}, 0.25, "ExitExpressive")
	end

	freezeMovements(state)
	cameraController.toggleInventoryCameraState(state)
end

function inventoryController.load()
	inventory.canvas.Frame.Position = UDim2.fromScale(-1, 0.5)
	inventory.canvas.Frame.scale.Scale = 0.9
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Q then
			inventoryController.isInventoryOpened = not inventoryController.isInventoryOpened
			animateInventoryManifestation(inventoryController.isInventoryOpened)
		end
	end)
end

return module.new("inventoryController", inventoryController)
