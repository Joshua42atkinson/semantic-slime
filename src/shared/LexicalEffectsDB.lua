--!strict
local LexicalEffectsDB = {}

LexicalEffectsDB.Elements = {
	Fire = {
		Color = Color3.fromRGB(255, 100, 50),
		Material = Enum.Material.Neon,
		Transparency = 0.5,
		Effect = "Speed",
		Value = 35 -- WalkSpeed
	},
	Water = {
		Color = Color3.fromRGB(50, 150, 255),
		Material = Enum.Material.Glass,
		Transparency = 0.6,
		Effect = "Slippery",
		Value = 0 -- Friction
	},
	Earth = {
		Color = Color3.fromRGB(120, 80, 50),
		Material = Enum.Material.Mud,
		Transparency = 0.1,
		Effect = "Sticky",
		Value = 8 -- WalkSpeed
	},
	Air = {
		Color = Color3.fromRGB(200, 255, 255),
		Material = Enum.Material.ForceField,
		Transparency = 0.8,
		Effect = "Floaty",
		Value = workspace.Gravity * 0.2 -- reduced gravity force
	},
	Shadow = {
		Color = Color3.fromRGB(30, 0, 50),
		Material = Enum.Material.Neon,
		Transparency = 0.4,
		Effect = "Blind",
		Value = 10 -- sight radius
	},
	Light = {
		Color = Color3.fromRGB(255, 255, 200),
		Material = Enum.Material.Neon,
		Transparency = 0.2,
		Effect = "Glow",
		Value = 10 -- bright aura
	},
	Normal = {
		Color = Color3.fromRGB(200, 200, 200),
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0.5,
		Effect = "Bounce",
		Value = 80 -- JumpPower
	}
}

LexicalEffectsDB.Roles = {
	Tank = { SizeMultiplier = 1.5, Duration = 2 },
	Striker = { SizeMultiplier = 1.0, Duration = 1.5 },
	Support = { SizeMultiplier = 1.2, Duration = 3 },
	Caster = { SizeMultiplier = 0.8, Duration = 2.5 },
	Assassin = { SizeMultiplier = 0.6, Duration = 1 },
	Healer = { SizeMultiplier = 1.0, Duration = 3 },
	Civilian = { SizeMultiplier = 1.0, Duration = 1 },
}

LexicalEffectsDB.SpecialRoots = {
	["mega"] = { Effect = "Scale", Value = 2.0 },
	["micro"] = { Effect = "Scale", Value = 0.5 },
	["celer"] = { Effect = "Speed", Value = 50 },
	["tard"] = { Effect = "Sticky", Value = 4 },
	["salto"] = { Effect = "Bounce", Value = 120 },
}

return LexicalEffectsDB
