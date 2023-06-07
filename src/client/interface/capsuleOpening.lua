--!strict
--[[
    FileName    > capsuleOpening.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 31/03/2023
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")

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
local debug3d = require(Astrax.workspaceDebugManifest)

local debounce = require(ReplicatedStorage.shared.debounce)
local number = require(ReplicatedStorage.shared.number)
local tween = require(ReplicatedStorage.shared.tween)
local playerDataHandler = require(ReplicatedStorage.shared.playerData)
local main = require(script.Parent.main)
local settings = require(script.Parent.settings)

local capsules = require(ReplicatedStorage.shared.capsules)
local heros = require(ReplicatedStorage.shared.heros)
local rarities = require(ReplicatedStorage.shared.rarities)

local blur = Instance.new("BlurEffect")
blur.Name = "__CAPSULE_BLUR"
blur.Enabled = false
blur.Size = 0
blur.Parent = Lighting

local cameraShake = require(ReplicatedStorage.CameraShaker)

local taunts = {
    "rbxassetid://12952740700",
}

return {
    load = function()

        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

        local capsuleOpening = playerGui:WaitForChild("capsuleOpening")
        local hud = playerGui:WaitForChild("hud")
        local activated = true

        local function ShakeCamera(shakeCf)
            -- shakeCf: CFrame value that represents the offset to apply for shake effect.
            -- Apply the effect:
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCf
        end
        
        -- Create CameraShaker instance:
        local renderPriority = Enum.RenderPriority.Camera.Value + 1
        local camShake = cameraShake.new(renderPriority, ShakeCamera)

        local animatedCapsuleOpening = function(rewards, capsuleId, type)

            local info = {}

            tween.instance(hud.right, {
                Position = UDim2.new(1, 0, 0.5, 0),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.smallButtons, {
                Position = UDim2.new(0, -231, 0.5, -112),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.currencies, {
                Position = UDim2.new(0, -250, 0.5, -40),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.buttons, {
                Position = UDim2.new(0, -231, 0.5, 60),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.level, {
                Position = UDim2.new(0.5, 0, 1, 0),
            }, 0.3, "ExitExpressive")
            tween.instance(hud.rebirth, {
                Position = UDim2.new(1, -28, 1, 0),
            }, 0.3, "ExitExpressive")
            
            task.delay(.25, function()
                Lighting:FindFirstChild("__ui__blurfocus").Enabled = false
                main.lock()
            end)

            blur.Size = 0
            blur.Enabled = true
            activated = true

            tween.instance(blur, {
                Size = 13,
            }, .4, "EntranceExpressive")

            capsuleOpening.cancel.Position = UDim2.fromScale(.5, 1.5)

            for _, id in pairs(rewards) do
                local data = heros[id]
                local clone = data.model:Clone()
                local rarityData = rarities[data.rarity]
                local percentage = capsules[capsuleId].rewards[id]

                clone.HumanoidRootPart.Anchored = true
                clone:ScaleTo(1.4)
                clone.Parent = workspace.gameFolders
                clone.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(69, -69, 69))

                local anim = Instance.new("Animation")
                anim.AnimationId = taunts[math.random(1, #taunts)]
    
                local track: AnimationTrack = clone.Humanoid.Animator:LoadAnimation(anim)
                track.Looped = true

                table.insert(info, {
                    clone = clone,
                    track = track,
                    data = data,
                    rarityData = rarityData,
                    percentage = percentage
                })
            end

            capsuleOpening.background.BackgroundTransparency = 1
            capsuleOpening.background.Visible = true

            tween.instance(capsuleOpening.background, {
                BackgroundTransparency = 0
            }, .4, "EntranceExpressive").Completed:Wait()

            local cf = workspace.CurrentCamera.CFrame
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = workspace.gameFolders.camPart1.CFrame

            tween.instance(capsuleOpening.background, {
                BackgroundTransparency = 1
            }, .4, "ExitExpressive")
            tween.instance(blur, {
                Size = 0
            }, .4, "ExitExpressive")

            if type == "Auto" then
                tween.instance(capsuleOpening.cancel, {
                    Position = UDim2.fromScale(.5, .8)
                })
            end

            for _, dat in pairs(info) do
                dat.billboard = capsuleOpening.billboard:Clone()
                dat.billboard.itemRarity.Text = dat.rarityData.name
                dat.billboard.itemRarity.TextColor3 = dat.rarityData.primaryColor
                dat.billboard.itemName.Text = dat.data.name
                dat.billboard.itemRarity.TextTransparency = 1
                dat.billboard.itemName.TextTransparency = 1
                dat.billboard.itemRarity.stroke.Transparency = 1
                dat.billboard.itemName.stroke.Transparency = 1
                dat.billboard.itemName.Position = UDim2.fromScale(.5, .1)
                dat.billboard.itemRarity.Position = UDim2.fromScale(.5, .45)
                dat.billboard.Adornee = dat.clone.HumanoidRootPart
                dat.billboard.Enabled = true
                dat.billboard.Name = dat.data.name
                dat.billboard.Parent = capsuleOpening
            end

            local tw = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                CFrame = workspace.gameFolders.camPart2.CFrame
            })
            tw:Play()
            tw.Completed:Wait()
            tw:Destroy()

            for i in pairs(info) do
                local particleContainer = workspace.gameFolders[`particle{i}`]:FindFirstChild("Attachment")
                particleContainer["1"]:Emit(30)
            end

            camShake:Start()
            camShake:ShakeOnce(5, 9, 0, 0.5, Vector3.new(0.25, 0.25, 0.25), Vector3.zero)

            task.wait(0.05)

            for i, dat in pairs(info) do
                dat.clone.HumanoidRootPart.CFrame = workspace.gameFolders[`capsuleOpeningPart{i}`].CFrame + Vector3.new(0, 2, 0)
            end
            for _, dat in pairs(info) do
                tween.instance(dat.billboard.itemRarity, {
                    TextTransparency = 0
                }, .3, "EntranceExpressive")
                tween.instance(dat.billboard.itemRarity.stroke, {
                    Transparency = 0.3
                }, .3, "EntranceExpressive")
                tween.instance(dat.billboard.itemName, {
                    TextTransparency = 0
                }, .3, "EntranceExpressive")
                tween.instance(dat.billboard.itemName.stroke, {
                    Transparency = 0
                }, .3, "EntranceExpressive")
                tween.instance(dat.billboard.itemName.stroke, {
                    Transparency = 0
                }, .3, "EntranceExpressive")
                tween.instance(dat.billboard.itemName, {
                    Position = UDim2.fromScale(.5, 0)
                }, .3, "EntranceExpressive")
                tween.instance(dat.billboard.itemRarity, {
                    Position = UDim2.fromScale(.5, .35)
                }, .3, "EntranceExpressive")
            end

            task.wait(0.3)
        
            for i in pairs(info) do
                local particleContainer = workspace.gameFolders[`particle{i}`]:FindFirstChild("Attachment")
                particleContainer["2"]:Emit(150)
            end

            task.wait(0.25)
            for i, dat in pairs(info) do
                dat.track:Play()
            end

            task.wait(1.75)
            camShake:Stop()
            capsuleOpening.cancel.Position = UDim2.fromScale(.5, 1.5)
            tween.instance(capsuleOpening.background, {
                BackgroundTransparency = 0
            }, .27, "EntranceExpressive")
           
            local tw2 = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                CFrame = workspace.gameFolders.camPart3.CFrame
            })
            tw2:Play()
            tw2.Completed:Wait()
            tw2:Destroy()

            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            workspace.CurrentCamera.FieldOfView = 50
            workspace.CurrentCamera.CFrame = cf

            tween.instance(capsuleOpening.background, {
                BackgroundTransparency = 1
            }, .4, "ExitExpressive")
            tween.instance(workspace.CurrentCamera, {
                FieldOfView = 70
            }, .3, "ExitExpressive")
            task.delay(0.1, function()
                tween.instance(hud.right, {
                    Position = UDim2.new(1, -258, 0.5, 0),
                }, 0.3, "EntranceExpressive")
                tween.instance(hud.currencies, {
                    Position = UDim2.new(0, 0, 0.5, -40),
                }, 0.3, "EntranceExpressive")
                tween.instance(hud.buttons, {
                    Position = UDim2.new(0, 8, 0.5, 66),
                }, 0.3, "EntranceExpressive")
                tween.instance(hud.smallButtons, {
                    Position = UDim2.new(0, 8, 0.5, -112),
                }, 0.3, "EntranceExpressive")
                tween.instance(hud.level, {
                    Position = UDim2.new(0.5, 0, 1, -48),
                }, 0.3, "EntranceExpressive")
                tween.instance(hud.rebirth, {
                    Position = UDim2.new(1, -28, 1, -32),
                }, 0.3, "EntranceExpressive")
            end)

            for i, dat in pairs(info) do
                dat.clone:Destroy()
                dat.billboard:Destroy()
                dat.billboard = nil
            end

            Lighting:FindFirstChild("__ui__blurfocus").Enabled = true
            main.unlock()
        end

        ReplicatedStorage.test3.Event:Connect(function(id, capsuleId)
            animatedCapsuleOpening(id, capsuleId)
        end)

        BridgeNet.CreateBridge("capsuleOpened"):Connect(animatedCapsuleOpening)
    end
}