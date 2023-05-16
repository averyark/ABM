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
local abilities = require(ReplicatedStorage.shared.abilities)
local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local weapons = require(ReplicatedStorage.shared.weapons)
local rarities = require(ReplicatedStorage.shared.rarities)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)
local heros = require(ReplicatedStorage.shared.heros)
local notifications = require(script.Parent.notifications)
local passHandler = require(script.Parent.Parent.passHandler)
local main = require(script.Parent.main)


local bridges = {
	equipWeapon = BridgeNet.CreateBridge("equipWeapon"),
	equipHero = BridgeNet.CreateBridge("equipHero"),
	unequipHero = BridgeNet.CreateBridge("unequipHero"),
	upgradeWeapon = BridgeNet.CreateBridge("upgradeWeapon"),
	trashWeapon = BridgeNet.CreateBridge("trashWeapon"),
	trashHero = BridgeNet.CreateBridge("trashHero"),
	equipSecondaryWeapon = BridgeNet.CreateBridge("equipSecondaryWeapon"),
	unequipSecondaryWeapon = BridgeNet.CreateBridge("unequipSecondaryWeapon"),
	bulkTrashItem = BridgeNet.CreateBridge("bulkTrashItem"),
	resetInventory = BridgeNet.CreateBridge("resetInventory")
}

local isUpgradeMode = false
local upgradingMeta
local itemSacrificaing = {}
local isTrashMode = false
local trashing = {
	heroes = {},
	swords = {}
}

local inventoryGui

local manifesting
local inputShowing

local findItemWithIndexId = function(tbl, id)
	for _, dat in pairs(tbl) do
		if dat.index == id then
			return dat
		end
	end
end


local showInput = function(pos, self)
	if isTrashMode then
		if self.itemType == "Sword" then
			if table.find(trashing.swords, self.indexId) then
				tween.instance(self.manifest.container.trash, {
					BackgroundTransparency = 1
				}, .15, "EntranceExpressive")
				tween.instance(self.manifest.container.trashLabel, {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}, .15, "EntranceExpressive")
				table.remove(trashing.swords, table.find(trashing.swords, self.indexId))
				return
			end
			table.insert(trashing.swords, self.indexId)
		else
			if table.find(trashing.heroes, self.indexId) then
				tween.instance(self.manifest.container.trash, {
					BackgroundTransparency = 1
				}, .15, "EntranceExpressive")
				tween.instance(self.manifest.container.trashLabel, {
					ImageColor3 = Color3.fromRGB(255, 255, 255)
				}, .15, "EntranceExpressive")
				table.remove(trashing.heroes, table.find(trashing.heroes, self.indexId))
				return
			end
			table.insert(trashing.heroes, self.indexId)
		end
		self.manifest.container.trash.Visible = true
		self.manifest.container.trash.BackgroundTransparency = 1
		tween.instance(self.manifest.container.trash, {
			BackgroundTransparency = .4
		}, .15, "EntranceExpressive")
		tween.instance(self.manifest.container.trashLabel, {
			ImageColor3 = Color3.fromRGB(255, 99, 99)
		}, .15, "EntranceExpressive")
		self.manifest.container.trashLabel.Visible = true
		print(trashing)
		return
	end
	if isUpgradeMode then
		
		return
	end
	local inputUi = inventoryGui.input

	if inputShowing == self then
		inputUi.Visible = false
		inputShowing = nil
		return
	end

	local playerData = playerDataHandler.getPlayer()

	if self.itemType == "Sword" then
		local itemData = findItemWithIndexId(playerData.data.inventory.weapon, self.indexId)

		for _, levelIcon in pairs(inputUi.level:GetChildren()) do
			if levelIcon:IsA("GuiObject") then
				if tonumber(levelIcon.Name) >= (itemData.level - (itemData.level-1)%5) and tonumber(levelIcon.Name) <= itemData.level then
					levelIcon.Visible = true
				else
					levelIcon.Visible = false
				end
			end
		end
	
		if itemData.level <= 0 then
			inputUi.level.Visible = false
		else
			inputUi.level.Visible = true
		end
	
		if itemData.level >= itemLevel.maxLevel then
			inputUi.buttons.upgrade.info.label.Text = "MAX LEVEL"
			inputUi.buttons.upgrade.info.label.TextColor3 = Color3.fromRGB(97, 91, 59)
		else
			local dupe = 0
			for _, sdat in pairs(playerData.data.inventory.weapon) do
				if sdat.id == itemData.id and sdat.level == 0 then
					dupe += 1
				end
			end
			local levelDat = itemLevel.getLevelInfo(itemData.level + 1)
			inputUi.buttons.upgrade.info.label.Text = levelDat.displayTxt .. (" (%s/%s)"):format(dupe, levelDat.req)
			inputUi.buttons.upgrade.info.label.TextColor3 = Color3.fromRGB(220, 206, 134)
		end
		inputUi.buttons.upgrade.Visible = true
		if playerData.data.equipped.weapon2 and self.indexId == playerData.data.equipped.weapon2 then
			inputUi.primary.Text = "[Secondary]"
			inputUi.primary.Visible = true
			inputUi.buttons.equip.info.label.Text = "Unequip"
			inputUi.buttons.equip.Visible = true
			inputUi.buttons.equip2.Visible = false
		elseif self.indexId == playerData.data.equipped.weapon then
			inputUi.primary.Text = "[Primary]"
			inputUi.primary.Visible = true
			inputUi.buttons.equip.Visible = false
			inputUi.buttons.equip2.Visible = false
		else
			inputUi.primary.Visible = false
			inputUi.buttons.equip.info.label.Text = "Equip Primary"
			inputUi.buttons.equip2.Visible = true
			inputUi.buttons.equip.Visible = true
		end
	else
		if table.find(playerData.data.equipped.hero, self.indexId) then
			inputUi.buttons.equip.info.label.Text = "Unequip"
		else
			inputUi.buttons.equip.info.label.Text = "Equip"
		end
		inputUi.buttons.equip.Visible = true
		inputUi.buttons.equip2.Visible = false
		inputUi.primary.Visible = false
		inputUi.buttons.upgrade.Visible = false
		inputUi.level.Visible = false
	end

	inputShowing = self

	-- SCALER
	inputUi.rarity.Text = self.rarityData.name
	inputUi.rarity.TextColor3 = self.rarityData.primaryColor
	inputUi.title.Text = self.data.name
	inputUi.Position = pos - UDim2.fromOffset(inputUi.AbsoluteSize.X/inventoryGui.scaler.Scale + 8, 0)
	inputUi.Visible = true
	inventoryGui.exitTrigger.Visible = true
