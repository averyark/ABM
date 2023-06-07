local ReplicatedStorage = game:GetService("ReplicatedStorage")
for _, object in pairs(game.Selection:Get()) do
    if object.Handle:FindFirstChild("AttackTrail") then
        object.Handle.AttackTrail:Destroy()
    end

    local highestPoint, lowestPoint
    local points = {}
    for _, DmgPoint in pairs(object.Handle:GetChildren()) do
        if DmgPoint.Name == "DmgPoint" then
            table.insert(points, {point=DmgPoint, y=DmgPoint.Position.Y})
        end
    end
    table.sort(points, function(a, b)
        return a.y < b.y
    end)
    highestPoint = points[#points].point
    lowestPoint = points[1].point
    
    local trail = ReplicatedStorage.AttackTrail:Clone()
    trail.Attachment0 = highestPoint
    trail.Attachment1 = lowestPoint
    trail.Parent = object.Handle
end