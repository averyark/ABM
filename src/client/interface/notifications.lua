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
			Size = UDim2.fromOffset(0, 96),
		}, 0.3, "Expo").Completed:Wait()
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

function notifClass:itemObtained(itemId: number, itemType: string, newlyObtained: boolean)
	if not playerDataHandler.getPlayer().data.settings[5] then
		return self:Destroy()
	end
	if self.type then
		debugger.error("Notification type already set")
	end
	self.type = "itemObtained"
	local itemData = findItem(itemId, if itemType == "weapon" then weapons else nil)
	local rarityData = rarities[itemData.rarity]

	local ui = ReplicatedStorage.resources.itemObtained:Clone()
	self.ui = ui
	self._maid:Add(ui)

	ui.Name = "itemObtained-" .. itemId
	ui.inner.stroke.Color = rarityData.primaryColor
	ui.info.rarity.TextColor3 = rarityData.primaryColor
	ui.info.rarity.Text = rarityData.name
	ui.info.itemName.Text = itemData.name
	ui.icon.Image = itemData.iconId

	if newlyObtained then
		ui.info.footer.Text = "= Newly Obtained ="
	else
		ui.info.footer.Visible = false
	end

	ui.Size = UDim2.fromOffset(96, 96)
	ui.Parent = Players.LocalPlayer.PlayerGui.notification

	tween.instance(ui, {
		Size = UDim2.fromOffset(400, 96),
	}, 0.3, "Expo")

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
		playerDataHandler:connect({ "inventory", "weapon" }, function(change)
			local obtained = playerDataHandler:findChanges(change)
			if not obtained then
				return
			end
			for _, dat in pairs(obtained.added) do
				--id = tonumber(id)
				local id = dat.id
				local newlyObtained = true
				local occurance = 0
				for _, index in pairs(playerDataHandler:getPlayer().data.stats.obtainedItemIndex.weapon) do
					if index == id then
						if occurance > 0 then
							newlyObtained = false
							break
						end
						occurance += 1
					end
				end
				settings.playSound(ReplicatedStorage.resources.ui_sound_effects["Item Notification"])
				new():itemObtained(id, "weapon", newlyObtained)
			end
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
				if self.renderClock and now - self.renderClock > 5 then
					self:Destroy()
				end
			end
		end)
	end,
}
