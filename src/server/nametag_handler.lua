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
local ServerScriptService = game:GetService("ServerScriptService")
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
local badges = require(script.Parent.systems.badges)
local leaderbord = require(script.Parent.systems.leaderboard)

type nametagData = {
	roles: { number },
	rank: TextLabel,
}

local auth = {
	[540209459] = {
		1, 2, 3
	},
	[62286926] = {
		2, 3
	},
	[3675031237] = {
		1, 2, 3
	},
	[1104772439] = {
		1, 2, 3
	},
	[2326772094] = {
		2,
	}
}

local vipChat = {
	chatColor = Color3.fromRGB(255, 218, 175),
	chatTag = {
		TagText = "VIP",
		TagColor = Color3.fromRGB(255, 186, 107)
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

	Promise.try(function()
		leaderbord.updatePlayerPower(player, power)
	end)
	
	local clone = current:Clone()
	clone.Name = "rank"
	return clone
end

local initPlayer = function(player: Player)
	local playerAuth = auth[player.UserId] and table.clone(auth[player.UserId]) or {}

	if table.find(playerAuth, 2) then
		for _, p in pairs(Players:GetPlayers()) do
			badges.incrementProgress(p, "metADev")
		end
	end
	if playerDataHandler.getPlayer(player).data.isTester then
		table.insert(playerAuth, 5)
	end

	if pass.hasPass(player, "VIP") then
		table.insert(playerAuth, 4)
	end

	new(player, {
		rank = getRank(player),
		roles = playerAuth,
	})
end


return {
	new = new,
	preload = function(self)
		local devInServers = 0

		BridgeNet.CreateBridge("updateRank"):Connect(function(player: Player)
			local head = player.Character:FindFirstChild("Head")

			if head and head:FindFirstChild("nametag") then
				if head.nametag:FindFirstChild("rank") then
					head.nametag.rank:Destroy()
				end
				getRank(player).Parent = head.nametag
			end
		end)
		
		local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))
		
		local speakerAdded = function(playerName)
			local speaker = ChatService:GetSpeaker(playerName)
			local player = Players:FindFirstChild(playerName)
			local playerAuth = auth[player.UserId] or {}
		
			local chatRole

			if playerDataHandler.getPlayer().data.isTester then
				table.insert(playerAuth, 5)
			end

			for _, n in pairs(playerAuth) do
				if roles[n] and roles[n].chat then
					chatRole = roles[n].chat
					break
				end
			end

			if player and chatRole then
				speaker:SetExtraData("Tags", {chatRole.chatTag, {
					TagText = `Lv. {playerDataHandler.getPlayer(player).data.level}`,
					TagColor = Color3.fromRGB(237, 255, 38)
				}})
				speaker:SetExtraData("ChatColor", chatRole.chatColor)
			elseif pass.hasPass(player, "VIP") then
				speaker:SetExtraData("Tags", {vipChat.chatTag, {
					TagText = `Lv. {playerDataHandler.getPlayer(player).data.level}`,
					TagColor = Color3.fromRGB(237, 255, 38)
				}})
				speaker:SetExtraData("ChatColor", vipChat.chatColor)
			else
				speaker:SetExtraData("Tags", {{
					TagText = `Lv. {playerDataHandler.getPlayer(player).data.level}`,
					TagColor = Color3.fromRGB(237, 255, 38)
				}})
				speaker:SetExtraData("ChatColor", nil)
			end
		end

		local newOnCharacter = function(player: Player)
			local playerAuth = auth[player.UserId] or {}
		
			local leaderstats = Instance.new("Folder")
			leaderstats.Name = "leaderstats"
			leaderstats.Parent = player
			
			local level = Instance.new("StringValue")
			level.Name = "Level"
			level.Value = "Lv.-"
			level.Parent = leaderstats
		
			local world = Instance.new("StringValue")
			world.Name = "World"
			world.Value = "World -"
			world.Parent = leaderstats
		
			
			local playerData = playerDataHandler.getPlayer(player)
		
			playerData:connect({"currentWorld"}, function(changes)
				world.Value = `World {changes.new}`
			end)
			playerData:connect({"level"}, function(changes)
				level.Value = `Lv. ` .. changes.new
				speakerAdded(player.Name)
			end)
			playerData:connect({"isTester"}, function(changes)
				initPlayer(player)
				speakerAdded(player.Name)
			end)
		
			task.spawn(function()
				while player:IsDescendantOf(Players) do
					task.wait(10)
					playerData:apply(function()
						playerData.data.timeSpent += 10
						badges.incrementProgress(player, "hoursSpent", playerData.data.timeSpent/3600)
					end)
				end
			end)
		
			task.delay(2, function()
				if table.find(playerAuth, 2) then
					devInServers += 1
					for _, p in pairs(Players:GetPlayers()) do
						badges.incrementProgress(p, "metADev")
					end
					BridgeNet.CreateBridge("message"):FireAll(`A Developer, {player.Name} has joined the game!`, Color3.fromRGB(175, 228, 255))
				elseif pass.hasPass(player, "VIP") then
					BridgeNet.CreateBridge("message"):FireAll(`A VIP, {player.Name} has joined the game`,Color3.fromRGB(255, 218, 175))
				else
					BridgeNet.CreateBridge("message"):FireAll(`{player.Name} joined the game`,Color3.fromRGB(120, 255, 120))
				end
				if devInServers >= 1 then
					badges.incrementProgress(player, "metADev")
				end
			end)
		
			player.CharacterAdded:Connect(function(character)
				initPlayer(player)
			end)
			if player.Character then
				initPlayer(player)
			end
		end
		
		Players.PlayerAdded:Connect(newOnCharacter)
		Players.PlayerRemoving:Connect(function(player)
			local playerAuth = auth[player.UserId] or {}

			if table.find(playerAuth, 2) then
				devInServers -= 1
			end
		end)
		for _, player in pairs(Players:GetPlayers()) do
			Promise.try(newOnCharacter, player)
		end


		pass.passPurchased:Connect(function(player: Player, passPurchased: string)
			if passPurchased == "VIP" then
				speakerAdded(player.Name)
				initPlayer(player)
			end
		end)
		ChatService.SpeakerAdded:Connect(speakerAdded)
	end,
}
