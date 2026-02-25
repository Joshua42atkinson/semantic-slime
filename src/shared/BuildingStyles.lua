--!strict
export type StyleDefinition = {
	Name: string,
	PrimaryMaterial: Enum.Material,
	SecondaryMaterial: Enum.Material,
	PrimaryColor: Color3,
	SecondaryColor: Color3,
	RoofType: "Flat" | "Wedge" | "Dome" | "Spire",
	Decorations: { string }?, -- List of decoration types to apply
}

local BuildingStyles: { [string]: StyleDefinition } = {
	Logos = {
		Name = "Classical",
		PrimaryMaterial = Enum.Material.Marble,
		SecondaryMaterial = Enum.Material.Granite,
		PrimaryColor = Color3.fromHex("#E2E8F0"), -- White/Light Grey
		SecondaryColor = Color3.fromHex("#1E3A8A"), -- Logos Blue
		RoofType = "Wedge",
		Decorations = { "Pillars", "Steps" },
	},
	Eros = {
		Name = "Organic",
		PrimaryMaterial = Enum.Material.WoodPlanks,
		SecondaryMaterial = Enum.Material.Grass,
		PrimaryColor = Color3.fromHex("#78350F"), -- Brown
		SecondaryColor = Color3.fromHex("#065F46"), -- Eros Green
		RoofType = "Dome", -- approximated with sphere
		Decorations = { "Vines", "Bushes" },
	},
	Pneuma = {
		Name = "Ethereal",
		PrimaryMaterial = Enum.Material.Glass,
		SecondaryMaterial = Enum.Material.Neon,
		PrimaryColor = Color3.fromHex("#E0E7FF"), -- Pale
		SecondaryColor = Color3.fromHex("#5B21B6"), -- Pneuma Purple
		RoofType = "Spire",
		Decorations = { "Floating_Orbs", "Rings" },
	},
	Soma = {
		Name = "Industrial",
		PrimaryMaterial = Enum.Material.CorrodedMetal,
		SecondaryMaterial = Enum.Material.DiamondPlate,
		PrimaryColor = Color3.fromHex("#451a03"), -- Rust
		SecondaryColor = Color3.fromHex("#991B1B"), -- Soma Red
		RoofType = "Flat",
		Decorations = { "Pipes", "Vents", "Truss" },
	},
	Hub = {
		Name = "Municipal",
		PrimaryMaterial = Enum.Material.Brick,
		SecondaryMaterial = Enum.Material.Concrete,
		PrimaryColor = Color3.fromHex("#FCD34D"), -- Goldish
		SecondaryColor = Color3.fromHex("#FFFFFF"),
		RoofType = "Dome",
		Decorations = { "Flags" },
	}
}

return BuildingStyles
