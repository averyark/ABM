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
local weapons = require(ReplicatedStorage.shared.weapons)
local rarities = require(ReplicatedStorage.shared.rarities)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)
local statusEffects = require(ReplicatedStorage.shared.statusEffects)
local heros = require(ReplicatedStorage.shared.heros)
local passHandler = require(script.Parent.Parent.passHandler)

local bridges = {
	equipWeapon = BridgeNet.CreateBridge("equipWeapon"),
	equipHero = BridgeNet.CreateBridge("equipHero"),
	unequipHero = BridgeNet.CreateBridge("unequipHero"),
	upgradeWeapon = BridgeNet.CreateBridge("upgradeWeapon"),
	trashWeapon = BridgeNet.CreateBridge("trashWeapon"),
	trashHero = BridgeNet.CreateBridge("trashHero"),
	equipSecondaryWeapon = BridgeNet.CreateBridge("equipSecondaryWeapon"),
	unequipSecondaryWeapon = BridgeNet.CreateBridge("unequipSecondaryWeapon"),
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
			inputUi.buttons.upgrade.Text = "MAX LEVEL"
			inputUi.buttons.upgrade.TextColor3 = Color3.fromRGB(97, 91, 59)
		else
			local dupe = 0
			for _, sdat in pairs(playerData.data.inventory.weapon) do
				if sdat.id == itemData.id and sdat.level == itemData.level then
					dupe += 1
				end
			end
			local levelDat = itemLevel.getLevelInfo(itemData.level + 1)
			inputUi.buttons.upgrade.Text = levelDat.displayTxt .. (" (%s/%s)"):format(dupe, levelDat.req)
			inputUi.buttons.upgrade.TextColor3 = Color3.fromRGB(220, 206, 134)
		end
		inputUi.buttons.upgrade.Visible = true
		if playerData.data.equipped.weapon2 and self.indexId == playerData.data.equipped.weapon2 then
			inputUi.primary.Text = "[Secondary]"
			inputUi.primary.Visible = true
			inputUi.buttons.equip.Text = "Unequip"
			inputUi.buttons.equip.Visible = true
			inputUi.buttons.equip2.Visible = false
		elseif self.indexId == playerData.data.equipped.weapon then
			inputUi.primary.Text = "[Primary]"
			inputUi.primary.Visible = true
			inputUi.buttons.equip.Visible = false
			inputUi.buttons.equip2.Visible = false
		else
			inputUi.primary.Visible = false
			inputUi.buttons.equip.Text = "Equip Primary"
			inputUi.buttons.equip2.Visible = true
			inputUi.buttons.equip.Visible = true
		end
	else
		if table.find(playerData.data.equipped.hero, self.indexId) then
			inputUi.buttons.equip.Text = "Unequip"
		else
			inputUi.buttons.equip.Text = "Equip"
		end
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
	inputUi.Position = pos - UDim2.fromOffset(inputUi.AbsoluteSize.X + 8, 0)
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
		self.manifest.container.info.amount.Text = number.abbreviate(power, 2)
		self.manifest.LayoutOrder = -self.rarityData.order -power
	
		local levelUi = self.manifest.container.level
	
		if itemData.level > 0 then
			levelUi.icon.icon.Image = levelDat.iconId
			levelUi.amount.Text = ((itemData.level-1)%5)+1
			levelUi.Visible = true
		else
			levelUi.Visible = false
		end
	else
		self.manifest.container.info.amount.Text = `x{number.abbreviate(self.data.multiplier)}`
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
	if self.itemType == "Sword" then
		bridges.trashWeapon:Fire(self.indexId)
	elseif self.itemType == "Hero" then
		bridges.trashHero:Fire(self.indexId)
	end
end

function itemClass:interact()
	showInput(UDim2.fromOffset(self.manifest.AbsolutePosition.X, self.manifest.AbsolutePosition.Y), self)
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

		for _, special in pairs(self.data.special or {}) do
			local dat = statusEffects[special.id]
			local statusEffectFrame = ReplicatedStorage.resources.statusEffectFrameTemplate:Clone()
			statusEffectFrame.Name = dat.name
			statusEffectFrame.icon.icon.Image = dat.icon
			statusEffectFrame.label.Text = ("<font weight=\"heavy\">[%s]</font> %s"):format(dat.name, dat.description)
			statusEffectFrame.label.TextColor3 = dat.color
			statusEffectFrame.LayoutOrder = dat.order
			statusEffectFrame.Parent = info.lower
			info.footer.special.Visible = true
		end

		if self.data.soulbound then
			info.footer.soulbound.Visible = true
		else
			info.footer.soulbound.Visible = false
		end

		info.lower.Coin.Visible = true
		info.lower.Knockback.Visible = true
		info.lower.Power.label.Text = "[<font weight=\"heavy\">Power</font>] "
			.. number.abbreviate(self.data.power * itemLevel.getMultiFromLevel(itemData.level) or self.data.baseDamage, 2)
		info.lower.Knockback.label.Text = "[<font weight=\"heavy\">Knockback</font>] "
			.. number.abbreviate(self.data.knockback, 2)
		info.lower.Coin.label.Text = "[<font weight=\"heavy\">Coin</font>] x" .. number.abbreviate(self.data.coin, 2)

		info.footer.Position = UDim2.fromOffset(0, math.max(info.lower.list.AbsoluteContentSize.Y + 4 + 33, 103))

		info.rarity.ImageColor3 = self.rarityData.primaryColor
		info.stroke.Color = self.rarityData.primaryColor
		info.content.icon.Image = self.data.iconId
		info.upper.title.Text = self.data.name
		info.footer.rarity.Text = self.rarityData.name .. " Rarity Weapon"
		info.footer.rarity.TextColor3 = self.rarityData.primaryColor
		info.Visible = true

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

		info.lower.Coin.Visible = false
		info.lower.Knockback.Visible = false
		info.lower.Power.label.Text = "[<font weight=\"heavy\">Power</font>] "
			.. `x{number.abbreviate(self.data.multiplier, 2)}`

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

function itemClass:upgrade()
    local response = bridges.upgradeWeapon:InvokeServerAsync(self.indexId)
	if response then
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
	end
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

local buttonColorCache = {}
local buttonValueIncrement = 0.4

local selectedPage

local update = function()
	local data = playerDataHandler.getPlayer().data
	local equipped = data.equipped
	local pageName = selectedPage.page.Name
	if pageName == "Sword" then
		local n = #data.inventory.weapon
		local max = 20 +
			(passHandler.ownPass("50SwordSlots") and 50 or 0) +
			(passHandler.ownPass("VIP") and 25 or 0)
		local isInfinite = passHandler.ownPass("InfiniteInventory")

		if isInfinite then
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 50)
		elseif n >= max then
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 50, 50)
		else
			inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		inventoryGui.mainframe.footer.capacity.Text = `Capacity {n}/{isInfinite and "∞" or max}`
		inventoryGui.mainframe.footer.equipped.Text = `Sword Equipped {1 + (equipped.weapon2 and 1 or 0)}/{1 + (passHandler.ownPass("DualWield") and 1 or 0)}`
	elseif pageName == "Hero" then
		local n = #data.inventory.hero
		local max = 15 +
			(passHandler.ownPass("25HeroSlots") and 25 or 0) +
			(passHandler.ownPass("VIP") and 25 or 0)
		local isInfinite = passHandler.ownPass("InfiniteInventory")

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

