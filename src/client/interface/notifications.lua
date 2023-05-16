--!strict
--[[
    FileName    > notifications.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 24/01/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

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
local weapons = require(ReplicatedStorage.shared.weapons)
local rarities = require(ReplicatedStorage.shared.rarities)

local settings = require(script.Parent.Parent.interface.settings)

local bridges = {
	notifError = BridgeNet.CreateBridge("notifError"),
	notifMessage = BridgeNet.CreateBridge("notifMessage"),
	itemObtained = BridgeNet.CreateBridge("itemObtained"),
}

local findItem = function(id, items): typeof(weapons["Katana"])
	for _, data in pairs(weapons) do
		if data.id == tonumber(id) then
			return data
		end
	end
end

local notifObjects = {}
local notifClass = {}
notifClass.__index = notifClass

function notifClass:Destroy()
	table.remove(notifObjects, table.find(notifObjects, self))

	if not self.ui then return self._maid:Destroy() end
	if self.type == "itemObtained" then
		tween.instance(self.ui, {
			Position = UDim2.new(.5, 0, 1, 0)
		}, .2, "ExitExpressive").Completed:Wait()
	elseif self.type == "message" then
		tween.instance(self.ui, {
			TextTransparency = 1
		}, .2)
		tween.instance(self.ui.stroke, {
			Transparency = 1
		}, .2).Completed:Wait()
	end
	self.ui.Visible = false
	self._maid:Destroy()
end

function notifClass:itemObtained(itemType: string, itemId: number, percentage: number)
	if not playerDataHandler.getPlayer().data.settings[5] then
		return self:Destroy()
	end
	if self.type then
		debugger.error("Notification type already set")
	end
	settings.playSound(SoundService.itemObtained)
	self.type = "itemObtained"
	local itemData = findItem(itemId, if itemType == "weapon" then weapons else nil)
	local rarityData = rarities[itemData.rarity]

	local ui = ReplicatedStorage.resources.itemObtained:Clone()
	self.ui = ui
	self._maid:Add(ui)

	ui.Name = "itemObtained-" .. itemId
	ui.Parent = Players.LocalPlayer.PlayerGui.hud.itemObtainedContainer
	
	ui.itemName.Text = itemData.name
	ui.Image = itemData.iconId

	ui.ImageColor3 = Color3.fromRGB(0, 0, 0)
	ui.shine.ImageColor3 = Color3.fromRGB(0, 0, 0)
	ui.percentage.TextTransparency = 1
	ui.percentage.stroke.Transparency = 1
	ui.itemName.TextTransparency = 1
	ui.itemName.stroke.Transparency = 1

	if percentage == 1 then
		ui.percentage.Visible = false
	else
		ui.percentage.Visible = true
	end

	ui.percentage.Text = `{math.round(percentage*100000)/1000}%`
	ui.Position = UDim2.new(.5, 0, 1, 0)
	ui.Visible = true

	tween.instance(ui, {
		Position = UDim2.new(.5, 0, 0, 20)
	}, .2, "EntranceExpressive").Completed:Wait()
	task.wait(1)
	tween.instance(ui, {
		ImageColor3 = Color3.fromRGB(255, 255, 255)
	}, .2, "EntranceExpressive")
	tween.instance(ui.shine, {
		ImageColor3 = Color3.fromRGB(255, 255, 255)
	}, .2, "EntranceExpressive").Completed:Wait()
	tween.instance(ui.itemName, {
		TextTransparency = 0
	}, .2, "EntranceExpressive")
	tween.instance(ui.itemName.stroke, {
		Transparency = 0
	}, .2, "EntranceExpressive")

	tween.instance(ui.percentage, {
		TextTransparency = 0
	}, .2, "EntranceExpressive")
	tween.instance(ui.percentage.stroke, {
		Transparency = 0
	}, .2, "EntranceExpressive")

	self.renderClock = os.clock()
	self.rendered = true
end

function notifClass:message(message: string, color: Color3?)
	if self.type then
		debugger.error("Notification type already set")
	end
	self.type = "message"
	local ui = ReplicatedStorage.resources.message:Clone()
	self.ui = ui
	self._maid:Add(ui)

	ui.Name = "message-" .. message
	ui.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	ui.Text = message
	ui.TextTransparency = 1
	ui.stroke.Transparency = 1
	ui.Parent = Players.LocalPlayer.PlayerGui.notification

	tween.instance(ui, {
		TextTransparency = 0
	}, .2)
	tween.instance(ui.stroke, {
		Transparency = 0.3
	}, .2)

	self.renderClock = os.clock()
	self.rendered = true
end

function notifClass:error(message: string)
	if self.type then
		debugger.error("Notification type already set")
	end
	self.type = "message"
	local ui = ReplicatedStorage.resources.message:Clone()
	self.ui = ui
	self._maid:Add(ui)

	ui.Name = "message-" .. message
	ui.TextColor3 = Color3.fromRGB(255, 50, 50)
	ui.Text = message
	ui.TextTransparency = 1
	ui.stroke.Transparency = 1
	
	ui.Parent = Players.LocalPlayer.PlayerGui.notification

	settings.playSound(SoundService["error"])

	tween.instance(ui, {
		TextTransparency = 0
	}, .2)
	tween.instance(ui.stroke, {
		Transparency = 0.3
	}, .2)

	self.renderClock = os.clock()
	self.rendered = true
end

local notifObject = objects.new(notifClass, {})

local new = function()
	local object = notifObject:new({
		rendered = false,
		type = nil,
	})

	table.insert(notifObjects, object)

	return object
end


return {
	new = new,
	load = function()
		--[[playerDataHandler:connect({ "inventory", "weapon" }, function(change)
			local obtained = playerDataHandler:findChanges(change)
			if not obtained then
				return
			end
			for _, dat in pairs(obtained.added) do
				--id = tonumber(id)
				local id = dat.id

				settings.playSound(ReplicatedStorage.resources.ui_sound_effects["Item Notification"])
				new():itemObtained(id, "weapon", )
			end
		end)]]

		bridges.itemObtained:Connect(function(id: number, type: "weapon" | "hero", percentage: number)
			print(id, type, percentage)
			Promise.try(function()
				new():itemObtained(id, type, percentage)
			end)
		end)
		bridges.notifError:Connect(function(message)
			new():error(message)
		end)
		bridges.notifMessage:Connect(function(message, color)
			new():message(message, color)
		end)

		RunService.Heartbeat:Connect(function(deltaTime)
			local now = os.clock()
			for _, self in pairs(notifObjects) do
				if self.ui and self.type == "itemObtained" and self.ui:FindFirstChild("shine") then
					self.ui.shine.Rotation += 30 * deltaTime
				end
				if self.renderClock and now - self.renderClock > 5 then
					self:Destroy()
				end
			end
		end)
	end,
}
