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
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local interface = require(script.Parent.Parent.interface.main)

local movement = require(script.Parent.movement)

local sprint = {}

local usingWeaponState = false
local sprintKeyDown = false
local isSprinting = false
local character: typeof(Players.LocalPlayer.Character)
local isUiFocusing = false
sprint.speed = 16

local tweenObject1, tweenObject2

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
	if tweenObject1 then
		tweenObject1:Destroy()
		tweenObject1 = nil
	end
	if tweenObject2 then
		tweenObject2:Destroy()
		tweenObject2 = nil
	end
	isSprinting = true

	local humanoid = character.Humanoid
	local defaultWalkSpeed = humanoid:GetAttribute("defaultWalkSpeed") or 16

	tweenObject1 = tween.instance(humanoid, {
		WalkSpeed = defaultWalkSpeed + 8,
	}, 0.5, "Cubic")
	if not isUiFocusing then
		tweenObject2 = tween.instance(workspace.CurrentCamera, {
			FieldOfView = 80,
		}, 0.4, "Cubic")
	end


	movement.sprinting(true)
end

local endSprint = function()
	if not character then
		return
	end
	if not isSprinting then
		return
	end
	if tweenObject1 then
		tweenObject1:Destroy()
		tweenObject1 = nil
	end
	if tweenObject2 then
		tweenObject2:Destroy()
		tweenObject2 = nil
	end

	isSprinting = false

	local humanoid = character.Humanoid

	local defaultWalkSpeed = humanoid:GetAttribute("defaultWalkSpeed") or 16

	tweenObject1 = tween.instance(humanoid, {
		WalkSpeed = defaultWalkSpeed,
	}, 0.5, "Cubic")
	if not isUiFocusing then
		tweenObject2 = tween.instance(workspace.CurrentCamera, {
			FieldOfView = 70,
		}, 0.4, "Cubic")
	end

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

	interface.hiding:Connect(function()
		isUiFocusing = false
		task.defer(function()
			if not isUiFocusing and isSprinting then
				tweenObject2 = tween.instance(workspace.CurrentCamera, {
					FieldOfView = 80,
				}, 0.4, "Cubic")
			end
		end)
	end)

	interface.showing:Connect(function()
		isUiFocusing = true
		if tweenObject1 then
			tweenObject1:Destroy()
			tweenObject1 = nil
		end
		if tweenObject2 then
			tweenObject2:Destroy()
			tweenObject2 = nil
		end
	end)

	player.CharacterAdded:Connect(function(char)
		isSprinting = false
		usingWeaponState = false
		character = char
		character:WaitForChild("Humanoid"):GetAttributeChangedSignal("defaultWalkSpeed"):Connect(function()
			sprint.speed = character.Humanoid:GetAttribute("defaultWalKSpeed")
			if isSprinting then
				tween.instance(character.Humanoid, {
					WalkSpeed = character.Humanoid:GetAttribute("defaultWalKSpeed") + 8,
				}, 0.25, "Cubic")
			else
				tween.instance(character.Humanoid, {
					WalkSpeed = character.Humanoid:GetAttribute("defaultWalKSpeed"),
				}, 0.25, "Cubic")
			end
		end)
	end)
	if player.Character then
		isSprinting = false
		usingWeaponState = false
		character = player.Character
		character:WaitForChild("Humanoid"):GetAttributeChangedSignal("defaultWalkSpeed"):Connect(function()
			sprint.speed = character.Humanoid:GetAttribute("defaultWalKSpeed")
			if isSprinting then
				tween.instance(character.Humanoid, {
					WalkSpeed = character.Humanoid:GetAttribute("defaultWalKSpeed") + 8,
				}, 0.25, "Cubic")
			else
				tween.instance(character.Humanoid, {
					WalkSpeed = character.Humanoid:GetAttribute("defaultWalKSpeed"),
				}, 0.25, "Cubic")
			end
		end)
	end
	
	ContextActionService:BindAction("sprint", function(_, inputState, inputObject: InputObject)
		if inputObject.KeyCode == Enum.KeyCode.LeftShift then
			if inputState == Enum.UserInputState.Begin then
				if not playerDataHandler.getPlayer().data.settings[3] then
					if sprintKeyDown then
						sprintKeyDown = false
						endSprint()
					else
						sprintKeyDown = true
						beginSprint()
					end
				else
					sprintKeyDown = true
					beginSprint()
				end
			elseif inputState == Enum.UserInputState.End then
				if playerDataHandler.getPlayer().data.settings[3] then
					sprintKeyDown = false
					endSprint()
				end
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
