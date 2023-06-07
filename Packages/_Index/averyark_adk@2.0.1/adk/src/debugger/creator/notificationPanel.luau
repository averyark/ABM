--[[
    FileName    > 2dDebugPanel.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/04/2023
--]]

local Players = game:GetService("Players")

return function()
	local panel = Instance.new("ScreenGui")
	panel.Name = "__astrax__notification"
	panel.ResetOnSpawn = false
	panel.DisplayOrder = 100

	local group = Instance.new("CanvasGroup")
	group.Name = "group"
	group.BackgroundTransparency = 1
	group.Size = UDim2.fromScale(0.3, 1)
	group.Position = UDim2.fromScale(0.7, 0.5)
	group.AnchorPoint = Vector2.new(0, 0.5)
	group.Parent = panel

	local padding = Instance.new("UIPadding")
	padding.Name = "padding"
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 2)
	padding.Parent = group

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Padding = UDim.new(0, 5)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Parent = group

	local entry = Instance.new("Frame")
	entry.Name = "entry"
	entry.BackgroundTransparency = 1
	entry.BorderSizePixel = 0
	entry.Size = UDim2.new(1, -12, 0, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y

	local entry_button = Instance.new("TextButton")
	entry_button.Name = "content"
	entry_button.Text = ""
	entry_button.Size = UDim2.fromScale(1, 1)
	entry_button.Parent = entry
	entry_button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

	local entry_button_padding = Instance.new("UIPadding")
	entry_button_padding.Name = "padding"
	entry_button_padding.PaddingBottom = UDim.new(0, 10)
	entry_button_padding.PaddingLeft = UDim.new(0, 4)
	entry_button_padding.PaddingRight = UDim.new(0, 4)
	entry_button_padding.PaddingTop = UDim.new(0, 2)
	entry_button_padding.Parent = entry_button

	local entry_button_corner = Instance.new("UICorner")
	entry_button_corner.Name = "corner"
	entry_button_corner.CornerRadius = UDim.new(0, 4)
	entry_button_corner.Parent = entry_button

	local entry_button_stroke = Instance.new("UIStroke")
	entry_button_stroke.Name = "stroke"
	entry_button_stroke.Thickness = 1
	entry_button_stroke.Color = Color3.fromRGB(50, 50, 50)
	entry_button_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	entry_button_stroke.Parent = entry_button

	local icon = Instance.new("ImageLabel")
	icon.Name = "icon"
	icon.Image = "rbxassetid://13608063696"
	icon.Size = UDim2.fromOffset(32, 32)
	icon.BackgroundTransparency = 1
	icon.Parent = entry_button

	local title = Instance.new("TextLabel")
	title.Name = "title"
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(36, 8)
	title.Size = UDim2.new(1, 0, 0, 16)
	title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = entry_button

	local desc = Instance.new("TextLabel")
	desc.Name = "desc"
	desc.AutomaticSize = Enum.AutomaticSize.Y
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.fromOffset(36, 28)
	desc.Size = UDim2.new(1, -36, 0, 0)
	desc.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	desc.TextSize = 14
	desc.TextColor3 = Color3.fromRGB(235, 235, 235)
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.Parent = entry_button

	return {
		group = group,
		panel = panel,
		entry = entry,
	}
end
