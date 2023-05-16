local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WELD = function(p0, p1)
    local weld = Instance.new("WeldConstraint")
    weld.Name = p1.Name
    weld.Part0 = p0
    weld.Part1 = p1
    weld.Parent = p0
    return weld
end

for _, object in pairs(game.Selection:Get()) do
    local tool = Instance.new("Tool")
    tool.Name = "SWORD"
    tool.Parent = workspace

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(.5, .5, .5)
    handle.Transparency = 1
    handle.Parent = tool
    handle.CanCollide = false
    handle.Anchored = false

    local model = Instance.new("Model")
    model.Name = "swordParts"
    model.Parent = tool

    if object:IsA("BasePart") then
        handle.CFrame = object.CFrame
        WELD(handle, object)
        object.Parent = model
        object.Anchored = false
        object.CanCollide = false
    elseif object:IsA("Model") then
        handle.CFrame = object:GetPivot()
    end

    for _, child in pairs(object:GetChildren()) do
        if object:IsA("BasePart") then
            WELD(handle, child)
            child.Parent = model
            child.Anchored = true
            child.CanCollide = false
        end
    end

    for _, attachment in pairs(ReplicatedStorage.Folder.point:GetChildren()) do
        attachment:Clone().Parent = handle
    end

    local highestPoint, lowestPoint
    local points = {}
    for _, DmgPoint in pairs(handle:GetChildren()) do
        if DmgPoint.Name == "DmgPoint" then
            table.insert(points, {point=DmgPoint, y=DmgPoint.Position.Y})
        end
    end
    table.sort(points, function(a, b)
        return a.y < b.y
    end)
    highestPoint = points[#points].point
    lowestPoint = points[1].point
    
    local trail = ReplicatedStorage.Folder.AttackTrail:Clone()
    trail.Attachment0 = highestPoint
    trail.Attachment1 = lowestPoint
    trail.Parent = handle
end
