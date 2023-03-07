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

local bridges = {
	equipWeapon = BridgeNet.CreateBridge("equipWeapon"),
	upgradeWeapon = BridgeNet.CreateBridge("upgradeWeapon"),
	trashWeapon = BridgeNet.CreateBridge("trashWeapon"),
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
    local playerData = playerDataHandler.getPlayer()
    local itemData = findItemWithIndexId(playerData.data.inventory.weapon, self.indexId)
    local levelDat = itemLevel.getLevelInfo(itemData.level)
    self.manifest.container.info.amount.Text = number.abbreviate(self.data.power * itemLevel.getMultiFromLevel(itemData.level), 2)
	self.manifest.LayoutOrder = -self.rarityData.order - self.data.power

    local levelUi = self.manifest.container.level

    if itemData.level > 0 then
        levelUi.icon.icon.Image = levelDat.iconId
        levelUi.amount.Text = ((itemData.level-1)%5)+1
        levelUi.Visible = true
    else
        levelUi.Visible = false
    end
end

function itemClass:equip()
	bridges.equipWeapon:Fire(self.indexId)
end

function itemClass:upgrade()
    local response = bridges.upgradeWeapon:InvokeServerAsync(self.indexId)
    
	if response then
        for i = 3, 1, -1 do -- 3 heartbeat
			task.wait()
		end
        self:updateManifest()
    end
end

function itemClass:trash()
	bridges.trashWeapon:Fire(self.indexId)
end

function itemClass:interact()
	showInput(UDim2.fromOffset(self.manifest.AbsolutePosition.X, self.manifest.AbsolutePosition.Y), self)
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

	info.lower.Power.label.Text = "[<font weight=\"heavy\">Power</font>] "
		.. number.abbreviate(self.data.power * itemLevel.getMultiFromLevel(itemData.level) or self.data.baseDamage, 2)
	info.lower.Knockback.label.Text = "[<font weight=\"heavy\">Knockback</font>] "
		.. number.abbreviate(self.data.knockback, 2)
	info.lower.Coin.label.Text = "[<font weight=\"heavy\">Coin</font>] x" .. number.abbreviate(self.data.coin, 2)

	info.footer.Position = UDim2.fromOffset(0, math.max(info.lower.list.AbsoluteContentSize.Y + 4 + 33, 103))

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
			BackgroundColor3 = Color3.fromRGB(126, 99, 76),
		}, 0.15, "Smoother")
	)
	table.insert(
		self.tweens,
		tween.instance(self.manifest.container.content, {
			Size = UDim2.fromScale(1.2, 1.2),
		}, 0.15, "Smoother")
	)
	table.insert(
		self.tweens,
		tween.instance(self.manifest.container.stroke, {
			Color = Color3.fromRGB(126, 99, 76),
		}, 0.15, "Smoother")
	)
end

function itemClass:hoverOut()
	if manifesting == self then
		inventoryGui.info.Visible = false
		manifesting = nil
	end
	table.insert(
		self.tweens,
		tween.instance(self.manifest.container, {
			BackgroundColor3 = Color3.fromRGB(63, 50, 38),
		}, 0.25, "Cubic")
	)
	table.insert(
		self.tweens,
		tween.instance(self.manifest.container.content, {
			Size = UDim2.fromScale(1.1, 1.1),
		}, 0.25, "Cubic")
	)
	table.insert(
		self.tweens,
		tween.instance(self.manifest.container.stroke, {
			Color = Color3.fromRGB(63, 50, 38),
		}, 0.25, "Cubic")
	)
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

	self.manifest = ReplicatedStorage.resources.inventoryItemTemplate:Clone()
	self.manifest.container.rarity.ImageColor3 = rarity.primaryColor
	self.manifest.LayoutOrder = -rarity.order - self.data.power
	self.manifest.Name = self.indexId
	self.manifest.container.content.Image = self.data.iconId
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

local itemObject = objects.new(itemClass, {})

local new = function(itemType, dat, data)
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

		local loaded = {}
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
		end)

		playerDataHandler:connect({ "equipped", "weapon" }, function(change)
			local equipped = inventoryGui.mainframe.lower.Sword:FindFirstChild(change.new)
			local unequipped = change.old and inventoryGui.mainframe.lower.Sword:FindFirstChild(change.old)

			if unequipped then
				unequipped.container.equipped.Visible = false
			end
			if equipped then
				equipped.container.equipped.Visible = true
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
				inputShowing:equip()
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

		--[[for _, item in pairs(weapons) do
            new("Sword", item.id, {
                equipped = false
            }, item):render()
        end]]
	end,
}

