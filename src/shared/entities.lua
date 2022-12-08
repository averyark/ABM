local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	["Evil Tree"] = {
		name = "Evil Tree",
		id = 1,
		model = ReplicatedStorage.entities["Evil Tree"],

		maxHealth = 1000,
		rangeOfAttack = 8,
		attackCooldown = 3,
		baseDamage = 20,
		visualDistance = 20,
		visualArcAngle = 100,
		walkSpeed = 10,

		agentParameter = {
			AgentCanJump = false,
			AgentCanClimb = false,
			AgentRadius = 8,
		},

		entitytagOffset = Vector3.new(0, 2, 0),

		animations = {
			WalkAnimation = "rbxassetid://7269213971",
			DyingAnimation = "rbxassetid://7269218510",
			IdleAnimation = "rbxassetid://7275473625",
			AttackAnimations = {
				"rbxassetid://7269224530",
				"rbxassetid://7269222936",
			},
		},
		sounds = {
			DyingSound = "rbxassetid://7274504800",
			AttackSound = "rbxassetid://7274504717",
		},
	},
}
