local DEFAULT_DEBUGGER_RAY_COLOUR = Color3.fromRGB(255, 0, 0)
local DEFAULT_DEBUGGER_RAY_WIDTH = 4
local DEFAULT_DEBUGGER_RAY_NAME = "_RaycastHitboxDebugLine"
local DEFAULT_FAR_AWAY_CFRAME = CFrame.new(0, math.huge, 0)
local cache = {}

cache.__index = cache
cache.__type = "RaycastHitboxVisualizerCache"
cache._AdornmentInUse = {}
cache._AdornmentInReserve = {}

function cache:_CreateAdornment()
	local line = Instance.new("LineHandleAdornment")

	line.Name = DEFAULT_DEBUGGER_RAY_NAME
	line.Color3 = DEFAULT_DEBUGGER_RAY_COLOUR
	line.Thickness = DEFAULT_DEBUGGER_RAY_WIDTH
	line.Length = 0
	line.CFrame = DEFAULT_FAR_AWAY_CFRAME
	line.Adornee = workspace.Terrain
	line.Parent = workspace.Terrain

	return {
		Adornment = line,
		LastUse = 0,
	}
end
function cache:GetAdornment()
	if #cache._AdornmentInReserve <= 0 then
		local adornment = cache:_CreateAdornment()

		table.insert(cache._AdornmentInReserve, adornment)
	end

	local adornment = table.remove(cache._AdornmentInReserve, 1)

	if adornment then
		adornment.Adornment.Visible = true
		adornment.LastUse = os.clock()

		table.insert(cache._AdornmentInUse, adornment)
	end

	return adornment
end
function cache:ReturnAdornment(adornment)
	adornment.Adornment.Length = 0
	adornment.Adornment.Visible = false
	adornment.Adornment.CFrame = DEFAULT_FAR_AWAY_CFRAME

	table.insert(cache._AdornmentInReserve, adornment)
end
function cache:Clear()
	for i = #cache._AdornmentInReserve, 1, -1 do
		if cache._AdornmentInReserve[i].Adornment then
			cache._AdornmentInReserve[i].Adornment:Destroy()
		end

		table.remove(cache._AdornmentInReserve, i)
	end
end

return cache
