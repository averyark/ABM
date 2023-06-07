--!strict
--[[
    FileName    > testModule.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 01/06/2023
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local astrax = require(ReplicatedStorage.Packages.Astrax)

local testModule = {}

testModule.foo = function()
    return ""
end

testModule.load = function()
    local testModule2 = require(script.Parent.testModule2)
    --print(testModule2.bar())
    
end

return astrax.module.new("testModule", testModule)

