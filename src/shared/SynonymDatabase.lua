--!strict
-- SynonymDatabase.lua
-- Comprehensive synonym/antonym database for the Lure minigame
-- Each word has: synonyms (correct), antonyms (wrong), and distractors (random)

export type WordEntry = {
	Synonyms: {string},      -- Correct answers for Lure
	Antonyms: {string}?,     -- Wrong answers (red herrings)
	Distractors: {string}?,  -- Random unrelated words
	Element: string?,        -- Associated element for spawning
	Difficulty: number?,     -- 1-5, affects XP bonus
}

local SynonymDatabase: { [string]: WordEntry } = {
	-- === FIRE ELEMENT (Ignis) ===
	["inferno"] = {
		Synonyms = {"blaze", "conflagration", "hellfire", "holocaust"},
		Antonyms = {"frost", "ice", "freeze"},
		Distractors = {"water", "calm", "peace"},
		Element = "Fire",
		Difficulty = 3,
	},
	["ignite"] = {
		Synonyms = {"spark", "kindle", "light", "inflame"},
		Antonyms = {"extinguish", "douse", "quench"},
		Distractors = {"freeze", "calm", "soothe"},
		Element = "Fire",
		Difficulty = 2,
	},
	["burning"] = {
		Synonyms = {"blazing", "fiery", "flaming", "scorching"},
		Antonyms = {"freezing", "cold", "icy"},
		Distractors = {"wet", "damp", "cool"},
		Element = "Fire",
		Difficulty = 1,
	},
	["passion"] = {
		Synonyms = {"ardor", "fervor", "zeal", "intensity"},
		Antonyms = {"apathy", "indifference", "lethargy"},
		Distractors = {"calm", "peace", "quiet"},
		Element = "Fire",
		Difficulty = 2,
	},
	
	-- === WATER ELEMENT (Aqua) ===
	["aquatic"] = {
		Synonyms = {"marine", "watery", "amphibious", "subaqueous"},
		Antonyms = {"terrestrial", "land", "arid"},
		Distractors = {"fiery", "burning", "dry"},
		Element = "Water",
		Difficulty = 2,
	},
	["tranquility"] = {
		Synonyms = {"serenity", "peace", "calm", "stillness"},
		Antonyms = {"chaos", "turmoil", "agitation"},
		Distractors = {"fire", "storm", "rage"},
		Element = "Water",
		Difficulty = 3,
	},
	["flow"] = {
		Synonyms = {"stream", "course", "current", "drift"},
		Antonyms = {"stagnate", "stop", "halt"},
		Distractors = {"burn", "freeze", "crack"},
		Element = "Water",
		Difficulty = 1,
	},
	["depth"] = {
		Synonyms = {"abyss", "profundity", "deepness", "chasm"},
		Antonyms = {"surface", "shallows", "height"},
		Distractors = {"peak", "summit", "top"},
		Element = "Water",
		Difficulty = 2,
	},
	
	-- === EARTH ELEMENT (Terra) ===
	["terrain"] = {
		Synonyms = {"landscape", "ground", "topography", "land"},
		Antonyms = {"sky", "air", "void"},
		Distractors = {"water", "ocean", "space"},
		Element = "Earth",
		Difficulty = 2,
	},
	["solid"] = {
		Synonyms = {"firm", "stable", "sturdy", "hard"},
		Antonyms = {"liquid", "fluid", "weak"},
		Distractors = {"soft", "gentle", "light"},
		Element = "Earth",
		Difficulty = 1,
	},
	["ancient"] = {
		Synonyms = {"archaic", "primeval", "antique", "aged"},
		Antonyms = {"modern", "new", "recent"},
		Distractors = {"young", "fresh", "current"},
		Element = "Earth",
		Difficulty = 2,
	},
	["foundation"] = {
		Synonyms = {"basis", "groundwork", "bedrock", "base"},
		Antonyms = {"superstructure", "top", "peak"},
		Distractors = {"ceiling", "roof", "height"},
		Element = "Earth",
		Difficulty = 2,
	},
	
	-- === AIR ELEMENT (Aer) ===
	["aerial"] = {
		Synonyms = {"airy", "atmospheric", "ethereal", "lofty"},
		Antonyms = {"grounded", "terrestrial", "earthly"},
		Distractors = {"heavy", "solid", "dense"},
		Element = "Air",
		Difficulty = 2,
	},
	["breeze"] = {
		Synonyms = {"wind", "gust", "draft", "zephyr"},
		Antonyms = {"calm", "stillness", "stagnation"},
		Distractors = {"storm", "hurricane", "flood"},
		Element = "Air",
		Difficulty = 1,
	},
	["freedom"] = {
		Synonyms = {"liberty", "independence", "autonomy", "emancipation"},
		Antonyms = {"captivity", "bondage", "slavery"},
		Distractors = {"order", "control", "rule"},
		Element = "Air",
		Difficulty = 2,
	},
	["whisper"] = {
		Synonyms = {"murmur", "mutter", "sigh", "breath"},
		Antonyms = {"shout", "scream", "roar"},
		Distractors = {"silence", "noise", "cry"},
		Element = "Air",
		Difficulty = 1,
	},
	
	-- === SHADOW ELEMENT (Umbra) ===
	["shadow"] = {
		Synonyms = {"shade", "darkness", "gloom", "silhouette"},
		Antonyms = {"light", "brightness", "radiance"},
		Distractors = {"color", "white", "clear"},
		Element = "Shadow",
		Difficulty = 1,
	},
	["mystery"] = {
		Synonyms = {"enigma", "puzzle", "riddle", "secret"},
		Antonyms = {"clarity", "explanation", "solution"},
		Distractors = {"fact", "truth", "knowledge"},
		Element = "Shadow",
		Difficulty = 2,
	},
	["cryptic"] = {
		Synonyms = {"obscure", "enigmatic", "arcane", "mysterious"},
		Antonyms = {"clear", "obvious", "evident"},
		Distractors = {"simple", "plain", "direct"},
		Element = "Shadow",
		Difficulty = 3,
	},
	["void"] = {
		Synonyms = {"emptiness", "nothingness", "abyss", "vacuum"},
		Antonyms = {"fullness", "substance", "matter"},
		Distractors = {"chaos", "life", "energy"},
		Element = "Shadow",
		Difficulty = 3,
	},
	
	-- === LIGHT ELEMENT (Lux) ===
	["luminous"] = {
		Synonyms = {"radiant", "brilliant", "glowing", "shining"},
		Antonyms = {"dark", "dim", "gloomy"},
		Distractors = {"shadow", "black", "dull"},
		Element = "Light",
		Difficulty = 2,
	},
	["clarity"] = {
		Synonyms = {"lucidity", "transparency", "clearness", "purity"},
		Antonyms = {"confusion", "obscurity", "ambiguity"},
		Distractors = {"chaos", "mess", "disorder"},
		Element = "Light",
		Difficulty = 2,
	},
	["revelation"] = {
		Synonyms = {"disclosure", "unveiling", "discovery", "epiphany"},
		Antonyms = {"concealment", "hiding", "secret"},
		Distractors = {"mystery", "puzzle", "question"},
		Element = "Light",
		Difficulty = 3,
	},
	["hope"] = {
		Synonyms = {"optimism", "aspiration", "desire", "expectation"},
		Antonyms = {"despair", "hopelessness", "pessimism"},
		Distractors = {"fear", "dread", "doubt"},
		Element = "Light",
		Difficulty = 1,
	},
	
	-- === ABSTRACT CONCEPTS (Higher difficulty) ===
	["rebellion"] = {
		Synonyms = {"defiance", "insurrection", "revolt", "uprising"},
		Antonyms = {"obedience", "compliance", "submission"},
		Distractors = {"peace", "order", "safety"},
		Difficulty = 4,
	},
	["love"] = {
		Synonyms = {"passion", "devotion", "affection", "adoration"},
		Antonyms = {"hate", "loathing", "indifference"},
		Distractors = {"fear", "anger", "cold"},
		Difficulty = 2,
	},
	["time"] = {
		Synonyms = {"chronology", "duration", "era", "epoch"},
		Antonyms = {"eternity", "timelessness", "infinity"},
		Distractors = {"space", "distance", "place"},
		Difficulty = 3,
	},
	["wisdom"] = {
		Synonyms = {"sagacity", "insight", "knowledge", "prudence"},
		Antonyms = {"ignorance", "folly", "stupidity"},
		Distractors = {"youth", "innocence", "naivety"},
		Difficulty = 3,
	},
	["power"] = {
		Synonyms = {"might", "strength", "authority", "dominion"},
		Antonyms = {"weakness", "impotence", "powerlessness"},
		Distractors = {"peace", "calm", "rest"},
		Difficulty = 2,
	},
	["creation"] = {
		Synonyms = {"genesis", "formation", "origin", "inception"},
		Antonyms = {"destruction", "annihilation", "demise"},
		Distractors = {"end", "finish", "death"},
		Difficulty = 2,
	},
}

