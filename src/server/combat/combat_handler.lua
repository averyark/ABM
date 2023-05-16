--!strict
--[[
    FileName    > combat_handler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/12/2022
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
local weapons = require(ReplicatedStorage.shared.weapons)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)
local levels = require(ReplicatedStorage.shared.levels)
local ascension = require(ReplicatedStorage.shared.ascension)
local entity = require(script.Parent.Parent.entities.entity)
local upgrade = require(script.Parent.Parent.systems.upgrade)
local heros = require(ReplicatedStorage.shared.heros)
local pass = require(script.Parent.Parent.systems.pass)
local abilities = require(ReplicatedStorage.shared.abilities)
local rarities = require(ReplicatedStorage.shared.rarities)

local bridges = {
	changeWeapon = BridgeNet.CreateBridge("changeWeapon"),
	damageEntity = BridgeNet.CreateBridge("damageEntity"),
	playEntitySound = BridgeNet.CreateBridge("playEntitySound"),
	equipWeapon = BridgeNet.CreateBridge("equipWeapon"),
	upgradeWeapon = BridgeNet.CreateBridge("upgradeWeapon"),
	trashWeapon = BridgeNet.CreateBridge("trashWeapon"),
	notifError = BridgeNet.CreateBridge("notifError"),
	notifMessage = BridgeNet.CreateBridge("notifMessage"),
	changeSecondaryWeapon = BridgeNet.CreateBridge("changeSecondaryWeapon"),
	equipSecondaryWeapon = BridgeNet.CreateBridge("equipSecondaryWeapon"),
	unequipSecondaryWeapon = BridgeNet.CreateBridge("unequipSecondaryWeapon"),
	bulkTrashItem = BridgeNet.CreateBridge("bulkTrashItem"),
	resetInventory = BridgeNet.CreateBridge("resetInventory")
}

local find = function<t>(id: t & number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
		end
	end
	return nil
end
local findHero = function<t>(id: t & number): typeof(heros[t])
	for _, dat in pairs(heros) do
		if dat.id == id then
			return dat
		end
	end
	return nil
end

local loadPlayerWeapon = function(player, dat)
	debugger.assert(t.instanceIsA("Player")(player))

	local data = find(dat.id)
	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. tostring(id))

	if player.Character:FindFirstChild("primary") then
		player.Character.primary:Destroy()
	end

	local weaponTool = data.model:Clone()

	weaponTool.Name = "primary"
	weaponTool.Parent = player.Character

	if dat.ability then
		local ability = abilities[dat.ability.id]
		if ability.onApply then
			ability.onApply(weaponTool)
		end
		weaponTool:SetAttribute("ability", dat.ability.id)
	end

	bridges.changeWeapon:FireTo(player, dat.id, weaponTool)
end

local loadSecondaryWeapon = function(player, id)
	debugger.assert(t.instanceIsA("Player")(player))

	local data = find(id)
	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. tostring(id))

	if player.Character:FindFirstChild("secondary") then
		player.Character.secondary:Destroy()
	end

	local weaponTool = data.model:Clone()
	local model = Instance.new("Model")
	model.Name = "secondary"
	model.Parent = player.Character

	for _, child in pairs(weaponTool:GetChildren()) do
		child.Parent = model
	end

	local handWeld = Instance.new("Weld")
	handWeld.Part0 = model.Handle
	handWeld.Part1 = player.Character["Left Arm"]
	handWeld.C1 = player.Character["Left Arm"].LeftGripAttachment.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
	handWeld.Parent = model

	bridges.changeSecondaryWeapon:FireTo(player, id, model)
end

local random = Random.new()
local playerDataHandler = require(ReplicatedStorage.shared.playerData)

local findItemWithIndexId = function(tbl, id)
	for _, dat in pairs(tbl) do
		if dat.index == id then
			return dat
		end
	end
end

local getChoiceFromChancePool = function(chancePool)
	local randomNumber = math.random()
	local n = 0
	for i, chance in pairs(chancePool) do
		if chance + n > randomNumber then
			return i
		end
		n += chance
	end
end

