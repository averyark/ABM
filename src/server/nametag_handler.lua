--!strict
--[[
    FileName    > nametag_handler.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/12/2022
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
local Astrax = require(ReplicatedStorage.Packages.Astrax)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)
local upgrades = require(ReplicatedStorage.shared.upgrades)
local levels = require(ReplicatedStorage.shared.levels)
local ascension = require(ReplicatedStorage.shared.ascension)
local weapons = require(ReplicatedStorage.shared.weapons)
local itemLevel = require(ReplicatedStorage.shared.itemLevel)
local heros = require(ReplicatedStorage.shared.heros)
local roles = require(script.Parent.roles)
local ranks = require(script.Parent.ranks)
local upgrade = require(script.Parent.systems.upgrade)
local pass = require(script.Parent.systems.pass)

type nametagData = {
	roles: { number },
	rank: TextLabel,
}

local auth = {
	[540209459] = {
		1, 2, 3
	}
}

local new = function(player: Player, data: nametagData)
	player.Character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	local head = player.Character:FindFirstChild("Head")

	if not head then
		head = player.Character:WaitForChild("head", 5)
		if not head then return end
	end

	local preexistingNametag = head:FindFirstChild("nametag")
	if preexistingNametag then
		preexistingNametag:Destroy()
	end

	local nametag = ReplicatedStorage.resources.nametag:Clone()
	nametag.displayname.Text = player.DisplayName
	
	if nametag:FindFirstChild("rank") then
		nametag.rank:Destroy()
	end

	data.rank.Parent = nametag

	for _, id in pairs(data.roles) do
		local role = roles[id]
		local roleIcon = nametag.roleContainer.template:Clone()
		roleIcon.Image = role.icon
		roleIcon.Name = role.name
		roleIcon.Visible = true
		roleIcon.Parent = nametag.roleContainer
	end

	nametag.Parent = head
	return nametag
end

local findSword = function<t>(id: t & number): typeof(weapons[t])
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
local findItemWithIndexId = function(tbl, id)
	for _, dat in pairs(tbl) do
		if dat.index == id then
			return dat
		end
	end
end

local getPlayerPower = function(player: Player)
	local playerData = playerDataHandler.getPlayer(player)
			
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
	
	local weaponData = findSword(equippedWeaponData.id)
	local weaponData2 = equippedWeaponData2 and findSword(equippedWeaponData2.id)

	local weaponPower = weaponData.power * (itemLevel.getMultiFromLevel(equippedWeaponData.level) or 1)
	local weaponPower2 = weaponData2 and weaponData2.power * (itemLevel.getMultiFromLevel(equippedWeaponData2.level) or 1)

	local basePower =  if weaponPower2 then (weaponPower2 + weaponPower) else weaponPower
	return basePower *
	(
		getTotalMulti()
		+ upgrade.getValueFromUpgrades(player, "Power Gain")
		+ ascension.getPowerMultiplier(playerData.data.ascension)
		+ math.max(levels[playerData.data.level].multiplier, 1)
	)
end

local getRank = function(player: Player)
	local power = getPlayerPower(player)
	local current

	for _, rank in pairs(ReplicatedStorage.ranks:GetChildren()) do
		local rPower = tonumber(rank.Name)
		if power > rPower then
			if current then
				if rPower > tonumber(current.Name) then
					current = rank
				end
			else
				current = rank
			end
		end
	end
	
	local clone = current:Clone()
	clone.Name = "rank"
	return clone
end

local initPlayer = function(player: Player)
	local playerAuth = table.clone(auth[player.UserId]) or {}

	if pass.hasPass(player, "VIP") then
		table.insert(playerAuth, 4)
	end

	new(player, {
		rank = getRank(player),
		roles = playerAuth,
	})
end

local newOnCharacter = function(player)
	player.CharacterAdded:Connect(function(character)
		initPlayer(player)
	end)
	if player.Character then
		initPlayer(player)
	end
end

return {
	new = new,
	preload = function(self)
		Players.PlayerAdded:Connect(newOnCharacter)

		BridgeNet.CreateBridge("updateRank"):Connect(function(player: Player)
			local head = player.Character:FindFirstChild("Head")

			if head and head:FindFirstChild("nametag") then
				if head.nametag:FindFirstChild("rank") then
					head.nametag.rank:Destroy()
				end
				getRank(player).Parent = head.nametag
			end
		end)

		for _, player in pairs(Players:GetPlayers()) do
			Promise.try(newOnCharacter, player)
		end
	end,
}
