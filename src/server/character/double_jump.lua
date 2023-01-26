--!strict
--[[
    FileName    > double_jump.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/12/2022
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
local Astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local bridges = {
	land = BridgeNet.CreateBridge("replicateLand"),
	onReplicateJumpLand = BridgeNet.CreateBridge("onReplicateJumpLand"),
	jump = BridgeNet.CreateBridge("replicateJump"),
	onReplicateJump = BridgeNet.CreateBridge("onReplicateJump"),
}

local double_jump = {}

function double_jump:load()
	bridges.jump:Connect(function(player)
		bridges.onReplicateJump:FireToAllExcept({ player }, player)
	end)
	bridges.land:Connect(function(player, position)
		bridges.onReplicateJumpLand:FireToAllExcept({ player }, player, position)
	end)
end

return double_jump