end

local itemClass = {}
itemClass.__index = itemClass


function itemClass:Destroy()
	if manifesting == self then
		inventoryGui.info.Visible = false
		manifesting = nil
	end
	self._maid:Destroy()
end

function itemClass:updateManifest()
	if self.itemType == "Sword" then
		local playerData = playerDataHandler.getPlayer()
		local itemData = findItemWithIndexId(playerData.data.inventory.weapon, self.indexId)
		local levelDat = itemLevel.getLevelInfo(itemData.level)
		local power = self.data.power * itemLevel.getMultiFromLevel(itemData.level)
		self.manifest.container.info.amount.Text = number.abbreviate(power, 2, true)
		self.manifest.LayoutOrder = -self.rarityData.order -power
	
		local levelUi = self.manifest.container.level
	
		if itemData.ability then
			local dat = abilities[itemData.ability.id]
			
			if levelUi:FindFirstChild("icon") then
				levelUi.icon:Destroy()
			end
			local content = ReplicatedStorage.abilities[dat.id]:Clone()
			content.Parent = levelUi
			content.Size = UDim2.fromOffset(21, 21)
			
			levelUi.amount.Text = itemData.level
			levelUi.amount.Visible = true
			levelUi.Visible = true
		else
			levelUi.Visible = false
		end

		--[[if itemData.level > 0 then
			levelUi.icon.icon.Image = levelDat.iconId
			levelUi.amount.Text = ((itemData.level-1)%5)+1
			if itemData.level % 5 == 1 then
				levelUi.amount.Visible = false
			else
				levelUi.amount.Visible = true
			end
			levelUi.Visible = true
		else
			levelUi.Visible = false
		end]]
	else
		self.manifest.container.info.amount.Text = `x{number.abbreviate(self.data.multiplier, 2, true)}`
	end
end

function itemClass:equip(type)
	if self.itemType == "Sword" then
		if type == "primary" then
			bridges.equipWeapon:Fire(self.indexId)
		else
			bridges.equipSecondaryWeapon:Fire(self.indexId)
		end
	elseif self.itemType == "Hero" then
		bridges.equipHero:Fire(self.indexId)
	end
end

function itemClass:unequip()
	if self.itemType == "Hero" then
		bridges.unequipHero:Fire(self.indexId)
	elseif self.itemType == "Sword" then
		bridges.unequipSecondaryWeapon:Fire(self.indexId)
	end
end

function itemClass:trash()
	if isTrashMode then return end
	local desc = inventoryGui.Parent.inventoryActionConfirmation.mainframe.lower.desc

	desc.Text = `You're <font color="rgb(255, 100, 100)">deleting</font> 1 {self.itemType} from your inventory. This action is irrevertible.`
	main.focus(inventoryGui.Parent.inventoryActionConfirmation)
	
	trashing = {
		swords = {},
		heroes = {}
	}

	if self.itemType == "Sword" then
		table.insert(trashing.swords, self.indexId)
	elseif self.itemType == "Hero" then
		table.insert(trashing.heroes, self.indexId)
	end

	--[[if self.itemType == "Sword" then
		bridges.trashWeapon:Fire(self.indexId)
	elseif self.itemType == "Hero" then
		bridges.trashHero:Fire(self.indexId)
	end]]
end

