--!nonstrict
--[[
    FileName    > interfaceController.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/06/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Red = require(ReplicatedStorage.Packages.Red)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local astrax = require(ReplicatedStorage.Packages.Astrax)

local class = astrax.class
local module = astrax.module
local data = astrax.dataClient
local number = astrax.number
local tween = astrax.tween

local player = Players.LocalPlayer
local interfaceController = {}

local gui = player:WaitForChild("PlayerGui") :: typeof(game.StarterGui)

function interfaceController.preload()
    
end

return module.new("interfaceController", interfaceController)