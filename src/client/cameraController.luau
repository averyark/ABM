--[[
    FileName    > cameraController.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/06/2023
--]]
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
local cameraController = { isCameraInventoryState = false }

local tween2 = function(instance, properties, duration)
	local object = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		properties
	)
	object:Play()
	task.spawn(function()
		object.Completed:Wait()
		object:Destroy()
	end)
	return object
end

local cam = workspace.CurrentCamera
local originalCameraCFrame

cameraController.toggleInventoryCameraState = function(state: boolean)
	if state then
		local character = player.Character
		local rootPart = character.HumanoidRootPart :: Part
		local humanoid = character.Humanoid :: Humanoid
		local rootPartCFrame = rootPart.CFrame
		originalCameraCFrame = cam.CFrame

		cam.CameraType = Enum.CameraType.Scriptable

		local pos = rootPartCFrame.Position
			+ rootPartCFrame.LookVector * 5
			- rootPartCFrame.RightVector * 2
			+ rootPartCFrame.UpVector * 0.5

		local cf = CFrame.new(pos, rootPartCFrame.Position)

		tween2(cam, {
			CFrame = cf - cf.RightVector * 1.5 - cf.UpVector * 0.5,
		}, 0.4)
	else
		local character = player.Character
		local rootPart = character.HumanoidRootPart :: Part

		tween2(cam, {
			CFrame = originalCameraCFrame,
		}, 0.25).Completed:Wait()
		cam.CameraType = Enum.CameraType.Custom
	end
end

return module.new("cameraController", cameraController)