function itemClass:interact()
	showInput(UDim2.fromOffset(self.manifest.AbsolutePosition.X/inventoryGui.scaler.Scale, self.manifest.AbsolutePosition.Y/inventoryGui.scaler.Scale), self)
	if self.itemType == "Sword" then
		tween.instance(self.manifest.container.content, {
			Size = UDim2.fromScale(1.05, 1.05),
		}, 0.15, "Sine").Completed:Wait()
		if manifesting ~= self then
			tween.instance(self.manifest.container.content, {
				Size = UDim2.fromScale(1.1, 1.1),
			}, 0.15, "Expo")
		else
			tween.instance(self.manifest.container.content, {
				Size = UDim2.fromScale(1.2, 1.2),
			}, 0.15, "Expo")
		end
	elseif self.itemType == "Hero" then
		tween.instance(self.manifest.container.content.icon, {
			Size = UDim2.fromScale(.95, .95),
		}, 0.15, "Sine").Completed:Wait()
		if manifesting ~= self then
			tween.instance(self.manifest.container.content.icon, {
				Size = UDim2.fromScale(1, 1),
			}, 0.15, "Expo")
		else
			tween.instance(self.manifest.container.content.icon, {
				Size = UDim2.fromScale(1.1, 1.1),
			}, 0.15, "Expo")
		end		
	end
end

function itemClass:destroyAllTweens()
	for _, tweenObject in pairs(self.tweens) do
		tweenObject:Destroy()
	end
	table.clear(self.tweens)
end

function itemClass:hoverIn()
	local info = inventoryGui.info
	local playerData = playerDataHandler.getPlayer()

	if isTrashMode then
		self.manifest.container.trashLabel.Visible = true
	end

	if self.itemType == "Sword" then
		local itemData = findItemWithIndexId(playerData.data.inventory.weapon, self.indexId)
		local levelDat = itemLevel.getLevelInfo(itemData.level)

		if itemData.level > 0 then
			info.level.icon.icon.Image = levelDat.iconId
			if itemData.level % 5 == 1 then
				info.level.amount.Visible = false
			else
				info.level.amount.Text = ((itemData.level-1)%5)+1
				info.level.amount.Visible = true
			end
			info.footer.leveled.Text = levelDat.txt .. " Weapon"
			info.level.Visible = true
			info.footer.leveled.Visible = true
		else
			info.level.Visible = false
			info.footer.leveled.Visible = false
		end

		info.footer.special.Visible = false

		for _, object in pairs(info.lower:GetChildren()) do
			if object:IsA("GuiObject") and object.Name ~= "Power" and object.Name ~= "Coin" and object.Name ~= "Knockback" then
				object:Destroy()
			end
		end

		if itemData.ability then
			local dat = abilities[itemData.ability.id]
			local ui = ReplicatedStorage.resources.abilitySmallTemplate:Clone()
			ui.label.Text = `[Lv. {itemData.level} {dat.name}] {dat.getTxt(dat.getValue(itemData.level))}`
			ui.label.TextColor3 = dat.color

			if ui.icon:FindFirstChild("icon") then
				ui.icon.icon:Destroy()
			end
			local content = ReplicatedStorage.abilities[dat.id]:Clone()
			content.Parent = ui.icon

			content.Size = UDim2.fromOffset(21, 21)
			content.ZIndex += 3
			for _, desc in pairs(content:GetDescendants()) do
				if desc:IsA("GuiObject") then
					desc.ZIndex += 3
				end
			end

			ui.Visible = true
			ui.Parent = info.lower
			info.footer.special.Visible = true
		end

		if self.data.soulbound then
			info.footer.soulbound.Visible = true
		else
			info.footer.soulbound.Visible = false
		end
		if self.data.rarity == 6 then
			info.footer.limited.Visible = true
		else
			info.footer.limited.Visible = false
		end

		info.lower.Coin.Visible = true
		info.lower.Knockback.Visible = true
		info.lower.Power.label.Text = "[Power] "
			.. number.abbreviate(self.data.power * itemLevel.getMultiFromLevel(itemData.level) or self.data.baseDamage, 2)
		info.lower.Knockback.label.Text = "[Knockback] "
		.. number.abbreviate(self.data.knockback, 2)
		info.lower.Coin.label.Text = "[Coin] "
		.. number.abbreviate(self.data.power * itemLevel.getMultiFromLevel(itemData.level) or self.data.baseDamage, 2)

		info.Visible = true

		info.rarity.ImageColor3 = self.rarityData.primaryColor
		info.stroke.Color = self.rarityData.primaryColor
		info.content.icon.Image = self.data.iconId
		info.upper.title.Text = self.data.name
		info.footer.rarity.Text = self.rarityData.name .. " Rarity Weapon"
		info.footer.rarity.TextColor3 = self.rarityData.primaryColor

		task.wait()
		info.footer.Position = UDim2.fromOffset(
			0,
			math.max((info.lower.list.AbsoluteContentSize.Y + 41)/inventoryGui.scaler.Scale, 103)
		)

		self:destroyAllTweens()
		manifesting = self
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container, {
				BackgroundColor3 = Color3.fromRGB(80, 80, 80),
			}, 0.15, "Smoother")
		)
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.content, {
				Size = UDim2.fromScale(1.1, 1.1),
			}, 0.15, "Smoother")
		)
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.stroke, {
				Transparency = 0.2
			}, 0.15, "Smoother")
		)
	else

		info.footer.special.Visible = false
		info.level.Visible = false
		info.footer.leveled.Visible = false

		for _, object in pairs(info.lower:GetChildren()) do
			if object:IsA("GuiObject") and object.Name ~= "Power" and object.Name ~= "Coin" and object.Name ~= "Knockback" then
				object:Destroy()
			end
		end

		info.lower.Coin.Visible = true
		info.lower.Knockback.Visible = false
		info.lower.Power.label.Text = "[<font weight=\"heavy\">Power</font>] "
			.. `x{number.abbreviate(self.data.multiplier, 2, true)}`
		info.lower.Coin.label.Text = "[<font weight=\"heavy\">Coin</font>] "
			.. `x{number.abbreviate(self.data.multiplier, 2, true)}`

		info.footer.Position = UDim2.fromOffset(0, math.max(info.lower.list.AbsoluteContentSize.Y + 4 + 33, 103))

		info.rarity.ImageColor3 = self.rarityData.primaryColor
		info.stroke.Color = self.rarityData.primaryColor
		info.content.icon.Image = self.data.iconId
		info.upper.title.Text = self.data.name
		info.footer.rarity.Text = self.rarityData.name .. " Rarity Hero"
		info.footer.rarity.TextColor3 = self.rarityData.primaryColor
		info.Visible = true

		if self.data.soulbound then
			info.footer.soulbound.Visible = true
		else
			info.footer.soulbound.Visible = false
		end

		self:destroyAllTweens()
		manifesting = self
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container, {
				BackgroundColor3 = Color3.fromRGB(80, 80, 80),
			}, 0.15, "Smoother")
		)
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.content.icon, {
				Size = UDim2.fromScale(1.1, 1.1),
			}, 0.15, "Smoother")
		)
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.outline.stroke, {
				Transparency = 0.2
			}, 0.15, "Smoother")
		)
	end
