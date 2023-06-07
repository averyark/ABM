--[[
	FileName    > parameterVisualPanel.luau
	Author      > AveryArk
	Contact     > Twitter: https://twitter.com/averyark_
	Created     > 01/06/2023
--]]

return function()
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "__debug"
	billboard.MaxDistance = 50
	billboard.ResetOnSpawn = false
	billboard.Size = UDim2.fromOffset(300, 350)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0

	local container = Instance.new("Frame")
	container.Name = "container"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Padding = UDim.new(0, 4)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = container

	local buttonTemplate = Instance.new("TextButton")
	buttonTemplate.BackgroundTransparency = 0.3
	buttonTemplate.TextTransparency = 0.15
	buttonTemplate.BorderSizePixel = 2
	buttonTemplate.BackgroundColor3 = Color3.fromRGB(5, 22, 20)
	buttonTemplate.BorderColor3 = Color3.fromRGB(5, 22, 20)
	buttonTemplate.TextColor3 = Color3.fromRGB(180, 213, 230)
	buttonTemplate.AutomaticSize = Enum.AutomaticSize.XY
	buttonTemplate.TextSize = 15
	buttonTemplate.TextWrapped = true
	buttonTemplate.AutoLocalize = false
	buttonTemplate.TextXAlignment = Enum.TextXAlignment.Left
	buttonTemplate.RichText = true
	buttonTemplate.FontFace = Font.new("Source Sans Pro")

	return {
		billboard = billboard,
		container = container,

		buttonTemplate = buttonTemplate,
	}
end
