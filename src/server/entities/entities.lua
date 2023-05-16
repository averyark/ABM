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
			min = 25,
			max = 50
		},

		maxHealth = 320,
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
			min = 75,
			max = 150
		},

		maxHealth = 3300,
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
			["Norse"] = 40,
			["Dark Iron Sword"] = 5,
		},
		expDrop = {
			min = 225,
			max = 450,
		},


		maxHealth = 25670,
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
			["Dull Blade"] = 10,
			["Norse"] = 70,
			["Dark Iron Sword"] = 10,
		},

		expDrop = {
			min = 525,
			max = 1050,
		},

		maxHealth = 54500,
		defence = 50,
		knockbackResistance = 10,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 50,
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
			["Dull Blade"] = 10,
			["Norse"] = 60,
			["Dark Iron Sword"] = 20,
		},

		expDrop = {
			min = 1025,
			max = 2050,
		},

		maxHealth = 110000,
		defence = 20,
		knockbackResistance = 13,
		rangeOfAttack = 5,
		attackCooldown = 1,
		baseDamage = 60,
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
	["Boss Kaguya"] = {
		name = "Boss Kaguya",
		id = 6,
		model = ReplicatedStorage.entities["Boss Kaguya"],

		level = 10,
		drops = {
			["Dull Blade"] = 10,
			["Norse"] = 30,
			["Dark Iron Sword"] = 45,
			["Amenoma Kageuchi"] = 15
		},

		expDrop = {
			min = 1775,
			max = 3550,
		},

		isBoss = true,
		maxHealth = 325000,
		defence = 20,
		knockbackResistance = 1000,
		rangeOfAttack = 12,
		attackCooldown = 2,
		baseDamage = 80,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 10,

		respawnTime = 20,
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
	
	["Levi"] = {
		name = "Levi",
		id = 7,
		model = ReplicatedStorage.entities["Levi"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 90,
			["Filet Blade"] = 10,
		},
		expDrop = {
			min = 6326150,
			max = 12652300
		},

		maxHealth = 570109824,
		defence = 20,
		knockbackResistance = 19,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 80,
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
	["Mikasa"] = {
		name = "Mikasa",
		id = 8,
		model = ReplicatedStorage.entities["Mikasa"],

		level = 10,
		drops = {
			["Cool Steel"] = 30,
			["Festering Desire"] = 60,
			["Katana"] = 10,
		},
		expDrop = {
			min = 18978450,
			max = 37956900
		},

		maxHealth = 1897692192,
		defence = 30,
		knockbackResistance = 21,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 90,
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
	["Armoured titan"] = {
		name = "Armoured titan",
		id = 9,
		model = ReplicatedStorage.entities["Armoured titan"],

		level = 10,
		drops = {
			["Cool Steel"] = 20,
			["Festering Desire "] = 30,
			["Katana"] = 45,
			["Mistsplitter Reforged"] = 5,
		},
		expDrop = {
			min = 56935350,
			max = 113870700,
		},


		maxHealth = 637911840,
		defence = 20,
		knockbackResistance = 23,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 100,
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
	["Eren"] = {
		name = "Eren",
		id = 10,
		model = ReplicatedStorage.entities["Eren"],

		level = 10,
		drops = {
			["Cool Steel"] = 10,
			["Festering Desire"] = 10,
			["Katana"] = 70,
			["Mistsplitter Reforged"] = 10,
		},

		expDrop = {
			min = 132849150,
			max = 265698300,
		},

		maxHealth = 4512175718,
		defence = 50,
		knockbackResistance = 28,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 110,
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
	["Zeke"] = {
		name = "Zeke",
		id = 11,
		model = ReplicatedStorage.entities["Zeke"],

		level = 10,
		drops = {
			["Cool Steel"] = 10,
			["Festering Desire "] = 10,
			["Katana"] = 60,
			["Mistsplitter Reforged"] = 20,
		},

		expDrop = {
			min = 2340259372150,
			max = 518744300,
		},

		maxHealth = 52804392960,
		defence = 20,
		knockbackResistance = 31,
		rangeOfAttack = 5,
		attackCooldown = 1,
		baseDamage = 120,
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
	["Boss Zeke"] = {
		name = "Boss Zeke",
		id = 12,
		model = ReplicatedStorage.entities["Boss Zeke"],

		level = 10,
		drops = {
			["Cool Steel"] = 0,
			["Festering Desire"] = 15,
			["Katana"] = 50,
			["Mistsplitter Reforged"] = 25,
			["Narukami"] = 10
		},

		expDrop = {
			min = 449156650,
			max = 898313300,
		},

		maxHealth = 502758236800,
		defence = 20,
		knockbackResistance = 1000,
		rangeOfAttack = 12,
		attackCooldown = 2,
		baseDamage = 140,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 10,
		isBoss = true,

		respawnTime = 20,
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

	["Tanjiro"] = {
		name = "Tanjiro",
		id = 13,
		model = ReplicatedStorage.entities["Tanjiro"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 90,
			["Filet Blade"] = 10,
		},
		expDrop = {
			min = 8910,
			max = 17820
		},

		maxHealth = 2447505,
		defence = 20,
		knockbackResistance = 10,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 45,
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
	["Nezuco"] = {
		name = "Nezuco",
		id = 14,
		model = ReplicatedStorage.entities["Nezuco"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 30,
			["Filet Blade"] = 60,
			["Iron Sting"] = 10,
		},
		expDrop = {
			min = 26730,
			max = 53460
		},

		maxHealth = 4283134,
		defence = 30,
		knockbackResistance = 12,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 55,
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
	["Zenitsu"] = {
		name = "Zenitsu",
		id = 15,
		model = ReplicatedStorage.entities["Zenitsu"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 20,
			["Filet Blade"] = 30,
			["Iron Sting"] = 45,
			["Aquila Favonia"] = 5,
		},
		expDrop = {
			min = 80190,
			max = 160380,
		},


		maxHealth = 9790020,
		defence = 20,
		knockbackResistance = 14,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 65,
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
	["Kokushibo"] = {
		name = "Kokushibo",
		id = 16,
		model = ReplicatedStorage.entities["Kokushibo"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 10,
			["Filet Blade"] = 15,
			["Iron Sting"] = 65,
			["Aquila Favonia"] = 10,
		},

		expDrop = {
			min = 187110,
			max = 374220,
		},

		maxHealth = 39160079,
		defence = 50,
		knockbackResistance = 19,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 75,
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
	["Muzan Kibitsuji"] = {
		name = "Muzan Kibitsuji",
		id = 17,
		model = ReplicatedStorage.entities["Muzan Kibitsuji"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 10,
			["Dull Blade"] = 15,
			["Norse"] = 60,
			["Dark Iron Sword"] = 15,
		},

		expDrop = {
			min = 365310,
			max = 730620,
		},

		maxHealth = 86886426,
		defence = 20,
		knockbackResistance = 22,
		rangeOfAttack = 5,
		attackCooldown = 1,
		baseDamage = 85,
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
	["Boss Muzan Kibitsuji"] = {
		name = "Boss Muzan Kibitsuji",
		id = 18,
		model = ReplicatedStorage.entities["Boss Muzan Kibitsuji"],

		level = 10,
		drops = {
			["Harbinger Of Dawn"] = 0,
			["Filet Blade"] = 5,
			["Iron Sting"] = 55,
			["Aquila Favonia"] = 25,
			["Summit Shaper"] = 15
		},

		expDrop = {
			min = 632610,
			max = 1265220,
		},

		isBoss = true,
		maxHealth = 200695407,
		defence = 20,
		knockbackResistance = 1000,
		rangeOfAttack = 12,
		attackCooldown = 2,
		baseDamage = 105,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 10,

		respawnTime = 20,
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

	["Deku"] = {
		name = "Deku",
		id = 19,
		model = ReplicatedStorage.entities["Deku"],

		level = 10,
		drops = {
			["Sword Of Descension"] = 90,
			["Royal Longsword"] = 10,
		},
		expDrop = {
			min = 6737349820,
			max = 13474699640
		},

		maxHealth = 310528000000,
		defence = 20,
		knockbackResistance = 28,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 125,
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
	["Bakugo"] = {
		name = "Bakugo",
		id = 20,
		model = ReplicatedStorage.entities["Bakugo"],

		level = 10,
		drops = {
			["Sword Of Descension"] = 30,
			["Royal Longsword"] = 60,
			["Skyward Blade"] = 10,
		},
		expDrop = {
			min = 20212049460,
			max = 40424098920
		},

		maxHealth = 1715792000000,
		defence = 30,
		knockbackResistance = 30,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 135,
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
	["Todoroki"] = {
		name = "Todoroki",
		id = 21,
		model = ReplicatedStorage.entities["Todoroki"],

		level = 10,
		drops = {
			["Sword Of Descension"] = 25,
			["Royal Longsword"] = 30,
			["Skyward Blade"] = 42,
			["Boreas"] = 3,
		},
		expDrop = {
			min = 60636148380,
			max = 121272296760,
		},


		maxHealth = 9231584000000,
		defence = 20,
		knockbackResistance = 32,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 145,
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
	["All M"] = {
		name = "All M",
		id = 22,
		model = ReplicatedStorage.entities["All M"],

		level = 10,
		drops = {
			["Sword Of Descension"] = 10,
			["Royal Longsword"] = 15,
			["Skyward Blade"] = 70,
			["Boreas"] = 5,
		},

		expDrop = {
			min = 141484346220,
			max = 282968692440,
		},

		maxHealth = 60526400000000,
		defence = 50,
		knockbackResistance = 37,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 155,
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
	["One For All"] = {
		name = "One For All",
		id = 23,
		model = ReplicatedStorage.entities["One For All"],

		level = 10,
		drops = {
			["Sword Of Descension"] = 10,
			["Royal Longsword"] = 15,
			["Skyward Blade"] = 60,
			["Boreas"] = 15,
		},

		expDrop = {
			min = 276231342620,
			max = 552462685240,
		},

		maxHealth = 7505264000000000,
		defence = 20,
		knockbackResistance = 40,
		rangeOfAttack = 5,
		attackCooldown = 1,
		baseDamage = 165,
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
	["Boss One For All"] = {
		name = "Boss One For All",
		id = 24,
		model = ReplicatedStorage.entities["Boss One For All"],

		level = 10,
		drops = {
			["Sword Of Descension"] = 0,
			["Royal Longsword"] = 10,
			["Skyward Blade"] = 50,
			["Boreas"] = 25,
			["Freedom Sworn"] = 15
		},

		expDrop = {
			min = 478351837220,
			max = 956703674440,
		},

		maxHealth = 67505264000000000,
		defence = 20,
		knockbackResistance = 1000,
		rangeOfAttack = 12,
		attackCooldown = 2,
		baseDamage = 185,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 10,

		respawnTime = 20,
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

	["Zoro"] = {
		name = "Zoro",
		id = 25,
		model = ReplicatedStorage.entities["Zoro"],

		level = 10,
		drops = {
			["Traveler's Handy Sword"] = 90,
			["The Black Sword"] = 10,
		},
		expDrop = {
			min = 9567036744550,
			max = 19134073489100
		},

		maxHealth = 60000000000000000,
		defence = 20,
		knockbackResistance = 37,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 180,
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
	["Luffy"] = {
		name = "Luffy",
		id = 26,
		model = ReplicatedStorage.entities["Bakugo"],

		level = 10,
		drops = {
			["Traveler's Handy Sword"] = 30,
			["The Black Sword"] = 60,
			["Lions Roar"] = 10,
		},
		expDrop = {
			min = 28701110233650,
			max = 57402220467300
		},

		maxHealth = 560000000000000000,
		defence = 30,
		knockbackResistance = 39,
		rangeOfAttack = 5,
		attackCooldown = 2,
		baseDamage = 190,
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
	["White Beard"] = {
		name = "White Beard",
		id = 27,
		model = ReplicatedStorage.entities["White Beard"],

		level = 10,
		drops = {
			["Traveler's Handy Sword"] = 25,
			["The Black Sword"] = 30,
			["Lions Roar"] = 40,
			["Royal Filet Blade"] = 5,
		},
		expDrop = {
			min = 86103330700950,
			max = 172206661401900,
		},


		maxHealth = 3250000000000000000,
		defence = 20,
		knockbackResistance = 41,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 200,
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
	["Kaido"] = {
		name = "Kaido",
		id = 28,
		model = ReplicatedStorage.entities["Kaido"],

		level = 10,
		drops = {
			["Traveler's Handy Sword"] = 10,
			["Dull Blade"] = 10,
			["Lions Roar"] = 70,
			["Royal Filet Blade"] = 10,
		},

		expDrop = {
			min = 200907771635550,
			max = 401815543271100,
		},

		maxHealth = 17500000000000000000,
		defence = 50,
		knockbackResistance = 46,
		rangeOfAttack = 5,
		attackCooldown = 1.5,
		baseDamage = 210,
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
	["Black Beard"] = {
		name = "Black Beard",
		id = 29,
		model = ReplicatedStorage.entities["Black Beard"],

		level = 10,
		drops = {
			["Traveler's Handy Sword"] = 10,
			["The Black Sword"] = 10,
			["Lions Roar"] = 60,
			["Royal Filet Blade"] = 20,
		},

		expDrop = {
			min = 392248506526550,
			max = 784497013053100,
		},

		maxHealth = 150000000000000000000,
		defence = 20,
		knockbackResistance = 49,
		rangeOfAttack = 5,
		attackCooldown = 1,
		baseDamage = 220,
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
	["Boss Black Beard"] = {
		name = "Boss Black Beard",
		id = 30,
		model = ReplicatedStorage.entities["Boss Black Beard"],

		level = 10,
		drops = {
			["Traveler's Handy Sword"] = 0,
			["The Black Sword"] = 5,
			["Lions Roar"] = 50,
			["Royal Filet Blade"] = 30,
			["Bakufu"] = 15
		},

		expDrop = {
			min = 679259608863050,
			max = 1358519217726100,
		},

		maxHealth = 3500000000000000000000,
		defence = 20,
		knockbackResistance = 1000,
		rangeOfAttack = 12,
		attackCooldown = 2,
		baseDamage = 240,
		visualDistance = 12,
		visualArcAngle = 100,
		walkSpeed = 10,

		respawnTime = 20,
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
