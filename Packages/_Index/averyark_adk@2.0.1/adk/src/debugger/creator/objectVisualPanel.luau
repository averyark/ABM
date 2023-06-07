--[[
	FileName    > objectVisualPanel.luau
	Author      > AveryArk
	Contact     > Twitter: https://twitter.com/averyark_
	Created     > 01/06/2023
--]]

local Players = game:GetService("Players")

return function()
	local debugUi = Instance.new("ScreenGui")
	debugUi.Name = "__debug_objectVisualPanel"
	debugUi.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	debugUi.ResetOnSpawn = false

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "scroll"
	scroll.Parent = debugUi
	scroll.ClipsDescendants = true
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(0.3, 0.6)
	scroll.Position = UDim2.fromScale(0.7, 0.4)
	scroll.ScrollBarThickness = 2
	scroll.CanvasSize = UDim2.fromScale(0, 0.6)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Parent = scroll
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.Padding = UDim.new(0, 0)

	local container = Instance.new("Frame")
	container.Name = "container"
	container.Parent = scroll
	container.ClipsDescendants = true
	container.BackgroundTransparency = 1
	container.BackgroundColor3 = Color3.fromRGB(25, 22, 20)
	container.BorderSizePixel = 0
	container.Size = UDim2.fromScale(1, 1)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.LayoutOrder = -1

	local list2 = Instance.new("UIListLayout")
	list2.Name = "list"
	list2.Parent = container
	list2.SortOrder = Enum.SortOrder.LayoutOrder
	list2.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list2.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list2.Padding = UDim.new(0, 4)

	local padding = Instance.new("UIPadding")
	padding.Name = "padding"
	padding.Parent = container
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)

	local mainpadding = Instance.new("UIPadding")
	mainpadding.Name = "padding"
	mainpadding.Parent = debugUi
	mainpadding.PaddingLeft = UDim.new(0, 6)
	mainpadding.PaddingRight = UDim.new(0, 4)
	mainpadding.PaddingTop = UDim.new(0, 4)
	mainpadding.PaddingBottom = UDim.new(0, 4)

	local entryTemplate = Instance.new("TextButton")
	entryTemplate.BackgroundTransparency = 0.1
	entryTemplate.BorderSizePixel = 2
	entryTemplate.AutomaticSize = Enum.AutomaticSize.XY
	entryTemplate.TextSize = 15
	entryTemplate.TextWrapped = true
	entryTemplate.AutoLocalize = false
	entryTemplate.TextXAlignment = Enum.TextXAlignment.Left
	entryTemplate.FontFace = Font.new("Source Sans Pro")
	entryTemplate.RichText = true

	return {
		main = debugUi,
		scroll = scroll,
		container = container,

		entryTemplate = entryTemplate,
	}
end
