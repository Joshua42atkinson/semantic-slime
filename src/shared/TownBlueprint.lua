--!strict
-- TownBlueprint.lua
-- Configuration data for Syllable Springs world generation.
-- Art direction: Cozy Fantasy + Studio Ghibli warmth.
-- SIMPLIFIED: Focus on clean, readable spaces. Less is more.

local TownBlueprint = {
	Settings = {
		DistrictSize      = 1200,
		BuildingSize      = Vector3.new(30, 25, 30),
		OffsetFromCenter  = 800,
		RoadWidth         = 20,
		CityPadRatio      = 0.6,
	},

	-- ============================================================
	-- HUB — Town Square. Clean and welcoming.
	-- ============================================================
	Hub = {
		Name  = "TownSquare",
		Size  = Vector3.new(200, 1, 200),
		Color = Color3.fromHex("#FFD700"),
		Props = {
			-- ============ CENTRAL FOUNTAIN (Simple) ============
			{ Name = "Fountain_Base",    Size = Vector3.new(30, 4, 30),  Offset = Vector3.new(0, 2, 0),    Color = Color3.fromHex("#C7D2FE"), Type = "Cylinder" },
			{ Name = "Fountain_Pool",    Size = Vector3.new(28, 2, 28),  Offset = Vector3.new(0, 1, 0),    Color = Color3.fromHex("#3B82F6"), Type = "Cylinder" },
			{ Name = "Fountain_Column",  Size = Vector3.new(6, 18, 6),   Offset = Vector3.new(0, 12, 0),   Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
			{ Name = "Fountain_Crown",   Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(0, 24, 0),   Color = Color3.fromHex("#60A5FA"), Type = "Ball", Neon = true },

			-- ============ SLIME SYNTHESIZER (The Fabricator) ============
			{ Name = "Synth_Platform",   Size = Vector3.new(20, 2, 20),  Offset = Vector3.new(-55, 1, -55), Color = Color3.fromHex("#1F2937"), Type = "Cylinder" },
			{ Name = "Synth_Column",     Size = Vector3.new(8, 20, 8),   Offset = Vector3.new(-55, 12, -55),Color = Color3.fromHex("#4B5563"), Type = "Cylinder" },
			{ Name = "Synth_Orb",        Size = Vector3.new(10, 10, 10), Offset = Vector3.new(-55, 28, -55),Color = Color3.fromHex("#3B82F6"), Type = "Ball", Neon = true },
			{ Name = "Synthesizer_Console", Size = Vector3.new(8, 5, 4), Offset = Vector3.new(-55, 5, -42),Color = Color3.fromHex("#FBBF24"), Type = "Block" },

			-- ============ CORNER TREES (4 trees for framing) ============
			{ Name = "Tree_1_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(70, 10, -70),  Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_1_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(70, 22, -70),  Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			{ Name = "Tree_2_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(-70, 10, -70), Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_2_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(-70, 22, -70), Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			{ Name = "Tree_3_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(70, 10, 70),   Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_3_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(70, 22, 70),   Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			{ Name = "Tree_4_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(-70, 10, 70),  Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_4_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(-70, 22, 70),  Color = Color3.fromHex("#4CAF50"), Type = "Ball" },

			-- ============ DISTRICT DIRECTIONAL SIGNS ============
			{ Name = "Sign_BrainyBorough",  Size = Vector3.new(3, 8, 3), Offset = Vector3.new(0, 4, -85),  Color = Color3.fromHex("#1E3A8A"), Type = "Cylinder" },
			{ Name = "Sign_HeartwoodGrove", Size = Vector3.new(3, 8, 3), Offset = Vector3.new(0, 4, 85),   Color = Color3.fromHex("#065F46"), Type = "Cylinder" },
			{ Name = "Sign_WhisperWinds",   Size = Vector3.new(3, 8, 3), Offset = Vector3.new(85, 4, 0),   Color = Color3.fromHex("#5B21B6"), Type = "Cylinder" },
			{ Name = "Sign_ActionAlley",    Size = Vector3.new(3, 8, 3), Offset = Vector3.new(-85, 4, 0),  Color = Color3.fromHex("#991B1B"), Type = "Cylinder" },

			-- ============ BENCHES (4 simple benches) ============
			{ Name = "Bench_N", Size = Vector3.new(15, 3, 4), Offset = Vector3.new(0, 1.5, -50),  Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_S", Size = Vector3.new(15, 3, 4), Offset = Vector3.new(0, 1.5, 50),   Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_E", Size = Vector3.new(4, 3, 15), Offset = Vector3.new(50, 1.5, 0),   Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_W", Size = Vector3.new(4, 3, 15), Offset = Vector3.new(-50, 1.5, 0),  Color = Color3.fromHex("#92400E"), Type = "Block" },
		},
	},

	-- ============================================================
	-- DISTRICTS — Each with minimal, thematic decoration
	-- ============================================================
	Districts = {
		BrainyBorough = {
			Name      = "The Brainy Borough",
			Direction = Vector3.new(0, 0, -1),
			Color     = Color3.fromHex("#1E3A8A"),
			FloorMaterial  = Enum.Material.Cobblestone,
			FloorColor     = Color3.fromHex("#CBD5E1"),
			Wilderness = { Biome = Enum.Material.Glacier, Roughness = 40, Scale = 250 },
			AmbientCrystals = { Color = Color3.fromHex("#60A5FA"), Count = 5, Height = 15 },
			Layout = {
				Buildings = {
					{ Name = "City Hall",          RingIndex = 11, Size = Vector3.new(60, 45, 60) },
					{ Name = "The Grand Pavilion", RingIndex = 0,  Size = Vector3.new(70, 50, 70) },
					{ Name = "The Archive",        RingIndex = 1,  Size = Vector3.new(60, 40, 60) },
				},
				Props = {
					{ Name = "Lamp1_Post",  Size = Vector3.new(3, 18, 3), Offset = Vector3.new(-30, 9, 20),  Color = Color3.fromHex("#37474F"), Type = "Cylinder" },
					{ Name = "Lamp1_Light", Size = Vector3.new(4, 4, 4),  Offset = Vector3.new(-30, 20, 20), Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
					{ Name = "Lamp2_Post",  Size = Vector3.new(3, 18, 3), Offset = Vector3.new(30, 9, 20),   Color = Color3.fromHex("#37474F"), Type = "Cylinder" },
					{ Name = "Lamp2_Light", Size = Vector3.new(4, 4, 4),  Offset = Vector3.new(30, 20, 20),  Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
				},
			},
		},

		HeartwoodGrove = {
			Name      = "Heartwood Grove",
			Direction = Vector3.new(0, 0, 1),
			Color     = Color3.fromHex("#065F46"),
			FloorMaterial  = Enum.Material.LeafyGrass,
			FloorColor     = Color3.fromHex("#4ADE80"),
			Wilderness = { Biome = Enum.Material.LeafyGrass, Roughness = 25, Scale = 80, HasWater = true },
			AmbientCrystals = { Color = Color3.fromHex("#86EFAC"), Count = 6, Height = 12 },
			Layout = {
				Buildings = {
					{ Name = "The Sanctuary", RingIndex = 5, Size = Vector3.new(70, 40, 70) },
					{ Name = "The Market",    RingIndex = 6, Size = Vector3.new(80, 25, 80) },
					{ Name = "The Docks",     RingIndex = 7, Size = Vector3.new(60, 25, 40) },
				},
				Props = {
					{ Name = "Tree1_Trunk", Size = Vector3.new(5, 25, 5),   Offset = Vector3.new(-60, 12.5, 30), Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Tree1_Leaf",  Size = Vector3.new(22, 22, 22), Offset = Vector3.new(-60, 28, 30),   Color = Color3.fromHex("#15803D"), Type = "Ball" },
					{ Name = "Tree2_Trunk", Size = Vector3.new(4, 20, 4),   Offset = Vector3.new(55, 10, 25),   Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					{ Name = "Tree2_Leaf",  Size = Vector3.new(18, 18, 18), Offset = Vector3.new(55, 23, 25),   Color = Color3.fromHex("#15803D"), Type = "Ball" },
					{ Name = "Well_Base",   Size = Vector3.new(12, 4, 12),  Offset = Vector3.new(0, 2, 70),     Color = Color3.fromHex("#5D4037"), Type = "Cylinder" },
					{ Name = "Well_Water",  Size = Vector3.new(10, 1, 10),  Offset = Vector3.new(0, 2, 70),     Color = Color3.fromHex("#3B82F6"), Type = "Cylinder" },
				},
			},
		},

		WhisperWinds = {
			Name      = "Whisper Winds",
			Direction = Vector3.new(1, 0, 0),
			Color     = Color3.fromHex("#5B21B6"),
			FloorMaterial  = Enum.Material.Sand,
			FloorColor     = Color3.fromHex("#C4B5FD"),
			Wilderness = { Biome = Enum.Material.Sand, Roughness = 60, Scale = 150 },
			AmbientCrystals = { Color = Color3.fromHex("#E9D5FF"), Count = 6, Height = 20 },
			Layout = {
				Buildings = {
					{ Name = "Cloud Spire",   RingIndex = 2,  Size = Vector3.new(40, 80, 40) },
					{ Name = "The Speakers",  RingIndex = 3,  Size = Vector3.new(60, 35, 60) },
					{ Name = "The Studio",    RingIndex = 4,  Size = Vector3.new(50, 40, 50) },
				},
				Props = {
					{ Name = "Lantern1_Post", Size = Vector3.new(2, 15, 2), Offset = Vector3.new(-20, 7.5, 0),  Color = Color3.fromHex("#7C3AED"), Type = "Cylinder" },
					{ Name = "Lantern1_Glow", Size = Vector3.new(4, 4, 4),  Offset = Vector3.new(-20, 17, 0),  Color = Color3.fromHex("#C4B5FD"), Type = "Ball", Neon = true },
					{ Name = "Lantern2_Post", Size = Vector3.new(2, 15, 2), Offset = Vector3.new(-20, 7.5, 40), Color = Color3.fromHex("#7C3AED"), Type = "Cylinder" },
					{ Name = "Lantern2_Glow", Size = Vector3.new(4, 4, 4),  Offset = Vector3.new(-20, 17, 40), Color = Color3.fromHex("#C4B5FD"), Type = "Ball", Neon = true },
				},
			},
		},

		ActionAlley = {
			Name      = "Action Alley",
			Direction = Vector3.new(-1, 0, 0),
			Color     = Color3.fromHex("#991B1B"),
			FloorMaterial  = Enum.Material.CrackedLava,
			FloorColor     = Color3.fromHex("#7C2D12"),
			Wilderness = { Biome = Enum.Material.Basalt, Roughness = 50, Scale = 90 },
			AmbientCrystals = { Color = Color3.fromHex("#FB923C"), Count = 4, Height = 10 },
			Layout = {
				Buildings = {
					{ Name = "The Outpost", RingIndex = 8, Size = Vector3.new(50, 30, 50) },
					{ Name = "The Arena",   RingIndex = 9, Size = Vector3.new(90, 40, 90) },
					{ Name = "The Sanctum", RingIndex = 10, Size = Vector3.new(60, 35, 60) },
				},
				Props = {
					{ Name = "GrandTorch_1",  Size = Vector3.new(4, 25, 4),  Offset = Vector3.new(-30, 12.5, -60), Color = Color3.fromHex("#292524"), Type = "Cylinder" },
					{ Name = "GrandTorch_1F", Size = Vector3.new(6, 6, 6),   Offset = Vector3.new(-30, 28, -60),   Color = Color3.fromHex("#F97316"), Type = "Ball", Neon = true },
					{ Name = "GrandTorch_2",  Size = Vector3.new(4, 25, 4),  Offset = Vector3.new(-30, 12.5, 60),  Color = Color3.fromHex("#292524"), Type = "Cylinder" },
					{ Name = "GrandTorch_2F", Size = Vector3.new(6, 6, 6),   Offset = Vector3.new(-30, 28, 60),    Color = Color3.fromHex("#EF4444"), Type = "Ball", Neon = true },
				},
			},
		},
	},
}

return TownBlueprint
