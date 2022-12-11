local solver = {}

function solver:Solve(point)
	if not point.LastPosition then
		point.LastPosition = point.Instances[1].WorldPosition
	end

	local origin = point.Instances[1].WorldPosition
	local direction = point.Instances[1].WorldPosition - point.LastPosition

	return origin, direction
end
function solver:UpdateToNextPosition(point)
	return point.Instances[1].WorldPosition
end
function solver:Visualize(point)
	return CFrame.lookAt(point.Instances[1].WorldPosition, point.LastPosition)
end

return solver
