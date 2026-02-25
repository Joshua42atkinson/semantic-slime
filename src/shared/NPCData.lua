--!strict
export type NPCData = {
	Id: string,
	Name: string,
	Archetype: string,
	District: string,
	Color: Color3,
	DialogueRoot: string,
	BuildingName: string,
}

local NPCData: { [string]: NPCData } = {
	-- HUB / LEVEL 1: Introduction (The "Why")
	["Apprentice_01"] = {
		Id = "Apprentice_01",
		Name = "The Apprentice",
		Archetype = "Guide",
		District = "Hub",
		Color = Color3.fromHex("#FCD34D"), -- Gold
		DialogueRoot = "Welcome, seeker! Psyche-Polis is quiet... too quiet. The words have lost their meaning. We need a hero to capture the erratic Etymons in the wilderness.",
		BuildingName = "The Portal",
	},

	-- LOGOS / LEVEL 2: Rule Sets (The "How")
	["Ruler_01"] = {
		Id = "Ruler_01",
		Name = "The Administrator",
		Archetype = "Ruler",
		District = "Logos",
		Color = Color3.fromHex("#1E3A8A"), -- Dark Blue
		DialogueRoot = "Order is paramount. I manage the town's logic. If you seek to understand the rules of this world, look to the code... or the library.",
		BuildingName = "City Hall",
	},
	["Creator_01"] = {
		Id = "Creator_01",
		Name = "The Architect",
		Archetype = "Creator",
		District = "Logos",
		Color = Color3.fromHex("#F59E0B"), -- Amber
		DialogueRoot = "I see you admire the geometry. Procedural generation is art, is it not? The wilderness out back is my masterpiece of perlin noise.",
		BuildingName = "The Forge",
	},

	-- EROS / LEVEL 3: Properties (The "Try")
	["Lover_01"] = {
		Id = "Lover_01",
		Name = "The Gardner",
		Archetype = "Lover",
		District = "Eros",
		Color = Color3.fromHex("#EC4899"), -- Pink
		DialogueRoot = "Do you feel the connection? The plants here whisper synonyms to me. It's quite romantic, don't you think?",
		BuildingName = "The Garden",
	},
	
	-- SOMA / LEVEL 4: Physics
	["Hero_01"] = {
		Id = "Hero_01",
		Name = "The Champion",
		Archetype = "Hero",
		District = "Soma",
		Color = Color3.fromHex("#DC2626"),
		DialogueRoot = "Strength! Power! Physics! I am a rigid body with Collisions enabled. Try to push me!",
		BuildingName = "The Arena",
	},
	
    -- PNEUMA / LEVEL 5: Rendering
	["Magician_01"] = {
		Id = "Magician_01",
		Name = "The Alchemist",
		Archetype = "Magician",
		District = "Pneuma",
		Color = Color3.fromHex("#7C3AED"),
		DialogueRoot = "Transparency, Reflectance... these are the alchemical properties of the rendering engine. Observe the light!",
		BuildingName = "The Observatory",
	},
}

return NPCData
