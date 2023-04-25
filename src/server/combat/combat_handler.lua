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

local loadPlayerWeapon = function(player, id)
	debugger.assert(t.instanceIsA("Player")(player))

	local data = find(id)
	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. tostring(id))

	if player.Character:FindFirstChild("primary") then
		player.Character.primary:Destroy()
	end

	local weaponTool = data.model:Clone()

	weaponTool.Name = "primary"
	weaponTool.Parent = player.Character

	bridges.changeWeapon:FireTo(player, id, weaponTool)
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

				local dat = findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon).id
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

			loadPlayerWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, dat.index).id)
		end)
		bridges.upgradeWeapon:OnInvoke(function(player, indexId)
			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.weapon, indexId)
			local buffer = {}

			for _, sdat in pairs(playerData.data.inventory.weapon) do
				if sdat.id == dat.id and sdat.level == dat.level then
					table.insert(buffer, sdat)
				end
			end

			local req = itemLevel.getRequiredDuplicateFromLevel(dat.level)

			local shouldEquip = false

			if #buffer >= req then
				local done = false
				playerData:apply(function()
					for i = req, 1, -1 do
						local itemDat = buffer[i]
						if playerData.data.equipped.weapon2 == itemDat.index then
							playerData.data.equipped.weapon2 = nil
							if player.Charater and player.Character:FindFirstChild("secondary") then
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
					print(playerData.data.inventory.weapon)
					loadPlayerWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon).id)
					done = true
				end)
				local timeout = 5
				local clock = os.clock()
				repeat
					task.wait()
				until done or os.clock() - clock > timeout
				return true
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
				playerData.data.equipped.weapon2 = nil
				
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
	
				local weaponPower = weaponData.power * (itemLevel.getMultiFromLevel(equippedWeaponData.level) or 1)
				local weaponPower2 = weaponData2 and weaponData2.power * (itemLevel.getMultiFromLevel(equippedWeaponData2.level) or 1)

				local baseDamage =  if weaponPower2 then (weaponPower2 + weaponPower) else weaponPower
				local damage = baseDamage *
				(
					getTotalMulti()
					+ upgrade.getValueFromUpgrades(fromPlayer, "Power Gain")
					+ ascension.getPowerMultiplier(playerData.data.ascension)
					+ math.max(levels[playerData.data.level].multiplier, 1)
				)
				local damageType = "basic"

				if random:NextNumber() <= weaponData.critChance then
					local multiplication = 1
					if typeof(weaponData.critMultiplication) == "table" then
						multiplication = random:NextNumber(
							weaponData.critMultiplication[1],
							weaponData.critMultiplication[2]
						)
					else
						multiplication = weaponData.critMultiplication
					end
					damageType = "crit"
					damage *= multiplication
				end

				--bridges.playEntitySound:FireAllInRange(monster.rootpart.Position, 50, monster.rootpart, "hit")
				--print("damage:", damage .. "\nknockback:", weaponData.knockback .. "\ndamageType:", damageType .. "\nmultiFromLevel", itemLevel.getMultiFromLevel(equippedWeaponData.level))
				monster:takeDamage(fromPlayer, damage, damageType, weaponData.knockback, cframeOnhit)
			end
			--target.Humanoid:TakeDamage(weaponData.baseDamage)
		end)
	end,
}
