--!strict
--[[
    FileName    > currencies.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 22/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
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
local upgrades = require(ReplicatedStorage.shared.upgrades)
local levels = require(ReplicatedStorage.shared.levels)
local ascension = require(ReplicatedStorage.shared.ascension)
local weapons = require(ReplicatedStorage.shared.weapons)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)
local main = require(script.Parent.main)
local heros = require(ReplicatedStorage.shared.heros)

local getValueFromUpgrades = function(upgradeType)
    local playerData = playerDataHandler.getPlayer()
    local value = 0
    for worldIndex, upgradeContent in pairs(playerData.data.upgrades) do
        for upgradeId, upgradeLevel in pairs(upgradeContent) do
            local data = upgrades.contents[worldIndex][upgradeId]
            if data.type == upgradeType then
                value += data.values[upgradeLevel] or 0
            end
        end
    end
    return value
end

local uiSounds = ReplicatedStorage.resources.ui_sound_effects

local currencies = {}

local findItemWithIndexId = function(tbl, id)
	for _, dat in pairs(tbl) do
		if dat.index == id then
			return dat
		end
	end
end
local find = function<t>(id: t & number): typeof(heros[t])
	for _, dat in pairs(heros) do
		if dat.id == id then
			return dat
		end
	end
	return nil
end
local getTotalMulti = function()
	local data = playerDataHandler.getPlayer().data
	local m = 0
	for _, indexId in pairs(data.equipped.hero) do
		m += find(findItemWithIndexId(data.inventory.hero, indexId).id).multiplier
	end
	return m
end
local findSword = function<t>(id: number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
		end
	end
	return nil
end

local powerInfo = function()
	local ui = Players.LocalPlayer.PlayerGui.powerInfo
	local playerData = playerDataHandler.getPlayer().data
	local weaponIndex = playerData.equipped.weapon
	local weaponIndex2 = playerData.equipped.weapon2
	local weaponMeta: {level: number, id: number, index: number}
	local weaponMeta2: {level: number, id: number, index: number}

	for _, dat in pairs(playerData.inventory.weapon) do
		if dat.index == weaponIndex then
			weaponMeta = dat
			break
		end
	end

	if weaponIndex2 then
		for _, dat in pairs(playerData.inventory.weapon) do
			if dat.index == weaponIndex2 then
				weaponMeta2 = dat
				break
			end
		end
	end

	local weaponData = findSword(weaponMeta.id)
	local weaponData2 =  weaponMeta2 and findSword(weaponMeta2.id)

	local weaponPower = weaponData.power
	local weaponPower2 = weaponData2 and weaponData2.power
	local upgradeM = getValueFromUpgrades("Power Gain")
	local ascensionM = ascension.getPowerMultiplier(playerData.ascension)
	local levelM = math.max(levels[playerData.level].multiplier, 1)
	local swordLevelM = (itemLevel.getMultiFromLevel(weaponMeta.level) or 1)
	local swordLevelM2 = weaponMeta2 and (itemLevel.getMultiFromLevel(weaponMeta2.level) or 1)
	local heroM = getTotalMulti()

	local base = if weaponPower2 then (weaponPower * swordLevelM) + (weaponPower2 * swordLevelM2) else (weaponPower * swordLevelM)
	local value =  base * (upgradeM + ascensionM + levelM + heroM)
	local abbreviated = value > 999
	ui.mainframe.lower.power.inner.label.Text = number.abbreviate(value, 2) .. (abbreviated and "+" or "")

	if weaponPower2 then
		ui.mainframe.lower.scroll.sword.number.Text =
		`{number.abbreviate(weaponPower, 2)} + {number.abbreviate(weaponPower2, 2)}`
		ui.mainframe.lower.scroll.swordLevel.number.Text = `x{("%.2f"):format(swordLevelM)} + x{("%.2f"):format(swordLevelM2)}`
	else
		ui.mainframe.lower.scroll.sword.number.Text = number.abbreviate(weaponPower, 2)
		ui.mainframe.lower.scroll.swordLevel.number.Text = `x{("%.2f"):format(swordLevelM)}`
	end
	
	ui.mainframe.lower.scroll.characterLevel.number.Text = `x{("%.2f"):format(levelM)}`
	ui.mainframe.lower.scroll.ascensionBonus.number.Text = `x{("%.2f"):format(ascensionM)}`
	ui.mainframe.lower.scroll.upgradeBonus.number.Text = `x{("%.2f"):format(upgradeM)}`
	ui.mainframe.lower.scroll.heroBonus.number.Text =`x{("%.2f"):format(heroM)}`

	main.focus(ui, true)
end

function currencies:load()
	local currenciesObject = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud").currencies
	local earnCurrency = Players.LocalPlayer.PlayerGui:WaitForChild("earnCurrency")

	local coins = currenciesObject.coins.inner.label
	local power = currenciesObject.power.inner.label
	local otween
	local otween2
	local update = function(value)
		local abbreviated = value > 999
		if otween then
			otween:Destroy()
			otween = nil
		end
		otween = tween.instance(coins, {
			TextSize = math.min(coins.TextSize + 3, 29),
			--Rotation = math.random(-5, 5),
		}, 0.1).Completed:Wait()
		coins.Text = number.abbreviate(value, 2) .. (abbreviated and "+" or "")
		otween = tween.instance(coins, {
			TextSize = 21,
			--Rotation = 0,
		}, 0.1)
	end

	local updatePower = function()
		if otween2 then
			otween2:Destroy()
			otween2 = nil
		end

		local playerData = playerDataHandler.getPlayer().data
		local weaponIndex = playerData.equipped.weapon
		local weaponIndex2 = playerData.equipped.weapon2
		local weaponMeta: {level: number, id: number, index: number}
		local weaponMeta2: {level: number, id: number, index: number}

		for _, dat in pairs(playerData.inventory.weapon) do
			if dat.index == weaponIndex then
				weaponMeta = dat
				break
			end
		end

		if weaponIndex2 then
			for _, dat in pairs(playerData.inventory.weapon) do
				if dat.index == weaponIndex2 then
					weaponMeta2 = dat
					break
				end
			end
		end

		local weaponData = findSword(weaponMeta.id)
		local weaponData2 =  weaponMeta2 and findSword(weaponMeta2.id)

		local weaponPower = weaponData.power * (itemLevel.getMultiFromLevel(weaponMeta.level) or 1)
		local weaponPower2 = weaponData2 and weaponData2.power * (itemLevel.getMultiFromLevel(weaponMeta2.level) or 1)
		local baseDamage =  if weaponData2 then (weaponPower2 + weaponPower) else weaponPower
		local value = baseDamage *
		(
			getTotalMulti()
			+ getValueFromUpgrades("Power Gain")
			+ ascension.getPowerMultiplier(playerData.ascension)
			+ math.max(levels[playerData.level].multiplier, 1)
		)

		BridgeNet.CreateBridge("updateRank"):Fire()
		
		local abbreviated = value > 999

		otween2 = tween.instance(power, {
			TextSize = math.min(power.TextSize + 3, 29),
			--Rotation = math.random(-5, 5),
		}, 0.1).Completed:Wait()
		power.Text = number.abbreviate(value, 2) .. (abbreviated and "+" or "")
		otween2 = tween.instance(power, {
			TextSize = 21,
			--Rotation = 0,
		}, 0.1)
	end

	playerDataHandler:connect({ "coins" }, function(data)
		if not playerDataHandler.getPlayer().data.settings[6] then
			return update(data.new)
		end
		local n = playerDataHandler:findChanges(data)
		if n then
			task.spawn(function()
				local clone = ReplicatedStorage.resources.coinObtained:Clone()
				clone.label.Text = number.abbreviate(n, 2)
				clone.Parent = earnCurrency.coin

				clone.icon.ImageTransparency = 1
				clone.label.TextTransparency = 1

				tween.instance(clone.icon, {
					ImageTransparency = 0
				}, .15)
				tween.instance(clone.label, {
					TextTransparency = 0
				}, .15)

				local pos = UDim2.fromScale(math.random(), math.random())
				
				clone.Position = pos

				tween.instance(clone, {
					Position = pos - UDim2.fromScale(0, 0.1)
				}, 1).Completed:Wait()
				tween.instance(clone.icon, {
					ImageTransparency = 1
				}, .5)
				tween.instance(clone.label, {
					TextTransparency = 1
				}, .5)
				tween.instance(clone.label.stroke, {
					Transparency = 1
				}, .5).Completed:Wait()
				clone:Destroy()
			end)
		end
		update(data.new)
	end)
	
	playerDataHandler:connect({ "equipped" }, updatePower)
	playerDataHandler:connect({ "upgrades" }, updatePower)
	playerDataHandler:connect({ "level" }, updatePower)

	main.initUi(Players.LocalPlayer.PlayerGui:WaitForChild("powerInfo"))
	currenciesObject.power.button.Activated:Connect(powerInfo)
	


end

return currencies
