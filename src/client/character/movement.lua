--!strict
--[[
    FileName    > movement.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
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

local movement = {}

local getHighest = function(...)
	local highest = 0
	for _, num in pairs({ ... }) do
		num = tonumber(num)
		if num > highest then
			highest = num
		end
	end
	return highest
end

local fov
local cacheTween

local updateFieldOfView = function(newFov)
	if fov == newFov then
		return
	end
	if cacheTween then
		cacheTween:Destroy()
	end
	fov = newFov
	cacheTween = tween.instance(workspace.CurrentCamera, {
		FieldOfView = newFov,
	}, 0.15, "Sine")
end

local player = Players.LocalPlayer
local character: typeof(player.Character) = player.Character

local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.RigidityEnabled = true
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.AlignType = Enum.AlignType.Parallel
alignOrientation.Enabled = false

local lockToObject = function(object)
	if object == nil then
		alignOrientation.Enabled = false
		return
	end
	alignOrientation.CFrame = CFrame.new(character.HumanoidRootPart.Position, object.Position)
	alignOrientation.Enabled = true
end

local locking
local resetTick
local isSprinting = false

local lockTarget = function(target)
	if isSprinting then
		return
	end
	if locking == target then
		resetTick = os.clock() + 5
		return
	end
	if locking then
		local highlight = locking:FindFirstChild("TargetHighlight")
		if highlight then
			tween.instance(highlight.highlight.label, {
				Size = UDim2.fromScale(0, 0),
				ImageTransparency = 1,
			})
		end
	end
	local highlight = target:FindFirstChild("TargetHighlight")
	if highlight then
		tween.instance(highlight.highlight.label, {
			Size = UDim2.fromScale(1, 1),
			ImageTransparency = 0,
		})
	end
	resetTick = os.clock() + 5
	locking = target
end

local unlockTarget = function(target)
	if locking ~= target and target ~= nil then
		return
	end
	if locking then
		local highlight = locking:FindFirstChild("TargetHighlight")
		if highlight then
			tween.instance(highlight.highlight.label, {
				Size = UDim2.fromScale(0, 0),
				ImageTransparency = 1,
			})
		end
	end
	resetTick = nil
	locking = nil
end

local sprinting = function(state)
	isSprinting = state
	if state then
		print("sprinting; giving up target")
		unlockTarget()
	end
end

local gameFolders = workspace.gameFolders

function movement:load()
	local entities = gameFolders.entities

	RunService.RenderStepped:Connect(function(deltaTime)
		if not character then
			return
		end
		if not character:FindFirstChild("HumanoidRootPart") then
			return
		end

		alignOrientation.Attachment0 = character.HumanoidRootPart.RootAttachment
		alignOrientation.Parent = character.HumanoidRootPart

		local charPosition = character.HumanoidRootPart.Position

		local check = function()
			for _, entityModel in pairs(entities:GetChildren()) do
				if entityModel:FindFirstChild("HumanoidRootPart") then
					local rootpart = entityModel.HumanoidRootPart
					local m1 = (rootpart.Position - charPosition).Magnitude
					if m1 < 20 then
						if locking and locking ~= rootpart.Parent then
							local m2 = (locking.HumanoidRootPart.Position - charPosition).Magnitude
							if m1 < m2 then
								lockTarget(rootpart.Parent)
								--resetTick = nil
							end
						else
							lockTarget(rootpart.Parent)
							--resetTick = nil
						end
					else
						unlockTarget(rootpart.Parent)
					end
				end
			end
		end

		if (resetTick and os.clock() > resetTick) or (not resetTick or not locking) then
			--resetTick = nil
			check()
			--unlockTarget(locking)
		end

		if locking and not locking:FindFirstChild("HumanoidRootPart") then
			unlockTarget(locking)
		end

		if locking and locking.Parent ~= gameFolders.entities then
			unlockTarget(locking)
		end

		lockToObject(locking and locking:FindFirstChild("HumanoidRootPart"))

		if locking then
			local highlight = locking:FindFirstChild("TargetHighlight")
			if highlight.highlight.label.Rotation >= 360 then
				highlight.highlight.label.Rotation = 0
			end
			highlight.highlight.label.Rotation += 30 * deltaTime
		end
	end)

	player.CharacterAdded:Connect(function(char)
		character = char
	end)
end

movement.sprinting = sprinting
movement.unlockTarget = unlockTarget
movement.lockTarget = lockTarget

return movement
