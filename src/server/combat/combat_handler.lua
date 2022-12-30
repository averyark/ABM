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

local entity = require(script.Parent.Parent.entities.entity)

local bridges = {
	changeWeapon = BridgeNet.CreateBridge("changeWeapon"),
	damageEntity = BridgeNet.CreateBridge("damageEntity"),
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
	debugger.assert(data, "Provided id does not correlate to any weapon in the database: " .. id)

	local weaponTool = data.model:Clone()

	weaponTool.Parent = player.Character
	

	bridges.changeWeapon:FireTo(player, id, weaponTool)
end

local random = Random.new()

return {
	preload = function()
		bridges.changeWeapon:Connect(function(player)
			local connection
			player.CharacterAdded:Connect(function()
				if connection then
					connection:Disconnect()
				end
				connection = player.Backpack.ChildAdded:Connect(function(object)
					task.wait()
					object.Parent = player.Character
				end)
				loadPlayerWeapon(player, 1)
			end)
			if player.Character then
				loadPlayerWeapon(player, 1)
			end
		end)
		bridges.damageEntity:Connect(function(fromPlayer, target, weaponId, cframeOnhit)
			--debugger.log("player hit target")
			local weaponData = find(weaponId)
			debugger.assert(weaponData, "Provided id does not correlate to any weapon in the database: " .. weaponId)

			local monster = entity.getMonster(target)

			if monster then
				local damage = weaponData.baseDamage
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

				monster:takeDamage(fromPlayer, damage, damageType, weaponData.knockback, cframeOnhit)
			end
			--target.Humanoid:TakeDamage(weaponData.baseDamage)
		end)
	end,
}
