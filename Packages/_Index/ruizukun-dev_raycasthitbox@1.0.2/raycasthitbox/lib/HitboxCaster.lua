-- #selene: allow(unused_variable)

local DEFAULT_ATTACHMENT_INSTANCE = "DmgPoint"
local DEFAULT_GROUP_NAME_INSTANCE = "Group"
local DEFAULT_DEBUGGER_RAY_DURATION = 0.25
local DEFAULT_DEBUG_LOGGER_PREFIX = "[ Raycast Hitbox V4 ]\n"
local DEFAULT_MISSING_ATTACHMENTS = [[No attachments found in object: %s. Can be safely ignored if using SetPoints.]]
local DEFAULT_ATTACH_COUNT_NOTICE = "%s attachments found in object: %s."
local MINIMUM_SECONDS_SCHEDULER = 1.6666666666666665E-2
local DEFAULT_SIMULATION_TYPE = game:GetService("RunService").Heartbeat
local CollectionService = game:GetService("CollectionService")
local VisualizerCache = require(script.Parent.VisualizerCache)
local ActiveHitboxes = {}
local Solvers = script.Parent:WaitForChild("Solvers")
local Hitbox = {}

Hitbox.__index = Hitbox
Hitbox.__type = "RaycastHitbox"
Hitbox.CastModes = {
	LinkAttachments = 1,
	Attachment = 2,
	Vector3 = 3,
	Bone = 4,
}

function Hitbox:HitStart(seconds)
	if self.HitboxActive then
		self:HitStop()
	end
	if seconds then
		self.HitboxStopTime = os.clock() + math.max(MINIMUM_SECONDS_SCHEDULER, seconds)
	end

	self.HitboxActive = true
end
function Hitbox:HitStop()
	self.HitboxActive = false
	self.HitboxStopTime = 0

	table.clear(self.HitboxHitList)
end
function Hitbox:Destroy()
	self.HitboxPendingRemoval = true

	if self.HitboxObject then
		CollectionService:RemoveTag(self.HitboxObject, self.Tag)
	end

	self:HitStop()
	self.OnHit:Destroy()
	self.OnUpdate:Destroy()

	self.HitboxRaycastPoints = nil
	self.HitboxObject = nil
end
function Hitbox:Recalibrate()
	local descendants = self.HitboxObject:GetDescendants()
	local attachmentCount = 0

	for i = #self.HitboxRaycastPoints, 1, -1 do
		if self.HitboxRaycastPoints[i].CastMode == Hitbox.CastModes.Attachment then
			table.remove(self.HitboxRaycastPoints, i)
		end
	end

	for _, attachment in ipairs(descendants) do
		if not attachment:IsA("Attachment") or attachment.Name ~= DEFAULT_ATTACHMENT_INSTANCE then
			continue
		end

		local group = attachment:GetAttribute(DEFAULT_GROUP_NAME_INSTANCE)
		local point = self:_CreatePoint(group, Hitbox.CastModes.Attachment, attachment.WorldPosition)

		table.insert(point.Instances, attachment)
		table.insert(self.HitboxRaycastPoints, point)

		attachmentCount += 1
	end

	if self.DebugLog then
		print(
			string.format(
				"%s%s",
				DEFAULT_DEBUG_LOGGER_PREFIX,
				attachmentCount > 0
						and string.format(DEFAULT_ATTACH_COUNT_NOTICE, attachmentCount, self.HitboxObject.Name)
					or string.format(DEFAULT_MISSING_ATTACHMENTS, self.HitboxObject.Name)
			)
		)
	end
end
function Hitbox:LinkAttachments(attachment1, attachment2)
	local group = attachment1:GetAttribute(DEFAULT_GROUP_NAME_INSTANCE)
	local point = self:_CreatePoint(group, Hitbox.CastModes.LinkAttachments)

	point.Instances[1] = attachment1
	point.Instances[2] = attachment2

	table.insert(self.HitboxRaycastPoints, point)
end
function Hitbox:UnlinkAttachments(attachment)
	for i = #self.HitboxRaycastPoints, 1, -1 do
		if #self.HitboxRaycastPoints[i].Instances >= 2 then
			if
				self.HitboxRaycastPoints[i].Instances[1] == attachment
				or self.HitboxRaycastPoints[i].Instances[2] == attachment
			then
				table.remove(self.HitboxRaycastPoints, i)
			end
		end
	end
end
function Hitbox:SetPoints(object, vectorPoints, group)
	for _, vector in ipairs(vectorPoints) do
		local point = self:_CreatePoint(group, Hitbox.CastModes[object:IsA("Bone") and "Bone" or "Vector3"])

		point.Instances[1] = object
		point.Instances[2] = vector

		table.insert(self.HitboxRaycastPoints, point)
	end
