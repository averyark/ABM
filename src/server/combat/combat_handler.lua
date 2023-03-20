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

local entity = require(script.Parent.Parent.entities.entity)
local upgrade = require(script.Parent.Parent.systems.upgrade)

local bridges = {
	changeWeapon = BridgeNet.CreateBridge("changeWeapon"),
	damageEntity = BridgeNet.CreateBridge("damageEntity"),
	playEntitySound = BridgeNet.CreateBridge("playEntitySound"),
	equipWeapon = BridgeNet.CreateBridge("equipWeapon"),
	upgradeWeapon = BridgeNet.CreateBridge("upgradeWeapon"),
	trashWeapon = BridgeNet.CreateBridge("trashWeapon"),
}

local find = function<t>(id: t & number): typeof(weapons[t])
	for _, data in pairs(weapons) do
		if data.id == id then
			return data
		end
	end
	return nil
end

local loadPlayerWeapon = function(player, id)
	debugger.assert(t.instanceIsA("Player")(player))

	local data = find(id)
	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. tostring(id))

	for _, tool in pairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			tool:Destroy()
		end
	end

	local weaponTool = data.model:Clone()

	weaponTool.Parent = player.Character

	bridges.changeWeapon:FireTo(player, id, weaponTool)
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
			end
			
			player.CharacterAdded:Connect(connect)
			if player.Character then
				connect(player.Character)
			end
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

			print(#buffer, req)

			if #buffer >= req then
				playerData:apply(function()
					for i = req, 1, -1 do
						local itemDat = buffer[i]
						if playerData.data.equipped.weapon == itemDat.index then
							playerData.data.equipped.weapon = dat.index
						end
						if itemDat.index ~= dat.index then
							table.remove(
								playerData.data.inventory.weapon,
								table.find(playerData.data.inventory.weapon, itemDat)
							)
						end
					end
					dat.level += 1
				end)

				print("success", playerData.data)

				loadPlayerWeapon(player, findItemWithIndexId(playerData.data.inventory.weapon, playerData.data.equipped.weapon).id)
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

			if playerData.data.inventory.equipped == indexId then
				print("ATTEMPTING TO TRASH EQUIPPED ITEM")
				-- message
				return
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

			local equippedWeaponData = findItemWithIndexId(
				playerData.data.inventory.weapon,
				playerData.data.equipped.weapon
			)
			
			local weaponData = find(equippedWeaponData.id)

			local monster = entity.getMonster(target)

			if monster then
				local damage = weaponData.power * (itemLevel.getMultiFromLevel(equippedWeaponData.level) or 1)
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

				damage *= math.max(levels[playerData.data.level].multiplier, 1) * (1 + upgrade.getValueFromUpgrades(fromPlayer, "Power Gain"))
				
				--bridges.playEntitySound:FireAllInRange(monster.rootpart.Position, 50, monster.rootpart, "hit")
				--print("damage:", damage .. "\nknockback:", weaponData.knockback .. "\ndamageType:", damageType .. "\nmultiFromLevel", itemLevel.getMultiFromLevel(equippedWeaponData.level))
				monster:takeDamage(fromPlayer, damage, damageType, weaponData.knockback, cframeOnhit)
			end
			--target.Humanoid:TakeDamage(weaponData.baseDamage)
		end)
	end,
}
