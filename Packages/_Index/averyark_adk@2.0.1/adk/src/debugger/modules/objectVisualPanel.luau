--[[
    FileName    > objectVisualPanel.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/04/2023
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local GroupService = game:GetService("GroupService")

local creator = script.Parent.Parent.creator
local Packages = script.Parent.Parent.Parent.Parent
local things = require(script.Parent.Parent.Parent.things)
local Promise = require(Packages.Promise)
local Red = require(Packages.Red)
local makeUi = require(creator.objectVisualPanel)
local class = require(script.Parent.Parent.Parent.class)

local module = {}
module.__index = module

local com = if RunService:IsClient() then Red.Client("__class") else nil

local enabled = true
local current

local colors = {
	[1] = {
		textColor = Color3.fromRGB(230, 60, 60),
		backgroundColor = Color3.fromRGB(25, 7, 7),
	},
	[2] = {
		textColor = Color3.fromRGB(230, 130, 80),
		backgroundColor = Color3.fromRGB(25, 14, 9),
	},
	[3] = {
		textColor = Color3.fromRGB(180, 218, 230),
		backgroundColor = Color3.fromRGB(20, 24, 25),
	},
	[4] = {
		textColor = Color3.fromRGB(230, 200, 180),
		backgroundColor = Color3.fromRGB(25, 22, 20),
	},
}

function module.display(self: module, type: ("log" | "prop"))
	self.type = type
	for _, ins in pairs(self.guiObjects.container:GetChildren()) do
		if ins:IsA("TextButton") then
			ins:Destroy()
		end
	end

	local addText = function(txt: string, clr: number)
		local entry = self.guiObjects.entryTemplate:Clone()
		local clrData = colors[clr]
		entry.TextColor3 = clrData.textColor
		entry.BackgroundColor3 = clrData.backgroundColor
		entry.BorderColor3 = clrData.backgroundColor
		entry.Text = txt
		entry.Parent = self.guiObjects.container
		return entry
	end

	local endSession = addText(`End object visual panel session`, 3)
	endSession.LayoutOrder = 1

	local update = addText(`Update Session`, 3)
	update.LayoutOrder = 1

	table.insert(
		self._connections,
		endSession.Activated:Connect(function()
			self:Destroy()
		end)
	)

	table.insert(
		self._connections,
		update.Activated:Connect(function()
			if self.object._isServerObject then
				local object = com:Call("getServerObject", self.object.identifier, self.object._id)
					:Then(function(object)
						if object then
							self:Destroy()
							module.new(object):display(type)
						end
					end)
			else
				print(self.object)
				self:Destroy()
				module.new(self.object):display(type)
			end
		end)
	)

	if type == "log" then
		addText(`Viewing object: <object: {self.object.class.identifier}>({self.object._id}). Viewing log.`, 3).LayoutOrder =
			-1
		table.insert(
			self._connections,
			addText(`Show object properties and meta`, 3).Activated:Connect(function()
				self:display("prop")
			end)
		)

		local find = function(id)
			for key, index in pairs(things.symbols.debugClassType) do
				if index == id then
					return key
				end
			end
			return
		end

		for _, log in pairs(self.object._log) do
			if log.type == 1 then
				local transformedValue = things.typeStringTransform(log.collection.value)
				local transformedKey = things.typeStringTransform(log.collection.key)
				addText(
					`read <b>{transformedKey}</b>: {transformedValue} - {log.timestamp:FormatLocalTime("H:mm:ss.SSS", "en-us")}\n{log.uptrace}`,
					4
				).LayoutOrder =
					2
			elseif log.type == 2 then
				local transformedValueOld = things.typeStringTransform(log.collection.value.old)
				local transformedValueNew = things.typeStringTransform(log.collection.value.new)
				local transformedKey = things.typeStringTransform(log.collection.key)
				addText(
					`modified <b>{transformedKey}</b>: {transformedValueOld} > {transformedValueNew} - {log.timestamp:FormatLocalTime("H:mm:ss.SSS", "en-us")}\n{log.uptrace}`,
					4
				).LayoutOrder =
					2
			elseif log.type == 3 then
				local transformedValue = things.typeStringTransform(log.collection.value)
				local transformedKey = things.typeStringTransform(log.collection.key)
				addText(
					`append <b>{transformedKey}</b>: {transformedValue} - {log.timestamp:FormatLocalTime("H:mm:ss.SSS", "en-us")}`,
					4
				).LayoutOrder =
					2
			elseif log.type == 4 then
				addText(`operation <b>init</b> - {log.timestamp:FormatLocalTime("H:mm:ss.SSS", "en-us")}`, 4).LayoutOrder =
					2
			elseif log.type == 5 then
				addText(
					`operation <b>destory</b> - {log.timestamp:FormatLocalTime("H:mm:ss.SSS", "en-us")}\n{log.uptrace}`,
					4
				).LayoutOrder =
					2
			end
		end
	elseif type == "prop" then
		addText(
			`Viewing object: <object: {self.object.class.identifier}>({self.object._id}). Viewing properties and meta.`,
			3
		).LayoutOrder =
			-1
		table.insert(
			self._connections,
			addText(`Show object op log`, 3).Activated:Connect(function()
				self:display("log")
			end)
		)

		for key, value in pairs(self.object.props) do
			local transformedValue = things.typeStringTransform(value)
			local transformedKey = things.typeStringTransform(key)

			addText(`property <b>{transformedKey}</b>: {transformedValue}`, 4).LayoutOrder = 2
		end
		for key, value in pairs(self.object.class) do
			local transformedValue = things.typeStringTransform(value)
			local transformedKey = things.typeStringTransform(key)

			addText(`metaProperty <b>{transformedKey}</b>: {transformedValue}`, 4).LayoutOrder = 4
		end
		for key, value in pairs(self.object) do
			local transformedValue = things.typeStringTransform(value)
			local transformedKey = things.typeStringTransform(key)

			addText(`raw <b>{transformedKey}</b>: {transformedValue}`, 4).LayoutOrder = 5
		end
		if self.object.methods then
			for key, value in pairs(self.object.methods) do
				local transformedValue = things.typeStringTransform(value)
				local transformedKey = things.typeStringTransform(key)

				addText(`methods <b>{transformedKey}</b>: {transformedValue}`, 4).LayoutOrder = 3
			end
		end
	end
end

function module.start(self: module, type)
	self.guiObjects.main.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.guiObjects.main.Enabled = enabled

	for _, ins in pairs(self.guiObjects.container:GetChildren()) do
		if ins:IsA("TextButton") then
			ins:Destroy()
		end
	end

	self:display(type)
end

function module.Destroy(self: module)
	self.guiObjects.main:Destroy()
	for _, connection in pairs(self._connections) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end
end

function module.new(object)
	local self = setmetatable({
		guiObjects = makeUi(),

		object = object,

		_connections = {},
	}, module)

	local typeCache
	if current then
		typeCache = current.type
		current:Destroy()
	end

	current = self
	self:start(typeCache or "prop")

	return self
end

type module = typeof(module.new())

return {
	new = module.new,
}
