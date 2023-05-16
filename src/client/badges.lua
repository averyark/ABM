--!strict
--[[
    FileName    > badges.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 02/05/2023
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local badges = {
    ["thanksForPlaying"] = 2145016612,
    ["metADev"] = 2145016629,
    ["firstLegendarySword"] = 2145016720,
    ["firstQuestCompleted"] = 2145016734,
    ["legendaryCollector"] = 2145016774,
    ["100Streak"] = 2145017690,
    ["emptiedTheShop"] = 2145017695,
    ["firstCpsule"] = 2145017704,
    ["100Capsule"] = 2145017710,
    ["100kCapsule"] = 2145017713,
    ["1mCapsule"] = 2145017726,
    ["10Hour"] = 2145017736,
    ["50Hour"] = 2145017742,
    ["1kHours"] = 2145017749,
    ["touchedGrass"] = 2145017763,
}


return {
    load = function()
        
    end
}