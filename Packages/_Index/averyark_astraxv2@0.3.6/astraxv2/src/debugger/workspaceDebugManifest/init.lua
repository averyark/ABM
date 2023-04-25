local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService")

local index = require(script.Parent.Parent.index)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

local ui = require(script.ui)
local objects = require(index.objects)

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
    }
}

local commaFormat = function(number: number)
	local i, j, n, int, dec = tostring(number):find("([-]?)(%d+)([.]?%d*)")
	int = string.gsub(string.reverse(int), "(%d%d%d)", "%1,")
	return n .. string.gsub(string.reverse(int), "^,", "") .. dec
end

local typeStringTransform; typeStringTransform = function(value: any, cache, str)
    local valueType = typeof(value)

    local numberTransformation = function(number)
        local rounded = math.round(number*10000)/10000
        if math.abs(rounded) == 0 then
            return 0
        end
        return if rounded > 999 then commaFormat(rounded) else tostring(rounded)
    end

    if valueType == "table" then
        cache = cache or {}
        if table.find(cache, value) then
            return
        end
        table.insert(cache, value)
        for k, v in pairs(value) do
            if typeof(v) == "table" then
                if table.find(cache, v) then
                    str = if not str then
                        "{" .. `{k} = [RECURSIVE_TABLE_REFERENCE]()`
                    else  `{str}, {k} = [RECURSIVE_TABLE_REFERENCE](}`

                    continue
                end
                table.insert(cache, v)
            end
            str = if not str then
                    "{" .. `{k} = {typeStringTransform(v)}`
                else  `{str}, {k} = {typeStringTransform(v)}`
        end
        if not str then
            str = "{}"
        else
            str = str .. "}"
        end
        return str
    elseif valueType == "string" then
        return `"{value}"`
    elseif valueType == "number" then
        return numberTransformation(value)
    elseif valueType == "Vector3" then
        local x, y, z = value.X, value.Y, value.Z
        return `Vector3({numberTransformation(x)}, {numberTransformation(y)}, {numberTransformation(z)})`
    end
    return tostring(value)
end

local format = "%s <b>%s</b>: %s"
local disabled = false
local transparency = 0

local cache = {}
local workspaceDebugManifestMeta = {}
workspaceDebugManifestMeta.__index = workspaceDebugManifestMeta

function workspaceDebugManifestMeta:linkAttribute(object: Instance, attribute: string)
    local button = ui.makeButton()
    button.Text = format:format("attribute", attribute, typeStringTransform(object:GetAttribute(attribute)))
    button.Parent = self.container.container
    button.BackgroundColor3 = color.attribute.backgroundColor
    button.BorderColor3 = color.attribute.backgroundColor
    button.TextColor3 = color.attribute.textColor
    button.LayoutOrder = 1

    table.insert(self.cache.attribute, {button = button, object = object, attribute = attribute, value = object:GetAttribute(attribute)})
    self._maid:Add(button)
end

function workspaceDebugManifestMeta:linkProperty(object: Instance, property: string)
    local button = ui.makeButton()
    button.Text = format:format("property", property, typeStringTransform(object[property]))
    button.Parent = self.container.container
    button.BackgroundColor3 = color.property.backgroundColor
    button.BorderColor3 = color.property.backgroundColor
    button.TextColor3 = color.property.textColor
    button.LayoutOrder = 2

    table.insert(self.cache.property, {button = button, object = object, property = property, value = object[property]})
    self._maid:Add(button)
end

function workspaceDebugManifestMeta:linkVariable(identifier: string, value: any)
    local button = ui.makeButton()
    button.Text = format:format("variable", identifier, typeStringTransform(value))
    button.Parent = self.container.container
    button.BackgroundColor3 = color.variable.backgroundColor
    button.BorderColor3 = color.variable.backgroundColor
    button.TextColor3 = color.variable.textColor
    button.LayoutOrder = 3

    table.insert(self.cache.variable, {button = button, identifier = identifier, value = value})
    self._maid:Add(button)
end

function workspaceDebugManifestMeta:changeValue(identifier: string, value: any)
    for _, variable in pairs(self.cache.variable) do
        if variable.identifier == identifier then
            if variable.value == value then
               return
            end
            variable.button.Text = format:format("variable", identifier, typeStringTransform(value))
        end
    end