return {
	selectPage = selectPage,
	load = function()
		inventoryGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("inventory")
		local hud = Players.LocalPlayer.PlayerGui:WaitForChild("hud")
		local info = inventoryGui.info

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
		playerDataHandler:connect({"ascension"}, function(changes)
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
			end
		end)
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

			local n = #change.new
			local max = 20 +
				(passHandler.ownPass("50SwordSlots") and 50 or 0) +
				(passHandler.ownPass("VIP") and 25 or 0)
			local isInfinite = passHandler.ownPass("InfiniteInventory")

			if selectedPage.page.Name == "Sword" then
				if isInfinite then
					inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 50)
				elseif n >= max then
					inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 50, 50)
				else
					inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 255)
				end

				inventoryGui.mainframe.footer.capacity.Text = `Capacity {n}/{isInfinite and "∞" or max}`
			end

			if isInfinite then
				hud.buttons.sword.notif.Text = n
				hud.buttons.sword.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
			elseif n >= max then
				hud.buttons.sword.notif.Text = "FULL"
				hud.buttons.sword.notif.TextColor3 = Color3.fromRGB(235, 80, 80)
			else
				hud.buttons.sword.notif.Text = `{n}/{max}`
				hud.buttons.sword.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
			end
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

			local n = #change.new
			local max = 15 +
				(passHandler.ownPass("25HeroSlots") and 25 or 0) +
				(passHandler.ownPass("VIP") and 25 or 0)
			local isInfinite = passHandler.ownPass("InfiniteInventory")

			if selectedPage.page.Name == "Hero" then
				if isInfinite then
					inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 50)
				elseif n >= max then
					inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 50, 50)
				else
					inventoryGui.mainframe.footer.capacity.TextColor3 = Color3.fromRGB(255, 255, 255)
				end

				inventoryGui.mainframe.footer.capacity.Text = `Capacity {n}/{isInfinite and "∞" or max}`
			end

			if isInfinite then
				hud.buttons.hero.notif.Text = n
				hud.buttons.hero.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
			elseif n >= max then
				hud.buttons.hero.notif.Text = "FULL"
				hud.buttons.hero.notif.TextColor3 = Color3.fromRGB(235, 80, 80)
			else
				hud.buttons.hero.notif.Text = `{n}/{max}`
				hud.buttons.hero.notif.TextColor3 = Color3.fromRGB(235, 235, 235)
			end
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
				info.Position = UDim2.fromOffset(mouseLocation.X + 16, mouseLocation.Y)
			end
		end)

		inventoryGui.input.buttons.equip.Activated:Connect(function(inputObject, clickCount)
			if inputShowing then
				if inventoryGui.input.buttons.equip.Text == "Unequip" then
					inputShowing:unequip()
				else
					inputShowing:equip("primary")
				end
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		inventoryGui.input.buttons.equip2.Activated:Connect(function(inputObject, clickCount)
			if inputShowing then
				inputShowing:equip("secondary")
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		inventoryGui.input.buttons.upgrade.Activated:Connect(function(inputObject, clickCount)
			if inputShowing then
				inputShowing:upgrade()
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

		inventoryGui.input.buttons.trash.Activated:Connect(function(inputObject, clickCount)
			if inputShowing then
				inputShowing:trash()
			end
			inventoryGui.input.Visible = false
			inventoryGui.exitTrigger.Visible = false
			inputShowing = nil
		end)

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

