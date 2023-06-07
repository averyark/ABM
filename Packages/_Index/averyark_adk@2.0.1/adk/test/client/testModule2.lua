--!strict
--[[
    FileName    > testModule.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 01/06/2023
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local astrax = require(ReplicatedStorage.Packages.Astrax)

local testModule2 = {}

testModule2.bar = function()
    return 1
end

testModule2.preload = function()
    task.wait(math.random())
end

testModule2.load = function()
    
end

return astrax.module.new("testModule2", testModule2)

