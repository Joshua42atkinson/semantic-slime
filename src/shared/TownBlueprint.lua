--!strict
local TownBlueprint = {
	Settings = {
		DistrictSize = 600, -- Expanded for Wilderness
		BuildingSize = Vector3.new(30, 25, 30),
		OffsetFromCenter = 350, -- Pushed out to accommodate larger hub/districts
		RoadWidth = 16,
	},
	Hub = {
		Name = "TownSquare",
		Size = Vector3.new(120, 1, 120),
		Color = Color3.fromHex("#FFD700"), -- Gold
		Props = {
			{ Name = "Fountain_Center", Size = Vector3.new(25, 8, 25), Offset = Vector3.new(0, 4, 0), Color = Color3.fromHex("#3B82F6"), Type = "Cylinder" },
			{ Name = "Bench_N", Size = Vector3.new(8, 2, 3), Offset = Vector3.new(0, 1, -40), Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_S", Size = Vector3.new(8, 2, 3), Offset = Vector3.new(0, 1, 40), Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_E", Size = Vector3.new(3, 2, 8), Offset = Vector3.new(40, 1, 0), Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_W", Size = Vector3.new(3, 2, 8), Offset = Vector3.new(-40, 1, 0), Color = Color3.fromHex("#92400E"), Type = "Block" },
		}
	},
	Districts = {
		Logos = { 
			Name = "Logos",
			Direction = Vector3.new(0, 0, -1), -- North
			Color = Color3.fromHex("#1E3A8A"), -- Blue
			Wilderness = {
				Biome = Enum.Material.Glacier,
				Roughness = 40,
				Scale = 120,
			},
			Layout = {
				Buildings = {
					{ Name = "City Hall", Offset = Vector3.new(0, 0, -120), Size = Vector3.new(80, 50, 50) },
					{ Name = "The Archive", Offset = Vector3.new(-100, 0, -60), Size = Vector3.new(60, 40, 60) },
					{ Name = "The Forge", Offset = Vector3.new(100, 0, -60), Size = Vector3.new(70, 45, 70) },
				},
				Props = {
					{ Name = "Lamp_L1", Size = Vector3.new(3, 18, 3), Offset = Vector3.new(-30, 9, 0), Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
					{ Name = "Lamp_L2", Size = Vector3.new(3, 18, 3), Offset = Vector3.new(30, 9, 0), Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
				}
			}
		},
		Eros = { 
			Name = "Eros",
			Direction = Vector3.new(0, 0, 1), -- South
			Color = Color3.fromHex("#065F46"), -- Green
			Wilderness = {
				Biome = Enum.Material.LeafyGrass,
				Roughness = 25,
				Scale = 80,
			},
			Layout = {
				Buildings = {
					{ Name = "The Sanctuary", Offset = Vector3.new(0, 0, 120), Size = Vector3.new(70, 40, 70) },
					{ Name = "The Garden", Offset = Vector3.new(-90, 0, 60), Size = Vector3.new(60, 15, 60), Color = Color3.fromHex("#10B981") }, 
					{ Name = "The Market", Offset = Vector3.new(90, 0, 60), Size = Vector3.new(70, 25, 70) },
				},
				Props = {
					{ Name = "Bush_E1", Size = Vector3.new(8, 8, 8), Offset = Vector3.new(-40, 4, 15), Color = Color3.fromHex("#047857"), Type = "Ball" },
					{ Name = "Bush_E2", Size = Vector3.new(8, 8, 8), Offset = Vector3.new(40, 4, 15), Color = Color3.fromHex("#047857"), Type = "Ball" },
				}
			}
		},
		Pneuma = { 
			Name = "Pneuma",
			Direction = Vector3.new(1, 0, 0), -- East
			Color = Color3.fromHex("#5B21B6"), -- Purple
			Wilderness = {
				Biome = Enum.Material.Sand, -- Dream-sands
				Roughness = 60, -- Dunes
				Scale = 150,
			},
			Layout = {
				Buildings = {
					{ Name = "The Observatory", Offset = Vector3.new(120, 0, 0), Size = Vector3.new(40, 80, 40) }, 
					{ Name = "Cloud Spire", Offset = Vector3.new(80, 0, -80), Size = Vector3.new(30, 100, 30) }, 
					{ Name = "The Carnival", Offset = Vector3.new(80, 0, 80), Size = Vector3.new(80, 30, 80) },
				},
				Props = {
					{ Name = "Balloon_P1", Size = Vector3.new(6, 6, 6), Offset = Vector3.new(30, 15, -30), Color = Color3.fromHex("#F472B6"), Type = "Ball" },
				}
			}
		},
		Soma = { 
			Name = "Soma",
			Direction = Vector3.new(-1, 0, 0), -- West
			Color = Color3.fromHex("#991B1B"), -- Red
			Wilderness = {
				Biome = Enum.Material.Basalt,
				Roughness = 50, -- Jagged
				Scale = 90,
			},
			Layout = {
				Buildings = {
					{ Name = "The Arena", Offset = Vector3.new(-120, 0, 0), Size = Vector3.new(100, 40, 100) },
					{ Name = "The Docks", Offset = Vector3.new(-80, 0, -90), Size = Vector3.new(80, 15, 40) },
					{ Name = "The Undercity", Offset = Vector3.new(-80, 0, 90), Size = Vector3.new(60, 20, 60) },
				},
				Props = {
					{ Name = "Crate_S1", Size = Vector3.new(7, 7, 7), Offset = Vector3.new(-30, 3.5, -15), Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "Crate_S2", Size = Vector3.new(7, 7, 7), Offset = Vector3.new(-40, 3.5, -8), Color = Color3.fromHex("#78350F"), Type = "Block" },
				}
			}
		},
	}
}

return TownBlueprint
