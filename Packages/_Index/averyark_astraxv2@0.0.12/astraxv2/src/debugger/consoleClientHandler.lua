local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local index = require(script.Parent.Parent.index)

local BridgeNet = require(index.packages.BridgeNet)
local Janitor = require(index.packages.Janitor)
local Promise = require(index.packages.Promise)
local Signal = require(index.packages.Signal)
local t = require(index.packages.t)
local TestEZ = require(index.packages.TestEZ)
local TableUtil = require(index.packages.TableUtil)

local consoleClientHandler = {}

function consoleClientHandler:load(consoleContainer)
	local exeuteCommand = BridgeNet.CreateBridge("__debug_console_executeCommnad")
	local consoleActivationState = false

	local consoleBar = Instance.new("TextBox")
	consoleBar.Name = "consolebar"
	consoleBar.BackgroundTransparency = 0.1
	consoleBar.BorderSizePixel = 2
	consoleBar.BackgroundColor3 = Color3.fromRGB(25, 22, 20)
	consoleBar.BorderColor3 = Color3.fromRGB(25, 22, 20)
	consoleBar.TextColor3 = Color3.fromRGB(230, 200, 180)
	consoleBar.AutomaticSize = Enum.AutomaticSize.XY
	consoleBar.Size = UDim2.fromOffset(200, 15)
	consoleBar.TextSize = 15
	consoleBar.TextWrapped = true
	consoleBar.TextXAlignment = Enum.TextXAlignment.Left
	consoleBar.FontFace = Font.new("Source Sans Pro")
	consoleBar.Parent = consoleContainer
	consoleBar.Text = "> "
	consoleBar.Visible = false
	consoleBar.LayoutOrder = 99
	consoleBar.ClearTextOnFocus = false

	local builtInHandlers = index.builtinDebugModulesClient.handlers

	local processInput = function(rawInput: string)
		print(rawInput) -- DO NOT REMOVE
		local input = rawInput:match("^[> ]+(.*)")

		-- argument divisions
		local rawArguments = input:split(" ")
		local customHandlers = index.debugSettings.debugCommandsHandlerFolder
		local commandName = tostring(rawArguments[1])

		local handler = builtInHandlers:FindFirstChild(commandName)
			or (customHandlers and customHandlers:FindFirstChild(commandName))

		assert(
			handler,
			"[<debugger>(console:client)]: Missing command handler for " .. commandName .. " (Missing command)"
		)

		local arguments = #rawArguments >= 2 and TableUtil.Array.Cut1D(rawArguments, 2, #rawArguments) or {}
		local commandModule = require(handler)

		print(
			"[<debugger>(console:client)]: Command execution successful",
			commandModule.commandInvoked(arguments, index)
		)

		exeuteCommand:InvokeServerAsync(rawArguments)
	end

	local updateConsoleVisibility = function(rec)
		if consoleActivationState then
			consoleBar.Visible = true
			consoleBar:CaptureFocus()
		else
			if not rec then
				consoleBar:ReleaseFocus()
			end
			consoleBar.Visible = false
		end
	end

	local activateConsole = function()
		consoleActivationState = not consoleActivationState
		updateConsoleVisibility()
	end

	consoleBar:GetPropertyChangedSignal("Text"):Connect(function()
		local input = consoleBar.Text
		if not input:match("^> ") then
			consoleBar.Text = "> " .. input:match("^[> ]*(.*)")
		end
	end)
	consoleBar:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		local input = consoleBar.CursorPosition
		if input < 3 then
			consoleBar.CursorPosition = 3
		end
	end)

	consoleBar.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss)
		if not consoleBar.Visible then
			return
		end
		if enterPressed then
			task.spawn(processInput, consoleBar.Text)
			consoleBar.Text = "> "
		end
		consoleActivationState = false
		updateConsoleVisibility(true)
	end)

	--ContextActionService:BindAction("__activateDebugConsole", activateConsole, false, Enum.KeyCode.Insert)
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.KeyCode == Enum.KeyCode.Insert then
			activateConsole()
		end
	end)
	Players.LocalPlayer.Chatted:Connect(function(message)
		if message == "/debugconsole" then
			activateConsole()
		end
	end)
end

return consoleClientHandler
