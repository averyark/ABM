local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService")

local index = require(script.Parent.index)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

--local workspaceDebugManifest = require(script.workspaceDebugManifest)

local _version = index.version

if RunService:IsClient() then
	local isWhitelisted = false
	for _, data in pairs(index.debugSettings.whitelisted) do
		if data.type == "userid" and Players.LocalPlayer.UserId == data.value then
			isWhitelisted = true
			break
		end
	end

	local silence = {}
	local debugUi = Instance.new("ScreenGui")
	debugUi.Name = "__debug"
	debugUi.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	debugUi.ResetOnSpawn = false
	debugUi.Enabled = false

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "scroll"
	scroll.Parent = debugUi
	scroll.ClipsDescendants = true
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(0.4, 1)
	scroll.ScrollBarThickness = 2
	scroll.CanvasSize = UDim2.fromScale(0, 1)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
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

	scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		if index.debugSettings.autoPositionCanvas then
			scroll.CanvasPosition = scroll.AbsoluteCanvasSize - scroll.AbsoluteWindowSize
		end
	end)
	scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		if index.debugSettings.autoPositionCanvas then
			scroll.CanvasPosition = scroll.AbsoluteCanvasSize - scroll.AbsoluteWindowSize
		end
	end)

	local manifestTime = 14

	local fadeOut = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

	local outputTypes = {
		[Enum.MessageType.MessageError] = {
			textColor = Color3.fromRGB(230, 60, 60),
			backgroundColor = Color3.fromRGB(25, 7, 7),
		},
		[Enum.MessageType.MessageWarning] = {
			textColor = Color3.fromRGB(230, 130, 80),
			backgroundColor = Color3.fromRGB(25, 14, 9),
		},
		[Enum.MessageType.MessageInfo] = {
			textColor = Color3.fromRGB(180, 218, 230),
			backgroundColor = Color3.fromRGB(20, 24, 25),
		},
		[Enum.MessageType.MessageOutput] = {
			textColor = Color3.fromRGB(230, 200, 180),
			backgroundColor = Color3.fromRGB(25, 22, 20),
		},
	}

	local cache = {}

	local lastOutput

	local manifestOutput = function(message, _type)
		for _, s in pairs(silence) do
			if message:match(s) then
				return
			end
		end
		if not index.debugSettings.debugEnabled then
			return
		end

		local object = Instance.new("TextButton")
		local info = outputTypes[_type]
		local connection, connection2

		local manifestMessage = message

		if lastOutput and lastOutput.message == message then
			lastOutput.rep += 1
			lastOutput.object.Text = (if lastOutput.expanded then lastOutput.rawMessage else lastOutput.message)
				.. "(x"
				.. lastOutput.rep
				.. ")"
			return
		end

		local specialMessageFunc = {
			["{"] = function(matched, regex)
				local openPos = manifestMessage:find("{")
				local closePos = manifestMessage:reverse():find("}")

				manifestMessage = manifestMessage:sub(0, openPos - 1)
					.. "[<table>(condensed:Click to expand)]"
					.. manifestMessage:sub(manifestMessage:len() - closePos + 2, -1)
			end,
		}

		for regex, f in pairs(specialMessageFunc) do
			local matched = manifestMessage:find(regex)
			if matched then
				f(matched, regex)
			end
		end

		if manifestMessage:len() > 320 then
			manifestMessage = manifestMessage:sub(0, 320) .. " ...[<debug-message>(condensed:Click to expand)]"
		end

		local id = #cache
		local meta = {
			message = manifestMessage,
			rawMessage = message,
			type = _type,
			object = object,
			rep = 1,
			expanded = false,
			id = id,
		}

		table.insert(cache, meta)

		lastOutput = meta

		object.Text = manifestMessage
		object.Name = "debugid:" .. id
		object.BackgroundTransparency = 0.1
		object.BorderSizePixel = 2
		object.BackgroundColor3 = info.backgroundColor
		object.BorderColor3 = info.backgroundColor
		object.TextColor3 = info.textColor
		object.AutomaticSize = Enum.AutomaticSize.XY
		object.TextSize = 15
		object.TextWrapped = true
		object.AutoLocalize = false
		object.TextXAlignment = Enum.TextXAlignment.Left
		object.FontFace = Font.new("Source Sans Pro")
		object.Parent = container
		connection = object.Activated:Connect(function()
			meta.expanded = not meta.expanded
			if meta.expanded then
				object.Text = message .. if meta.rep == 1 then "" else "(x" .. meta.rep .. ")"
			else
				object.Text = manifestMessage .. if meta.rep == 1 then "" else "(x" .. meta.rep .. ")"
			end
		end)
		connection2 = object.AncestryChanged:Connect(function()
			if object.Parent ~= container then
				connection:Disconnect()
				connection2:Disconnect()
			end
		end)

		if index.debugSettings.fadeOutputMessage then
			task.wait(manifestTime)
			local tween = TweenService:Create(object, fadeOut, {
				BackgroundTransparency = 1,
				TextTransparency = 1,
			})

			tween:Play()
			tween.Completed:Wait()
			tween:Destroy()
			object:Destroy()
		end
	end

	if isWhitelisted and index.debugSettings.enableForWhitelistedOnly then
		if index.debugSettings.debugEnabled then -- initialized with debug enabled
			warn(
				(
					"ASTRAX_FRAMEWORK V-%s AVERYARK[<debugger>(manifest)] :  Debug is enabled for this game; This game is still experimental, nothing represents the final product. "
				):format(_version)
			)
		end

		LogService.MessageOut:Connect(manifestOutput)
		if index.debugSettings.serverDebugEnabled and not RunService:IsStudio() then
			Promise.try(function()
				local onServerLog = BridgeNet.CreateBridge("__debug_serverlog")
				onServerLog:Connect(manifestOutput)
			end)
		end
	end

	Promise.try(function()
		if index.debugSettings.debugConsoleEnabled then
			print("[<debugger>(console:client)]: Debug console is enabled; Initializing.")
			require(script.consoleClientHandler):load(container)
			print(
				"[<debugger>(console:client)]: Initialized debug console. Press `Insert` on your keyboard or chat `/debugconsole` to activate console command bar"
			)
		end
	end)

	return {
		log = print,
		warn = warn,
		error = error,
		assert = assert,
		clearMessages = function()
			for _, object in pairs(container:GetChildren()) do
				if object.Name ~= "consolebar" and t.instanceIsA("GuiObject")(object) then
					object:Destroy()
				end
			end
		end,
		waitIntervalAndClear = function(interval: number)
			local childrens = container:GetChildren() -- cache it
			task.wait(interval)
			for _, object in pairs(childrens) do
				if object.Name ~= "consolebar" and t.instanceIsA("GuiObject")(object) then
					object:Destroy()
				end
			end
		end,
		silence = function(string)
			table.insert(silence, string)
		end,
		--newWorkspaceDebug = workspaceDebugManifest.new,
	}
