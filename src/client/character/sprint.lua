--!strict
--[[
    FileName    > sprint.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 09/12/2022
--]]
local ContextActionService = game:GetService("ContextActionService")
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

local movement = require(script.Parent.movement)

local sprint = {}

local usingWeaponState = false
local sprintKeyDown = false
local isSprinting = false
local character: typeof(Players.LocalPlayer.Character)

local beginSprint = function()
	if usingWeaponState then
		return
	end
	if not character then
		return
	end
	if isSprinting then
		return
	end
	isSprinting = true

	local humanoid = character.Humanoid

	tween.instance(humanoid, {
		WalkSpeed = 24,
	}, 0.5, "Cubic")

	movement.sprinting(true)
end

local endSprint = function()
	if not character then
		return
	end
	if not isSprinting then
		return
	end

	isSprinting = false

	local humanoid = character.Humanoid

	tween.instance(humanoid, {
		WalkSpeed = 16,
	}, 0.5, "Cubic")

	movement.sprinting(false)
end

local usingWeapon = function(state)
	usingWeaponState = state
	if isSprinting and usingWeaponState then
		endSprint()
	elseif not isSprinting and not usingWeaponState and sprintKeyDown then
		beginSprint()
	end
end

function sprint:load()
	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(function(char)
		isSprinting = false
		character = char
	end)
	ContextActionService:BindAction("sprint", function(_, inputState, inputObject: InputObject)
		if inputObject.KeyCode == Enum.KeyCode.LeftShift then
			if inputState == Enum.UserInputState.Begin then
				sprintKeyDown = true
				beginSprint()
			elseif inputState == Enum.UserInputState.End then
				sprintKeyDown = false
				endSprint()
			end
		else
			if isSprinting then
				endSprint()
			else
				beginSprint()
			end
		end
	end, true, Enum.KeyCode.LeftShift)
	isSprinting = false
	usingWeaponState = false
end

sprint.endSprint = endSprint
sprint.beginSprint = beginSprint
sprint.usingWeapon = usingWeapon

return sprint
