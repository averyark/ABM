--[[
    FileName    > objectListPanel.lua
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

local net = Red.Client("__class")

local ui = require(creator.objectListPanel)()

local color = {
	textColor = Color3.fromRGB(230, 200, 180),
	backgroundColor = Color3.fromRGB(25, 22, 20),
}

local cache = {}

local registerObject = function(self)
	local entry = ui.entryTemplate:Clone()
	entry.Text = `view object <object: {self.class.identifier}>({self._id})`
	entry.TextColor3 = color.textColor
	entry.BackgroundColor3 = color.backgroundColor
	entry.BorderColor3 = color.backgroundColor
	entry.Parent = ui.container
	entry.Activated:Connect(function()
		objectVisualPanel.new(self)
	end)
	cache[self] = entry
end

return {
	start = function()
		if not things.settings.DebugEnabled then
			ui.main.Enabled = false
			return
		end
		if not things.isPlayerWhitelisted(Players.LocalPlayer) then
			ui.main.Enabled = false
			return
		end
		class.onObjectAdded:Connect(function(self)
			registerObject(self)
		end)
		class.onObjectDestroyed:Connect(function(self)
			if cache[self] then
				cache[self]:Destroy()
				cache[self] = nil
			end
		end)

		for _, self in pairs(class.objects) do
			Promise.try(registerObject, self)
		end

		net:On("serverObjectCreated", function(metatable)
			registerObject(metatable)
		end)
		net:On("serverObjectDestroyed", function(metatable)
			for self, entry in pairs(cache) do
				if self.identifier == metatable.identifier and self._id == metatable._id then
					entry:Destroy()
					cache[self] = nil
				end
			end
		end)
		net:Call("getServerObjects"):Then(function(metatables)
			for _, metatable in pairs(metatables) do
				registerObject(metatable)
			end
		end)

		ui.scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
			ui.scroll.CanvasPosition = ui.scroll.AbsoluteCanvasSize - ui.scroll.AbsoluteWindowSize
		end)
		ui.scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
			ui.scroll.CanvasPosition = ui.scroll.AbsoluteCanvasSize - ui.scroll.AbsoluteWindowSize
		end)
	end,
}
