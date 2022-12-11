local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	["Katana"] = {
		name = "Katana",
		id = 1,
		model = ReplicatedStorage.items.weapons["Katana"],
		class = "single_wield",

		baseDamage = 100,
		critChance = 0.2,
		critMultiplication = { 1.4, 2.2 },
		knockback = 15,
		basicAttackCooldown = 0.05,
	},
}