end

function itemClass:hoverOut()
	if isTrashMode then
		if self.itemType == "Sword" then
			if not table.find(trashing.swords, self.indexId) then
				self.manifest.container.trashLabel.Visible = false
			end
		else
			if not table.find(trashing.heroes, self.indexId) then
				self.manifest.container.trashLabel.Visible = false
			end
		end
	end
	if manifesting == self then
		inventoryGui.info.Visible = false
		manifesting = nil
	end
	table.insert(
		self.tweens,
		tween.instance(self.manifest.container, {
			BackgroundColor3 = Color3.fromRGB(80, 80, 80),
		}, 0.25, "Smoother")
	)
	if self.itemType == "Sword" then
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.content, {
				Size = UDim2.fromScale(1.1, 1.1),
			}, 0.25, "Cubic")
		)
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.stroke, {
				Transparency = 0.4
			}, 0.25, "Cubic")
		)
	else
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.content.icon, {
				Size = UDim2.fromScale(1, 1),
			}, 0.25, "Smoother")
		)
		table.insert(
			self.tweens,
			tween.instance(self.manifest.container.outline.stroke, {
				Transparency = 0.4
			}, 0.25, "Smoother")
		)
	end
end

function itemClass:render()
	local rarity
	for _, r in pairs(rarities) do
		if r.order == self.data.rarity then
			rarity = r
			break
		end
	end

    local playerData = playerDataHandler.getPlayer()
	local itemData = findItemWithIndexId(playerData.data.inventory.weapon, self.indexId)

	self.rarityData = rarity

	self.manifest = self.itemType == "Sword" and ReplicatedStorage.resources.inventoryItemTemplate:Clone() or ReplicatedStorage.resources.inventoryHeroTemplate:Clone()
	self.manifest.container.rarity.ImageColor3 = rarity.primaryColor
	self.manifest.LayoutOrder = -rarity.order - (self.itemType == "Sword" and self.data.power or self.data.multiplier)
	self.manifest.Name = self.indexId

	if self.itemType == "Sword" then
		self.manifest.container.stroke.Color = rarity.primaryColor
		self.manifest.container.content.Image = self.data.iconId
	else
		self.manifest.container.outline.stroke.Color = rarity.primaryColor
		self.manifest.container.content.icon.Image = self.data.iconId
	end

    self:updateManifest()

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
	self._maid:Add(self.manifest.Destroying:Connect(function()
		self:Destroy()
	end))

	self.manifest.Parent = inventoryGui.mainframe.lower[self.itemType]
	self:hoverOut()
	--self._maid:Add(self.manifest)
end

local new

local buttonColorCache = {}
local buttonValueIncrement = 0.4

local selectedPage


