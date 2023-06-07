local ReplicatedStorage = game:GetService("ReplicatedStorage")
local astrax = require(ReplicatedStorage.Packages.Astrax)

astrax.module.setModuleFolder(script.Parent.server)
astrax.start():andThen(function()
	print("[AstraxFramework] AF loaded on the server")
end)
