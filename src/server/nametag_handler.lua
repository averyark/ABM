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

local module = require(Astrax.module)
local objects = require(Astrax.objects)
local debugger = require(Astrax.debugger)

local roles = require(script.Parent.roles)
local ranks = require(script.Parent.ranks)

type nametagData = {
	roles: { number },
	rankId: number,
}

local new = function(player: Player, data: nametagData)
	player.Character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	local preexistingNametag = player.Character:FindFirstChild("nametag")
	if preexistingNametag then
		preexistingNametag:Destroy()
	end

	local rank = ranks[data.rankId]

	local nametag = ReplicatedStorage.resources.nametag:Clone()
	nametag.displayname.Text = player.DisplayName
	nametag.rank.Text = rank.name
	nametag.rank.TextColor3 = rank.textColor

	for _, id in pairs(data.roles) do
		local role = roles[id]
		if role then
			local roleIcon = nametag.roleContainer.template:Clone()
			roleIcon.Image = role.icon
			roleIcon.Name = role.name
			roleIcon.Visible = true
			roleIcon.Parent = nametag.roleContainer
		end
	end

	nametag.Parent = player.Character
	return nametag
end

local newOnCharacter = function(player)
	player.CharacterAdded:Connect(function(character)
		new(player, {
			rankId = 1,
			roles = {
				1,
				2,
			},
		})
	end)
	if player.Character then
		new(player, {
			rankId = 1,
			roles = {
				1,
				2,
			},
		})
	end
end

return {
	new = new,
	preload = function(self)
		Players.PlayerAdded:Connect(newOnCharacter)

		for _, player in pairs(Players:GetPlayers()) do
			Promise.try(newOnCharacter, player)
		end
	end,
}
