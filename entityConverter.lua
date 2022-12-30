local Selection = game:GetService("Selection")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local targetHighlightModel = ReplicatedStorage.TargetHighlight:Clone()

local damageboxSize = 2
local hitboxSizeMultiplier = 1.5

local makeHitbox = function (object: Model)
    local hitbox = Instance.new("Part")
    local cf, size = object:GetBoundingBox()

    hitbox.Name = "Hitbox"
    hitbox.Size = size * Vector3.new(hitboxSizeMultiplier, hitboxSizeMultiplier, hitboxSizeMultiplier)
    hitbox.CFrame = object.HumanoidRootPart.CFrame
    hitbox.Transparency = 0.8
    hitbox.CanCollide = false
    hitbox.Color = Color3.fromRGB(255, 0, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = object.HumanoidRootPart
    weld.Parent = hitbox
    weld.Name = "HitboxWeld"

    hitbox.Parent = object

    return object
end

local makeDamagebox = function (object: Model)
    local damagebox = Instance.new("Part")

    local rightArm = object:FindFirstChild("Right Arm")

    damagebox.Name = "Damagebox"
    damagebox.Size = Vector3.one * damageboxSize
    damagebox.Position = rightArm.Position - rightArm.CFrame.UpVector * damageboxSize
    damagebox.Transparency = 0.8
    damagebox.CanCollide = false
    damagebox.Color = Color3.fromRGB(255, 0, 255)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = damagebox
    weld.Part1 = rightArm
    weld.Parent = damagebox
    weld.Name = "DamageboxWeld"

    damagebox.Parent = object

    return object
end

local makeTargetHighlight = function (object: Model)
	local targetHightlightClone = targetHighlightModel:Clone()

    local hrpPos = object["HumanoidRootPart"].Position
    local y = object["Left Leg"].Position.Y
    local x, z = hrpPos.X, hrpPos.Z

    targetHightlightClone.Position = Vector3.new(x, y - (object["Left Leg"].Size.Y/2), z)
    targetHightlightClone.Color = Color3.fromRGB(0, 0, 255)
    targetHightlightClone.Transparency = 0.8

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = targetHightlightClone
    weld.Part1 = object.HumanoidRootPart
    weld.Parent = targetHightlightClone
    weld.Name = "TargetHighlightWeld"

    targetHightlightClone.Parent = object

    return object
end

for _, object in pairs(Selection:Get()) do
    if not object:FindFirstChild("Humanoid") then return warn("Expected Humanoid for entityConversion task:", object) end
    
    for _, part in pairs(object:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end

    object.Humanoid.BreakJointsOnDeath = false
    
    makeHitbox(object)
    makeDamagebox(object)
    makeTargetHighlight(object)


end