local update = function()
	local data = playerDataHandler.getPlayer().data
	local equipped = data.equipped
	local pageName = selectedPage.page.Name

	local n = #data.inventory.hero
	local max = 15 +
		(passHandler.ownPass("25HeroSlots") and 25 or 0) +
		(passHandler.ownPass("VIP") and 25 or 0)
	local isInfinite = passHandler.ownPass("InfiniteInventory")

	local n2 = #data.inventory.weapon
	local max2 = 20 +
		(passHandler.ownPass("50SwordSlots") and 50 or 0) +
		(passHandler.ownPass("VIP") and 25 or 0)

	if isInfinite then
		inventoryGui.Parent.hud.buttons.sword.notif.Text = n2
		inventoryGui.Parent.hud.buttons.sword.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
	elseif n2 >= max2 then
		inventoryGui.Parent.hud.buttons.sword.notif.Text = "FULL"
		inventoryGui.Parent.hud.buttons.sword.notif.TextColor3 = Color3.fromRGB(235, 80, 80)
	else
		inventoryGui.Parent.hud.buttons.sword.notif.Text = `{n2}/{max2}`
		inventoryGui.Parent.hud.buttons.sword.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
	end
	if isInfinite then
		inventoryGui.Parent.hud.buttons.hero.notif.Text = n
		inventoryGui.Parent.hud.buttons.hero.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
	elseif n >= max then
		inventoryGui.Parent.hud.buttons.hero.notif.Text = "FULL"
		inventoryGui.Parent.hud.buttons.hero.notif.TextColor3 = Color3.fromRGB(235, 80, 80)
	else
		inventoryGui.Parent.hud.buttons.hero.notif.Text = `{n}/{max}`
		inventoryGui.Parent.hud.buttons.hero.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
	end

	if pageName == "Sword" then
		if isInfinite then
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 50)
		elseif n2 >= max2 then
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 50, 50)
		else
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		inventoryGui.mainframe.footer.capacity.Text = `Capacity {n}/{isInfinite and "∞" or max2}`
		inventoryGui.mainframe.footer.equipped.Text = `Sword Equipped {1 + (equipped.weapon2 and 1 or 0)}/{1 + (passHandler.ownPass("DualWield") and 1 or 0)}`
	elseif pageName == "Hero" then
		if isInfinite then
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 50)
		elseif n >= max then
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 50, 50)
		else
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		inventoryGui.mainframe.footer.capacity.Text = `Capacity {n}/{isInfinite and "∞" or max}`
		inventoryGui.mainframe.footer.equipped.Text = `Hero Equipped {#equipped.hero}/{2 + (passHandler.ownPass("3HeroEquip") and 3 or 0) + (passHandler.ownPass("VIP") and 1 or 0)}`
	end
end

function itemClass:upgrade()

	if isUpgradeMode then return end

	local playerData = playerDataHandler.getPlayer()
	local itemData = findItemWithIndexId(playerData.data.inventory.weapon, self.indexId)

	local dupe = 0
	for _, sdat in pairs(playerData.data.inventory.weapon) do
		if sdat.id == itemData.id and sdat.level == 0 then
			dupe += 1
		end
	end

	if itemData.level+1 > itemLevel.maxLevel then
		return notifications.new():error("Error: You cannot star this item; This item already has max stars")
	end
	local reqDupe = itemLevel.getRequiredDuplicateFromLevel(itemData.level+1)
	if dupe < reqDupe then
		return notifications.new():error(`Error: You need {number.toWord(reqDupe - dupe)} more duplicate{reqDupe - dupe > 1 and "s" or ""} of "{self.data.name}" to star this item`)
	end

	if not itemData.ability then
		local ui = inventoryGui.Parent.upgradeConfirmation
		ui.mainframe.lower.desc.Text = `You're sacrificing {number.toWord(reqDupe)} <font color="rgb(255, 186, 107)">"{self.data.name}"</font> to infuse this sword with a random ability. This action is irrevertible.`
		
		upgradingMeta = self

		main.focus(ui)
	else
		local dat = abilities[itemData.ability.id]
		local ui = inventoryGui.Parent.abilityUpgradeConfirmation
		ui.mainframe.lower.desc.Text = `You're sacrificing {number.toWord(itemLevel.getRequiredDuplicateFromLevel(itemData.level))} <font color="rgb(255, 186, 107)">"{self.data.name}"</font> to upgrade <font color="rgb(255, 186, 107)">"{dat.name}"</font> from <font color="rgb(255, 186, 107)">Lv. {itemData.level}</font> to <font color="rgb(255, 186, 107)">Lv. {itemData.level+1}</font>. This action is irrevertible.`
		
		upgradingMeta = self

		main.focus(ui)
	end

	--main.focus(inventoryGui.Parent.upgradeConfirmation)

    --[[local response = bridges.upgradeWeapon:InvokeServerAsync(self.indexId)
	if response then
		for _, object in pairs(inventoryGui.mainframe.lower.Sword:GetChildren()) do
			if object:IsA("GuiObject") then
				object:Destroy()
			end
		end
		local playerData = playerDataHandler.getPlayer().data
		for _, dat in pairs(playerData.inventory.weapon) do
			local itemdat
			for name, data in pairs(weapons) do
				if data.id == dat.id then
					itemdat = data
				end
			end
			new("Sword", dat, itemdat):render()
		end
		if playerData.equipped.weapon then
			local equipped = inventoryGui.mainframe.lower.Sword:FindFirstChild(playerData.equipped.weapon)
			equipped.container.equipped.Visible = true
		end
		if playerData.equipped.weapon2 then
			local equipped2 = inventoryGui.mainframe.lower.Sword:FindFirstChild(playerData.equipped.weapon2)
			equipped2.container.equipped.Visible = true
		end
		update()
	end]]
