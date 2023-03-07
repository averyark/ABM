--!strict
--[[
    FileName    > level.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/03/2023
--]]
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
local levels = require(ReplicatedStorage.shared.levels)


--[[local max = 50
local equation = function(n)
    return ((n-32)*1000)^1.85
end
local str = ""

for i = 1, 10 do
    local format = "    [%d] = {\n        requirement = %d,\n        multiplier = 0,\n    },\n"
    str = str .. format:format(max-10+i, equation(max-10+i))
end

print(str)]]

return {
    load = function()
        local connect = function(player: Player)
            local playerData = playerDataHandler.getPlayer(player)
            playerData:connect({"xp"}, function(change)
                local level = playerData.data.level
                
                if level == #levels then return end

                local levelupData = levels[playerData.data.level+1]

                if playerData.data.xp >= levelupData.requirement then
                    playerData:apply(function()
                        playerData.data.level += 1
                        playerData.data.xp = playerData.data.xp - levelupData.requirement
                    end)
                end
            end)
        end
        for _, player in pairs(Players:GetPlayers()) do
            connect(player)
        end
        Players.PlayerAdded:Connect(connect)
    end
}

--[[
    local s, e = 41, 50
    local equation = function(n) return ((n-32)*1000)^1.85  end
    local equation2 = function(n) return ((n-26)*1250)^1.7 end

    print("Level", "Requirement", "Offset")
    local number = require(game.ReplicatedStorage.shared.number)
    for i = s,e do
    local now = math.round(equation(i))
    local last = i ~= 1 and i%10 == 1 and i%10 == 1 and equation2(i-1) or math.round(equation(i-1))
    print(
        string.format("%-5s", i),
        string.format("%-11s", number.abbreviate(now, 2)),
        i == 1 and "" or number.abbreviate(now - last, 2)
    )
end

]]