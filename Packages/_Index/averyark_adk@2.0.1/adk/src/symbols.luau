--[[
    FileName    > symbols.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 03/04/2023
--]]

local enum = {}

enum.setting = {
	EnabledInLiveServers = "EnabledInLiveServers",
	EnableForWhitelistedOnly = "EnableForWhitelistedOnly",
	DebugEnabled = "DebugEnabled",
	Whitelisted = "Whitelisted",
}

enum.debugClassType = {
	Read = 1,
	Modified = 2,
	Append = 3,
	Initialize = 4,
	Destroy = 5,
}

enum.notificationType = {
	Error = 1,
	Warning = 2,
	Info = 3,
	Question = 4,
}

return enum