end

local itemObject = objects.new(itemClass, {})

new = function(itemType, dat, data)
	return itemObject:new({
		indexId = dat.index,
		itemType = itemType,
		itemId = dat.id,
		data = data,

		tweens = {},
	})
end

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

	update()
end

local trashMode = function()
	--rbxassetid://13340905566 checkmark
	--rbxassetid://13340837940 trash
	if isTrashMode then
		local desc = inventoryGui.Parent.inventoryActionConfirmation.mainframe.lower.desc
		local str = ""
		if #trashing.swords > 0 then
			str = `{#trashing.swords} Swords {#trashing.heroes > 0 and "and " or ""}`
		end
		if #trashing.heroes > 0 then
			str = `{str}{#trashing.heroes} Heroes`
		end
		if str ~= "" then
			desc.Text = `You're <font color="rgb(255, 100, 100)">deleting</font> {str}from your inventory. This action is irrevertible.`
			main.focus(inventoryGui.Parent.inventoryActionConfirmation)
		end
		inventoryGui.mainframe.trash.info.label.Image = "rbxassetid://13340837940"
		isTrashMode = false
		for _, object in pairs(inventoryGui.mainframe.lower:GetDescendants()) do
			if object:IsA("TextButton") then
				object.container.trash.Visible = false
				object.container.trashLabel.Visible = false
				object.container.trashLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	else
		inventoryGui.input.Visible = false
		trashing = {
			heroes = {},
			swords = {}
		}
		isTrashMode = true
		inventoryGui.mainframe.trash.info.label.Image = "rbxassetid://13340905566"
		notifications.new():message("Select items you want to trash")
	end
end

