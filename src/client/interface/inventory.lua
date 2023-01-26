--!strict
--[[
    FileName    > inventory.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 11/01/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local BridgeNet = require(ReplicatedStorage.Packages.BridgeNet)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Matter = require(ReplicatedStorage.Packages.Matter)
local Astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local inventoryGui

local manifesting

local showInfo = function(pos)
    local inputUi = inventoryGui.input
    
    inputUi.Position = pos + UDim2.fromOffset(69 + 8, 0)
    inputUi.Visible = true
end

local itemClass = {}
itemClass.__index = itemClass

function itemClass:interact()
    showInfo(UDim2.fromOffset(self.manifest.AbsolutePosition.X, self.manifest.AbsolutePosition.Y))
    tween.instance(self.manifest.content, {
        Size = UDim2.fromScale(1.05, 1.05)
    }, .15, "Sine").Completed:Wait()
    if manifesting ~= self then
        tween.instance(self.manifest.content, {
            Size = UDim2.fromScale(1.1, 1.1)
        }, .15, "Expo")
    else
        tween.instance(self.manifest.content, {
            Size = UDim2.fromScale(1.2, 1.2)
        }, .15, "Expo")
    end
end

function itemClass:destroyAllTweens()
    for _, tweenObject in pairs(self.tweens) do
        tweenObject:Destroy()
    end
    table.clear(self.tweens)
end

function itemClass:hoverIn()
    self:destroyAllTweens()
    manifesting = self
    table.insert(self.tweens, tween.instance(self.manifest, {
        BackgroundColor3 = Color3.fromRGB(126, 99, 76)
    }, .15, "Smoother"))
    table.insert(self.tweens, tween.instance(self.manifest.content, {
        Size = UDim2.fromScale(1.2, 1.2)
    }, .15, "Smoother"))
    table.insert(self.tweens, tween.instance(self.manifest.stroke, {
        Color = Color3.fromRGB(126, 99, 76)
    }, .15, "Smoother"))
end

function itemClass:hoverOut()
    manifesting = nil
    table.insert(self.tweens, tween.instance(self.manifest, {
        BackgroundColor3 = Color3.fromRGB(63, 50, 38)
    }, .25, "Cubic"))
    table.insert(self.tweens, tween.instance(self.manifest.content, {
        Size = UDim2.fromScale(1.1, 1.1)
    }, .25, "Cubic"))
    table.insert(self.tweens, tween.instance(self.manifest.stroke, {
        Color = Color3.fromRGB(63, 50, 38)
    }, .25, "Cubic"))

end

function itemClass:render()
    self.manifest = ReplicatedStorage.resources.inventoryItemTemplate:Clone()

    self._maid:Add(self.manifest.Activated:Connect(function()
        self:interact()
    end))
    self._maid:Add(self.manifest.MouseEnter:Connect(function()
        if manifesting and manifesting ~= self then
            manifesting:hoverOut()
        end
        self:hoverIn()
    end))
    self._maid:Add(self.manifest.MouseLeave:Connect(function()
        self:hoverOut()
    end))

    self.manifest.Parent = inventoryGui.mainframe.lower[self.itemType]
    self:hoverOut()
    self._maid:Add(self.manifest)
end

local itemObject = objects.new(itemClass, {})

local new = function(itemType, itemId, itemData)
    return itemObject:new {
        itemType = itemType,
        itemId = itemId,
        itemData = itemData,

        tweens = {}
    }
end

local buttonColorCache = {}
local buttonValueIncrement = 0.4

local selectedPage

local selectPage = function(pageName)
    local pageContainer = inventoryGui.mainframe.lower
    local buttons = inventoryGui.mainframe.buttons

	if selectedPage then
		local button = selectedPage.button

        selectedPage.page.Visible = false

		if t.instanceIsA("GuiButton")(button) then
			tween.instance(button.innerOutline.stroke, {
				Color = buttonColorCache[button].defaultColor,
			}, 0.2)
			tween.instance(button.icon, {
				Size = UDim2.fromOffset(32, 32),
			}, 0.2)
		end
	end
	local pageInstance = pageContainer:FindFirstChild(pageName)
	local button = buttons:FindFirstChild(pageName)

	debugger.assert(t.instanceIsA("GuiObject")(pageInstance))
	debugger.assert(t.instanceIsA("GuiButton")(button))

    pageInstance.Visible = true

	tween.instance(button.innerOutline.stroke, {
		Color = buttonColorCache[button].hoveredColor,
	}, 0.3)
	tween.instance(button.icon, {
		Size = UDim2.fromOffset(32, 32),
	}, 0.15).Completed:Wait()
	tween.instance(button.icon, {
		Size = UDim2.fromOffset(38, 38),
	}, 0.2)

	selectedPage = { page = pageInstance, button = button }
end

return {
    load = function()
        inventoryGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("inventory")

        for _, object in pairs(inventoryGui.mainframe.lower:GetChildren()) do
            if object:IsA("GuiObject") then
                for _, b in pairs(object:GetChildren()) do
                    if b:IsA("GuiObject") then
                        b:Destroy()
                    end
                end
            end
        end

        for _, button in pairs(inventoryGui.mainframe.buttons:GetChildren()) do
            if button:IsA("GuiButton") then
                if not buttonColorCache[button] then
                    local defaultColor = button.innerOutline.stroke.Color
                    local h, s, v = defaultColor:ToHSV()
                    local color = Color3.fromHSV(h, s, v + buttonValueIncrement)
    
                    buttonColorCache[button] = { defaultColor = defaultColor, hoveredColor = color }
                end
                button.Activated:Connect(function()
                    selectPage(button.Name)
                end)
                button.MouseEnter:Connect(function()
                    tween.instance(button.innerOutline.stroke, {
                        Color = buttonColorCache[button].hoveredColor,
                    }, 0.3)
                    tween.instance(button.icon, {
                        Size = UDim2.fromOffset(38, 38),
                    }, 0.2)
                end)
                button.MouseLeave:Connect(function()
                    if selectedPage and selectedPage.button == button then
                        return
                    end
                    tween.instance(button.innerOutline.stroke, {
                        Color = buttonColorCache[button].defaultColor,
                    }, 0.2)
                    tween.instance(button.icon, {
                        Size = UDim2.fromOffset(32, 32),
                    }, 0.2)
                end)
            end
        end
        selectPage("Sword")

        for i = 10, 1, -1 do
            new("Sword", 1, {
                equipped = false
            }):render()
        end
    end
}