end
function Hitbox:RemovePoints(object, vectorPoints)
	for i = #self.HitboxRaycastPoints, 1, -1 do
		local part = (self.HitboxRaycastPoints[i]).Instances[1]

		if part == object then
			local originalVector = (self.HitboxRaycastPoints[i]).Instances[2]

			for _, vector in ipairs(vectorPoints) do
				if vector == originalVector then
					table.remove(self.HitboxRaycastPoints, i)

					break
				end
			end
		end
	end
end
function Hitbox:_CreatePoint(group, castMode, lastPosition)
	return {
		Group = group,
		CastMode = castMode,
		LastPosition = lastPosition,
		WorldSpace = nil,
		Instances = {},
	}
end
function Hitbox:_FindHitbox(object)
	for _, hitbox in ipairs(ActiveHitboxes) do
		if not hitbox.HitboxPendingRemoval and hitbox.HitboxObject == object then
			return hitbox
		end
	end
end
function Hitbox:_Init()
	if not self.HitboxObject then
		return
	end

	local tagConnection

	local function onTagRemoved(instance)
		if instance == self.HitboxObject then
			tagConnection:Disconnect()
			self:Destroy()
		end
	end

	self:Recalibrate()
	table.insert(ActiveHitboxes, self)
	CollectionService:AddTag(self.HitboxObject, self.Tag)

	tagConnection = CollectionService:GetInstanceRemovedSignal(self.Tag):Connect(onTagRemoved)
end

local function Init()
	local solversCache = table.create(#Solvers:GetChildren())

	DEFAULT_SIMULATION_TYPE:Connect(function(step)
		for i = #ActiveHitboxes, 1, -1 do
			if ActiveHitboxes[i].HitboxPendingRemoval then
				local hitbox = table.remove(ActiveHitboxes, i)

				table.clear(hitbox)
				setmetatable(hitbox, nil)

				continue
			end

			for _, point in ipairs(ActiveHitboxes[i].HitboxRaycastPoints) do
				if not ActiveHitboxes[i].HitboxActive then
					point.LastPosition = nil

					continue
				end

				local castMode = solversCache[point.CastMode]
				local origin, direction = castMode:Solve(point)
				local raycastResult = workspace:Raycast(origin, direction, ActiveHitboxes[i].RaycastParams)

				if ActiveHitboxes[i].Visualizer then
					local adornmentData = VisualizerCache:GetAdornment()

					if adornmentData then
						local debugStartPosition = castMode:Visualize(point)

						adornmentData.Adornment.Length = direction.Magnitude
						adornmentData.Adornment.CFrame = debugStartPosition
					end
				end

				point.LastPosition = castMode:UpdateToNextPosition(point)

				if raycastResult then
					local part = raycastResult.Instance
					local model
					local humanoid
					local target

					if ActiveHitboxes[i].DetectionMode == 1 then
						model = part:FindFirstAncestorOfClass("Model")

						if model then
							humanoid = model:FindFirstChildOfClass("Humanoid")
						end

						target = humanoid
					else
						target = part
					end
					if target then
						if ActiveHitboxes[i].DetectionMode <= 2 then
							if ActiveHitboxes[i].HitboxHitList[target] then
								continue
							else
								ActiveHitboxes[i].HitboxHitList[target] = true
							end
						end

						ActiveHitboxes[i].OnHit:Fire(part, humanoid, raycastResult, point.Group)
					end
				end
				if ActiveHitboxes[i].HitboxStopTime > 0 then
					if ActiveHitboxes[i].HitboxStopTime <= os.clock() then
						ActiveHitboxes[i]:HitStop()
					end
				end

				ActiveHitboxes[i].OnUpdate:Fire(point.LastPosition)

				if ActiveHitboxes[i].OnUpdate._signalType ~= ActiveHitboxes[i].SignalType then
					ActiveHitboxes[i].OnUpdate._signalType = ActiveHitboxes[i].SignalType
					ActiveHitboxes[i].OnHit._signalType = ActiveHitboxes[i].SignalType
				end
			end
		end

		local adornmentsInUse = #VisualizerCache._AdornmentInUse

		if adornmentsInUse > 0 then
			for i = adornmentsInUse, 1, -1 do
				if (os.clock() - VisualizerCache._AdornmentInUse[i].LastUse) >= DEFAULT_DEBUGGER_RAY_DURATION then
					local adornment = table.remove(VisualizerCache._AdornmentInUse, i)

					if adornment then
						VisualizerCache:ReturnAdornment(adornment)
					end
				end
			end
		end
	end)

	for castMode, enum in pairs(Hitbox.CastModes) do
		local moduleScript = Solvers:FindFirstChild(castMode)

		if moduleScript then
			local load = require(moduleScript)

			solversCache[enum] = load
		end
	end
end

Init()

return Hitbox
