--!strict
--[[
    FileName    > main.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 08/12/2022
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
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

local interface = {}

local uiBlurFocus = Instance.new("BlurEffect")
uiBlurFocus.Name = "__ui__blurfocus"
uiBlurFocus.Size = 0
uiBlurFocus.Parent = Lighting
local playerCamera = workspace.CurrentCamera

local interfaceList = {}
local showingUi

local uiSounds = ReplicatedStorage.resources.ui_sound_effects

interface.showing = Signal.new()
interface.hiding = Signal.new()

interface.unfocus = function()
	if not showingUi then
		return
	end
	interface.hiding:Fire(showingUi)
	tween.instance(playerCamera, {
		FieldOfView = 70,
	}, 0.25)
	tween.instance(uiBlurFocus, {
		Size = 0,
	}, 0.25)

	local hud = Players.LocalPlayer.PlayerGui.hud
	tween.instance(hud.currencies, {
		Position = UDim2.new(0, 0, 0.5, -40),
	}, 0.3, "EntranceExpressive")
	tween.instance(hud.buttons, {
		Position = UDim2.new(0, 8, 0.5, 66),
	}, 0.3, "EntranceExpressive")

	showingUi.mainframe.Visible = false
	showingUi = nil
	task.wait(0.1)
end

interface.focus = function(ui)
	if not table.find(interfaceList, ui) then
		return
	end
	if showingUi == ui then
		return interface.unfocus()
	end
	interface.unfocus()
	showingUi = ui
	interface.showing:Fire(showingUi)

	local hud = Players.LocalPlayer.PlayerGui.hud
	tween.instance(hud.currencies, {
		Position = UDim2.new(0, -250, 0.5, -40),
	}, 0.3, "ExitExpressive")
	tween.instance(hud.buttons, {
		Position = UDim2.new(0, -231, 0.5, 60),
	}, 0.3, "ExitExpressive")

	-- reset
	showingUi.mainframe.Visible = false
	showingUi.scaler.Scale = 0.9
	showingUi.mainframe.Position = UDim2.fromScale(0.5, 0.8)

	if showingUi.Name == "shop" then
		SoundService:PlayLocalSound(uiSounds["shop ui sound"])
	end

	tween.instance(showingUi.mainframe, {
		Position = UDim2.fromScale(0.5, 0.5),
	}, 0.6)
	tween.instance(showingUi.scaler, {
		Scale = 1,
	}, 0.4)
	showingUi.mainframe.Visible = true
	tween.instance(playerCamera, {
		FieldOfView = 55,
	}, 0.5, "EntranceExpressive")
	tween.instance(uiBlurFocus, {
		Size = 12,
	}, 0.6)
end

interface.initUi = function(ui)
	debugger.assert(t.instanceIsA("ScreenGui")(ui))
	debugger.assert(t.instanceIsA("GuiObject")(ui:FindFirstChild("mainframe")))
	table.insert(interfaceList, ui)
	ui.mainframe.Visible = false
	ui.Enabled = true
end

function interface:load()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	local list = {
		"shop",
		"stats",
		"settings",
		"ascend",
		"inventory",
	}

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local hud = playerGui:WaitForChild("hud")
	local selectedButton

	local buttons = {}

	local unselected = function(button)
		if selectedButton == button then
			selectedButton = nil
		end

		local color = buttons[button].default

		tween.instance(button.tip.stroke, {
			Color = color,
		}, 0.2)
		tween.instance(button.innerOutline.stroke, {
			Color = color,
		}, 0.2)
		tween.instance(button.tip, {
			TextTransparency = 1,
		}, 0.2)
		tween.instance(button.tip.stroke, {
			Transparency = 1,
		}, 0.2)
		tween.instance(button.icon, {
			Size = UDim2.fromOffset(32, 32),
		}, 0.2)
	end

	local selected = function(button)
		if selectedButton == button then
			return
		end
		if selectedButton then
			unselected(selectedButton)
		end
		selectedButton = button

		local color = buttons[button].hovered

		tween.instance(button.tip.stroke, {
			Color = color,
		}, 0.2)
		tween.instance(button.innerOutline.stroke, {
			Color = color,
		}, 0.2)
		tween.instance(button.tip, {
			TextTransparency = 0,
		}, 0.2)
		tween.instance(button.tip.stroke, {
			Transparency = 0,
		}, 0.2)
		tween.instance(button.icon, {
			Size = UDim2.fromOffset(38, 38),
		}, 0.2)
	end

	for _, name in pairs(list) do
		local ui = playerGui:FindFirstChild(name)
		interface.initUi(ui)

		local button = hud.buttons:FindFirstChild(name) :: TextButton
		local buttonMainColorCache = button.tip.stroke.Color
		local h, s, v = buttonMainColorCache:ToHSV()
		local hoveredColor = Color3.fromHSV(h, s, v + 0.3)

		buttons[button] = {
			hovered = hoveredColor,
			default = buttonMainColorCache,
		}

		button.SelectionGained:Connect(function()
			selected(button)
		end)
		button.SelectionLost:Connect(function()
			unselected(button)
		end)
		button.MouseEnter:Connect(function()
			selected(button)
		end)
		button.MouseLeave:Connect(function()
			unselected(button)
		end)
		button.Activated:Connect(function()
			interface.focus(ui)
		end)

		ui.mainframe.upper.close.Activated:Connect(function()
			interface.unfocus()
		end)
	end

	local connect = function(button)
		button.Activated:Connect(function()
			SoundService:PlayLocalSound(uiSounds.Click)
		end)
		button.MouseEnter:Connect(function()
			--SoundService:PlayLocalSound(uiSounds.Hover)
		end)
	end

	for _, gui in pairs(playerGui:GetChildren()) do
		if gui:GetAttribute("clickSFX") == true then
			for _, button in pairs(gui:GetDescendants()) do
				if button:IsA("GuiButton") then
					connect(button)
				end
			end
			gui.DescendantAdded:Connect(function(button)
				if button:IsA("GuiButton") then
					connect(button)
				end
			end)
		end
	end
	playerGui.ChildAdded:Connect(function(gui)
		if gui:GetAttribute("clickSFX") == true then
			for _, button in pairs(gui:GetDescendants()) do
				if button:IsA("GuiButton") then
					connect(button)
				end
			end
			gui.DescendantAdded:Connect(function(button)
				if button:IsA("GuiButton") then
					connect(button)
				end
			end)
		end
	end)

	SoundService:PlayLocalSound(SoundService.music)
end

return interface