-- Helper function to get random choices for Lure minigame
function SynonymDatabase.GetLureChoices(word: string, count: number?): {string}
	local entry = SynonymDatabase[word:lower()]
	if not entry then
		-- Fallback for unknown words
		return {"Synonym", "Antonym", "Random", "Unknown"}
	end
	
	local numChoices = count or 4
	local choices = {}
	local correctCount = 0
	
	-- Always include at least one synonym (correct answer)
	local synonyms = entry.Synonyms or {}
	if #synonyms > 0 then
		local idx = math.random(1, #synonyms)
		table.insert(choices, synonyms[idx])
		correctCount = 1
	end
	
	-- Add antonyms as distractors
	local antonyms = entry.Antonyms or {}
	for _, ant in ipairs(antonyms) do
		if #choices >= numChoices then break end
		table.insert(choices, ant)
	end
	
	-- Add more distractors if needed
	local distractors = entry.Distractors or {}
	for _, dist in ipairs(distractors) do
		if #choices >= numChoices then break end
		table.insert(choices, dist)
	end
	
	-- Fill remaining slots with random words if needed
	while #choices < numChoices do
		table.insert(choices, "???")
	end
	
	-- Shuffle the choices
	for i = #choices, 2, -1 do
		local j = math.random(1, i)
		choices[i], choices[j] = choices[j], choices[i]
	end
	
	return choices, correctCount > 0
end

-- Check if a choice is correct (synonym)
function SynonymDatabase.IsSynonym(word: string, choice: string): boolean
	local entry = SynonymDatabase[word:lower()]
	if not entry then return false end
	
	choice = choice:lower()
	for _, syn in ipairs(entry.Synonyms) do
		if syn:lower() == choice then
			return true
		end
	end
	return false
end

-- Get word difficulty for XP calculation
function SynonymDatabase.GetDifficulty(word: string): number
	local entry = SynonymDatabase[word:lower()]
	return entry and entry.Difficulty or 1
end

-- Get element for spawning
function SynonymDatabase.GetElement(word: string): string?
	local entry = SynonymDatabase[word:lower()]
	return entry and entry.Element or nil
end

-- Get all words of a specific element
function SynonymDatabase.GetWordsByElement(element: string): {string}
	local words = {}
	for word, entry in pairs(SynonymDatabase) do
		if type(entry) == "table" and entry.Element == element then
			table.insert(words, word)
		end
	end
	return words
end

-- Get random word for spawning
function SynonymDatabase.GetRandomWord(element: string?): string
	if element then
		local words = SynonymDatabase.GetWordsByElement(element)
		if #words > 0 then
			return words[math.random(1, #words)]
		end
	end
	
	-- Get any word
	local words = {}
	for word, entry in pairs(SynonymDatabase) do
		if type(entry) == "table" then
			table.insert(words, word)
		end
	end
	
	if #words > 0 then
		return words[math.random(1, #words)]
	end
	
	return "mystery" -- fallback
end

return SynonymDatabase