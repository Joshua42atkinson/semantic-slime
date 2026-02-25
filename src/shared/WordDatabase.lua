--!strict
-- Psycholinguistic Database (Mock Data for Prototype)
-- Metrics:
-- C: Concreteness (1-5)
-- AoA: Age of Acquisition (Years)
-- V: Valence (1-9)
-- A: Arousal (1-9)
-- D: Dominance (1-9)

local WordDatabase = {
	["rock"] = { 
		C = 4.85, 
		AoA = 2, 
		V = 5.0, 
		A = 2.0, 
		D = 6.0 
	},
	["idea"] = { 
		C = 1.45, 
		AoA = 8, 
		V = 6.5, 
		A = 4.0, 
		D = 5.0 
	},
	["inferno"] = { 
		C = 4.5, 
		AoA = 10, 
		V = 2.1, 
		A = 7.8, 
		D = 8.0 
	},
	["tranquility"] = { 
		C = 1.8, 
		AoA = 12, 
		V = 8.5, 
		A = 1.2, 
		D = 6.0 
	},
	["shadow"] = { 
		C = 3.5, 
		AoA = 4, 
		V = 3.0, 
		A = 4.5, 
		D = 4.0 
	},
}

return WordDatabase
