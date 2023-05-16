local ReplicatedStorage = game:GetService("ReplicatedStorage")
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)

return {
    {
        name = "Precise Aim",
        id = 1,
        rarity = 1,
        chance = 0.33,

        color = Color3.fromRGB(177, 177, 177),

        onApply = function(sword)
            sword.Handle.AttackTrail.Brightness = 2
            sword.Handle.AttackTrail.LightEmission = 1
            sword.Handle.AttackTrail.LightInfluence = 0
            sword.Handle.AttackTrail.Transparency = NumberSequence.new(0.5)
            sword.Handle.AttackTrail.Color = ColorSequence.new(Color3.fromRGB(161, 197, 245))
        end,
        getValue = function(level: number)
            return level/10, level/20
        end,
        getTxt = function(dmg: number, rate: number)
            return `Sword has {math.round(dmg*10000)/100}% more Crit Damage and {math.round(rate*10000)/100}% higher Crit Rate`
        end,

        description = "The sword has increased Crit Damage and Crit Rate"
    },
    {
        name = "Ice",
        id = 2,
        rarity = 4,
        chance = 0.07,

        color = Color3.fromRGB(0, 156, 213),

        getValue = function(level: number)
            return level/4, (level/2)+1
        end,
        getTxt = function(chance: number, seconds: number, dmg: number)
            return `Target hit by the sword has a {math.round(chance*10000)/100}% chance of freezing for {math.round(seconds*10000)/10000} seconds. The victim takes a one time damage when frozen`
        end,
        onApply = function(sword)

            for _, object in pairs(ReplicatedStorage.resources.effects.ice:GetChildren()) do
                object:Clone().Parent = sword.bladePart
            end
            ReplicatedStorage.resources.effects.freezelight:Clone().Parent = sword.Handle
            sword.Handle.AttackTrail.Brightness = 4
            sword.Handle.AttackTrail.LightEmission = 1
            sword.Handle.AttackTrail.LightInfluence = 0
            sword.Handle.AttackTrail.Transparency = NumberSequence.new(0.35)
            sword.Handle.AttackTrail.Color = ColorSequence.new(Color3.fromRGB(127, 212, 255))
        end,
        onTargetHit = function(entity, level, damage, player, cfOnHit)
            if entity.entity:FindFirstChild("HumanoidRootPart") then
                if entity.stunned then return end
                local chance = math.random()
                local freezeChance = level/3
                if chance > freezeChance then
                    return true
                end
                task.spawn(function()
                    if entity.pathfinding._status ~= "Idle" then
                        entity.pathfinding:Stop()
                    end
                    entity.stunned = true
                    entity.entity.HumanoidRootPart.Anchored = true
                    local freezeIce = ReplicatedStorage.resources.effects.freeze:Clone()
                    freezeIce.Transparency = 1
                    local size = entity.entity.Hitbox.Size - Vector3.new(2, 1, 2)
                    freezeIce.Size = size
                    freezeIce.Attach.CFrame = CFrame.new(0, (-size.Y/2)+0.5, 0)
                    freezeIce.Attachment.CFrame = CFrame.new(0, -size.Y/2, 0)
                    freezeIce.Parent = entity.entity.HumanoidRootPart
                    freezeIce.CFrame = entity.entity.HumanoidRootPart.CFrame
                    freezeIce.WeldConstraint.Part1 = entity.entity.HumanoidRootPart
                    for _, a in pairs(freezeIce.Attach:GetChildren()) do
                        a:Emit(3)
                    end

                    tween.instance(freezeIce, {
                        Transparency = 0.5
                    }, .15)
                    
                    freezeIce.sfx:Play()
                    task.wait(level+2)
                    if entity.entity:FindFirstChild("HumanoidRootPart") then
                        entity.entity.HumanoidRootPart.Anchored = false
                        entity:takeDamage(player, damage*(1 + level/3), "ice", 0, cfOnHit)
                        freezeIce:Destroy()
                        entity.stunned = false
                    end
                end)
            end

            return true
        end,

        description = "Targets has a chance of freezing for a few seconds. The victim takes a one time freezing damage"
    },
    {
        name = "Burn",
        id = 3,
        rarity = 3,
        chance = 0.15,

        color = Color3.fromRGB(230, 120, 80),
        onTargetHit = function(entity, level, damage, player, cfOnHit)
            if entity.entity:FindFirstChild("HumanoidRootPart") and not entity.isBurning then
                entity.isBurning = true
                task.spawn(function()
                    local sfx = ReplicatedStorage.resources.effects.Burned_1:Clone()
                    sfx.Parent = entity.entity.HumanoidRootPart
                    sfx:Play()
                    local parts = {}
                    for _, burn in pairs(ReplicatedStorage.resources.effects.burn:GetChildren()) do
                        local burnClone = burn:Clone()
                        burnClone.Parent = entity.entity.HumanoidRootPart
                        if burnClone.Name == "spark" then
                            burnClone:Emit(30)
                        end
                        table.insert(parts, burnClone)
                    end
                    local max = (level-1) + 2
                    for i = 0, max do
                        entity:takeDamage(player, damage*(1 + level/5)*0.4, "burn", 0, cfOnHit)
                        task.wait(1)
                    end
                    for _, burn in pairs(parts) do
                        burn:Destroy()
                    end
                    entity.isBurning = false
                end)
            end
            return true
        end,
        onApply = function(sword)
            for _, object in pairs(ReplicatedStorage.resources.effects.fire:GetChildren()) do
                object:Clone().Parent = sword.bladePart
            end
            ReplicatedStorage.resources.effects.PointLight:Clone().Parent = sword.Handle
            sword.Handle.AttackTrail.Brightness = 3
            sword.Handle.AttackTrail.LightEmission = 1
            sword.Handle.AttackTrail.LightInfluence = 0
            sword.Handle.AttackTrail.Transparency = NumberSequence.new(0.4)
            sword.Handle.AttackTrail.Color = ColorSequence.new(Color3.fromRGB(255, 167, 95))
        end,
        getValue = function(level: number, power: number)
            return (level-1)*2 + 2
        end,
        getTxt = function(sec: number)
            return `Target hit experience {sec} seconds of burning.`
        end,

        description = "Target hit experience 2 seconds of burning. The target takes burning damage"
    },
    {
        name = "Poison",
        id = 4,
        rarity = 3,
        chance = 0.18,

        color = Color3.fromRGB(70, 170, 70),

        onApply = function(sword)
            for _, object in pairs(ReplicatedStorage.resources.effects.poison:GetChildren()) do
                object:Clone().Parent = sword.bladePart
            end
            ReplicatedStorage.resources.effects.PointLight:Clone().Parent = sword.Handle
            sword.Handle.AttackTrail.Brightness = 2
            sword.Handle.AttackTrail.LightEmission = 1
            sword.Handle.AttackTrail.LightInfluence = 0
            sword.Handle.AttackTrail.Transparency = NumberSequence.new(0.4)
            sword.Handle.AttackTrail.Color = ColorSequence.new(Color3.fromRGB(5, 148, 0))
        end,
        onTargetHit = function(entity, level, damage, player, cfOnHit)
            if entity.entity:FindFirstChild("HumanoidRootPart") and not entity.poisoned then
                task.spawn(function()
                    entity.poisoned = true
                    entity.entity.Humanoid.WalkSpeed = entity.data.walkSpeed - 6
                    local parts = {}
                    for _, poison in pairs(ReplicatedStorage.resources.effects.poisonEff:GetChildren()) do
                        local clone = poison:Clone()
                        clone.Parent = entity.entity.HumanoidRootPart
                        table.insert(parts, clone)
                    end
                    local max = level+2
                    for i = 0, max do
                        entity:takeDamage(player, damage*(1 + level/5)*0.25, "poison", 0, cfOnHit)
                        task.wait(1)
                    end
                    for _, poison in pairs(parts) do
                        poison:Destroy()
                    end
                    entity.entity.Humanoid.WalkSpeed = entity.data.walkSpeed
                    entity.poisoned = false
                end)
            end
            return true
        end,
        getValue = function(level: number, power: number)
            return level+2
        end,
        getTxt = function(damageTime: number)
            return `Hitting a target has a chance of inflicting poision damage for {damageTime} seconds. The victim slows down and takes damage when poisoned`
        end,

        description = "Hitting a target has a chance of inflicting poision damage for a few seconds. The victim slows down and takes damage when poisoned"
    },
    {
        name = "Lightning",
        id = 5,
        rarity = 4,
        chance = 0.03,

        color = Color3.fromRGB(230, 230, 30),

        getValue = function(level: number)
            return 1 + level
        end,
        getTxt = function(damageTime: number)
            return `Victim is stunned for {damageTime} and takes lightning damage {math.round(damageTime/.5)} times`
        end,
        onApply = function(sword)
            for _, attachment in pairs(sword.Handle:GetChildren()) do
                if attachment.Name == "DmgPoint" then
                    for _, object in pairs(ReplicatedStorage.resources.effects.lightning:GetChildren()) do
                        object:Clone().Parent = attachment
                    end
                end
            end
            ReplicatedStorage.resources.effects.PointLight:Clone().Parent = sword.Handle
            sword.Handle.AttackTrail.Brightness = 5
            sword.Handle.AttackTrail.LightEmission = 1
            sword.Handle.AttackTrail.LightInfluence = 0
            sword.Handle.AttackTrail.Transparency = NumberSequence.new(0.3)
            sword.Handle.AttackTrail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
        end,
        onTargetHit = function(entity, level, damage, player, cfOnHit)
            if entity.entity:FindFirstChild("HumanoidRootPart") then
                task.spawn(function()
                    local lightning = ReplicatedStorage.resources.effects.FlashStep.attachment:Clone()
                    lightning.Parent = entity.entity.HumanoidRootPart
                    --lightning.CFrame = entity.entity.HumanoidRootPart.CFrame
                    local sfx = lightning["sfx" .. math.random(1, 2)]
                    sfx:Destroy()
                    entity:takeDamage(player, damage*(math.random(1 + level/2, 1 + level/4)), "lightning", 13 + ((level-1)*8), cfOnHit)
                    task.wait(.05)
                    lightning:Destroy()

                    task.spawn(function()
                        for i = math.random(level/.5), 1, -1 do
                            entity:takeDamage(player, damage*(1 + level/4), "lightning", 0, cfOnHit)
                            task.wait(.5)
                        end
                    end)
                    
                    sfx:Destroy()
                end)
            end
            return true
        end,

        description = "Lightning strikes nearby targets. Targets hit takes sustained lightning damage for a few seconds"
    },
    {
        name = "Sharpness",
        id = 6,
        rarity = 2,
        chance = 0.24,

        color = Color3.fromRGB(220, 220, 220),

        onApply = function(sword)
           print(sword)
            sword.Handle.AttackTrail.Brightness = 2
            sword.Handle.AttackTrail.LightEmission = 1
            sword.Handle.AttackTrail.LightInfluence = 0
            sword.Handle.AttackTrail.Transparency = NumberSequence.new(0.4)
            sword.Handle.AttackTrail.Color = ColorSequence.new(Color3.fromRGB(150, 246, 253))
        end,
        getValue = function(level: number)
            return level/2
        end,
        getTxt = function(value: number)
            return `Sword has a {math.round(value*10000)/1000}% increase in damage`
        end,
        onTargetHit = function(entity, level, damage)
            return true, damage + damage*(level/4)
        end,

        description = "The sword has an increased damage (not added to power)"
    },
}