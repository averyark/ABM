--!strict
--[[
    FileName    > heroHandler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 17/04/2023
--]]
local MarketplaceService = game:GetService("MarketplaceService")
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

local SimplePath = require(ReplicatedStorage.shared.SimplePath)
local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)
local heros = require(ReplicatedStorage.shared.heros)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local rarities = require(ReplicatedStorage.shared.rarities)

local bridges = {
	initializeHeroOnClient = BridgeNet.CreateBridge("initializeHeroOnClient"),
}

local animationIds = {
    idle = "http://www.roblox.com/asset/?id=507766388",
    walk = "http://www.roblox.com/asset/?id=913402848",
    jump =  "http://www.roblox.com/asset/?id=507765000",
    fall = "http://www.roblox.com/asset/?id=507767968"
}

local meta = {}
meta.__index = meta

local getPointOnCircle = function(circle_radius, degrees)
	local a = math.cos(degrees) * circle_radius
	local b = math.sin(degrees) * circle_radius
	return Vector3.new(a, 0, b)
end
--GetPointOnCircle(5, i * (math.pi*2 / #Character.pets_folder:GetChildren()))

function meta:Destroy()
   self._maid:Destroy()
end

function meta:getDesiredPosition()
    if not self.index then return end
    local equipped = playerDataHandler.getPlayer(self.player).data.equipped.hero
    local point = getPointOnCircle(
        6,
        table.find(equipped, self.index) * (math.pi*2 / #equipped)
    )
    return CFrame.new(self.player.Character.HumanoidRootPart.CFrame.Position) * CFrame.new(point)
end

function meta:teleportToPlayer()
    if self.pathFinding and self.pathFinding._status == SimplePath.StatusType.Active then
        self.pathFinding:Stop()
    end
    self.model.HumanoidRootPart.CFrame = self.chase.CFrame
end

function meta:moveToPlayer()
    self.resetPathFindingDebounce:lock()

    self.pathFinding:Run(self.chase)
end

function meta:init()
    self.model.Name = `{self.player.UserId}-{self.index}`
    self.model.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    self.model.Humanoid.WalkSpeed = 30
    self.model.HumanoidRootPart.Anchored = true
    self.model.Parent = workspace.gameFolders.heros
    self.model.HumanoidRootPart.CFrame = CFrame.new(69, -69, 69)

    self.itemData = heros[self.id]

    self.tag = ReplicatedStorage.resources.herotag:Clone()
    self.tag.Parent = self.model.HumanoidRootPart

    local rarityData = rarities[self.itemData.rarity]

    self.tag.displayname.Text = `{self.player.DisplayName}'s {self.itemData.name}`
    self.tag.rarity.Text = rarityData.name
    self.tag.rarity.TextColor3 = rarityData.primaryColor

    for _, part in pairs(self.model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Hero"
		end
	end

	self._maid:Add(self.model.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "Hero"
		end
	end))

    self.chase = Instance.new("Part")
    self.chase.Name = `_{self.model.Name}_chase`
    self.chase.Parent = workspace.gameFolders.heros
    self.chase.CFrame = self:getDesiredPosition()
    self.chase.Anchored = true
    self.chase.Size = Vector3.new(1, 1, 1)
    self.chase.Color = Color3.fromRGB(255, 0, 0)
    self.chase.Transparency = 1
    self.chase.CanCollide = false

    self.pathFinding = SimplePath.new(self.model, {
        AgentCanJump = true,
		AgentCanClimb = false,
		AgentRadius = 4
    }, { JUMP_WHEN_STUCK = false })
    self.pathFinding.Visualize = false

    self._maid:Add(self.pathFinding.Blocked:Connect(function()
		self:moveToPlayer()
	end))
	self._maid:Add(self.pathFinding.Error:Connect(function(errorType)
        if errorType == "LimitReached" then
            return
        end
        --warn(errorType)
		--self:teleportToPlayer()
	end))
	self._maid:Add(self.pathFinding.WaypointReached:Connect(function()
		self:moveToPlayer()
	end))
    --self._maid:Add(self.model)
    self._maid:Add(self.pathFinding)
    self._maid:Add(self.chase)

    --[[local gyro = Instance.new("BodyGyro")
	gyro.D = 150
	gyro.P = 4000
	gyro.MaxTorque = Vector3.new(0, 10000, 0)
	gyro.CFrame = self._spawnCFrame
	gyro.Parent = nil

	self.gyro = gyro]]

    self._maid:Add(RunService.Heartbeat:Connect(function()
        if not self.player.Character then return end
        local modelPosition = self.model.HumanoidRootPart.Position
        local characterPosition = self.player.Character.HumanoidRootPart.Position
        if characterPosition ~= self.positionCache then
            self.chase.CFrame = self:getDesiredPosition()
            local magnitude = (modelPosition - characterPosition).Magnitude
            if magnitude >= 40 then
                self:teleportToPlayer()
            elseif (self.chase.Position - modelPosition).Magnitude >= 10 and self.pathFinding._status ~= SimplePath.StatusType.Active then
                self:moveToPlayer()
            end
            self.positionCache = characterPosition
        end
    end))
    self._maid:Add(self.model.Destroying:Connect(function()
        self:Destroy()
    end))
    self._maid:Add(self.model.AncestryChanged:Connect(function(...)
        if not self.model:IsDescendantOf(workspace.gameFolders.heros) then
            self:Destroy()
        end
    end))
    self._maid:Add(self.player.AncestryChanged:Connect(function()
        if not self.player:IsDescendantOf(Players) then
            self:Destroy()
        end
    end))

    bridges.initializeHeroOnClient:FireAll(self.player, self.id, self.model)

    self:teleportToPlayer()
    self.model.HumanoidRootPart.Anchored = false

    return self
end

local class = objects.new(meta, {})

local new = function(player: Player, id: number, index: number)
    return class:new({
        player = player,
        id = id,
        index = index,

        positionCache = Vector3.zero,

        resetPathFindingDebounce = debounce.new(debounce.type.Timer, 10 / 20),

        data = heros[id],
        model = heros[id].model:Clone()
    })
end

return {
    new = new,
}