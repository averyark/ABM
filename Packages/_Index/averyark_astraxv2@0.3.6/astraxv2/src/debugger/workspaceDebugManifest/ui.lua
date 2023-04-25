local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService")

local index = require(script.Parent.Parent.Parent.index)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

if RunService:IsClient() then
	local ui = {}
	local stored = 0
	local valueManifestUiFolder = Instance.new("Folder")
	valueManifestUiFolder.Name = "__debug__valueManifestContainer"

	local valueManifestUi = Instance.new("BillboardGui")
	valueManifestUi.Name = "__debugValueManifest"
	valueManifestUi.MaxDistance = 50
	valueManifestUi.ResetOnSpawn = false
	valueManifestUi.Size = UDim2.fromOffset(300, 350)
	valueManifestUi.AlwaysOnTop = true
	valueManifestUi.LightInfluence = 0

	local container = Instance.new("Frame")
	container.Name = "container"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = valueManifestUi

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Padding = UDim.new(0, 4)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = container

	local makeButton = function()
		stored += 1
		local debugButtonTempalate = Instance.new("TextButton")
		debugButtonTempalate.Name = "debugid: " .. stored
		debugButtonTempalate.BackgroundTransparency = 0.3
		debugButtonTempalate.TextTransparency = 0.15
		debugButtonTempalate.BorderSizePixel = 2
		debugButtonTempalate.BackgroundColor3 = Color3.fromRGB(5, 22, 20)
		debugButtonTempalate.BorderColor3 = Color3.fromRGB(5, 22, 20)
		debugButtonTempalate.TextColor3 = Color3.fromRGB(180, 213, 230)
		debugButtonTempalate.AutomaticSize = Enum.AutomaticSize.XY
		debugButtonTempalate.TextSize = 15
		debugButtonTempalate.TextWrapped = true
		debugButtonTempalate.AutoLocalize = false
		debugButtonTempalate.TextXAlignment = Enum.TextXAlignment.Left
		debugButtonTempalate.RichText = true
		debugButtonTempalate.FontFace = Font.new("Source Sans Pro")
		return debugButtonTempalate
	end

	task.spawn(function()
		valueManifestUiFolder.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		valueManifestUiFolder.AncestryChanged:Connect(function()
			if valueManifestUiFolder.Parent ~= Players.LocalPlayer.PlayerGui then
				valueManifestUiFolder = Instance.new("Folder")
				valueManifestUiFolder.Name = "__debug__valueManifestContainer"
				valueManifestUiFolder.Parent = Players.LocalPlayer.PlayerGui
				ui.folder = valueManifestUiFolder
			end
		end)
	end)

	ui.makeButton = makeButton
	ui.valueManifestUi = valueManifestUi
	ui.folder = valueManifestUiFolder

	return ui
else
	return {}
end

return 0
