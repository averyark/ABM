local ReplicatedStorage = game:GetService("ReplicatedStorage")
local astrax = require(ReplicatedStorage.Packages.Astrax)

local module = require(astrax.module)
local objects = require(astrax.objects)
local debugger = require(astrax.debugger)

astrax.debugSettings.debugCommandsHandlerFolder = script.Parent.debugCommandsHandler
astrax.start()

module.loadDescendants(script.Parent)
print("MODULE LOADED")