end

function workspaceDebugManifestMeta:linkMetatable(metatable: {[any]: any?}, list: {[number]: any}?)
    if not table.find(metatable._debugFunctions, self) then
        table.insert(metatable._debugFunctions, self)
    end
    for key, value in pairs(metatable._meta.newindexCache) do
        if list and not table.find(list, key) then continue end
        local button = ui.makeButton()
        button.Text = format:format("metaProperty", key, typeStringTransform(value))
        button.Parent = self.container.container
        button.BackgroundColor3 = color.property.backgroundColor
        button.BorderColor3 = color.property.backgroundColor
        button.TextColor3 = color.property.textColor
        button.LayoutOrder = 4
    
        table.insert(self.cache.metatable, {button = button, key = key, value = value})
        self._maid:Add(button)
    end
end

function workspaceDebugManifestMeta.__metatableUpdated(self, key, value)
    local info
    for _, v in pairs(self.cache.metatable) do
        if v.key == key then
            info = v
            break
        end
    end
    if not info then return end
    if value == info.value then
        return
    end
    info.button.Text = format:format("metaProperty", key, typeStringTransform(value))
end

function workspaceDebugManifestMeta:Destroy()
    self._maid:Destroy()
    table.remove(cache, table.find(cache, self))
end

local class = objects.new(workspaceDebugManifestMeta, {})

local new = function(adornee: BasePart | Model)
    local tbl = {
        adornee = adornee,
        container = ui.valueManifestUi:Clone(),
        cache = {
            property = {},
            attribute = {},
            variable = {},
            metatable = {}
        },
    }
    local self = class:new(tbl)
    self.container.Parent = ui.folder
    self.container.Adornee = self.adornee
    self._maid:Add(adornee.AncestryChanged:Connect(function()
        if not adornee:IsDescendantOf(game) then
            self:Destroy()
        end
    end))

    if disabled or not index.debugSettings.debugEnabled then
        self.container.Enabled = false
    else
        self.container.Enabled = true
    end

    table.insert(cache, self)
    return self :: typeof(setmetatable(tbl, workspaceDebugManifestMeta))
end

RunService.Heartbeat:Connect(function(deltaTime)
    if not index.debugSettings.debugEnabled then return end
    if disabled then return end
    for _, object in pairs(cache) do
        for _, property in pairs(object.cache.property) do
            local newValue = property.object[property.property]
            if newValue == property.value then
                continue
            end
            property.button.Text = format:format("property", property.property, typeStringTransform(newValue))
        end
        for _, attribute in pairs(object.cache.attribute) do
            local newValue = attribute.object:GetAttribute(attribute.attribute)
            if newValue == attribute.value then
                continue
            end
            attribute.button.Text = format:format("attribute", attribute.attribute, typeStringTransform(newValue))
        end
    end
end)

if not index.debugSettings.debugEnabled then
    for _, object: typeof(new(Instance.new("Part"))) in pairs(cache) do
        object.container.Enabled = false
    end
end

return {
    disable = function()
        disabled = true
        for _, object: typeof(new(Instance.new("Part"))) in pairs(cache) do
            object.container.Enabled = false
        end
    end,
    enable = function()
        disabled = false
        for _, object: typeof(new(Instance.new("Part"))) in pairs(cache) do
            object.container.Enabled = true
        end
    end,
    gEnable = function(state)
        if disabled then return end
        if state then
            for _, object: typeof(new(Instance.new("Part"))) in pairs(cache) do
                object.container.Enabled = true
            end
        else
            for _, object: typeof(new(Instance.new("Part"))) in pairs(cache) do
                object.container.Enabled = false
            end
        end
    end,
    setTransparency = function(value)
        transparency = value
        for _, object: typeof(new(Instance.new("Part"))) in pairs(cache) do
            for _, button: TextButton in pairs(object.container.container:GetChildren()) do
                if button:IsA("TextButton") then
                    button.TextTransparency = math.clamp(transparency, 0, 1)
                    button.BackgroundTransparency = math.clamp(transparency+0.15, 0, 1)
                end
            end
        end
    end,
    new = new
}