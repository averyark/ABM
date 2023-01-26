--!strict
--[[
    FileName    > ${double_jump.lua}
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 04/12/2022
--]]
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local BridgeNet = require(ReplicatedStorage.Packages.BridgeNet)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local animations = require(script.Parent.animations)

local double_jump = {}

local effects_landed = ReplicatedStorage.effects.Land
local effects_jump = ReplicatedStorage.effects.JumpEffect

local maxJumps: number
local jumps: number
local jumpButton: TextButton

local hugeVector = Vector3.new(math.huge, math.huge, math.huge)

local bridges = {
	land = BridgeNet.CreateBridge("replicateLand"),
	onReplicateJumpLand = BridgeNet.CreateBridge("onReplicateJumpLand"),
	jump = BridgeNet.CreateBridge("replicateJump"),
	onReplicateJump = BridgeNet.CreateBridge("onReplicateJump"),
}

local jumped = function(player: Player)
	assert(t.instanceIsA("Player")(player))

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	if player == Players.LocalPlayer then
		animations.get(ReplicatedStorage.animations.double_jump):play()
	end

	local jumpEffectLeft = effects_jump:Clone()
	local jumpEffectRight = effects_jump:Clone()
	local timeout = function()
		task.wait(0.5)
		jumpEffectLeft:Destroy()
		jumpEffectRight:Destroy()
	end

	jumpEffectLeft.Parent = player.Character["Left Leg"]
	jumpEffectRight.Parent = player.Character["Right Leg"]
	jumpEffectLeft:Emit()
	jumpEffectRight:Emit()

	timeout()
end

local land = function(player: Player, position: Vector3, velocity)
	assert(t.instanceIsA("Player")(player))
	assert(t.Vector3(position))

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local landEffect = effects_landed:Clone()
	local timeout = function()
		task.wait(0.5)
		landEffect:Destroy()
	end

	landEffect.Parent = player.Character
	landEffect.Position = position
	landEffect.Hit:Emit()
	local a = math.clamp(velocity / 80, 1, 1.5)
	landEffect.Land.PlaybackSpeed = a
	landEffect.Land:Play()

	timeout()
end

local groundRaycast = function(part, character)
	local groundRaycastParams = RaycastParams.new()
	groundRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	groundRaycastParams.FilterDescendantsInstances = { character }
	groundRaycastParams.IgnoreWater = false

	local result = workspace:Raycast(part.Position, Vector3.FromNormalId(Enum.NormalId.Bottom) * 4, groundRaycastParams)

	if not result then
		return
	end
	if result.Material == Enum.Material.Water then
		return
	end
	return result.Position.Y
end

local getLandPosition = function(character)
	local HumanoidRootPart = character.HumanoidRootPart

	local leftFoot = groundRaycast(character["Left Leg"])
	local rightFoot = groundRaycast(character["Right Leg"])

	return Vector3.new(HumanoidRootPart.Position.X, leftFoot or rightFoot, HumanoidRootPart.Position.Z)
end

local boostVelocity = function(character)
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local hrp = character.HumanoidRootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Parent = hrp
	bodyVelocity.MaxForce = hugeVector
	bodyVelocity.P = 1000
	bodyVelocity.Velocity = Vector3.new(hrp.CFrame.lookVector.X * 24, 60, hrp.CFrame.lookVector.Z * 24)
	task.wait(0.1)
	bodyVelocity:Destroy()
end

local updateJumpsManifest = function()
	debugger.log("Remaining jumps:", jumps, "; Max jumps:", maxJumps)
end

local onJumpRequest = function(character, _, input)
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	local humanoid = character:WaitForChild("Humanoid")

	if input == Enum.UserInputState.Begin and humanoid then
		local state = humanoid:GetState()
		if
			state == Enum.HumanoidStateType.Running
			or state == Enum.HumanoidStateType.RunningNoPhysics
			or state == Enum.HumanoidStateType.Landed
		then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			jumps -= 1
			updateJumpsManifest()
		elseif jumps > 0 and (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping) then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			bridges.jump:Fire()
			jumps -= 1
			coroutine.resume(coroutine.create(boostVelocity), character)
			jumped(Players.LocalPlayer)
			updateJumpsManifest()
		end
	end
end

local initializeCharacter = function(character)
	local player = Players.LocalPlayer
	local humanoid = character:WaitForChild("Humanoid")

	maxJumps = 3
	jumps = maxJumps

	humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			if old == Enum.HumanoidStateType.Freefall then
				local velocity = math.abs(character.HumanoidRootPart.AssemblyLinearVelocity.Y)
				print("HIT GROUND VELOCITY:", velocity)
				if velocity > 80 then
					local pos = getLandPosition(character)
					if pos then
						land(Players.LocalPlayer, pos, velocity)
					end
				end
			end
			--network:GetConnection("jump_land_absolute"):Set()
			jumps = maxJumps
			updateJumpsManifest()
			if
				jumpButton and jumpButton.ImageRectOffset.X == 146
				or UserInputService:IsKeyDown(Enum.KeyCode.Space)
				or UserInputService:IsKeyDown(Enum.KeyCode.ButtonX)
			then
				bridges.jump:Fire()
				onJumpRequest(character, nil, Enum.UserInputState.Begin)
			end
		end
	end)
end

function double_jump:load()
	local player = Players.LocalPlayer

	bridges.onReplicateJumpLand:Connect(land)
	bridges.onReplicateJump:Connect(jumped)

	if UserInputService.TouchEnabled then
		jumpButton = player
			:WaitForChild("PlayerGui")
			:WaitForChild("TouchGui")
			:WaitForChild("TouchControlFrame")
			:WaitForChild("JumpButton")
	else
		ContextActionService:BindAction("JumpRequest", function(...)
			onJumpRequest(player.Character, ...)
		end, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonX)
	end

	player.CharacterAdded:Connect(initializeCharacter)
	if player.Character then
		initializeCharacter(player.Character)
	end

	ReplicatedStorage.mobileJumpRequest.Event:Connect(onJumpRequest)
end

return double_jump