return {
	loadPlayerWeapon = loadPlayerWeapon,
	preload = function()
		bridges.changeWeapon:Connect(function(player)
			local connection
			local connect = function(character)
				if connection then
					connection:Disconnect()
				end
				connection = player.Backpack.ChildAdded:Connect(function(object)
					task.wait()
					object.Parent = character
				end)
				local playerData = playerDataHandler.getPlayer(player)
				if not playerData then
					return
				end

				local dat = findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon)
				loadPlayerWeapon(player, dat)
				if playerData.data.equipped.weapon2 then
					local dat2 = findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon2).id
					loadSecondaryWeapon(player, dat2)
				end
			end
			
			player.CharacterAdded:Connect(connect)
			if player.Character then
				connect(player.Character)
			end
		end)
		bridges.unequipSecondaryWeapon:Connect(function(player)
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			playerData:apply(function()
				playerData.data.equipped.weapon2 = nil
			end)

			if player.Character and player.Character:FindFirstChild("secondary") then
				player.Character.secondary:Destroy()
			end
		end)
		bridges.equipSecondaryWeapon:Connect(function(player, indexId)
			if not pass.hasPass(player, "DualWield") then
				return bridges.notifError:FireTo(player, "Error: You need the Dual Wield gamepass to equip a second sword.")
			end

			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.weapon, indexId)

			if not dat then
				return
			end -- player does not own the item

			playerData:apply(function()
				playerData.data.equipped.weapon2 = indexId
			end)

			loadSecondaryWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, dat.index).id)
		end)
		bridges.equipWeapon:Connect(function(player, indexId)
			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.weapon, indexId)

			if not dat then
				return
			end -- player does not own the item

			playerData:apply(function()
				playerData.data.equipped.weapon = indexId
			end)

			loadPlayerWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, dat.index))
		end)
		bridges.upgradeWeapon:Connect(function(player, indexId)
			print(indexId)
			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.weapon, indexId)
			local buffer = {}

			for _, sdat in pairs(playerData.data.inventory.weapon) do
				if sdat.id == dat.id and sdat.level == 0 then
					table.insert(buffer, sdat)
				end
			end

			local req = itemLevel.getRequiredDuplicateFromLevel(dat.level+1)

			local shouldEquip = false

			if #buffer >= req then
				playerData:apply(function()
					for i = req, 1, -1 do
						local itemDat = buffer[i]
						if playerData.data.equipped.weapon2 == itemDat.index then
							playerData.data.equipped.weapon2 = nil
							if player.Character and player.Character:FindFirstChild("secondary") then
								player.Character.secondary:Destroy()
							end
							bridges.notifMessage:FireTo(player, "Your secondary sword was unequipped because it was destroyed.")
						elseif playerData.data.equipped.weapon == itemDat.index then
							shouldEquip = true
						end
						if dat.index == itemDat.index then
							continue
						end
						table.remove(
							playerData.data.inventory.weapon,
							table.find(playerData.data.inventory.weapon, itemDat)
						)
					end

					if not dat.ability then
						local chancePool = {}
						for _, ability in pairs(abilities) do
							chancePool[ability.id] = ability.chance
						end
	
						local abilityId = getChoiceFromChancePool(chancePool)
	
						dat.level = 1
						dat.ability = {
							id = abilityId
						}

						local abilityData = abilities[abilityId]
						local rarityData = rarities[abilityData.rarity]

						bridges.notifMessage:FireTo(player, `Your sword was infused with a {rarityData.name} {abilityData.name}`, rarityData.primaryColor)
					else
						local abilityData = abilities[dat.ability.id]
						dat.level += 1
						bridges.notifMessage:FireTo(player, `{abilityData.name} upgraded from Lv. {dat.level-1} to Lv. {dat.level}`)
					end

					if shouldEquip then
						playerData.data.equipped.weapon = dat.index
					end

					BridgeNet.CreateBridge("playSound"):FireTo(player, SoundService.upgrade)

					loadPlayerWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon))
					task.delay(0.1, function()
						bridges.resetInventory:FireTo(player, dat.index)
					end)
				end)

				
				--[[local done = false
				playerData:apply(function()
					for i = req, 1, -1 do
						local itemDat = buffer[i]
						if playerData.data.equipped.weapon2 == itemDat.index then
							playerData.data.equipped.weapon2 = nil
							if player.Character and player.Character:FindFirstChild("secondary") then
								player.Character.secondary:Destroy()
							end
							bridges.notifMessage:FireTo(player, "Your secondary sword was unequipped because it was destroyed.")
						elseif playerData.data.equipped.weapon == itemDat.index then
							shouldEquip = true
						end
						table.remove(
							playerData.data.inventory.weapon,
							table.find(playerData.data.inventory.weapon, itemDat)
						)
					end
					playerData.data.stats.itemsObtained.weapon += 1
					local id = playerData.data.stats.itemsObtained.weapon
					table.insert(playerData.data.inventory.weapon, {
						index = id,
						id = dat.id,
						level = dat.level+1,
					})
					if shouldEquip then
						playerData.data.equipped.weapon = id
					end
					loadPlayerWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon).id)
					done = true
				end)
				task.wait()
				task.wait()
				return true]]

			end
			return false
		end)
		bridges.trashWeapon:Connect(function(player, indexId)
			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			if playerData.data.equipped.weapon == indexId then
				print("ATTEMPTING TO TRASH EQUIPPED ITEM")
				bridges.notifError:FireTo(player, "You cannot Trash the item you primary sword!")
				return
			elseif playerData.data.equipped.weapon2 == indexId then
				playerData:apply(function()
					playerData.data.equipped.weapon2 = nil
				end)
				
				if player.Charater and player.Character:FindFirstChild("secondary") then
					player.Character.secondary:Destroy()
				end
				bridges.notifMessage:FireTo(player, "Your secondary sword was unequipped because it was destroyed.")
			end

			local dat = findItemWithIndexId(playerData.data.inventory.weapon, indexId)

			playerData:apply(function()
				table.remove(playerData.data.inventory.weapon, table.find(playerData.data.inventory.weapon, dat))
			end)
		end)
		bridges.bulkTrashItem:Connect(function(player, items)
			debugger.assert(t.table(items))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end
			for _, indexId in pairs(items.swords) do
				if playerData.data.equipped.weapon == indexId then
					bridges.notifError:FireTo(player, "You cannot Trash the item you primary sword!")
					table.remove(items.swords, table.find(items.swords, indexId))
				elseif playerData.data.equipped.weapon2 == indexId then
					playerData:apply(function()
						playerData.data.equipped.weapon2 = nil
					end)
					
					if player.Charater and player.Character:FindFirstChild("secondary") then
						player.Character.secondary:Destroy()
					end
					bridges.notifMessage:FireTo(player, "Your secondary sword was unequipped because it was destroyed.")
				end
			end
			for _, indexId in pairs(items.heroes) do
				if table.find(playerData.data.equipped.hero, indexId) then
					bridges.notifError:FireTo(player, "You cannot Trash the item you're equipping!")
					table.remove(items.heroes, table.find(items.heroes, indexId))
				end
			end

			playerData:apply(function()
				for _, indexId in pairs(items.swords) do
					local dat = findItemWithIndexId(playerData.data.inventory.weapon, indexId)
					table.remove(playerData.data.inventory.weapon, table.find(playerData.data.inventory.weapon, dat))
				end
				for _, indexId in pairs(items.heroes) do
					local dat = findItemWithIndexId(playerData.data.inventory.hero, indexId)
					table.remove(playerData.data.inventory.hero, table.find(playerData.data.inventory.hero, dat))
				end
			end)
		end)
		bridges.damageEntity:Connect(function(fromPlayer, target, cframeOnhit)
			--debugger.log("player hit target")
			local playerData = playerDataHandler.getPlayer(fromPlayer)
			if not playerData then
				return
			end

			local monster = entity.getMonster(target)

			if monster then
				local equippedWeaponData = findItemWithIndexId(
					playerData.data.inventory.weapon,
					playerData.data.equipped.weapon
				)
				local equippedWeaponData2
				if playerData.data.equipped.weapon2 then
					equippedWeaponData2 = findItemWithIndexId(
						playerData.data.inventory.weapon,
						playerData.data.equipped.weapon2
					)
				end
				
				local getTotalMulti = function()
					local m = 0
					for _, indexId in pairs(playerData.data.equipped.hero) do
						m += findHero(findItemWithIndexId(playerData.data.inventory.hero, indexId).id).multiplier
					end
					return m
				end
				
				local weaponData = find(equippedWeaponData.id)
				local weaponData2 = equippedWeaponData2 and find(equippedWeaponData2.id)
	
				local weaponPower = weaponData.power
				local weaponPower2 = weaponData2 and weaponData2.power

				local baseDamage =  if weaponPower2 then (weaponPower2 + weaponPower) else weaponPower
				local damage = baseDamage *
				(
					getTotalMulti()
					+ upgrade.getValueFromUpgrades(fromPlayer, "Power Gain")
					+ ascension.getPowerMultiplier(playerData.data.ascension)
					+ math.max(levels[playerData.data.level].multiplier, 1)
				)
				local damageType = "basic"

				local extraCritChance = 0
				local extraCritDamage = 1

				if equippedWeaponData.ability and equippedWeaponData.ability == 1 then
					local ability = abilities[equippedWeaponData.ability.id]
					local d, r = ability.getValue(equippedWeaponData.level)
					extraCritChance += r or 0
					extraCritDamage += d or 0
				end

				if random:NextNumber() <= weaponData.critChance + extraCritChance then
					local multiplication = 1
					local critDmgUp = upgrade.getValueFromUpgrades(fromPlayer, "Critical Hit")
					if typeof(weaponData.critMultiplication) == "table" then
						multiplication = random:NextNumber(
							weaponData.critMultiplication[1],
							weaponData.critMultiplication[2]
						)
					else
						multiplication = weaponData.critMultiplication
					end
					damageType = "crit"
					damage *= (multiplication * extraCritDamage) + critDmgUp
				end

				local shouldDamageQ = true

				if equippedWeaponData.ability then
					local ability = abilities[equippedWeaponData.ability.id]

					if ability and ability.onTargetHit then
						local shouldDamge, newDamage = ability.onTargetHit(monster, equippedWeaponData.level, damage, fromPlayer, cframeOnhit)
						damage = newDamage and newDamage or damage
						shouldDamageQ = shouldDamge
					end
				end

				--bridges.playEntitySound:FireAllInRange(monster.rootpart.Position, 50, monster.rootpart, "hit")
				--print("damage:", damage .. "\nknockback:", weaponData.knockback .. "\ndamageType:", damageType .. "\nmultiFromLevel", itemLevel.getMultiFromLevel(equippedWeaponData.level))
				if shouldDamageQ then
					monster:takeDamage(fromPlayer, damage, damageType, weaponData.knockback, cframeOnhit)
				end
			end
			--target.Humanoid:TakeDamage(weaponData.baseDamage)
		end)
	end,
}
