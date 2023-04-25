local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local dump = Janitor.new()
local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = "__DEBUG"
selectionBox.Color3 = Color3.fromRGB(50, 50, 50)
selectionBox.LineThickness = 0.05
selectionBox.SurfaceTransparency = 0.95
selectionBox.SurfaceColor3 = Color3.fromRGB(205, 205, 205)

local debugHitbox = Instance.new("Highlight")
debugHitbox.Name = "__DEBUG"
debugHitbox.OutlineColor = Color3.fromRGB(200, 200, 200)
debugHitbox.FillColor = Color3.fromRGB(150, 150, 150)
debugHitbox.FillTransparency = .8

local renderCharacterSelection = function(character)
	local characterSelection = debugHitbox:Clone()
	characterSelection.Adornee = character
	characterSelection.Parent = character
	local hrpSelection = selectionBox:Clone()
	hrpSelection.Adornee = character:WaitForChild("HumanoidRootPart")
	hrpSelection.SurfaceTransparency = 1
	hrpSelection.Color3 = Color3.fromRGB(205, 205, 205)
	hrpSelection.Parent = character
end

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)

		if arguments[1] == "true" then
			local reg = function(player)
				dump:Add(player.CharacterAdded:Connect(function(character)
					renderCharacterSelection(character)
				end))
				if player.Character then
					renderCharacterSelection(player.Character)
				end
			end
			dump:Add(Players.PlayerAdded:Connect(reg))
			for _, player in pairs(Players:GetPlayers()) do
				task.spawn(reg, player)
			end
		elseif arguments[1] == "false" then
			dump:Cleanup()
		else
			error("Invalid arguments[1]")
		end
	end,
}

