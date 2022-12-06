local solver = {}

function solver:Solve(point)
	local origin = point.Instances[1].WorldPosition
	local direction = point.Instances[2].WorldPosition - point.Instances[1].WorldPosition

	return origin, direction
end
function solver:UpdateToNextPosition(point)
	return point.Instances[1].WorldPosition
end
function solver:Visualize(point)
	return CFrame.lookAt(point.Instances[1].WorldPosition, point.Instances[2].WorldPosition)
end

return solver
