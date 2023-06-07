--!nonstrict
--[[
    FileName    > wind.luau
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 05/06/2023
--]]
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
local wind = {}

local gustCycleDelay = 5 -- Max duration between gust cycles in seconds
local gustCycleDuration = 5 -- Duration of each gust cycle in seconds

-- During each gust cycle, a portion of "gust" will be added to "baseWind" in a ramped fashion
local baseWind = Vector3.new(-4, 0, -4) -- Vector3 representing base wind speed and direction
local gust = Vector3.new(-8, 8, -8) -- Vector3 representing gust speed and direction
local gustIntervals = 100 -- Number of iterations used to calculate each gust interval
local dg = gustCycleDuration / gustIntervals
local dgf = dg / gustCycleDuration

wind.load = function()
	workspace.GlobalWind = baseWind -- Set globalWind to baseWind initially
	task.wait(gustCycleDelay) -- Wait delay amount before starting gusts

	task.spawn(function()
		while true do
			for i = 1, gustIntervals do
				local f = math.sin(math.pi * dgf * i) -- Use sin function to ramp gust
				workspace.GlobalWind = baseWind + f * gust -- Set GlobalWind to baseWind + gust
				task.wait(dg)
			end

			workspace.GlobalWind = baseWind -- Reset wind to base wind at end of gust cycle
			task.wait(math.random() * gustCycleDelay) -- Wait a random fraction of delay before next gust cycle
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local windmills = CollectionService:GetTagged("Windmill")
		local globalWind = workspace.GlobalWind
		local total = (globalWind.X + globalWind.Y + globalWind.Z) / 3

		for _, windmill in pairs(windmills) do
			local cf = windmill.CFrame :: CFrame
			windmill.CFrame = cf * cf:ToObjectSpace(cf * CFrame.Angles(0, 0, total / 2 * dt))
		end
	end)
end

return module.new("wind", wind)
