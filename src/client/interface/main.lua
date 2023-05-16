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
local UserInputService = game:GetService("UserInputService")

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
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local levels = require(ReplicatedStorage.shared.levels)
local settings = require(script.Parent.Parent.interface.settings)

local bridges = {
	playSound = BridgeNet.CreateBridge("playSound")
}

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

local tweens = {}

local locked = false

interface.lock = function()
	locked = true
	for _, object in pairs(interfaceList) do
		object.Enabled = false
	end
	playerCamera.FieldOfView = 70
	uiBlurFocus.Size = 0
end

interface.unlock = function()
	locked = false
	for _, object in pairs(interfaceList) do
		object.Enabled = true
	end
end

interface.unfocus = function()
	if not showingUi then
		return
	end
	for i, object in pairs(tweens) do
		object:Destroy()
	end
	table.clear(tweens)
	table.insert(tweens, tween.instance(playerCamera, {
		FieldOfView = 70,
	}, 0.25))
	table.insert(tweens, tween.instance(uiBlurFocus, {
		Size = 0,
	}, 0.25))

	local hud = Players.LocalPlayer.PlayerGui.hud
	--[[table.insert(tweens, tween.instance(hud.currencies, {
		Position = UDim2.new(0, 0, 0.5, -40),
	}, 0.3, "EntranceExpressive"))]]
	tween.instance(hud.smallButtons, {
		Position = UDim2.new(0, 8, 0.5, -112),
	}, 0.3, "EntranceExpressive")
	tween.instance(hud.right, {
		Position = UDim2.new(1, -258, 0.5, 0),
	}, 0.3, "EntranceExpressive")
	tween.instance(hud.currencies, {
		Position = UDim2.new(0, 0, 0.5, -40),
	}, 0.3, "EntranceExpressive")
	tween.instance(hud.buttons, {
		Position = UDim2.new(0, 8, 0.5, 66),
	}, 0.3, "EntranceExpressive")
	tween.instance(hud.level, {
		Position = UDim2.new(0.5, 0, 1, -48),
	}, 0.3, "EntranceExpressive")
	tween.instance(hud.rebirth, {
		Position = UDim2.new(1, -28, 1, -32),
	}, 0.3, "EntranceExpressive")

	showingUi.mainframe.Visible = false
	showingUi = nil
	task.wait(0.1)
	task.delay(.3, function()
		interface.hiding:Fire(showingUi)
	end)
end

interface.focus = function(ui, showCurrency, showQuest)
	if locked then return end
	if not table.find(interfaceList, ui) then
		return
	end
	if showingUi == ui then
		return interface.unfocus()
	end
	if showingUi then
		showingUi.mainframe.Visible = false
		showingUi = nil
		interface.hiding:Fire(showingUi)
	end
	--interface.unfocus()
	interface.showing:Fire(showingUi)
	showingUi = ui
	for i, object in pairs(tweens) do
		object:Destroy()
	end
	table.clear(tweens)

	local hud = Players.LocalPlayer.PlayerGui.hud
	--[[table.insert(tweens, tween.instance(hud.currencies, {
		Position = UDim2.new(0, -250, 0.5, -40),
	}, 0.3, "ExitExpressive"))]]

	if not showCurrency then
		table.insert(tweens, tween.instance(hud.currencies, {
			Position = UDim2.new(0, -250, 0.5, -40),
		}, 0.3, "ExitExpressive"))
	end
	tween.instance(hud.smallButtons, {
		Position = UDim2.new(0, -231, 0.5, -112),
	}, 0.3, "ExitExpressive")
	if not showQuest then
		tween.instance(hud.right, {
			Position = UDim2.new(1, 0, 0.5, 0),
		}, 0.3, "ExitExpressive")
	end
	table.insert(tweens, tween.instance(hud.buttons, {
		Position = UDim2.new(0, -231, 0.5, 60),
	}, 0.3, "ExitExpressive"))
	table.insert(tweens, tween.instance(hud.level, {
		Position = UDim2.new(0.5, 0, 1, 0),
	}, 0.3, "ExitExpressive"))
	table.insert(tweens, tween.instance(hud.rebirth, {
		Position = UDim2.new(1, -28, 1, 0),
	}, 0.3, "ExitExpressive"))

	-- reset
	showingUi.mainframe.Visible = false
	showingUi.scaler.Scale = 0.9 * showingUi.scaler:GetAttribute("__SCALE")
	local size = showingUi.mainframe.Size
	--showingUi.mainframe.Size = UDim2.new(-.1, size.X.Offset, -.1, size.Y.Offset)
	showingUi.mainframe.Position = UDim2.fromScale(0.52, 0.8)

	if showingUi.Name == "shop" then
		settings.playSound(uiSounds["shop ui sound"])
	end

	table.insert(tweens, tween.instance(showingUi.mainframe, {
		Position = UDim2.fromScale(0.52, 0.5),
	}, 0.6))
	table.insert(tweens, tween.instance(showingUi.scaler, {
		Scale = 1 * showingUi.scaler:GetAttribute("__SCALE"),
	}, 0.4))
	--[[table.insert(tweens, tween.instance(showingUi.mainframe, {
		Size = UDim2.fromOffset(size.X.Offset, size.Y.Offset)
	}, 0.35))]]
	showingUi.mainframe.Visible = true
	table.insert(tweens, tween.instance(playerCamera, {
		FieldOfView = 55,
	}, 0.5, "EntranceExpressive"))
	table.insert(tweens, tween.instance(uiBlurFocus, {
		Size = 12,
	}, 0.6))