return {
	selectPage = selectPage,
	load = function()
		inventoryGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("inventory")
		local hud = Players.LocalPlayer.PlayerGui:WaitForChild("hud")
		local info = inventoryGui.info

		hud.buttons.hero.Activated:Connect(function()
			selectPage("Hero")
		end)
		hud.buttons.sword.Activated:Connect(function()
			selectPage("Sword")
		end)

		local trashButton = inventoryGui.mainframe.trash
		local upgradeConfirmation = inventoryGui.Parent:WaitForChild("upgradeConfirmation")
		local actionConfirmation = inventoryGui.Parent:WaitForChild("inventoryActionConfirmation")
		local abilityUpgradeConfirmation = inventoryGui.Parent:WaitForChild("abilityUpgradeConfirmation")
		local trashConfirm = actionConfirmation.mainframe.lower.confirm
		local upgradeConfirm = upgradeConfirmation.mainframe.lower.confirm
		local upgradeConfirm2 = abilityUpgradeConfirmation.mainframe.lower.confirm

		local abilityInfo = upgradeConfirmation.info

		main.initUi(upgradeConfirmation)
		main.initUi(actionConfirmation)
		main.initUi(abilityUpgradeConfirmation)

        main:button(trashConfirm).Activated:Connect(function()
            if not trashing then return end
            main.focus(inventoryGui)
            bridges.bulkTrashItem:Fire(trashing)
            trashing = nil
        end)


		main:button(upgradeConfirm2).Activated:Connect(function()
            main.focus(inventoryGui)

			if not upgradingMeta then
				return
			end
			bridges.upgradeWeapon:Fire(upgradingMeta.indexId)
			upgradingMeta = nil
        end)
		main:button(upgradeConfirm).Activated:Connect(function()
            main.focus(inventoryGui)

			if not upgradingMeta then
				return
			end
			bridges.upgradeWeapon:Fire(upgradingMeta.indexId)
			upgradingMeta = nil
        end)
		abilityUpgradeConfirmation.mainframe.close2.Activated:Connect(function()
			main.focus(inventoryGui)
		end)
		upgradeConfirmation.mainframe.close2.Activated:Connect(function()
			main.focus(inventoryGui)
		end)
        actionConfirmation.mainframe.close2.Activated:Connect(function()
            main.focus(inventoryGui)
			trashing = nil
        end)

		main:button(trashButton).Activated:Connect(trashMode)

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
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						tween.instance(button, {
							Size = UDim2.fromOffset(70, 70)
						}, .15, "Back")
					end
				end)
				button.MouseButton1Down:Connect(function()
					tween.instance(button, {
						Size = UDim2.fromOffset(60, 60)
					}, .1)
				end)
				--[[button.MouseEnter:Connect(function()
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
				end)]]
			end
		end
		selectPage("Sword")

		local loaded = {}
		bridges.resetInventory:Connect(function(indexid)
			for _, b in pairs(inventoryGui.mainframe.lower.Sword:GetChildren()) do
				if b:IsA("GuiObject") then
					b:Destroy()
				end
			end
			
			local playerData = playerDataHandler.getPlayer().data
			for _, a in pairs(playerData.inventory.weapon) do
				if a.index == indexid then
					print(print("reset", a))
				end
			end

			for _, dat in pairs(playerData.inventory.weapon) do
				local itemdat
				for name, data in pairs(weapons) do
					if data.id == dat.id then
						itemdat = data
					end
				end
				new("Sword", dat, itemdat):render()
			end
			if playerData.equipped.weapon then
				local equipped = inventoryGui.mainframe.lower.Sword:FindFirstChild(playerData.equipped.weapon)
				equipped.container.equipped.Visible = true
			end
			if playerData.equipped.weapon2 then
				local equipped2 = inventoryGui.mainframe.lower.Sword:FindFirstChild(playerData.equipped.weapon2)
				equipped2.container.equipped.Visible = true
			end
		end)
		--[[playerDataHandler:connect({"ascension"}, function(changes)
			if changes.new and changes.old then
				for _, object in pairs(inventoryGui.mainframe.lower:GetChildren()) do
					if object:IsA("GuiObject") then
						for _, b in pairs(object:GetChildren()) do
							if b:IsA("GuiObject") then
								b:Destroy()
							end
						end
					end
				end
				local playerData = playerDataHandler.getPlayer().data
				for _, dat in pairs(playerData.inventory.weapon) do
					local itemdat
					for name, data in pairs(weapons) do
						if data.id == dat.id then
							itemdat = data
						end
					end
					new("Sword", dat, itemdat):render()
					
				end
				if playerData.equipped.weapon then
					local equipped = inventoryGui.mainframe.lower.Sword:FindFirstChild(playerData.equipped.weapon)
					equipped.container.equipped.Visible = true
				end
				if playerData.equipped.weapon2 then
					local equipped2 = inventoryGui.mainframe.lower.Sword:FindFirstChild(playerData.equipped.weapon2)
					equipped2.container.equipped.Visible = true
				end
				for _, dat in pairs(playerData.inventory.hero) do
					local itemdat
					for name, data in pairs(heros) do
						if data.id == dat.id then
							itemdat = data
						end
					end
					new("Hero", dat, itemdat):render()
				end

				update()
			end
		end)]]
		playerDataHandler:connect({ "inventory", "weapon" }, function(change)
			local newlyObtained = playerDataHandler:findChanges(change, true)

			for _, dat in pairs(newlyObtained.added) do
				local itemdat
				for name, data in pairs(weapons) do
					if data.id == dat.id then
						itemdat = data
					end
				end
				new("Sword", dat, itemdat):render()
			end

            if change.new and change.old then
                local removed = {}
                for _, dat in pairs(change.old) do
                    if not findItemWithIndexId(change.new, dat.index) then
                        inventoryGui.mainframe.lower.Sword:FindFirstChild(dat.index):Destroy()
                    end
                end
            end
			update()
		end)

		playerDataHandler:connect({ "inventory", "hero" }, function(change)
			local newlyObtained = playerDataHandler:findChanges(change, true)

			for _, dat in pairs(newlyObtained.added) do
				local itemdat
				for name, data in pairs(heros) do
					if data.id == dat.id then
						itemdat = data
					end
				end
				new("Hero", dat, itemdat):render()
			end

            if change.new and change.old then
                for _, dat in pairs(change.old) do
                    if not findItemWithIndexId(change.new, dat.index) then
                        inventoryGui.mainframe.lower.Hero:FindFirstChild(dat.index):Destroy()
                    end
                end
            end

			update()
		end)

		playerDataHandler:connect({ "equipped", "weapon" }, function(change)
			local equipped = inventoryGui.mainframe.lower.Sword:FindFirstChild(change.new)
			local unequipped = change.old and inventoryGui.mainframe.lower.Sword:FindFirstChild(change.old)
			local data = playerDataHandler.getPlayer().data

			if unequipped then
				unequipped.container.equipped.Visible = false
			end
			if equipped then
				equipped.container.equipped.Visible = true
			end
			if data.equipped.weapon2 then
				local equipped2 = inventoryGui.mainframe.lower.Sword:FindFirstChild(data.equipped.weapon2)
				equipped2.container.equipped.Visible = true
			end
			if selectedPage.page.Name == "Sword" then
				inventoryGui.mainframe.footer.equipped.Text = `Sword Equipped {1 + (data.equipped.weapon2 and 1 or 0)}/{1 + (passHandler.ownPass("DualWield") and 1 or 0)}`
			end
		end)

		playerDataHandler:connect({ "equipped", "weapon2" }, function(change)
			local equipped = change.new and inventoryGui.mainframe.lower.Sword:FindFirstChild(change.new)
			local unequipped = change.old and inventoryGui.mainframe.lower.Sword:FindFirstChild(change.old)
			local data = playerDataHandler.getPlayer().data

			if equipped then
				equipped.container.equipped.Visible = true
			end
			if unequipped then
				unequipped.container.equipped.Visible = false
			end
			if data.equipped.weapon then
				local equipped2 = inventoryGui.mainframe.lower.Sword:FindFirstChild(data.equipped.weapon)
				if equipped2 then
					equipped2.container.equipped.Visible = true
				end
			end
			if selectedPage.page.Name == "Sword" then
				inventoryGui.mainframe.footer.equipped.Text = `Sword Equipped {1 + (data.equipped.weapon2 and 1 or 0)}/{1 + (passHandler.ownPass("DualWield") and 1 or 0)}`
			end
		end)

		
		playerDataHandler:connect({ "equipped", "hero" }, function(change)
			for _, equippedId in pairs(change.new) do
				local equipped = inventoryGui.mainframe.lower.Hero:FindFirstChild(equippedId)
				equipped.container.equipped.Visible = true
			end
			if change.old then
				for _, unequippedId in pairs(change.old) do
					if table.find(change.new, unequippedId) then
						continue
					end
					local unequipped = inventoryGui.mainframe.lower.Hero:FindFirstChild(unequippedId)
					if unequipped then
						unequipped.container.equipped.Visible = false
					end
				end
			end

			if selectedPage.page.Name == "Hero" then
				inventoryGui.mainframe.footer.equipped.Text = `Equipped Hero {#change.new}/{2 + (passHandler.ownPass("3HeroEquip") and 3 or 0) + (passHandler.ownPass("VIP") and 1 or 0) }`
			end
		end)

		inventoryGui.exitTrigger.Activated:Connect(function(inputObject, clickCount)
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local mouseLocation = input.Position
				if info.Visible then
					info.Position = UDim2.fromOffset((mouseLocation.X/inventoryGui.scaler.Scale) + 16, mouseLocation.Y/inventoryGui.scaler.Scale)
				end
				
				if abilityInfo.Visible then
					abilityInfo.Position = UDim2.fromOffset((mouseLocation.X/upgradeConfirmation.scaler.Scale) + 16, mouseLocation.Y/upgradeConfirmation.scaler.Scale)
				end
			end
		end)

		main:button(inventoryGui.input.buttons.equip, .03).Activated:Connect(function()
			if inputShowing then
				if inventoryGui.input.buttons.equip.info.label.Text == "Unequip" then
					inputShowing:unequip()
				else
					inputShowing:equip("primary")
				end
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		main:button(inventoryGui.input.buttons.equip2, .03).Activated:Connect(function()
			if inputShowing then
				inputShowing:equip("secondary")
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		main:button(inventoryGui.input.buttons.upgrade, .03).Activated:Connect(function()
			if inputShowing then
				inputShowing:upgrade()
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		main:button(inventoryGui.input.buttons.trash, .03).Activated:Connect(function()
			if inputShowing then
				inputShowing:trash()
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		local abilityHovering

		for id, ability in pairs(abilities) do
			local abilityTemplate = ReplicatedStorage.resources.abilityTemplate:Clone()
			local rarityData = rarities[ability.rarity]
			
			abilityTemplate.Name = ability.name
			abilityTemplate.LayoutOrder = ability.chance*10000
			abilityTemplate.Parent = upgradeConfirmation.mainframe.lower.abilities
			abilityTemplate.container.content:Destroy()

			local content = ReplicatedStorage.abilities[id]:Clone()
			content.Name = "content"
			content.Parent = abilityTemplate.container
			
			abilityTemplate.container.rarity.ImageColor3 = rarityData.primaryColor
			abilityTemplate.container.rarityLabel.TextColor3 = rarityData.primaryColor
			abilityTemplate.container.rarityLabel.Text = rarityData.name
			abilityTemplate.container.stroke.Color = rarityData.primaryColor
			abilityTemplate.container.percentage.Text = `{math.round(ability.chance*10000)/100}%`

			abilityTemplate.MouseEnter:Connect(function()
				if abilityHovering and abilityHovering == abilityTemplate then
					return
				end

				abilityHovering = abilityTemplate

				if abilityInfo.content:FindFirstChild("icon") then
					abilityInfo.content.icon:Destroy()
				end

				local contentHover = content:Clone()
				contentHover.Name = "icon"
				contentHover.Parent = abilityInfo.content
				contentHover.ZIndex += 3
				for _, desc in pairs(contentHover:GetDescendants()) do
					if desc:IsA("GuiObject") then
						desc.ZIndex += 3
					end
				end

				abilityInfo.footer.rarity.Text = `{rarityData.name} Rarity Ability`
				abilityInfo.label.Text = ability.description
				abilityInfo.upper.title.Text = ability.name
				abilityInfo.footer.rarity.TextColor3 = rarityData.primaryColor
				abilityInfo.stroke.Color = rarityData.primaryColor
				abilityInfo.rarity.ImageColor3 = rarityData.primaryColor

				abilityInfo.Visible = true

				abilityInfo.footer.Position = UDim2.fromOffset(0,
				math.max(37 + abilityInfo.label.TextBounds.Y/upgradeConfirmation.scaler.Scale, 103))
			end)
			abilityTemplate.MouseLeave:Connect(function()
				if abilityHovering == abilityTemplate then
					abilityHovering = nil
					abilityInfo.Visible = false
				end
			end)
		end

		passHandler.once("DualWield", update)
		passHandler.once("3HeroEquip", update)
		passHandler.once("VIP", update)
		passHandler.once("InfiniteInventory", update)
		passHandler.once("50SwordSlots", update)
		passHandler.once("25HeroSlots", update)

		--[[for _, item in pairs(weapons) do
            new("Sword", item.id, {
                equipped = false
            }, item):render()
        end]]
	end,
}
