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
selectionBox.Color3 = Color3.fromRGB(0, 0, 255)
selectionBox.LineThickness = 0.05
selectionBox.SurfaceTransparency = 0.95
selectionBox.SurfaceColor3 = Color3.fromRGB(0, 0, 255)

local renderEntitySelection = function(entity)
	local hitboxSelection = selectionBox:Clone()
	hitboxSelection.Adornee = entity:WaitForChild("Hitbox")
	hitboxSelection.Parent = entity.Damagebox
	local damageboxSelection = selectionBox:Clone()
	damageboxSelection.Adornee = entity:WaitForChild("Damagebox")
	damageboxSelection.SurfaceTransparency = 1
	damageboxSelection.Color3 = Color3.fromRGB(255, 0, 0)
	damageboxSelection.Parent = entity.Hitbox
end

task.spawn(function()
	dump:Add(workspace.gameFolders.entities.ChildAdded:Connect(function(child)
		renderEntitySelection(child)
	end))
	for _, child in pairs(workspace.gameFolders.entities:GetChildren()) do
		renderEntitySelection(child)
	end
end)

return {
	commandInvoked = function(arguments, index)
		local debugger = require(index.debugger)

		if arguments[1] == "true" then
			dump:Add(workspace.gameFolders.entities.ChildAdded:Connect(function(child)
				renderEntitySelection(child)
			end))
			for _, child in pairs(workspace.gameFolders.entities:GetChildren()) do
				renderEntitySelection(child)
			end
		elseif arguments[1] == "false" then
			dump:Cleanup()
		else
			error("Invalid arguments[1]")
		end
	end,
}
