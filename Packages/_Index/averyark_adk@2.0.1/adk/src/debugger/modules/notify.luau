--[[
    FileName    > notify.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/05/2023
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = script.Parent.Parent.Parent.Parent
local creator = script.Parent.Parent.creator
local things = require(script.Parent.Parent.Parent.things)
local Promise = require(Packages.Promise)
local Red = require(Packages.Red)
local class = require(script.Parent.Parent.Parent.class)
local objectVisualPanel = require(script.Parent.objectVisualPanel)
local tween = require(script.Parent.Parent.Parent.tween)

local net = Red.Client("__class")

local ui = require(creator.notificationPanel)()

local notify = {}

local notificationTypes = {
	[1] = "rbxassetid://13608728321",
	[2] = "rbxassetid://13608063696",
	[3] = "rbxassetid://13608597943",
	[4] = "rbxassetid://13608600232",
}

function notify.new(type: number, title: string, message: string, duration: number?)
	assert(notificationTypes[type], "error: invalid notificationType")
	local entry = ui.entry:Clone()

	local isDiscarded = false

	local discardEntry = function()
		if isDiscarded then
			return
		end
		isDiscarded = true
		tween.instance(entry.content, {
			Position = UDim2.new(1, 10, 0, 0),
		}, 0.15, "Back", "Out")
	end

	entry.content.title.Text = title
	entry.content.desc.Text = message
	entry.content.icon.Image = notificationTypes[type]
	entry.content.Position = UDim2.new(1, 10, 0, 0)
	entry.Parent = ui.group
	entry.content.Active = true
	entry.content.Activated:Connect(function()
		discardEntry()
	end)

	tween.instance(entry.content, {
		Position = UDim2.new(),
	}, 0.15, "Back", "Out")

	if duration then
		task.delay(duration, function()
			discardEntry()
		end)
	end
end

function notify.start()
	ui.panel.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

return notify
