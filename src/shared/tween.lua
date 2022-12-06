local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoatTween = require(ReplicatedStorage.Packages.BoatTween)

type easingStyles =
	"RidiculousWiggle"
	| "Quart"
	| "Spring"
	| "ExitExpressive"
	| "SoftSpring"
	| "Sharp"
	| "Bounce"
	| "Back"
	| "UWPAccelerate"
	| "Elastic"
	| "StandardProductive"
	| "Quad"
	| "EntranceExpressive"
	| "Expo"
	| "Circ"
	| "Smooth"
	| "EntranceProductive"
	| "Acceleration"
	| "Sine"
	| "FabricDecelerate"
	| "Standard"
	| "FabricStandard"
	| "ExitProductive"
	| "Quint"
	| "FabricAccelerate"
	| "MozillaCurve"
	| "Linear"
	| "Cubic"
	| "RevBack"
	| "Smoother"
	| "Deceleration"
	| "StandardExpressive"

type easingDirections = "In" | "Out" | "InOut" | "OutIn"

-- tweens a instance once
local tweenInstance = function(
	object: Instance,
	goals: { [string]: any },
	duration: number?,
	easingStyle: easingStyles?,
	easingDirection: easingDirections?
)
	local _tween = BoatTween:Create(object, {
		Time = duration or 0.3,
		EasingStyle = easingStyle or "Cubic",
		EasingDirection = easingDirection or "Out",
		Goal = goals,
	})

	_tween:Play()

	coroutine.resume(coroutine.create(function()
		_tween.Completed:Wait()
		_tween:Destroy()
		_tween = nil
	end))

	return _tween
end

return {
	instance = tweenInstance,
}
