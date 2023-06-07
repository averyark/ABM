--[[
    FileName    > parameterVisualpanel.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/04/2023
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local GroupService = game:GetService("GroupService")

local Packages = script.Parent.Parent.Parent.Parent
local Janitor = require(Packages.Janitor)
local class = require(script.Parent.Parent.Parent.class)
local things = require(script.Parent.Parent.Parent.things)
local Promise = require(Packages.Promise)
local makeUi = require(script.Parent.Parent.creator.parameterVisualPanel)

local folder

local module = {}
module.__index = module

local format = "%s <b>%s</b>: %s"
local enabled = false
local transparency = 0
local cache = {}

local color = {
	property = {
		backgroundColor = Color3.fromRGB(22, 14, 5),
		textColor = Color3.fromRGB(230, 205, 180),
	},
	attribute = {
		backgroundColor = Color3.fromRGB(5, 22, 20),
		textColor = Color3.fromRGB(180, 213, 230),
	},
	variable = {
		backgroundColor = Color3.fromRGB(22, 22, 22),
		textColor = Color3.fromRGB(230, 230, 230),
	},
}

function module.linkAttribute(self: module, adornee, attribute: string)
	local button = self.guiObjects.buttonTemplate:Clone()
	button.Text = format:format("attribute", attribute, things.typeStringTransform(adornee:GetAttribute(attribute)))
	button.Parent = self.guiObjects.container
	button.BackgroundColor3 = color.attribute.backgroundColor
	button.BorderColor3 = color.attribute.backgroundColor
	button.TextColor3 = color.attribute.textColor
	button.LayoutOrder = 1

	table.insert(
		self.cache.attribute,
		{ button = button, object = adornee, attribute = attribute, value = adornee:GetAttribute(attribute) }
	)
	self._maid:Add(button)
end

function module.linkProperty(self: module, adornee, property: string)
	local button = self.guiObjects.buttonTemplate:Clone()
	button.Text = format:format("property", property, things.typeStringTransform(adornee[property]))
	button.Parent = self.guiObjects.container
	button.BackgroundColor3 = color.property.backgroundColor
	button.BorderColor3 = color.property.backgroundColor
	button.TextColor3 = color.property.textColor
	button.LayoutOrder = 2

	table.insert(
		self.cache.property,
		{ button = button, object = adornee, property = property, value = adornee[property] }
	)
	self._maid:Add(button)
end

function module.linkVariable(self: module, identifier: string, value: any)
	local button = self.guiObjects.buttonTemplate:Clone()
	button.Text = format:format("variable", identifier, things.typeStringTransform(value))
	button.Parent = self.guiObjects.container
	button.BackgroundColor3 = color.variable.backgroundColor
	button.BorderColor3 = color.variable.backgroundColor
	button.TextColor3 = color.variable.textColor
	button.LayoutOrder = 3

	table.insert(self.cache.variable, { button = button, identifier = identifier, value = value })
	self._maid:Add(button)
end

function module.changeValue(self: module, identifier: string, value: any)
	for _, variable in pairs(self.cache.variable) do
		if variable.identifier == identifier then
			if variable.value == value then
				return
			end
			variable.button.Text = format:format("variable", identifier, things.typeStringTransform(value))
		end
	end
end

function module.linkMetatable(
	self: module,
	metatable: {
		props: { [any]: any },
		_debugModifiedFunctions: { module? },
		[any]: any?,
	},
	list: { [number]: any }?
)
	if not table.find(metatable._debugModifiedFunctions, self) then
		table.insert(metatable._debugModifiedFunctions, self)
		table.insert(self.refCache, metatable)
	end
	for key, value in pairs(metatable.props) do
		if list and not table.find(list, key) then
			continue
		end
		local button = self.guiObjects.buttonTemplate:Clone()
		button.Text = format:format("metaProperty", key, things.typeStringTransform(value))
		button.Parent = self.guiObjects.container
		button.BackgroundColor3 = color.property.backgroundColor
		button.BorderColor3 = color.property.backgroundColor
		button.TextColor3 = color.property.textColor
		button.LayoutOrder = 4

		table.insert(self.cache.metatable, { button = button, key = key, value = value })
		self._maid:Add(button)
	end
end

function module.__metatableUpdated(self: module, key, value)
	local info
	for _, v in pairs(self.cache.metatable) do
		if v.key == key then
			info = v
			break
		end
	end
	if not info then
		return
	end
	if value == info.value then
		return
	end
	info.button.Text = format:format("metaProperty", key, things.typeStringTransform(value))
end

function module.Destroy(self: module)
	self._maid:Destroy()
	for _, con in pairs(self.refCache) do
		pcall(function()
			if con._debugModifiedFunctions then
				local i = table.find(con._debugModifiedFunctions, self)
				if i then
					table.remove(con._debugModifiedFunctions, i)
				end
			end
		end)
	end
	table.remove(cache, table.find(cache, self))
end

function module.start(self: module)
	self.guiObjects.billboard.Adornee = self.adornee
	self.guiObjects.billboard.Parent = folder
end

module.new = function(adornee: BasePart | Model)
	local self = setmetatable({
		guiObjects = makeUi(),
		cache = {
			property = {},
			attribute = {},
			variable = {},
			metatable = {},
		},
		refCache = {},
		adornee = adornee,

		_maid = Janitor.new(),
	}, module)

	self:start()
	table.insert(cache, self)

	return self
end

type module = typeof(module.new())

if not things.settings.DebugEnabled then
	for _, object: typeof(module.new(Instance.new("Part"))) in pairs(cache) do
		object.container.Enabled = false
	end
end

return {
	new = module.new,
	start = function()
		local parameterVisualPanelFolder = Instance.new("Folder")
		parameterVisualPanelFolder.Name = "__debug__parameterVisualPanel"
		parameterVisualPanelFolder.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		parameterVisualPanelFolder.AncestryChanged:Connect(function()
			if parameterVisualPanelFolder.Parent ~= Players.LocalPlayer.PlayerGui then
				parameterVisualPanelFolder = Instance.new("Folder")
				parameterVisualPanelFolder.Name = "__debug__parameterVisualPanel"
				parameterVisualPanelFolder.Parent = Players.LocalPlayer.PlayerGui
				folder = parameterVisualPanelFolder
			end
		end)
		folder = parameterVisualPanelFolder
	end,
} :: {
	new: (adornee: BasePart | Model) -> typeof(module.new()),
}
