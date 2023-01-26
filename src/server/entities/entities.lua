local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	--[[	["Evil Tree"] = {
		name = "Evil Tree",
		id = 1,
		model = ReplicatedStorage.entities["Evil Tree"],

		maxHealth = 1000,
		defence = 20,
		knockbackResistance = 0,
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
	},]]
	["Naruto"] = {
		name = "Naruto",
		id = 1,
		model = ReplicatedStorage.entities["Naruto"],

		level = 10,

		maxHealth = 1000,
		defence = 20,
		knockbackResistance = 0,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 20,
		visualDistance = 20,
		visualArcAngle = 100,
		walkSpeed = 15,

		respawnTime = 15,
		maximumDistanceFromSpawn = 70,

		agentParameter = {
			AgentCanJump = false,
			AgentCanClimb = false,
			AgentRadius = 4,
		},

		entitytagOffset = Vector3.new(0, 3, 0),

		animations = {
			WalkAnimation = "rbxassetid://12147286437",
			DyingAnimation = "rbxassetid://12147299702",
			IdleAnimation = "rbxassetid://12147280656",
			KnockbackAnimation = {
				"rbxassetid://12147288719",
				--"rbxassetid://12147293282",
			},
			AttackAnimations = {
				"rbxassetid://12147295583",
				"rbxassetid://12147298133",
			},
		},
		sounds = {
			DyingSound = "rbxassetid://7274504800",
			AttackSound = {
				"rbxassetid://12145816556",
				"rbxassetid://12145811328"
			},
		},
	},
}
