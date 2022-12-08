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

if RunService:IsClient() then
	local silence = {}
	local debugUi = Instance.new("ScreenGui")
	debugUi.Name = "__debug"
	debugUi.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	debugUi.ResetOnSpawn = false

	local container = Instance.new("Frame")
	container.Name = "container"
	container.Parent = debugUi
	container.ClipsDescendants = true
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.fromScale(0.4, 1)
	--[[container.ScrollBarThickness = 2
    container.CanvasSize = UDim2.fromScale(0, 1)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
    container.ScrollingDirection = Enum.ScrollingDirection.Y]]

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Parent = container
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.HorizontalAlignment = Enum.HorizontalAlignment.Left
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Padding = UDim.new(0, 4)

	local padding = Instance.new("UIPadding")
	padding.Name = "padding"
	padding.Parent = container
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)

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
		local connection

		object.Name = "debugid:" .. #cache
		object.Text = message
		object.BackgroundTransparency = 0.1
		object.BorderSizePixel = 2
		object.BackgroundColor3 = info.backgroundColor
		object.BorderColor3 = info.backgroundColor
		object.TextColor3 = info.textColor
		object.AutomaticSize = Enum.AutomaticSize.XY
		object.TextSize = 15
		object.TextWrapped = true
		object.TextXAlignment = Enum.TextXAlignment.Left
		object.FontFace = Font.new("Source Sans Pro")
		object.Parent = container
		connection = object.Activated:Connect(function()
			connection:Disconnect()
			object:Destroy()
		end)
		table.insert(cache, { message = message, type = _type })

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

	if index.debugSettings.debugEnabled then -- initialized with debug enabled
		warn(
			"ASTRAX_FRAMEWORK AVERYARK[<debugger>(manifest)] :  Debug is enabled for this game; This game is still experimental, nothing represents the final product. "
		)
	end

	LogService.MessageOut:Connect(manifestOutput)
	if index.debugSettings.serverDebugEnabled and not RunService:IsStudio() then
		Promise.try(function()
			local onServerLog = BridgeNet.CreateBridge("__debug_serverlog")
			local sendLast20Log = BridgeNet.CreateBridge("__debug_onitserverlog")
			onServerLog:Connect(manifestOutput)
			sendLast20Log:Connect(function(msgs)
				for _, msg in pairs(msgs) do
					task.spawn(manifestOutput, msg.message, msg.type)
				end
			end)
		end)
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
		end
	}
else
	local onServerLog = BridgeNet.CreateBridge("__debug_serverlog")
	local cache = {}
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
				onServerLog:FireAll(message, Enum.MessageType.MessageOutput)
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
				onServerLog:FireAll(message, Enum.MessageType.MessageWarning)
			end
			warn(...)
		end,
		error = function(message, level)
			table.insert(cache, {
				message = message,
				type = Enum.MessageType.MessageError,
			})
			if index.debugSettings.serverDebugEnabled then
				onServerLog:FireAll(message, Enum.MessageType.MessageError)
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
					onServerLog:FireAll(message, Enum.MessageType.MessageError)
				end
			end
			assert(condition, message)
		end,
	}
	task.spawn(function()
		local sendLast20Log = BridgeNet.CreateBridge("__debug_onitserverlog")
		local initPlayer = function(player)
			local logs = {}
			for i = 20, 1, -1 do
				table.insert(logs, cache[#cache - i])
			end
			task.wait(5)
			sendLast20Log:FireTo(player, logs)
		end
		Players.PlayerAdded:Connect(initPlayer)
		for _, player in pairs(Players:GetPlayers()) do
			initPlayer(player)
		end
		require(script.consoleServerHandler):load(methods)
	end)
	return methods
end