end

interface.initUi = function(ui)
	debugger.assert(t.instanceIsA("ScreenGui")(ui))
	debugger.assert(t.instanceIsA("GuiObject")(ui:FindFirstChild("mainframe")))
	table.insert(interfaceList, ui)
	ui.mainframe.Visible = false
	ui.Enabled = true

	if ui.mainframe:FindFirstChild("close") then
		ui.mainframe.close.Activated:Connect(function()
			interface.unfocus()
		end)
	end
end

function interface:button(button: GuiButton, amount: number?)
	amount = amount or 0.05
	local innerOutline = button:FindFirstChild("innerOutline")
	local scale = button:FindFirstChild("scale")

	if not innerOutline or not scale then
		return warn("not a standard button")
	end

	local defaultColor = innerOutline.stroke.Color
	local dh, ds, dv = defaultColor:ToHSV()
	local hoverColor = Color3.fromHSV(dh, ds, dv+0.3)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			tween.instance(scale, {
				Scale = 1,
			}, .15)
		end
	end)

	button.MouseButton1Down:Connect(function()
		tween.instance(scale, {
			Scale = 1 - amount,
		}, .15, "Back")
	end)
	button.MouseLeave:Connect(function()
		tween.instance(scale, {
			Scale = 1,
		}, .15, "Back")
		tween.instance(innerOutline.stroke, {
			Color = defaultColor
		}, .15, "Back")
	end)
	button.MouseEnter:Connect(function()
		tween.instance(scale, {
			Scale = 1 + amount,
		}, .15, "Back")
		tween.instance(innerOutline.stroke, {
			Color = hoverColor
		}, .15, "Back")
	end)

	return button
end

