--[[
    FileName    > initialize.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/05/2023
--]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local astrax = require(ReplicatedStorage.Packages.Astrax)

astrax.module.setModuleFolder(ServerScriptService.server)
astrax.start():andThen(function() 
    print("[AstraxFramework] Framework loaded on the client")
end)