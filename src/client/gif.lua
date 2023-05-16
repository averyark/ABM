--!strict
--[[
    FileName    > gif.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 27/04/2023
--]]
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Astrax = require(ReplicatedStorage.Packages.Astrax)

local objects = require(Astrax.objects)

local imageLabel = Instance.new("ImageLabel")
imageLabel.BackgroundTransparency = 1
imageLabel.Name = "__gif_SpriteSheet"

local gifs: {gif?} = {}

local class = {} :: gif
class.__index = class

function class:Destroy()
    local position = table.find(gifs, self)
    if position then
        table.remove(gifs, position)
    end
    self.isPlaying = false
    self._maid:Destroy()
end

function class:addContainer(container: GuiObject)
    if self._buffer[container] then
        return
    end

    if not self.isLoaded then
        warn("not loaded yet")
        local timeoutClock = os.clock() + 5
        repeat
            task.wait()
        until self.isLoaded or os.clock() > timeoutClock
        warn("give up")
        if not self.isLoaded then
            return
        end
    end

    local _imageLabel = imageLabel:Clone()
    if self.isPlaying then
        _imageLabel.Position = self._slices[self._at][self._frame]
        _imageLabel.Image = self._sheets[self._at].image
    end
    _imageLabel.ZIndex = container.ZIndex
    _imageLabel.Parent = container

    self._maid:Add(_imageLabel)

    container.ClipsDescendants = true

    self._buffer[container] = _imageLabel
end

function class:removeContainer(container: GuiObject)
    self._buffer[container] = nil
end

function class:play()
    self.isPlaying = true
    table.insert(gifs, self)
end

function class:stop()
    self.isPlaying = false
    table.remove(gifs, table.find(gifs, self))
end

function class:_calculateSlices()
    for index, sheet in pairs(self._sheets) do
        self._slices[index] = {}
        for row = 0, sheet.rows-1 do
            for column = 0, sheet.columns-1 do
                table.insert(self._slices[index], UDim2.new(-column, 0, -row, 0))
                if #self._slices[index] == sheet.frames then break end
            end
        end
    end
end

function class:_step()
    local sheet = self._sheets[self._at]
    local slices = self._slices[self._at]
    
    if self._frame >= #slices then
        self._frame = 0
        if self._at >= #self._sheets then
            self._at = 0
        end
        self._at += 1
        slices = self._slices[self._at]
        sheet = self._sheets[self._at]
    end
    self._frame += 1
    self._nextFrame = os.clock() + self._frameRate

    for container, _imageLabel in pairs(self._buffer) do
        if not container.Visible then continue end
        _imageLabel.Image = sheet.image
        _imageLabel.Size = UDim2.fromScale(sheet.columns, sheet.rows)
        _imageLabel.Position = slices[self._frame]
    end
end

local constructor = objects.new(class, {})

local construct = function(spriteSheets: {{image: string, frames: number, columns: number}}, frameRate: number)
    local meta = {
        _sheets = spriteSheets,
        _slices = {},
        _frame = 1,
        _at = 1,
        _buffer = {},
        _nextFrame = 0,
        _frameRate = 1/frameRate,

        isPlaying = true,
        isLoaded = false,
    }
    local self = constructor:new(meta)

    for _, sheet in pairs(meta._sheets) do
        task.spawn(function()
            ContentProvider:PreloadAsync({sheet.image})
        end)
        sheet.rows = math.ceil(sheet.frames/sheet.columns)
    end

    self:_calculateSlices()
    self.isLoaded = true

    return self :: typeof(self) & typeof(class) & typeof(meta)
end

type gif = typeof(construct({{image="",frames=24,columns=1}}, 24))

RunService.RenderStepped:Connect(function(deltaTime)
    local clock = os.clock()
    for _, object in pairs(gifs) do
        task.spawn(function()
            if not object.isPlaying then return end
            if clock >= object._nextFrame then
                object:_step()
            end
        end)
    end
end)

return {
    new  = construct,
}