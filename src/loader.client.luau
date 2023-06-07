local ReplicatedStorage = game:GetService("ReplicatedStorage")
local astrax = require(ReplicatedStorage.Packages.Astrax)

astrax.module.setModuleFolder(ReplicatedStorage.client)
astrax.start():andThen(function()
	print("[AstraxFramework] AF loaded on the client")
end)
