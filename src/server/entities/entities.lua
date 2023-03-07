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
		drops = {
			["Wooden"] = 90,
			["Dull Blade"] = 10,
		},
		expDrop = {
			min = 200, -- Kill 10
			max = 600 -- Kill 4
		},

		maxHealth = 200,
		defence = 20,
		knockbackResistance = 1,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 20,
		visualDistance = 12,
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
				"rbxassetid://12145811328",
			},
		},
	},
	["Itachi"] = {
		name = "Itachi",
		id = 2,
		model = ReplicatedStorage.entities["Itachi"],

		level = 10,
		drops = {
			["Wooden"] = 30,
			["Dull Blade"] = 60,
			["Norse"] = 10,
		},
		expDrop = {
			min = 600, -- Kill 10
			max = 1400 -- Kill 4
		},

		maxHealth = 2400,
		defence = 30,
		knockbackResistance = 3,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 30,
		visualDistance = 12,
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
				"rbxassetid://12145811328",
			},
		},
	},
	["Obito"] = {
		name = "Obito",
		id = 3,
		model = ReplicatedStorage.entities["Obito"],

		level = 10,
		drops = {
			["Wooden"] = 25,
			["Dull Blade"] = 30,
			["Norse"] = 42,
			["Dark Iron Sword"] = 3,
		},
		expDrop = {
			min = 1400, -- Kill 10
			max = 2900 -- Kill 4
		},


		maxHealth = 28000,
		defence = 20,
		knockbackResistance = 5,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 40,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 16,

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
				"rbxassetid://12145811328",
			},
		},
	},
	["Madara"] = {
		name = "Madara",
		id = 4,
		model = ReplicatedStorage.entities["Madara"],

		level = 10,
		drops = {
			["Wooden"] = 10,
			["Dull Blade"] = 15,
			["Norse"] = 70,
			["Dark Iron Sword"] = 5,
		},

		expDrop = {
			min = 1400, -- Kill 10
			max = 2900 -- Kill 4
		},

		maxHealth = 75000,
		defence = 50,
		knockbackResistance = 6,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 20,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 16,

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
				"rbxassetid://12145811328",
			},
		},
	},
	["Kaguya"] = {
		name = "Kaguya",
		id = 5,
		model = ReplicatedStorage.entities["Kaguya"],

		level = 10,
		drops = {
			["Wooden"] = 10,
			["Dull Blade"] = 15,
			["Norse"] = 60,
			["Dark Iron Sword"] = 15,
		},

		maxHealth = 144000,
		defence = 20,
		knockbackResistance = 7,
		rangeOfAttack = 5,
		attackCooldown = 1,
		baseDamage = 50,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 18,

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
				"rbxassetid://12145811328",
			},
		},
	},
	["Dummy"] = {
		name = "Dummy",
		id = 6,
		model = ReplicatedStorage.entities["Dummy"],

		level = 10,
		drops = {
			["Wooden"] = 25,
			["Dull Blade"] = 25,
			["Norse"] = 25,
			["Dark Iron Sword"] = 25,
		},

		maxHealth = 2000,
		defence = 20,
		knockbackResistance = 7,
		rangeOfAttack = 5,
		attackCooldown = .5,
		baseDamage = 15,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 18,

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
				"rbxassetid://12145811328",
			},
		},
	},
}