function interface:load()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	local list = {
		"shop",
		"stats",
		"settings",
		"ascend",
		"sword",
		"hero",
		"fastTravel",
		"promocodes",
		"changelog"
	}

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local hud = playerGui:WaitForChild("hud")
	local selectedButton

	local buttons = {}

	local unselected = function(button, isSmallButton)
		if selectedButton == button then
			selectedButton = nil
		end

		local color = buttons[button].default
		local size = isSmallButton and 18 or 32

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
			Size = UDim2.fromOffset(size, size),
		}, 0.2)
		tween.instance(button.scale, {
			Scale = 1
		}, .15, "Back")
	end

	local selected = function(button, isSmallButton)
		if selectedButton == button then
			return
		end
		if selectedButton then
			unselected(selectedButton, isSmallButton)
		end
		selectedButton = button

		local color = buttons[button].hovered
		local size = isSmallButton and 22 or 38

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
			Size = UDim2.fromOffset(size, size),
		}, 0.2)
		tween.instance(button.scale, {
			Scale = 1.05
		}, .15, "Back")
	end

	for _, name in pairs(list) do
		local ui = if name == "sword" or name == "hero" then playerGui:FindFirstChild("inventory")else playerGui:FindFirstChild(name)
		interface.initUi(ui)

		local smallButton = hud.smallButtons:FindFirstChild(name) :: TextButton
		local button = smallButton or hud.buttons:FindFirstChild(name) :: TextButton
		local buttonMainColorCache = button.tip.stroke.Color
		local h, s, v = buttonMainColorCache:ToHSV()
		local hoveredColor = Color3.fromHSV(h, s, v + 0.3)

		buttons[button] = {
			hovered = hoveredColor,
			default = buttonMainColorCache,
		}

		button.SelectionGained:Connect(function()
			selected(button, smallButton and true)
		end)
		button.SelectionLost:Connect(function()
			unselected(button, smallButton and true)
		end)
		button.MouseEnter:Connect(function()
			selected(button, smallButton and true)
		end)
		button.MouseLeave:Connect(function()
			unselected(button, smallButton and true)
		end)
		button.MouseButton1Down:Connect(function(x, y)
			tween.instance(button.scale, {
				Scale = .9
			}, .15, "Back")
		end)
		UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
				tween.instance(button.scale, {
					Scale = 1
				}, .15, "Back")
			end
		end)
		button.Activated:Connect(function()
			interface.focus(ui, name == "shop" or name == "ascend")
		end)

		if ui.mainframe:FindFirstChild("close") then
			ui.mainframe.close.Activated:Connect(function()
				interface.unfocus()
			end)
		end
	end

	local connect = function(button)
		button.Activated:Connect(function()
			settings.playSound(uiSounds.Click)
		end)
		button.MouseEnter:Connect(function()
			--SoundService:PlayLocalSound(uiSounds.Hover)
		end)
	end

	local initScrollingFrame = function(scroll: ScrollingFrame)
		if scroll.AutomaticCanvasSize ~= Enum.AutomaticSize.Y then
			return
		end
		local listLayout =  scroll:FindFirstChildOfClass("UIListLayout")
		local gridLayout = scroll:FindFirstChildOfClass("UIGridLayout")
		local screenGui = scroll:FindFirstAncestorOfClass("ScreenGui")
		local scaler = screenGui and screenGui:FindFirstChild("scaler")
		local padding = scroll:FindFirstChildOfClass("UIPadding")
		local update = function(y, paddingY)
			if scaler then
				scroll.CanvasSize = UDim2.fromOffset(0, (y + paddingY)/scaler.Scale)
			else
				scroll.CanvasSize = UDim2.fromOffset(0, y + paddingY)
			end
		end
		if listLayout then
			scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				local n = 0
				for _, object in pairs(scroll:GetChildren()) do
					if object:IsA("GuiObject") and object.Visible then
						n += 1
					end
				end
				update(
					listLayout.AbsoluteContentSize.Y,
				padding and padding.PaddingTop.Offset + padding.PaddingBottom.Offset or 0
				)
			end)
			local n = 0
				for _, object in pairs(scroll:GetChildren()) do
					if object:IsA("GuiObject") and object.Visible then
						n += 1
					end
				end
				update(
					listLayout.AbsoluteContentSize.Y,
				padding and padding.PaddingTop.Offset + padding.PaddingBottom.Offset or 0
				)
		elseif gridLayout then
			scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
			gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				update(
					gridLayout.AbsoluteContentSize.Y,
					padding and padding.PaddingTop.Offset + padding.PaddingBottom.Offset or 0
				)
			end)
			update(
				gridLayout.AbsoluteContentSize.Y,
				padding and padding.PaddingTop.Offset + padding.PaddingBottom.Offset or 0
			)
		end
	end

	local initTextLabel = function(textLabel: TextLabel)
		if textLabel.AutomaticSize ~= Enum.AutomaticSize.Y then
			return
		end
		local screenGui = textLabel:FindFirstAncestorOfClass("ScreenGui")
		local scaler = screenGui and screenGui:FindFirstChild("scaler")
		if not scaler or not screenGui then return end

		--[[textLabel.AutomaticSize = Enum.AutomaticSize.None

		textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
			textLabel.Size = UDim2.new(
				textLabel.Size.X.Scale,
				textLabel.Size.X.Offset,
				0,
				textLabel.TextBounds.Y/scaler.Scale
			)
		end)
		textLabel.Size = UDim2.new(
				textLabel.Size.X.Scale,
				textLabel.Size.X.Offset,
				0,
				textLabel.TextBounds.Y/scaler.Scale
			)]]
	end

	playerGui.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ScrollingFrame") then
			initScrollingFrame(descendant)
		elseif descendant:IsA("TextLabel") then
			initTextLabel(descendant)
		end
	end)
	for _, descendant in pairs(playerGui:GetDescendants()) do
		if descendant:IsA("ScrollingFrame") then
			initScrollingFrame(descendant)
		elseif descendant:IsA("TextLabel") then
			initTextLabel(descendant)
		end
	end

	for _, gui in pairs(playerGui:GetChildren()) do
		--[[for _, scroll in pairs(gui:GetDescendants()) do
			if scroll:IsA("ScrollingFrame") then
				initScrollingFrame(scroll)
			end
		end
		gui.DescendantAdded:Connect(function(scroll)
			if scroll:IsA("ScrollingFrame") then
				initScrollingFrame(scroll)
			end
		end)]]
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
		--[[for _, scroll in pairs(gui:GetDescendants()) do
			if scroll:IsA("ScrollingFrame") then
				initScrollingFrame(scroll)
			end
		end
		gui.DescendantAdded:Connect(function(scroll)
			if scroll:IsA("ScrollingFrame") then
				initScrollingFrame(scroll)
			end
		end)]]
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

	--[[playerDataHandler:connect({"level"}, function(changes)
		local levelMulti = levels[changes.new].multiplier

		hud.damageMulti.Text = "Damage x" .. levelMulti
	end)]]

	bridges.playSound:Connect(function(sound)
		settings.playSound(sound)
	end)

	BridgeNet.CreateBridge("message"):Connect(function(message, color)
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = message,
			Color = color or Color3.fromRGB(255, 255, 255)
		})
	end)

	--settings.playSound(SoundService.music)
end

return interface