else
	local onServerLog = BridgeNet.CreateBridge("__debug_serverlog")
	local cache = {}
	local fire = function(...)
		for _, player in pairs(Players:GetPlayers()) do
			for _, data in pairs(index.debugSettings.whitelisted) do
				if data.type == "userid" and player.UserId == data.value then
					onServerLog:FireTo(player, ...)
				end
			end
		end
	end
	local methods = {
		log = function(...)
			local tab = { ... }
			for a, b in pairs(tab) do
				tab[a] = tostring(b)
			end
			local message = table.concat(tab, " ")
			table.insert(cache, {
				message = message,
				type = Enum.MessageType.MessageOutput,
			})
			if index.debugSettings.serverDebugEnabled then
				fire(message, Enum.MessageType.MessageOutput)
			end
			print(...)
		end,
		warn = function(...)
			local tab = { ... }
			for a, b in pairs(tab) do
				tab[a] = tostring(b)
			end
			local message = table.concat(tab, " ")
			table.insert(cache, {
				message = message,
				type = Enum.MessageType.MessageWarning,
			})
			if index.debugSettings.serverDebugEnabled then
				fire(message, Enum.MessageType.MessageWarning)
			end
			warn(...)
		end,
		error = function(message, level)
			table.insert(cache, {
				message = message,
				type = Enum.MessageType.MessageError,
			})
			if index.debugSettings.serverDebugEnabled then
				fire(message, Enum.MessageType.MessageError)
			end
			error(message, level)
		end,
		assert = function(condition, message)
			if not condition then
				table.insert(cache, {
					message = message,
					type = Enum.MessageType.MessageError,
				})
				if index.debugSettings.serverDebugEnabled then
					fire(message, Enum.MessageType.MessageError)
				end
			end
			assert(condition, message)
		end,
	}
	task.spawn(function()
		require(script.consoleServerHandler):load(methods)
	end)
	return methods
end
