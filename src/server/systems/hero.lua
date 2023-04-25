--!strict
--[[
    FileName    > hero.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 17/04/2023
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
local workspaceDebugManifest = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local heros = require(ReplicatedStorage.shared.heros)
local pass = require(script.Parent.pass)
local heroHandler = require(script.Parent.Parent.heros.heroHandler)

local bridges = {
    equipHero = BridgeNet.CreateBridge("equipHero"),
    unequipHero = BridgeNet.CreateBridge("unequipHero"),
    trashHero = BridgeNet.CreateBridge("trashHero"),
    notifError = BridgeNet.CreateBridge("notifError"),
	readyToLoadHeroAnim = BridgeNet.CreateBridge("readyToLoadHeroAnim"),
}
local find = function<t>(id: t & number): typeof(heros[t])
	for _, data in pairs(heros) do
		if data.id == id then
			return data
		end
	end
	return nil
end

local findItemWithIndexId = function(tbl, id)
	for _, dat in pairs(tbl) do
		if dat.index == id then
			return dat
		end
	end
end

--[[
	if not cache[player] then
		cache[player] = {}
	end

	for _, indexId: {
		id: number,
		index: number,
		level: number
	} in pairs(playerData.data.equipped.hero) do
		local itemData = findItemWithIndexId(playerData.data.inventory.hero, indexId)
		if not cache[player][itemData.index] then
			cache[player][itemData.index] = heroHandler.new(player, itemData.id, itemData.index):init()
		end
	end

	for i, hero in pairs(cache[player]) do
		if not table.find(playerData.data.equipped.hero, hero.index) then
			hero:Destroy()
			table.remove(cache[player], i)
		end
]]

local updatePlayerSpawnedHeros = function(player: Player)
	local playerData = playerDataHandler.getPlayer(player)

	if not playerData then
		return
	end

	for _, indexId in pairs(playerData.data.equipped.hero) do
		local itemData = findItemWithIndexId(playerData.data.inventory.hero, indexId)
		local hero = workspace.gameFolders.heros:FindFirstChild(`{player.UserId}-{indexId}`)
		if hero then
			continue
		end
		task.spawn(function()
			heroHandler.new(player, itemData.id, indexId):init()
		end)
	end

	for _, hero in pairs(workspace.gameFolders.heros:GetChildren()) do
		local userId, heroIndexId = hero.Name:match("(%d+)-(%d+)")

		if not userId or not heroIndexId then
			continue
		end

		userId = tonumber(userId)
		heroIndexId = tonumber(heroIndexId)

		if not userId == player.UserId then
			continue
		end

		if not table.find(playerData.data.equipped.hero, heroIndexId) then
			hero:Destroy()
		end
	end

end

return {
    load = function()
		Players.PlayerRemoving:Connect(function(player)
			for _, hero in pairs(workspace.gameFolders.heros:GetChildren()) do
				local userId = hero.Name:match("(%d)")
				if userId and userId == player.UserId then
					hero:Destroy()
				end
			end
		end)
		bridges.readyToLoadHeroAnim:Connect(function(player)
			updatePlayerSpawnedHeros(player)
		end)
        bridges.unequipHero:Connect(function(player, indexId)
            debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.hero, indexId)

			if not dat then
				return
			end -- player does not own the item

			playerData:apply(function()
                table.remove(playerData.data.equipped.hero, table.find(playerData.data.equipped.hero, indexId))
				updatePlayerSpawnedHeros(player)
			end)
        end)
        bridges.equipHero:Connect(function(player, indexId)
			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.hero, indexId)

			if not dat then
				return
			end -- player does not own the item

			local max = 2 + (pass.hasPass(player, "3HeroEquip") and 3 or 0) + (pass.hasPass(player, "VIP") and 1 or 0)

            if #playerData.data.equipped.hero >= max then
                return bridges.notifError:FireTo(player, `You already equipped {max} Heros, purchase the gamepass to increase the cap.`)
            end

			playerData:apply(function()
                table.insert(playerData.data.equipped.hero, indexId)
				updatePlayerSpawnedHeros(player)
			end)
		end)
        bridges.trashHero:Connect(function(player, indexId)
			debugger.assert(t.integer(indexId))
			local playerData = playerDataHandler.getPlayer(player)
			if not playerData then
				return
			end

			if table.find(playerData.data.equipped.hero, indexId) then
				bridges.notifError:FireTo(player, "You cannot Trash the item you're equipping!")
				return
			end

			local dat = findItemWithIndexId(playerData.data.inventory.hero, indexId)

			playerData:apply(function()
				table.remove(playerData.data.inventory.hero, table.find(playerData.data.inventory.hero, dat))
			end)
		end)
    end
}