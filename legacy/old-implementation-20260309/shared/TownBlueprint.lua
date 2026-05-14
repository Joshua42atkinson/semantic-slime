--!strict
-- TownBlueprint.lua
-- Configuration data for Syllable Springs world generation.
-- Art direction: Cozy Fantasy + Studio Ghibli warmth.
-- Districts each have a unique material palette and atmosphere.

local TownBlueprint = {
	Settings = {
		DistrictSize      = 1200,  -- Total size per district (city pad = 60% = 360 studs)
		BuildingSize      = Vector3.new(30, 25, 30),
		OffsetFromCenter  = 800,  -- Center of each district from world origin
		RoadWidth         = 20,   -- Width of the road connecting hub to districts
		CityPadRatio      = 0.6,  -- 60% of DistrictSize = city pad
	},

	-- ============================================================
	-- HUB — Town Square. Warm gold/marble. Welcoming.
	-- Enhanced with grand decorative elements.
	-- ============================================================
	Hub = {
		Name  = "TownSquare",
		Size  = Vector3.new(200, 1, 200), -- Larger hub
		Color = Color3.fromHex("#FFD700"),
		Props = {
			-- ============ CENTRAL FOUNTAIN (Grand Multi-Tier) ============
			{ Name = "Fountain_Base",      Size = Vector3.new(40, 5, 40),   Offset = Vector3.new(0, 2.5, 0),    Color = Color3.fromHex("#C7D2FE"), Type = "Cylinder" },
			{ Name = "Fountain_Pool",      Size = Vector3.new(38, 2, 38),   Offset = Vector3.new(0, 1, 0),      Color = Color3.fromHex("#3B82F6"), Type = "Cylinder" },
			{ Name = "Fountain_Rim",       Size = Vector3.new(42, 3, 42),   Offset = Vector3.new(0, 3, 0),      Color = Color3.fromHex("#A5B4FC"), Type = "Cylinder" },
			{ Name = "Fountain_Column1",   Size = Vector3.new(10, 15, 10),  Offset = Vector3.new(0, 10, 0),     Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
			{ Name = "Fountain_Column2",   Size = Vector3.new(6, 20, 6),    Offset = Vector3.new(0, 20, 0),     Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
			{ Name = "Fountain_Top",       Size = Vector3.new(20, 6, 20),   Offset = Vector3.new(0, 32, 0),     Color = Color3.fromHex("#BAE6FD"), Type = "Cylinder" },
			{ Name = "Fountain_Crown",     Size = Vector3.new(8, 8, 8),     Offset = Vector3.new(0, 38, 0),     Color = Color3.fromHex("#60A5FA"), Type = "Ball", Neon = true },
			-- Water spray effects (decorative)
			{ Name = "WaterSpray_1",       Size = Vector3.new(3, 3, 3),     Offset = Vector3.new(8, 5, 0),      Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
			{ Name = "WaterSpray_2",       Size = Vector3.new(3, 3, 3),     Offset = Vector3.new(-8, 5, 0),     Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
			{ Name = "WaterSpray_3",       Size = Vector3.new(3, 3, 3),     Offset = Vector3.new(0, 5, 8),      Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
			{ Name = "WaterSpray_4",       Size = Vector3.new(3, 3, 3),     Offset = Vector3.new(0, 5, -8),     Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
			
			-- ============ BATTLE ARENA (East Side - for slime battles) ============
			{ Name = "Arena_Floor",        Size = Vector3.new(50, 1, 50),   Offset = Vector3.new(55, 0.5, 0),    Color = Color3.fromHex("#DC2626"), Type = "Cylinder" },
			{ Name = "Arena_Ring_L",       Size = Vector3.new(2, 4, 52),    Offset = Vector3.new(31, 2, 0),      Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Arena_Ring_R",       Size = Vector3.new(2, 4, 52),    Offset = Vector3.new(79, 2, 0),      Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Arena_Ring_B",       Size = Vector3.new(52, 4, 2),    Offset = Vector3.new(55, 2, -24),    Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Arena_Ring_T",       Size = Vector3.new(52, 4, 2),    Offset = Vector3.new(55, 2, 24),     Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Arena_Gate_L",       Size = Vector3.new(3, 6, 8),     Offset = Vector3.new(40, 3, -10),    Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Arena_Gate_R",       Size = Vector3.new(3, 6, 8),     Offset = Vector3.new(70, 3, -10),    Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Arena_Pillar_1",     Size = Vector3.new(4, 15, 4),   Offset = Vector3.new(35, 7.5, 15),   Color = Color3.fromHex("#B91C1C"), Type = "Cylinder" },
			{ Name = "Arena_Pillar_2",     Size = Vector3.new(4, 15, 4),   Offset = Vector3.new(75, 7.5, 15),   Color = Color3.fromHex("#B91C1C"), Type = "Cylinder" },
			{ Name = "Arena_Pillar_3",     Size = Vector3.new(4, 15, 4),   Offset = Vector3.new(35, 7.5, -15),  Color = Color3.fromHex("#B91C1C"), Type = "Cylinder" },
			{ Name = "Arena_Pillar_4",     Size = Vector3.new(4, 15, 4),   Offset = Vector3.new(75, 7.5, -15),  Color = Color3.fromHex("#B91C1C"), Type = "Cylinder" },
			-- Arena flags
			{ Name = "Arena_Flag_1",      Size = Vector3.new(2, 12, 8),    Offset = Vector3.new(35, 14, 20),    Color = Color3.fromHex("#EF4444"), Type = "Block" },
			{ Name = "Arena_Flag_2",      Size = Vector3.new(2, 12, 8),    Offset = Vector3.new(75, 14, 20),    Color = Color3.fromHex("#3B82F6"), Type = "Block" },
			{ Name = "Arena_Flag_3",      Size = Vector3.new(2, 12, 8),    Offset = Vector3.new(35, 14, -20),   Color = Color3.fromHex("#10B981"), Type = "Block" },
			{ Name = "Arena_Flag_4",      Size = Vector3.new(2, 12, 8),    Offset = Vector3.new(75, 14, -20),   Color = Color3.fromHex("#F59E0B"), Type = "Block" },

			-- ============ SLIME EXHIBITION AREA (West Side - for showcasing slimes) ============
			{ Name = "Exhibit_Base",       Size = Vector3.new(40, 1, 40),   Offset = Vector3.new(-55, 0.5, 0),   Color = Color3.fromHex("#8B5CF6"), Type = "Cylinder" },
			{ Name = "Exhibit_Podium_1",   Size = Vector3.new(8, 3, 8),    Offset = Vector3.new(-70, 1.5, -12), Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Exhibit_Podium_2",   Size = Vector3.new(8, 3, 8),    Offset = Vector3.new(-40, 1.5, -12), Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Exhibit_Podium_3",   Size = Vector3.new(8, 3, 8),    Offset = Vector3.new(-70, 1.5, 12),  Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Exhibit_Podium_4",   Size = Vector3.new(8, 3, 8),    Offset = Vector3.new(-40, 1.5, 12),  Color = Color3.fromHex("#FCD34D"), Type = "Cylinder" },
			{ Name = "Exhibit_Center",     Size = Vector3.new(12, 5, 12),  Offset = Vector3.new(-55, 2.5, 0),  Color = Color3.fromHex("#A78BFA"), Type = "Cylinder" },
			-- Exhibit glow rings
			{ Name = "Exhibit_Ring_1",     Size = Vector3.new(48, 1, 48),  Offset = Vector3.new(-55, 1, 0),     Color = Color3.fromHex("#C4B5FD"), Type = "Cylinder" },
			{ Name = "Exhibit_Ring_2",     Size = Vector3.new(55, 1, 55),  Offset = Vector3.new(-55, 0.5, 0),   Color = Color3.fromHex("#7C3AED"), Type = "Cylinder" },
			
			-- ============ DECORATIVE HEDGES (around fountain) ============
			{ Name = "Hedge_N1",    Size = Vector3.new(25, 5, 4),   Offset = Vector3.new(0, 2.5, -55),   Color = Color3.fromHex("#2E7D32"), Type = "Block" },
			{ Name = "Hedge_N2",    Size = Vector3.new(15, 4, 3),   Offset = Vector3.new(-20, 2, -50),   Color = Color3.fromHex("#388E3C"), Type = "Block" },
			{ Name = "Hedge_N3",    Size = Vector3.new(15, 4, 3),   Offset = Vector3.new(20, 2, -50),    Color = Color3.fromHex("#388E3C"), Type = "Block" },
			{ Name = "Hedge_S1",    Size = Vector3.new(25, 5, 4),   Offset = Vector3.new(0, 2.5, 55),    Color = Color3.fromHex("#2E7D32"), Type = "Block" },
			{ Name = "Hedge_S2",    Size = Vector3.new(15, 4, 3),   Offset = Vector3.new(-20, 2, 50),    Color = Color3.fromHex("#388E3C"), Type = "Block" },
			{ Name = "Hedge_S3",    Size = Vector3.new(15, 4, 3),   Offset = Vector3.new(20, 2, 50),     Color = Color3.fromHex("#388E3C"), Type = "Block" },
			{ Name = "Hedge_E1",    Size = Vector3.new(4, 5, 25),   Offset = Vector3.new(55, 2.5, 0),    Color = Color3.fromHex("#2E7D32"), Type = "Block" },
			{ Name = "Hedge_W1",    Size = Vector3.new(4, 5, 25),   Offset = Vector3.new(-55, 2.5, 0),   Color = Color3.fromHex("#2E7D32"), Type = "Block" },
			
			-- ============ GRAND LANTERN TOWERS (4 corners) ============
			{ Name = "Tower_NE",    Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(80, 20, -80),   Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
			{ Name = "Tower_NW",    Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(-80, 20, -80),  Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
			{ Name = "Tower_SE",    Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(80, 20, 80),    Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
			{ Name = "Tower_SW",    Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(-80, 20, 80),   Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
			-- Tower tops (ornate)
			{ Name = "TowerTop_NE", Size = Vector3.new(10, 8, 10),  Offset = Vector3.new(80, 42, -80),   Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
			{ Name = "TowerTop_NW", Size = Vector3.new(10, 8, 10),  Offset = Vector3.new(-80, 42, -80),  Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
			{ Name = "TowerTop_SE", Size = Vector3.new(10, 8, 10),  Offset = Vector3.new(80, 42, 80),    Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
			{ Name = "TowerTop_SW", Size = Vector3.new(10, 8, 10),  Offset = Vector3.new(-80, 42, 80),   Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
			
			-- ============ BENCHES (more, arranged in seating areas) ============
			{ Name = "Bench_N1",    Size = Vector3.new(18, 4, 5),   Offset = Vector3.new(-15, 2, -65),   Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_N2",    Size = Vector3.new(18, 4, 5),   Offset = Vector3.new(15, 2, -65),    Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_S1",    Size = Vector3.new(18, 4, 5),   Offset = Vector3.new(-15, 2, 65),    Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_S2",    Size = Vector3.new(18, 4, 5),   Offset = Vector3.new(15, 2, 65),     Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_E1",    Size = Vector3.new(5, 4, 18),   Offset = Vector3.new(65, 2, -15),    Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_E2",    Size = Vector3.new(5, 4, 18),   Offset = Vector3.new(65, 2, 15),     Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_W1",    Size = Vector3.new(5, 4, 18),   Offset = Vector3.new(-65, 2, -15),   Color = Color3.fromHex("#92400E"), Type = "Block" },
			{ Name = "Bench_W2",    Size = Vector3.new(5, 4, 18),   Offset = Vector3.new(-65, 2, 15),    Color = Color3.fromHex("#92400E"), Type = "Block" },
			
			-- ============ FLOWER BEDS (colorful accents) ============
			{ Name = "FlowerBed_N1", Size = Vector3.new(12, 2, 6),  Offset = Vector3.new(0, 1, -75),     Color = Color3.fromHex("#5D4037"), Type = "Block" },
			{ Name = "Flower_N1a",   Size = Vector3.new(2, 2, 2),   Offset = Vector3.new(-4, 3, -75),    Color = Color3.fromHex("#E91E63"), Type = "Ball", Neon = true },
			{ Name = "Flower_N1b",   Size = Vector3.new(2, 2, 2),   Offset = Vector3.new(0, 3, -75),     Color = Color3.fromHex("#9C27B0"), Type = "Ball", Neon = true },
			{ Name = "Flower_N1c",   Size = Vector3.new(2, 2, 2),   Offset = Vector3.new(4, 3, -75),     Color = Color3.fromHex("#FFEB3B"), Type = "Ball", Neon = true },
			{ Name = "FlowerBed_S1", Size = Vector3.new(12, 2, 6),  Offset = Vector3.new(0, 1, 75),      Color = Color3.fromHex("#5D4037"), Type = "Block" },
			{ Name = "Flower_S1a",   Size = Vector3.new(2, 2, 2),   Offset = Vector3.new(-4, 3, 75),     Color = Color3.fromHex("#FF5722"), Type = "Ball", Neon = true },
			{ Name = "Flower_S1b",   Size = Vector3.new(2, 2, 2),   Offset = Vector3.new(0, 3, 75),      Color = Color3.fromHex("#03A9F4"), Type = "Ball", Neon = true },
			{ Name = "Flower_S1c",   Size = Vector3.new(2, 2, 2),   Offset = Vector3.new(4, 3, 75),     Color = Color3.fromHex("#E91E63"), Type = "Ball", Neon = true },
			
			-- ============ EXTRA NATURE SCATTERED AROUND HUB ============
			-- Scattered trees around the perimeter
			{ Name = "Tree_Outer_1",  Size = Vector3.new(6, 30, 6),   Offset = Vector3.new(-120, 15, -100), Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
			{ Name = "Tree_Outer_1_Leaves", Size = Vector3.new(25, 25, 25), Offset = Vector3.new(-120, 32, -100), Color = Color3.fromHex("#15803D"), Type = "Ball" },
			{ Name = "Tree_Outer_2",  Size = Vector3.new(5, 25, 5),   Offset = Vector3.new(130, 12.5, -80), Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
			{ Name = "Tree_Outer_2_Leaves", Size = Vector3.new(20, 20, 20), Offset = Vector3.new(130, 27, -80), Color = Color3.fromHex("#16A34A"), Type = "Ball" },
			{ Name = "Tree_Outer_3",  Size = Vector3.new(7, 35, 7),   Offset = Vector3.new(-110, 17.5, 120), Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
			{ Name = "Tree_Outer_3_Leaves", Size = Vector3.new(28, 28, 28), Offset = Vector3.new(-110, 38, 120), Color = Color3.fromHex("#22C55E"), Type = "Ball" },
			{ Name = "Tree_Outer_4",  Size = Vector3.new(5, 22, 5),   Offset = Vector3.new(100, 11, 90),  Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
			{ Name = "Tree_Outer_4_Leaves", Size = Vector3.new(18, 18, 18), Offset = Vector3.new(100, 24, 90),  Color = Color3.fromHex("#15803D"), Type = "Ball" },
			
			-- Scattered bushes
			{ Name = "Bush_1", Size = Vector3.new(6, 4, 6), Offset = Vector3.new(-40, 2, -90), Color = Color3.fromHex("#166534"), Type = "Ball" },
			{ Name = "Bush_2", Size = Vector3.new(5, 3, 5), Offset = Vector3.new(50, 1.5, -85), Color = Color3.fromHex("#15803D"), Type = "Ball" },
			{ Name = "Bush_3", Size = Vector3.new(7, 4, 6), Offset = Vector3.new(-80, 2, 40), Color = Color3.fromHex("#22C55E"), Type = "Ball" },
			{ Name = "Bush_4", Size = Vector3.new(4, 3, 4), Offset = Vector3.new(70, 1.5, 60), Color = Color3.fromHex("#166534"), Type = "Ball" },
			{ Name = "Bush_5", Size = Vector3.new(5, 3, 5), Offset = Vector3.new(-60, 1.5, -50), Color = Color3.fromHex("#16A34A"), Type = "Ball" },
			{ Name = "Bush_6", Size = Vector3.new(6, 4, 5), Offset = Vector3.new(40, 2, 70), Color = Color3.fromHex("#15803D"), Type = "Ball" },
			
			-- Decorative rock formations
			{ Name = "Rock_1", Size = Vector3.new(8, 5, 6), Offset = Vector3.new(-100, 2.5, -40), Color = Color3.fromHex("#6B7280"), Type = "Block" },
			{ Name = "Rock_2", Size = Vector3.new(5, 3, 4), Offset = Vector3.new(-95, 1.5, -35), Color = Color3.fromHex("#9CA3AF"), Type = "Block" },
			{ Name = "Rock_3", Size = Vector3.new(6, 4, 5), Offset = Vector3.new(110, 2, 30), Color = Color3.fromHex("#6B7280"), Type = "Block" },
			{ Name = "Rock_4", Size = Vector3.new(4, 2, 3), Offset = Vector3.new(115, 1, 35), Color = Color3.fromHex("#9CA3AF"), Type = "Block" },
			{ Name = "Rock_5", Size = Vector3.new(7, 4, 5), Offset = Vector3.new(-30, 2, 100), Color = Color3.fromHex("#6B7280"), Type = "Block" },
			
			-- Mushrooms (whimsical touch)
			{ Name = "Mushroom_1_Stem", Size = Vector3.new(1, 2, 1), Offset = Vector3.new(-70, 1, -30), Color = Color3.fromHex("#F5F5DC"), Type = "Cylinder" },
			{ Name = "Mushroom_1_Cap", Size = Vector3.new(3, 1.5, 3), Offset = Vector3.new(-70, 2.5, -30), Color = Color3.fromHex("#DC2626"), Type = "Ball" },
			{ Name = "Mushroom_2_Stem", Size = Vector3.new(1, 1.5, 1), Offset = Vector3.new(80, 0.75, -50), Color = Color3.fromHex("#F5F5DC"), Type = "Cylinder" },
			{ Name = "Mushroom_2_Cap", Size = Vector3.new(2.5, 1, 2.5), Offset = Vector3.new(80, 1.75, -50), Color = Color3.fromHex("#7C3AED"), Type = "Ball" },
			{ Name = "Mushroom_3_Stem", Size = Vector3.new(1.2, 2.5, 1.2), Offset = Vector3.new(-50, 1.25, 90), Color = Color3.fromHex("#F5F5DC"), Type = "Cylinder" },
			{ Name = "Mushroom_3_Cap", Size = Vector3.new(3.5, 1.8, 3.5), Offset = Vector3.new(-50, 3, 90), Color = Color3.fromHex("#DB2777"), Type = "Ball" },
			
			-- ============ DISTRICT DIRECTIONAL SIGNS (Grand Arches) ============
			{ Name = "Arch_Brainy_L",  Size = Vector3.new(5, 35, 5), Offset = Vector3.new(-12, 17.5, -90), Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
			{ Name = "Arch_Brainy_R",  Size = Vector3.new(5, 35, 5), Offset = Vector3.new(12, 17.5, -90),  Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
			{ Name = "Arch_Brainy_T",  Size = Vector3.new(30, 4, 4), Offset = Vector3.new(0, 36, -90),     Color = Color3.fromHex("#1E3A8A"), Type = "Block" },
			{ Name = "Arch_Heartwood_L",   Size = Vector3.new(5, 35, 5), Offset = Vector3.new(-12, 17.5, 90),  Color = Color3.fromHex("#A7F3D0"), Type = "Cylinder" },
			{ Name = "Arch_Heartwood_R",   Size = Vector3.new(5, 35, 5), Offset = Vector3.new(12, 17.5, 90),   Color = Color3.fromHex("#A7F3D0"), Type = "Cylinder" },
			{ Name = "Arch_Heartwood_T",   Size = Vector3.new(30, 4, 4), Offset = Vector3.new(0, 36, 90),      Color = Color3.fromHex("#065F46"), Type = "Block" },
			{ Name = "Arch_Whisper_L", Size = Vector3.new(5, 35, 5), Offset = Vector3.new(90, 17.5, -12),  Color = Color3.fromHex("#E9D5FF"), Type = "Cylinder" },
			{ Name = "Arch_Whisper_R", Size = Vector3.new(5, 35, 5), Offset = Vector3.new(90, 17.5, 12),   Color = Color3.fromHex("#E9D5FF"), Type = "Cylinder" },
			{ Name = "Arch_Whisper_T", Size = Vector3.new(4, 4, 30), Offset = Vector3.new(90, 36, 0),      Color = Color3.fromHex("#5B21B6"), Type = "Block" },
			{ Name = "Arch_Action_L",   Size = Vector3.new(5, 35, 5), Offset = Vector3.new(-90, 17.5, -12), Color = Color3.fromHex("#FCA5A5"), Type = "Cylinder" },
			{ Name = "Arch_Action_R",   Size = Vector3.new(5, 35, 5), Offset = Vector3.new(-90, 17.5, 12),  Color = Color3.fromHex("#FCA5A5"), Type = "Cylinder" },
			{ Name = "Arch_Action_T",   Size = Vector3.new(4, 4, 30), Offset = Vector3.new(-90, 36, 0),     Color = Color3.fromHex("#991B1B"), Type = "Block" },
			
			-- ============ DECORATIVE TREES (small accent trees in planters) ============
			{ Name = "Planter_1",    Size = Vector3.new(8, 3, 8),   Offset = Vector3.new(70, 1.5, -70),  Color = Color3.fromHex("#5D4037"), Type = "Cylinder" },
			{ Name = "Tree_1_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(70, 10, -70),   Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_1_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(70, 22, -70),   Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			{ Name = "Planter_2",    Size = Vector3.new(8, 3, 8),   Offset = Vector3.new(-70, 1.5, -70), Color = Color3.fromHex("#5D4037"), Type = "Cylinder" },
			{ Name = "Tree_2_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(-70, 10, -70),  Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_2_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(-70, 22, -70),  Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			{ Name = "Planter_3",    Size = Vector3.new(8, 3, 8),   Offset = Vector3.new(70, 1.5, 70),   Color = Color3.fromHex("#5D4037"), Type = "Cylinder" },
			{ Name = "Tree_3_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(70, 10, 70),    Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_3_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(70, 22, 70),    Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			{ Name = "Planter_4",    Size = Vector3.new(8, 3, 8),   Offset = Vector3.new(-70, 1.5, 70),  Color = Color3.fromHex("#5D4037"), Type = "Cylinder" },
			{ Name = "Tree_4_Trunk", Size = Vector3.new(3, 15, 3),  Offset = Vector3.new(-70, 10, 70),   Color = Color3.fromHex("#6D4C41"), Type = "Cylinder" },
			{ Name = "Tree_4_Leaf",  Size = Vector3.new(12, 12, 12),Offset = Vector3.new(-70, 22, 70),   Color = Color3.fromHex("#4CAF50"), Type = "Ball" },
			
			-- ============ WORD ORB PEDESTAL (Central lore object) ============
			{ Name = "WordOrb_Base",   Size = Vector3.new(15, 3, 15), Offset = Vector3.new(55, 1.5, -55), Color = Color3.fromHex("#E2E8F0"), Type = "Cylinder" },
			{ Name = "WordOrb_Pillar", Size = Vector3.new(8, 12, 8),  Offset = Vector3.new(55, 9, -55),   Color = Color3.fromHex("#CBD5E1"), Type = "Cylinder" },
			{ Name = "WordOrb_Top",    Size = Vector3.new(12, 3, 12), Offset = Vector3.new(55, 16, -55),  Color = Color3.fromHex("#E2E8F0"), Type = "Cylinder" },
			
			-- ============ SLIME SYNTHESIZER (Grand Machine) ============
			{ Name = "Synth_Platform", Size = Vector3.new(25, 2, 25), Offset = Vector3.new(-55, 1, -55),  Color = Color3.fromHex("#1F2937"), Type = "Cylinder" },
			{ Name = "Synth_Base",     Size = Vector3.new(18, 3, 18), Offset = Vector3.new(-55, 3.5, -55),Color = Color3.fromHex("#374151"), Type = "Cylinder" },
			{ Name = "Synth_Column",   Size = Vector3.new(10, 25, 10),Offset = Vector3.new(-55, 16, -55), Color = Color3.fromHex("#4B5563"), Type = "Cylinder" },
			{ Name = "Synth_Ring1",    Size = Vector3.new(20, 2, 20), Offset = Vector3.new(-55, 30, -55), Color = Color3.fromHex("#60A5FA"), Type = "Cylinder", Neon = true },
			{ Name = "Synth_Orb",      Size = Vector3.new(14, 14, 14),Offset = Vector3.new(-55, 38, -55), Color = Color3.fromHex("#3B82F6"), Type = "Ball", Neon = true },
			{ Name = "Synth_Console",  Size = Vector3.new(8, 5, 4),   Offset = Vector3.new(-55, 5, -42),  Color = Color3.fromHex("#FBBF24"), Type = "Block" },
			{ Name = "Synth_Screen",   Size = Vector3.new(6, 4, 0.5), Offset = Vector3.new(-55, 10, -42), Color = Color3.fromHex("#10B981"), Type = "Block", Neon = true },

			-- ============ MAD LIB STAGE (Amphitheater for display) ============
			{ Name = "Stage_Base",     Size = Vector3.new(40, 3, 40), Offset = Vector3.new(0, 1.5, -85),  Color = Color3.fromHex("#8B5CF6"), Type = "Cylinder" },
			{ Name = "Stage_Step",     Size = Vector3.new(46, 1.5, 46),Offset = Vector3.new(0, 0.75, -85),Color = Color3.fromHex("#7C3AED"), Type = "Cylinder" },
			{ Name = "Stage_Backdrop", Size = Vector3.new(30, 25, 4), Offset = Vector3.new(0, 15, -100),  Color = Color3.fromHex("#4C1D95"), Type = "Block" },
			{ Name = "Stage_Screen",   Size = Vector3.new(26, 18, 1), Offset = Vector3.new(0, 15, -97.5), Color = Color3.fromHex("#1E3A8A"), Type = "Block", Neon = true },
			
			-- ============ GACHA MACHINE (Whimsical Dispenser) ============
			{ Name = "Gacha_Base",     Size = Vector3.new(12, 10, 12),Offset = Vector3.new(55, 5, -55),   Color = Color3.fromHex("#EF4444"), Type = "Cylinder" },
			{ Name = "Gacha_Glass",    Size = Vector3.new(14, 14, 14),Offset = Vector3.new(55, 17, -55),  Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true, Transparency = 0.5 },
			{ Name = "Gacha_Top",      Size = Vector3.new(12, 3, 12), Offset = Vector3.new(55, 25.5, -55),Color = Color3.fromHex("#DC2626"), Type = "Cylinder" },
			{ Name = "Gacha_Knob",     Size = Vector3.new(3, 3, 3),   Offset = Vector3.new(55, 6, -48),   Color = Color3.fromHex("#FBBF24"), Type = "Cylinder" },
			{ Name = "Gacha_PrizeHole",Size = Vector3.new(4, 4, 1),   Offset = Vector3.new(55, 3, -48.5), Color = Color3.fromHex("#000000"), Type = "Block" },
		},
	},

	-- ============================================================
	-- THE BRAINY BOROUGH (North, formerly Logos) — Knowledge, Logic, Fire of the Mind
	-- Art: Clean marble, pillars, library-tower vibes, calm blue
	-- ============================================================
	Districts = {
		BrainyBorough = {
			Name      = "The Brainy Borough",
			Direction = Vector3.new(0, 0, -1),
			Color     = Color3.fromHex("#1E3A8A"),
			FloorMaterial  = Enum.Material.Cobblestone,
			FloorColor     = Color3.fromHex("#CBD5E1"),
			Wilderness = {
				Biome     = Enum.Material.Glacier,
				Roughness = 40,
				Scale     = 250,
			},
			-- Ambient accent: floating blue light crystals scattered near buildings
			AmbientCrystals = { Color = Color3.fromHex("#60A5FA"), Count = 12, Height = 25 },
			-- FLOATING LETTERS (intellectual theme)
			FloatingElements = {
				{ Name = "Letter_A", Offset = Vector3.new(-20, 25, -30), Color = Color3.fromHex("#60A5FA") },
				{ Name = "Letter_B", Offset = Vector3.new(30, 30, 20), Color = Color3.fromHex("#3B82F6") },
				{ Name = "Letter_C", Offset = Vector3.new(-40, 22, 10), Color = Color3.fromHex("#93C5FD") },
				{ Name = "Letter_X", Offset = Vector3.new(10, 35, -40), Color = Color3.fromHex("#1E40AF") },
				{ Name = "Letter_Z", Offset = Vector3.new(50, 28, -20), Color = Color3.fromHex("#60A5FA") },
				{ Name = "Letter_Q", Offset = Vector3.new(-60, 32, 30), Color = Color3.fromHex("#3B82F6") },
				{ Name = "Letter_W", Offset = Vector3.new(20, 40, 50), Color = Color3.fromHex("#93C5FD") },
				{ Name = "Letter_K", Offset = Vector3.new(-30, 38, -50), Color = Color3.fromHex("#1E40AF") },
			},
			Layout = {
				Buildings = {
					{ Name = "City Hall",          RingIndex = 11, Size = Vector3.new(60, 45, 60) }, -- Ignis
					{ Name = "The Grand Pavilion", RingIndex = 0,  Size = Vector3.new(70, 50, 70) }, -- Barnaby
					{ Name = "The Archive",        RingIndex = 1,  Size = Vector3.new(60, 40, 60) }, -- Ozymandias
				},
				Props = {
					-- ============ STUDY NOOKS (quiet reading spots) ============
					{ Name = "StudyDesk_1", Size = Vector3.new(10, 4, 6), Offset = Vector3.new(-100, 2, 20), Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "StudyDesk_2", Size = Vector3.new(10, 4, 6), Offset = Vector3.new(-100, 2, -20), Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "StudyChair_1", Size = Vector3.new(4, 4, 4), Offset = Vector3.new(-92, 2, 20), Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					{ Name = "StudyChair_2", Size = Vector3.new(4, 4, 4), Offset = Vector3.new(-92, 2, -20), Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					-- Glowing reading orbs
					{ Name = "StudyOrb_1", Size = Vector3.new(2, 2, 2), Offset = Vector3.new(-100, 7, 20), Color = Color3.fromHex("#60A5FA"), Type = "Ball", Neon = true },
					{ Name = "StudyOrb_2", Size = Vector3.new(2, 2, 2), Offset = Vector3.new(-100, 7, -20), Color = Color3.fromHex("#60A5FA"), Type = "Ball", Neon = true },
					
					-- ============ GRAND ENTRANCE GATE ============
					{ Name = "Gate_Pillar_L",  Size = Vector3.new(8, 45, 8),  Offset = Vector3.new(-45, 22.5, 50), Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
					{ Name = "Gate_Pillar_R",  Size = Vector3.new(8, 45, 8),  Offset = Vector3.new(45, 22.5, 50),  Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
					{ Name = "Gate_Arch",      Size = Vector3.new(100, 6, 6),  Offset = Vector3.new(0, 47, 50),     Color = Color3.fromHex("#1E3A8A"), Type = "Block" },
					{ Name = "Gate_Orb_L",     Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(-45, 48, 50),   Color = Color3.fromHex("#60A5FA"), Type = "Ball", Neon = true },
					{ Name = "Gate_Orb_R",     Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(45, 48, 50),    Color = Color3.fromHex("#60A5FA"), Type = "Ball", Neon = true },
					
					-- ============ STREET LAMPS (elegant, along paths) ============
					{ Name = "Lamp1_Post",  Size = Vector3.new(3, 22, 3),  Offset = Vector3.new(-30, 11, 20),   Color = Color3.fromHex("#37474F"), Type = "Cylinder" },
					{ Name = "Lamp1_Light", Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(-30, 24, 20),   Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
					{ Name = "Lamp2_Post",  Size = Vector3.new(3, 22, 3),  Offset = Vector3.new(30, 11, 20),    Color = Color3.fromHex("#37474F"), Type = "Cylinder" },
					{ Name = "Lamp2_Light", Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(30, 24, 20),    Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
					{ Name = "Lamp3_Post",  Size = Vector3.new(3, 22, 3),  Offset = Vector3.new(-30, 11, -20),  Color = Color3.fromHex("#37474F"), Type = "Cylinder" },
					{ Name = "Lamp3_Light", Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(-30, 24, -20),  Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
					{ Name = "Lamp4_Post",  Size = Vector3.new(3, 22, 3),  Offset = Vector3.new(30, 11, -20),   Color = Color3.fromHex("#37474F"), Type = "Cylinder" },
					{ Name = "Lamp4_Light", Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(30, 24, -20),   Color = Color3.fromHex("#93C5FD"), Type = "Ball", Neon = true },
					
					-- ============ KNOWLEDGE MONUMENT (central feature) ============
					{ Name = "Monument_Base",  Size = Vector3.new(20, 4, 20),  Offset = Vector3.new(0, 2, -50),    Color = Color3.fromHex("#DBEAFE"), Type = "Cylinder" },
					{ Name = "Monument_Pedestal", Size = Vector3.new(12, 10, 12), Offset = Vector3.new(0, 9, -50),   Color = Color3.fromHex("#E0E7FF"), Type = "Cylinder" },
					{ Name = "Monument_Orb",   Size = Vector3.new(10, 10, 10),  Offset = Vector3.new(0, 20, -50),   Color = Color3.fromHex("#3B82F6"), Type = "Ball", Neon = true },
					{ Name = "Monument_Ring",  Size = Vector3.new(18, 1, 18),   Offset = Vector3.new(0, 18, -50),   Color = Color3.fromHex("#60A5FA"), Type = "Cylinder", Neon = true },
					
					-- ============ DECORATIVE PILLARS (around district) ============
					{ Name = "Pillar_1", Size = Vector3.new(6, 35, 6), Offset = Vector3.new(-80, 17.5, -30),  Color = Color3.fromHex("#E2E8F0"), Type = "Cylinder" },
					{ Name = "Pillar_2", Size = Vector3.new(6, 35, 6), Offset = Vector3.new(80, 17.5, -30),   Color = Color3.fromHex("#E2E8F0"), Type = "Cylinder" },
					{ Name = "Pillar_3", Size = Vector3.new(6, 35, 6), Offset = Vector3.new(-80, 17.5, -100), Color = Color3.fromHex("#E2E8F0"), Type = "Cylinder" },
					{ Name = "Pillar_4", Size = Vector3.new(6, 35, 6), Offset = Vector3.new(80, 17.5, -100),  Color = Color3.fromHex("#E2E8F0"), Type = "Cylinder" },
					
					-- ============ BOOK STACKS (decorative, near Archive) ============
					{ Name = "BookStack1", Size = Vector3.new(8, 6, 8),  Offset = Vector3.new(-130, 3, -50),  Color = Color3.fromHex("#7C3AED"), Type = "Block" },
					{ Name = "BookStack2", Size = Vector3.new(6, 4, 6),  Offset = Vector3.new(-130, 8, -50),  Color = Color3.fromHex("#EC4899"), Type = "Block" },
					{ Name = "BookStack3", Size = Vector3.new(7, 5, 7),  Offset = Vector3.new(-140, 2.5, -60),Color = Color3.fromHex("#3B82F6"), Type = "Block" },
					
					-- ============ BENCHES ============
					{ Name = "Bench_1", Size = Vector3.new(15, 4, 4), Offset = Vector3.new(-50, 2, 30),   Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "Bench_2", Size = Vector3.new(15, 4, 4), Offset = Vector3.new(50, 2, 30),    Color = Color3.fromHex("#78350F"), Type = "Block" },
				},
			},
		},

		-- ============================================================
		-- HEARTWOOD GROVE (South, formerly Eros) — Heart, Nature, Growth, Warmth
		-- Art: WoodPlanks, overgrown, soft green, cozy market
		-- ============================================================
		HeartwoodGrove = {
			Name      = "Heartwood Grove",
			Direction = Vector3.new(0, 0, 1),
			Color     = Color3.fromHex("#065F46"),
			FloorMaterial  = Enum.Material.LeafyGrass,
			FloorColor     = Color3.fromHex("#4ADE80"),
			Wilderness = {
				Biome     = Enum.Material.LeafyGrass,
				Roughness = 25,
				Scale     = 80,
				HasWater  = true, -- Eros has natural ponds and streams
			},
			AmbientCrystals = { Color = Color3.fromHex("#86EFAC"), Count = 15, Height = 18 },
				-- ============ FLOATING FIREFLIES (nature magic) ============
			FloatingElements = {
				{ Name = "Firefly_1", Offset = Vector3.new(-30, 12, 20), Color = Color3.fromHex("#FCD34D") },
				{ Name = "Firefly_2", Offset = Vector3.new(40, 15, -20), Color = Color3.fromHex("#FDE68A") },
				{ Name = "Firefly_3", Offset = Vector3.new(-50, 10, -30), Color = Color3.fromHex("#FBBF24") },
				{ Name = "Firefly_4", Offset = Vector3.new(20, 18, 40), Color = Color3.fromHex("#F59E0B") },
				{ Name = "Firefly_5", Offset = Vector3.new(-10, 8, -40), Color = Color3.fromHex("#FCD34D") },
				{ Name = "Firefly_6", Offset = Vector3.new(60, 14, 30), Color = Color3.fromHex("#FDE68A") },
				{ Name = "Firefly_7", Offset = Vector3.new(-70, 16, 50), Color = Color3.fromHex("#FBBF24") },
				{ Name = "Firefly_8", Offset = Vector3.new(30, 12, -60), Color = Color3.fromHex("#F59E0B") },
			},
			Layout = {
				Buildings = {
					{ Name = "The Sanctuary", RingIndex = 5, Size = Vector3.new(70, 40, 70) }, -- Vlad
					{ Name = "The Market",    RingIndex = 6, Size = Vector3.new(80, 25, 80) }, -- Chesty
					{ Name = "The Docks",     RingIndex = 7, Size = Vector3.new(60, 25, 40) }, -- Yorick
				},
				Props = {
					-- ============ HIDDEN FAIRY RING (secret area) ============
					{ Name = "FairyRing_1", Size = Vector3.new(8, 1, 8), Offset = Vector3.new(-120, 0.5, -80), Color = Color3.fromHex("#86EFAC"), Type = "Cylinder" },
					{ Name = "FairyRing_2", Size = Vector3.new(8, 1, 8), Offset = Vector3.new(-110, 0.5, -90), Color = Color3.fromHex("#86EFAC"), Type = "Cylinder" },
					{ Name = "FairyRing_3", Size = Vector3.new(8, 1, 8), Offset = Vector3.new(-130, 0.5, -90), Color = Color3.fromHex("#86EFAC"), Type = "Cylinder" },
					{ Name = "FairyRing_4", Size = Vector3.new(8, 1, 8), Offset = Vector3.new(-120, 0.5, -100), Color = Color3.fromHex("#86EFAC"), Type = "Cylinder" },
					-- Fairy glow in center
					{ Name = "FairyGlow", Size = Vector3.new(3, 6, 3), Offset = Vector3.new(-120, 4, -85), Color = Color3.fromHex("#F0ABFC"), Type = "Cylinder", Neon = true },
					
					-- ============ GRAND ENTRANCE ARCH (natural wood) ============
					{ Name = "Arch_L",       Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(-40, 20, -50), Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Arch_R",       Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(40, 20, -50),  Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Arch_Top",     Size = Vector3.new(90, 5, 5),   Offset = Vector3.new(0, 42, -50),   Color = Color3.fromHex("#065F46"), Type = "Block" },
					{ Name = "Arch_Vine1",   Size = Vector3.new(2, 25, 2),   Offset = Vector3.new(-38, 30, -50), Color = Color3.fromHex("#22C55E"), Type = "Cylinder" },
					{ Name = "Arch_Vine2",   Size = Vector3.new(2, 25, 2),   Offset = Vector3.new(38, 30, -50),  Color = Color3.fromHex("#22C55E"), Type = "Cylinder" },
					
					-- ============ LARGE TREES (oak-style with full canopies) ============
					{ Name = "Tree1_Trunk",  Size = Vector3.new(5, 25, 5),   Offset = Vector3.new(-60, 12.5, 30), Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Tree1_Leaf1",  Size = Vector3.new(22, 22, 22), Offset = Vector3.new(-60, 28, 30),   Color = Color3.fromHex("#15803D"), Type = "Ball" },
					{ Name = "Tree1_Leaf2",  Size = Vector3.new(18, 18, 18), Offset = Vector3.new(-55, 35, 35),  Color = Color3.fromHex("#16A34A"), Type = "Ball" },
					{ Name = "Tree2_Trunk",  Size = Vector3.new(4, 20, 4),   Offset = Vector3.new(55, 10, 25),   Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					{ Name = "Tree2_Leaf1",  Size = Vector3.new(18, 18, 18), Offset = Vector3.new(55, 23, 25),   Color = Color3.fromHex("#15803D"), Type = "Ball" },
					{ Name = "Tree2_Leaf2",  Size = Vector3.new(14, 14, 14), Offset = Vector3.new(60, 30, 30),   Color = Color3.fromHex("#22C55E"), Type = "Ball" },
					{ Name = "Tree3_Trunk",  Size = Vector3.new(5, 22, 5),   Offset = Vector3.new(-45, 11, 80),  Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Tree3_Leaf1",  Size = Vector3.new(20, 20, 20), Offset = Vector3.new(-45, 25, 80),   Color = Color3.fromHex("#14532D"), Type = "Ball" },
					
					-- ============ FLOWER GARDENS (clustered beds) ============
					{ Name = "Garden_Bed1",  Size = Vector3.new(15, 2, 8),   Offset = Vector3.new(0, 1, 20),     Color = Color3.fromHex("#5D4037"), Type = "Block" },
					{ Name = "Flower_B1a",   Size = Vector3.new(3, 3, 3),    Offset = Vector3.new(-5, 3.5, 20),  Color = Color3.fromHex("#F472B6"), Type = "Ball", Neon = true },
					{ Name = "Flower_B1b",   Size = Vector3.new(3, 3, 3),    Offset = Vector3.new(0, 3.5, 20),   Color = Color3.fromHex("#E879F9"), Type = "Ball", Neon = true },
					{ Name = "Flower_B1c",   Size = Vector3.new(3, 3, 3),    Offset = Vector3.new(5, 3.5, 20),   Color = Color3.fromHex("#F9A8D4"), Type = "Ball", Neon = true },
					{ Name = "Garden_Bed2",  Size = Vector3.new(12, 2, 6),   Offset = Vector3.new(-30, 1, 50),   Color = Color3.fromHex("#5D4037"), Type = "Block" },
					{ Name = "Flower_B2a",   Size = Vector3.new(2.5, 2.5, 2.5),Offset = Vector3.new(-33, 3, 50), Color = Color3.fromHex("#EC4899"), Type = "Ball", Neon = true },
					{ Name = "Flower_B2b",   Size = Vector3.new(2.5, 2.5, 2.5),Offset = Vector3.new(-27, 3, 50), Color = Color3.fromHex("#F472B6"), Type = "Ball", Neon = true },
					
					-- ============ MARKET STALLS (colorful awnings) ============
					{ Name = "Stall1_PostL", Size = Vector3.new(2, 15, 2),   Offset = Vector3.new(70, 7.5, 30),  Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Stall1_PostR", Size = Vector3.new(2, 15, 2),   Offset = Vector3.new(110, 7.5, 30), Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Stall1_Awn",   Size = Vector3.new(50, 2, 20),  Offset = Vector3.new(90, 16, 30),   Color = Color3.fromHex("#FDE68A"), Type = "Block" },
					{ Name = "Stall2_PostL", Size = Vector3.new(2, 12, 2),   Offset = Vector3.new(70, 6, 60),   Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Stall2_PostR", Size = Vector3.new(2, 12, 2),   Offset = Vector3.new(110, 6, 60),  Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Stall2_Awn",   Size = Vector3.new(50, 2, 18),  Offset = Vector3.new(90, 13, 60),   Color = Color3.fromHex("#86EFAC"), Type = "Block" },
					
					-- ============ STONE PATH LIGHTS ============
					{ Name = "Light1_Stone", Size = Vector3.new(4, 3, 4),    Offset = Vector3.new(-20, 1.5, 0),  Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "Light1_Glow",  Size = Vector3.new(3, 3, 3),    Offset = Vector3.new(-20, 4, 0),   Color = Color3.fromHex("#86EFAC"), Type = "Ball", Neon = true },
					{ Name = "Light2_Stone", Size = Vector3.new(4, 3, 4),    Offset = Vector3.new(20, 1.5, 0),   Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "Light2_Glow",  Size = Vector3.new(3, 3, 3),    Offset = Vector3.new(20, 4, 0),    Color = Color3.fromHex("#86EFAC"), Type = "Ball", Neon = true },
					
					-- ============ WATER WELL (central feature) ============
					{ Name = "Well_Base",    Size = Vector3.new(12, 4, 12),  Offset = Vector3.new(0, 2, 70),     Color = Color3.fromHex("#5D4037"), Type = "Cylinder" },
					{ Name = "Well_Water",   Size = Vector3.new(10, 1, 10),  Offset = Vector3.new(0, 2, 70),     Color = Color3.fromHex("#3B82F6"), Type = "Cylinder" },
					{ Name = "Well_Rim",     Size = Vector3.new(14, 3, 14),  Offset = Vector3.new(0, 3.5, 70),   Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Well_PostL",   Size = Vector3.new(2, 12, 2),   Offset = Vector3.new(-5, 10, 70),   Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Well_PostR",   Size = Vector3.new(2, 12, 2),   Offset = Vector3.new(5, 10, 70),    Color = Color3.fromHex("#78350F"), Type = "Cylinder" },
					{ Name = "Well_Top",     Size = Vector3.new(14, 2, 4),   Offset = Vector3.new(0, 17, 70),    Color = Color3.fromHex("#78350F"), Type = "Block" },
					
					-- ============ BENCHES (rustic wood) ============
					{ Name = "Bench1",       Size = Vector3.new(15, 4, 4),   Offset = Vector3.new(-50, 2, 0),    Color = Color3.fromHex("#92400E"), Type = "Block" },
					{ Name = "Bench2",       Size = Vector3.new(15, 4, 4),   Offset = Vector3.new(50, 2, 0),     Color = Color3.fromHex("#92400E"), Type = "Block" },
				},
			},
		},

		-- ============================================================
		-- WHISPER WINDS (East, formerly Pneuma) — Spirit, Light, Dream, Celestial
		-- Art: Crystal spires, glass, ethereal purple/white, floating
		-- ============================================================
		WhisperWinds = {
			Name      = "Whisper Winds",
			Direction = Vector3.new(1, 0, 0),
			Color     = Color3.fromHex("#5B21B6"),
			FloorMaterial  = Enum.Material.Sand,
			FloorColor     = Color3.fromHex("#C4B5FD"),
			Wilderness = {
				Biome     = Enum.Material.Sand,
				Roughness = 60,
				Scale     = 150,
			},
			AmbientCrystals = { Color = Color3.fromHex("#E9D5FF"), Count = 18, Height = 35 },
			-- FLOATING SPIRIT ORBS (ethereal theme)
			FloatingElements = {
				{ Name = "Spirit_1", Offset = Vector3.new(30, 40, -20), Color = Color3.fromHex("#F5F3FF") },
				{ Name = "Spirit_2", Offset = Vector3.new(-20, 55, 30), Color = Color3.fromHex("#C4B5FD") },
				{ Name = "Spirit_3", Offset = Vector3.new(50, 30, 40), Color = Color3.fromHex("#DDD6FE") },
				{ Name = "Spirit_4", Offset = Vector3.new(-40, 45, -10), Color = Color3.fromHex("#A78BFA") },
				{ Name = "Spirit_5", Offset = Vector3.new(10, 60, 20), Color = Color3.fromHex("#EDE9FE") },
			},
			Layout = {
				Buildings = {
					{ Name = "Cloud Spire",   RingIndex = 2,  Size = Vector3.new(40, 80, 40) }, -- Martha
					{ Name = "The Speakers",  RingIndex = 3,  Size = Vector3.new(60, 35, 60) }, -- Nyx
					{ Name = "The Studio",    RingIndex = 4, Size = Vector3.new(50, 40, 50) }, -- Pygmalion
				},
				Props = {
					-- ============ MEDITATION CIRCLES (quiet contemplation) ============
					{ Name = "MeditatePad_1", Size = Vector3.new(15, 1, 15), Offset = Vector3.new(20, 0.5, -50), Color = Color3.fromHex("#E9D5FF"), Type = "Cylinder" },
					{ Name = "MeditatePad_2", Size = Vector3.new(15, 1, 15), Offset = Vector3.new(50, 0.5, -70), Color = Color3.fromHex("#E9D5FF"), Type = "Cylinder" },
					{ Name = "MeditatePad_3", Size = Vector3.new(15, 1, 15), Offset = Vector3.new(-20, 0.5, 50), Color = Color3.fromHex("#E9D5FF"), Type = "Cylinder" },
					-- Glowing meditation crystals
					{ Name = "MeditateCrystal_1", Size = Vector3.new(2, 8, 2), Offset = Vector3.new(20, 5, -50), Color = Color3.fromHex("#A78BFA"), Type = "Cylinder" },
					{ Name = "MeditateCrystal_2", Size = Vector3.new(2, 8, 2), Offset = Vector3.new(50, 5, -70), Color = Color3.fromHex("#A78BFA"), Type = "Cylinder" },
					{ Name = "MeditateCrystal_3", Size = Vector3.new(2, 8, 2), Offset = Vector3.new(-20, 5, 50), Color = Color3.fromHex("#A78BFA"), Type = "Cylinder" },
					
					-- ============ GRAND CRYSTAL ENTRANCE ============
					{ Name = "CrystalGate_L",  Size = Vector3.new(5, 50, 5),   Offset = Vector3.new(-50, 25, -30), Color = Color3.fromHex("#A78BFA"), Type = "Block", Neon = true },
					{ Name = "CrystalGate_R",  Size = Vector3.new(5, 50, 5),   Offset = Vector3.new(-50, 25, 30),  Color = Color3.fromHex("#A78BFA"), Type = "Block", Neon = true },
					{ Name = "CrystalGate_Arch",Size = Vector3.new(4, 4, 70),  Offset = Vector3.new(-50, 52, 0),   Color = Color3.fromHex("#7C3AED"), Type = "Block", Neon = true },
					
					-- ============ FLOATING CRYSTAL CLUSTERS ============
					{ Name = "Shard_1",        Size = Vector3.new(8, 30, 8),   Offset = Vector3.new(40, 35, -30),  Color = Color3.fromHex("#A78BFA"), Type = "Block", Neon = true },
					{ Name = "Shard_2",        Size = Vector3.new(6, 40, 6),   Offset = Vector3.new(60, 50, 40),   Color = Color3.fromHex("#7C3AED"), Type = "Block", Neon = true },
					{ Name = "Shard_3",        Size = Vector3.new(7, 22, 7),   Offset = Vector3.new(30, 28, 60),   Color = Color3.fromHex("#DDD6FE"), Type = "Block", Neon = true },
					{ Name = "Shard_4",        Size = Vector3.new(5, 35, 5),   Offset = Vector3.new(100, 40, -50), Color = Color3.fromHex("#C4B5FD"), Type = "Block", Neon = true },
					{ Name = "Shard_5",        Size = Vector3.new(4, 25, 4),   Offset = Vector3.new(20, 20, 20),   Color = Color3.fromHex("#E9D5FF"), Type = "Block", Neon = true },
					
					-- ============ FLOATING PLATFORMS ============
					{ Name = "Platform_1",     Size = Vector3.new(22, 3, 22),  Offset = Vector3.new(40, 20, -30),  Color = Color3.fromHex("#EDE9FE"), Type = "Block" },
					{ Name = "Platform_2",     Size = Vector3.new(18, 3, 18),  Offset = Vector3.new(60, 35, 40),   Color = Color3.fromHex("#EDE9FE"), Type = "Block" },
					{ Name = "Platform_3",     Size = Vector3.new(15, 3, 15),  Offset = Vector3.new(30, 15, 60),   Color = Color3.fromHex("#EDE9FE"), Type = "Block" },
					
					-- ============ CELESTIAL RINGS (floating halos) ============
					{ Name = "Ring_1",         Size = Vector3.new(50, 2, 50),  Offset = Vector3.new(60, 65, 0),    Color = Color3.fromHex("#F5F3FF"), Type = "Cylinder" },
					{ Name = "Ring_2",         Size = Vector3.new(40, 2, 40),  Offset = Vector3.new(60, 85, 0),    Color = Color3.fromHex("#EDE9FE"), Type = "Cylinder" },
					{ Name = "Ring_3",         Size = Vector3.new(30, 2, 30),  Offset = Vector3.new(60, 100, 0),   Color = Color3.fromHex("#DDD6FE"), Type = "Cylinder" },
					
					-- ============ STAR ORBS (floating lights) ============
					{ Name = "StarOrb_1",      Size = Vector3.new(6, 6, 6),    Offset = Vector3.new(45, 45, -35),  Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
					{ Name = "StarOrb_2",      Size = Vector3.new(5, 5, 5),    Offset = Vector3.new(70, 60, 45),   Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
					{ Name = "StarOrb_3",      Size = Vector3.new(4, 4, 4),    Offset = Vector3.new(35, 35, 65),   Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
					{ Name = "StarOrb_4",      Size = Vector3.new(5, 5, 5),    Offset = Vector3.new(105, 50, -45), Color = Color3.fromHex("#FCD34D"), Type = "Ball", Neon = true },
					
					-- ============ MYSTIC LANTERNS ============
					{ Name = "Lantern1_Post",  Size = Vector3.new(2, 20, 2),   Offset = Vector3.new(-20, 10, 0),   Color = Color3.fromHex("#7C3AED"), Type = "Cylinder" },
					{ Name = "Lantern1_Glow",  Size = Vector3.new(5, 5, 5),    Offset = Vector3.new(-20, 22, 0),   Color = Color3.fromHex("#C4B5FD"), Type = "Ball", Neon = true },
					{ Name = "Lantern2_Post",  Size = Vector3.new(2, 20, 2),   Offset = Vector3.new(-20, 10, 40),  Color = Color3.fromHex("#7C3AED"), Type = "Cylinder" },
					{ Name = "Lantern2_Glow",  Size = Vector3.new(5, 5, 5),    Offset = Vector3.new(-20, 22, 40),  Color = Color3.fromHex("#C4B5FD"), Type = "Ball", Neon = true },
					
					-- ============ DREAM CLOUDS (fluffy decorative) ============
					{ Name = "Cloud_1",        Size = Vector3.new(25, 8, 15),  Offset = Vector3.new(50, 15, -60),  Color = Color3.fromHex("#F5F3FF"), Type = "Ball" },
					{ Name = "Cloud_2",        Size = Vector3.new(20, 6, 12),  Offset = Vector3.new(80, 18, 70),   Color = Color3.fromHex("#EDE9FE"), Type = "Ball" },
				},
			},
		},

		-- ============================================================
		-- ACTION ALLEY (West, formerly Soma) — Body, Shadow, Fire, Primal, Industrial
		-- Art: CorrodedMetal, lava accents, dark warm, dramatic
		-- ============================================================
		ActionAlley = {
			Name      = "Action Alley",
			Direction = Vector3.new(-1, 0, 0),
			Color     = Color3.fromHex("#991B1B"),
			FloorMaterial  = Enum.Material.CrackedLava,
			FloorColor     = Color3.fromHex("#7C2D12"),
			Wilderness = {
				Biome     = Enum.Material.Basalt,
				Roughness = 50,
				Scale     = 90,
			},
			AmbientCrystals = { Color = Color3.fromHex("#FB923C"), Count = 10, Height = 15 },
			-- FLOATING EMBERS (fire theme)
			FloatingElements = {
				{ Name = "Ember_1", Offset = Vector3.new(-40, 20, -30), Color = Color3.fromHex("#F97316") },
				{ Name = "Ember_2", Offset = Vector3.new(20, 25, 40), Color = Color3.fromHex("#FB923C") },
				{ Name = "Ember_3", Offset = Vector3.new(-60, 15, 10), Color = Color3.fromHex("#EF4444") },
				{ Name = "Ember_4", Offset = Vector3.new(30, 30, -20), Color = Color3.fromHex("#F59E0B") },
				{ Name = "Ember_5", Offset = Vector3.new(-20, 18, -50), Color = Color3.fromHex("#DC2626") },
			},
			Layout = {
				Buildings = {
					{ Name = "The Outpost", RingIndex = 8, Size = Vector3.new(50, 30, 50) }, -- Gribble
					{ Name = "The Arena",   RingIndex = 9, Size = Vector3.new(90, 40, 90) }, -- Kael
					{ Name = "The Sanctum", RingIndex = 10, Size = Vector3.new(60, 35, 60) }, -- Zafir
				},
				Props = {
					-- ============ TRAINING DUMMY ARENA (for practice battles) ============
					{ Name = "TrainingDummy_1", Size = Vector3.new(4, 8, 4),   Offset = Vector3.new(-50, 4, -80),  Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					{ Name = "TrainingDummy_2", Size = Vector3.new(4, 8, 4),   Offset = Vector3.new(-70, 4, -60),  Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					{ Name = "TrainingDummy_3", Size = Vector3.new(4, 8, 4),   Offset = Vector3.new(-50, 4, 60),   Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					{ Name = "TrainingDummy_4", Size = Vector3.new(4, 8, 4),   Offset = Vector3.new(-70, 4, 80),   Color = Color3.fromHex("#92400E"), Type = "Cylinder" },
					-- Training target circles
					{ Name = "Target_1", Size = Vector3.new(6, 1, 6), Offset = Vector3.new(-50, 0.5, -80), Color = Color3.fromHex("#EF4444"), Type = "Cylinder" },
					{ Name = "Target_2", Size = Vector3.new(6, 1, 6), Offset = Vector3.new(-70, 0.5, -60), Color = Color3.fromHex("#EF4444"), Type = "Cylinder" },
					{ Name = "Target_3", Size = Vector3.new(6, 1, 6), Offset = Vector3.new(-50, 0.5, 60), Color = Color3.fromHex("#EF4444"), Type = "Cylinder" },
					{ Name = "Target_4", Size = Vector3.new(6, 1, 6), Offset = Vector3.new(-70, 0.5, 80), Color = Color3.fromHex("#EF4444"), Type = "Cylinder" },
					
					-- ============ GRAND FORGE ENTRANCE ============
					{ Name = "ForgeGate_L",   Size = Vector3.new(8, 45, 8),   Offset = Vector3.new(50, 22.5, -35), Color = Color3.fromHex("#292524"), Type = "Cylinder" },
					{ Name = "ForgeGate_R",   Size = Vector3.new(8, 45, 8),   Offset = Vector3.new(50, 22.5, 35),  Color = Color3.fromHex("#292524"), Type = "Cylinder" },
					{ Name = "ForgeGate_Top", Size = Vector3.new(6, 6, 80),   Offset = Vector3.new(50, 47, 0),     Color = Color3.fromHex("#44403C"), Type = "Block" },
					{ Name = "ForgeGate_FireL",Size = Vector3.new(5, 5, 5),   Offset = Vector3.new(50, 52, -35),   Color = Color3.fromHex("#F97316"), Type = "Ball", Neon = true },
					{ Name = "ForgeGate_FireR",Size = Vector3.new(5, 5, 5),   Offset = Vector3.new(50, 52, 35),    Color = Color3.fromHex("#EF4444"), Type = "Ball", Neon = true },
					
					-- ============ GRAND TORCHES (towering fire pillars) ============
					{ Name = "GrandTorch_1",   Size = Vector3.new(6, 35, 6),   Offset = Vector3.new(-30, 17.5, -60),Color = Color3.fromHex("#292524"), Type = "Cylinder" },
					{ Name = "GrandTorch_1F",  Size = Vector3.new(10, 10, 10), Offset = Vector3.new(-30, 38, -60),  Color = Color3.fromHex("#F97316"), Type = "Ball", Neon = true },
					{ Name = "GrandTorch_2",   Size = Vector3.new(6, 35, 6),   Offset = Vector3.new(-30, 17.5, 60), Color = Color3.fromHex("#292524"), Type = "Cylinder" },
					{ Name = "GrandTorch_2F",  Size = Vector3.new(10, 10, 10), Offset = Vector3.new(-30, 38, 60),   Color = Color3.fromHex("#EF4444"), Type = "Ball", Neon = true },
					{ Name = "GrandTorch_3",   Size = Vector3.new(5, 30, 5),   Offset = Vector3.new(-80, 15, -30),  Color = Color3.fromHex("#44403C"), Type = "Cylinder" },
					{ Name = "GrandTorch_3F",  Size = Vector3.new(8, 8, 8),    Offset = Vector3.new(-80, 33, -30),  Color = Color3.fromHex("#F97316"), Type = "Ball", Neon = true },
					
					-- ============ LAVA POOLS (glowing danger zones) ============
					{ Name = "LavaPool_1",     Size = Vector3.new(50, 1, 30),  Offset = Vector3.new(-60, 0, 0),     Color = Color3.fromHex("#DC2626"), Type = "Block", Neon = true },
					{ Name = "LavaPool_2",     Size = Vector3.new(25, 1, 25),  Offset = Vector3.new(-100, 0, -50),  Color = Color3.fromHex("#EA580C"), Type = "Cylinder", Neon = true },
					
					-- ============ CRATE STACKS (dock cargo) ============
					{ Name = "Crate_Stack1a",  Size = Vector3.new(10, 10, 10), Offset = Vector3.new(-25, 5, -25),   Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "Crate_Stack1b",  Size = Vector3.new(10, 10, 10), Offset = Vector3.new(-25, 15, -25),  Color = Color3.fromHex("#92400E"), Type = "Block" },
					{ Name = "Crate_Stack2a",  Size = Vector3.new(8, 8, 8),    Offset = Vector3.new(-15, 4, -35),   Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "Crate_Stack2b",  Size = Vector3.new(8, 8, 8),    Offset = Vector3.new(-15, 12, -35),  Color = Color3.fromHex("#92400E"), Type = "Block" },
					{ Name = "Crate_Stack2c",  Size = Vector3.new(8, 8, 8),    Offset = Vector3.new(-15, 20, -35),  Color = Color3.fromHex("#78350F"), Type = "Block" },
					
					-- ============ ARENA BANNERS (dramatic flags) ============
					{ Name = "Banner_1",       Size = Vector3.new(3, 45, 12),  Offset = Vector3.new(-100, 22.5, -50),Color = Color3.fromHex("#B91C1C"), Type = "Block" },
					{ Name = "Banner_2",       Size = Vector3.new(3, 45, 12),  Offset = Vector3.new(-100, 22.5, 50), Color = Color3.fromHex("#DC2626"), Type = "Block" },
					{ Name = "Banner_3",       Size = Vector3.new(3, 40, 10),  Offset = Vector3.new(-140, 20, -30), Color = Color3.fromHex("#991B1B"), Type = "Block" },
					{ Name = "Banner_4",       Size = Vector3.new(3, 40, 10),  Offset = Vector3.new(-140, 20, 30),  Color = Color3.fromHex("#B91C1C"), Type = "Block" },
					
					-- ============ ANVIL & FORGE EQUIPMENT ============
					{ Name = "Anvil_Base",     Size = Vector3.new(8, 4, 8),    Offset = Vector3.new(-50, 2, -70),   Color = Color3.fromHex("#44403C"), Type = "Block" },
					{ Name = "Anvil_Top",      Size = Vector3.new(12, 3, 6),   Offset = Vector3.new(-50, 5.5, -70), Color = Color3.fromHex("#57534E"), Type = "Block" },
					
					-- ============ WEAPON RACKS ============
					{ Name = "WeaponRack_1",   Size = Vector3.new(15, 20, 3),  Offset = Vector3.new(-90, 10, -80),  Color = Color3.fromHex("#78350F"), Type = "Block" },
					{ Name = "WeaponRack_2",   Size = Vector3.new(15, 20, 3),  Offset = Vector3.new(-90, 10, 80),   Color = Color3.fromHex("#78350F"), Type = "Block" },
				},
			},
		},
	},
}

return TownBlueprint
