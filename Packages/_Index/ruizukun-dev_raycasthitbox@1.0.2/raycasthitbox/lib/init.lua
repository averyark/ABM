local SHOW_DEBUG_RAY_LINES = false
local SHOW_OUTPUT_MESSAGES = false
local DEFAULT_COLLECTION_TAG_NAME = "_RaycastHitboxV4Managed"
local CollectionService = game:GetService("CollectionService")
local HitboxData = require(script.HitboxCaster)
local Signal = require(script.GoodSignal)
local RaycastHitbox = {}

RaycastHitbox.__index = RaycastHitbox
RaycastHitbox.__type = "RaycastHitboxModule"
RaycastHitbox.DetectionMode = {
	Default = 1,
	PartMode = 2,
	Bypass = 3,
}
RaycastHitbox.SignalType = {
	Default = 1,
	Single = 2,
}

function RaycastHitbox.new(object)
	local hitbox

	if object and CollectionService:HasTag(object, DEFAULT_COLLECTION_TAG_NAME) then
		hitbox = HitboxData:_FindHitbox(object)
	else
		hitbox = setmetatable({
			RaycastParams = nil,
			DetectionMode = RaycastHitbox.DetectionMode.Default,
			HitboxRaycastPoints = {},
			HitboxPendingRemoval = false,
			HitboxStopTime = 0,
			HitboxObject = object,
			HitboxHitList = {},
			HitboxActive = false,
			Visualizer = SHOW_DEBUG_RAY_LINES,
			DebugLog = SHOW_OUTPUT_MESSAGES,
			SignalType = RaycastHitbox.SignalType.Single,
			OnUpdate = Signal.new(RaycastHitbox.SignalType.Single),
			OnHit = Signal.new(RaycastHitbox.SignalType.Single),
			Tag = DEFAULT_COLLECTION_TAG_NAME,
		}, HitboxData)

		hitbox:_Init()
	end

	return hitbox
end
function RaycastHitbox:GetHitbox(object)
	if object then
		return HitboxData:_FindHitbox(object)
	end
end

return RaycastHitbox
