--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local EtymologyDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EtymologyDB"))
local WordDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("WordDatabase"))

local SlimeFactory = Knit.CreateService {
	Name = "SlimeFactory",
	Client = {
		SlimeCreated = Knit.CreateSignal(),
		SlimeEvolved = Knit.CreateSignal(),
		CompanionChanged = Knit.CreateSignal(),
	},
}

-- Types
type SlimeInstance = {
	InstanceId: string,
	WordId: string,
	Term: string,
	Root: string,
	Suffix: string?,
	Prefix: string?,
	Element: string,
	Role: string,
	Level: number,
	XP: number,
	EvolutionStage: number,
	Stats: {
		Logos: number,
		Pathos: number,
		Ethos: number,
		Speed: number,
	},
	ContextPoints: number,
	ContextHistory: { [number]: { QuestId: string, Slot: string, Outcome: string } },
	Rarity: string,
	ImaginaryTrait: string?,
	SignatureMove: string?,
	CreatedAt: number,
	PhraseComponents: { [number]: { InstanceId: string, Word: string, Term: string, Suffix: string?, Role: string } },
	AggregatedStats: { [string]: number }?,
	SacrificeCount: number,
	EvolutionPath: { [number]: string },
}

export type Modifier = {
	Suffix: string,
	Name: string,
	StatBonuses: { [string]: number },
	Description: string,
}

-- Configuration
local INITIAL_XP_REQ = 100
local EVOLUTION_LEVEL = 10
local MAX_EVOLUTION_STAGE = 5

local MODIFIERS: { [string]: Modifier } = {
	["s"] = {
		Suffix = "s",
		Name = "Plural",
		StatBonuses = { Speed = 3, Logos = 2 },
		Description = "The base form made plural"
	},
	["ed"] = {
		Suffix = "ed",
		Name = "Past Tense",
		StatBonuses = { Ethos = 5, Pathos = 3 },
		Description = "Actions completed in the past"
	},
	["ing"] = {
		Suffix = "ing",
		Name = "Progressive",
		StatBonuses = { Logos = 4, Speed = 4 },
		Description = "Actions happening now"
	},
	["er"] = {
		Suffix = "er",
		Name = "Agent",
		StatBonuses = { Logos = 5, Ethos = 3 },
		Description = "One who performs an action"
	},
	["est"] = {
		Suffix = "est",
		Name = "Superlative",
		StatBonuses = { Logos = 6, Pathos = 2 },
		Description = "The most extreme form"
	},
	["ly"] = {
		Suffix = "ly",
		Name = "Adverbial",
		StatBonuses = { Speed = 5, Ethos = 2 },
		Description = "Describes how an action is performed"
	},
	["ness"] = {
		Suffix = "ness",
		Name = "State",
		StatBonuses = { Pathos = 6, Ethos = 2 },
		Description = "The quality or state of being"
	},
	["ful"] = {
		Suffix = "ful",
		Name = "Fullness",
		StatBonuses = { Pathos = 5, Ethos = 3 },
		Description = "Filled with the quality"
	},
	["less"] = {
		Suffix = "less",
		Name = "Without",
		StatBonuses = { Logos = 4, Speed = 4 },
		Description = "Without the quality"
	},
	["able"] = {
		Suffix = "able",
		Name = "Capability",
		StatBonuses = { Ethos = 4, Pathos = 4 },
		Description = "Capable of being"
	},
	["tion"] = {
		Suffix = "tion",
		Name = "Action/Result",
		StatBonuses = { Logos = 6, Ethos = 2 },
		Description = "The action or result of"
	},
	["ment"] = {
		Suffix = "ment",
		Name = "Result",
		StatBonuses = { Ethos = 5, Pathos = 3 },
		Description = "The result of an action"
	},
}

local RARITY_STAT_POOLS = {
	Common = 80,
	Uncommon = 120,
	Rare = 180,
	Epic = 260,
	Legendary = 380,
	Mythic = 550,
}

local RARITY_MULTIPLIERS = {
	Common = 1.0,
	Uncommon = 1.15,
	Rare = 1.35,
	Epic = 1.6,
	Legendary = 2.0,
	Mythic = 2.5,
}

local ROLE_DISTRIBUTIONS = {
	Tank = { Ethos = 0.4, Logos = 0.2, Pathos = 0.3, Speed = 0.1 },
	Striker = { Logos = 0.5, Ethos = 0.2, Pathos = 0.1, Speed = 0.2 },
	Support = { Pathos = 0.4, Logos = 0.2, Ethos = 0.3, Speed = 0.1 },
	Caster = { Logos = 0.4, Speed = 0.4, Ethos = 0.1, Pathos = 0.1 },
	Assassin = { Speed = 0.5, Logos = 0.3, Ethos = 0.1, Pathos = 0.1 },
	Healer = { Pathos = 0.5, Ethos = 0.3, Logos = 0.1, Speed = 0.1 },
	Civilian = { Logos = 0.25, Pathos = 0.25, Ethos = 0.25, Speed = 0.25 },
}

local EVOLUTION_STAGE_NAMES = {
	"Baseline",      -- K-2
	"Elementary",    -- 3-5
	"Intermediate",  -- 6-9
	"Advanced",      -- 10-12
	"Graduate",      -- Academic Adult
}

-- Evolution types for phrase building
export type EvolutionType = "suffix" | "fuse_noun" | "possessive" | "adjective" | "determiner"

local EVOLUTION_TYPES: { [number]: { type: EvolutionType, name: string, description: string, xpCost: number } } = {
	{ type = "suffix", name = "Suffix Addition", description = "Add a suffix to your word", xpCost = 50 },
	{ type = "fuse_noun", name = "Noun Fusion", description = "Combine with another noun", xpCost = 100 },
	{ type = "possessive", name = "Possessive", description = "Add 's to show ownership", xpCost = 150 },
	{ type = "adjective", name = "Adjective", description = "Add a descriptive word", xpCost = 200 },
	{ type = "determiner", name = "Determiner", description = "Add 'that', 'the', or 'a'", xpCost = 250 },
}

-- Grade level progression thresholds
local GRADE_LEVEL_THRESHOLDS = {
	{ stage = 1, grade = "K-2", minWords = 0 },
	{ stage = 2, grade = "3-5", minWords = 1 },
	{ stage = 3, grade = "6-9", minWords = 2 },
	{ stage = 4, grade = "10-12", minWords = 3 },
	{ stage = 5, grade = "Graduate", minWords = 4 },
}

-- Private state
local playerSlimes: { [Player]: { [string]: SlimeInstance } } = {}

-- Analyze word to find root and suffix
local function analyzeWord(word: string): (string, string, string?)
	local term = word:lower()
	
	-- Find longest matching suffix
	local foundSuffix = ""
	local foundModifier: Modifier? = nil
	
	for suffix, modifier in pairs(MODIFIERS) do
		if #suffix >= #foundSuffix and term ~= suffix then
			if term:sub(-#suffix) == suffix then
				foundSuffix = suffix
				foundModifier = modifier
			end
		end
	end
	
	-- Extract base word (without suffix)
	local baseWord = term
	if foundSuffix ~= "" then
		baseWord = term:sub(1, -#foundSuffix - 1)
	end
	
	-- Find root in etymology DB
	local foundRoot = "Terra" -- Default
	for root, data in pairs(EtymologyDB.Roots or {}) do
		if baseWord:find(root:lower()) then
			foundRoot = root
			break
		end
	end
	
	-- If no root found, use base word as root
	if foundRoot == "Terra" and #baseWord >= 3 then
		foundRoot = baseWord
	end
	
	return foundRoot, foundSuffix, foundModifier
end

-- Calculate base stats from root, role, and rarity (FAB-001/002)
local function calculateStats(rarity: string, role: string, level: number, root: string, suffix: string): { [string]: number }
	local pool = RARITY_STAT_POOLS[rarity] or RARITY_STAT_POOLS.Common
	local distribution = ROLE_DISTRIBUTIONS[role] or ROLE_DISTRIBUTIONS.Civilian
	
	-- Level scaling: +10% total stats per level
	local levelBonus = 1 + (level - 1) * 0.1
	local totalPool = pool * levelBonus
	
	local stats = {
		Logos = math.floor(totalPool * distribution.Logos),
		Pathos = math.floor(totalPool * distribution.Pathos),
		Ethos = math.floor(totalPool * distribution.Ethos),
		Speed = math.floor(totalPool * distribution.Speed),
	}
	
	-- [FAB-004] Apply Root/Suffix focus bonuses (+5% to focused stat)
	local rootData = EtymologyDB.Roots[root]
	if rootData and stats[rootData.StatFocus] then
		stats[rootData.StatFocus] = math.floor(stats[rootData.StatFocus] * 1.05)
	end
	
	local suffixData = EtymologyDB.Suffixes[suffix]
	if suffixData and stats[suffixData.StatBonus] then
		stats[suffixData.StatBonus] = math.floor(stats[suffixData.StatBonus] * 1.05)
	end
	
	return stats
end

-- Determine element from root
local function getElementFromRoot(root: string): string
	local rootData = EtymologyDB.Roots and EtymologyDB.Roots[root]
	if rootData and rootData.Element then
		return rootData.Element
	end
	
	-- Heuristic fallback
	local lower = root:lower()
	if lower:find("ignis") or lower:find("pyr") or lower:find("fire") then
		return "Fire"
	elseif lower:find("aqua") or lower:find("hydr") or lower:find("water") then
		return "Water"
	elseif lower:find("terra") or lower:find("geo") or lower:find("earth") then
		return "Earth"
	elseif lower:find("aer") or lower:find("pneu") or lower:find("air") then
		return "Air"
	elseif lower:find("umbra") or lower:find("scot") or lower:find("shadow") then
		return "Shadow"
	elseif lower:find("lux") or lower:find("phot") or lower:find("light") then
		return "Light"
	end
	
	return "Normal"
end

-- Determine role from suffix
local function getRoleFromSuffix(suffix: string): string
	if suffix == "" or not suffix then
		return "Civilian"
	end
	
	-- Verb suffixes tend toward Striker
	if suffix == "ing" or suffix == "ize" or suffix == "ate" or suffix == "fy" then
		return "Striker"
	-- Noun suffixes tend toward Tank
	elseif suffix == "tion" or suffix == "ment" or suffix == "ness" or suffix == "er" then
		return "Tank"
	-- Adjective suffixes tend toward Support
	elseif suffix == "ful" or suffix == "less" or suffix == "able" or suffix == "ly" then
		return "Support"
	-- Superlative
	elseif suffix == "est" then
		return "Caster"
	end
	
	return "Civilian"
end

-- Generate rarity based on word properties (FAB-003)
local function generateRarity(word: string, baseWord: string): string
	local score = 0
	
	-- Length bonus
	score += #word * 2
	
	-- Complexity bonus (unique letters)
	local unique = {}
	for i = 1, #word do
		unique[word:sub(i, i)] = true
	end
	local uniqueCount = 0
	for _ in pairs(unique) do uniqueCount += 1 end
	score += uniqueCount * 3
	
	-- Grade level bonus from WordDatabase
	local wordData = WordDatabase[word]
	if wordData and wordData.GradeLevel then
		local gradeBonus = {
			["K-2"] = 0,
			["3-5"] = 10,
			["6-9"] = 25,
			["10-12"] = 40,
			["Graduate"] = 60,
		}
		score += (gradeBonus[wordData.GradeLevel] or 0)
	end
	
	-- Scrabble-style complexity (Rare letters)
	local complexLetters = { q=10, z=10, x=8, j=8, k=5, v=4 }
	for i = 1, #word do
		local letter = word:sub(i, i):lower()
		score += (complexLetters[letter] or 0)
	end
	
	if score >= 120 then return "Mythic"
	elseif score >= 90 then return "Legendary"
	elseif score >= 70 then return "Epic"
	elseif score >= 50 then return "Rare"
	elseif score >= 25 then return "Uncommon"
	else return "Common" end
end

-- Apply rarity multiplier to stats
local function applyRarityMultiplier(stats: { [string]: number }, rarity: string): { [string]: number }
	local multiplier = RARITY_MULTIPLIERS[rarity] or 1.0
	
	local newStats = {}
	for stat, value in pairs(stats) do
		newStats[stat] = math.floor(value * multiplier)
	end
	
	return newStats
end

function SlimeFactory.Client:GetPlayerSlimes(player: Player)
	return self.Server:GetPlayerSlimes(player)
end

function SlimeFactory.Client:SetCompanion(player: Player, instanceId: string)
	if type(instanceId) ~= "string" then return false end
	return self.Server:SetCompanion(player, instanceId)
end

function SlimeFactory:KnitStart()
	print("[SlimeFactory] Started.")
end

-- Create a new slime from a word
function SlimeFactory:CreateSlime(player: Player, word: string): (SlimeInstance?, string?)
	-- Validate inputs
	if not player or not player.Parent then
		return nil, "Invalid player"
	end
	
	if type(word) ~= "string" or #word == 0 then
		return nil, "Invalid word"
	end
	
	word = word:lower()
	
	-- Validate it's a real word (check in WordDatabase or basic validation)
	local isValidWord
	local wordCheckSuccess, wordCheckResult = pcall(function()
		return WordDatabase[word] ~= nil or #word >= 3
	end)
	
	if not wordCheckSuccess then
		warn("[SlimeFactory] Error validating word:", wordCheckResult)
		return nil, "Error validating word"
	end
	
	isValidWord = wordCheckResult
	
	if not isValidWord then
		return nil, "That doesn't look like a real word!"
	end
	
	-- Add to player's collection
	if not playerSlimes[player] then
		playerSlimes[player] = {}
	end
	
	-- [PLAYER-001] Limit inventory to 5 active Slimes
	local currentCount = 0
	for _ in pairs(playerSlimes[player]) do currentCount += 1 end
	if currentCount >= 5 then
		return nil, "Your inventory is full! Max 5 slimes."
	end

	-- Analyze the word with error handling
	local root, suffix, modifier
	local analysisSuccess, analysisResult = pcall(function()
		return analyzeWord(word)
	end)
	
	if not analysisSuccess then
		warn("[SlimeFactory] Error analyzing word:", analysisResult)
		return nil, "Error analyzing word"
	end
	
	root, suffix, modifier = analysisResult
	
	-- Determine element and role with error handling
	local element, role
	local elementSuccess, elementResult = pcall(function()
		return getElementFromRoot(root)
	end)
	
	if not elementSuccess then
		warn("[SlimeFactory] Error determining element:", elementResult)
		element = "Neutral" -- Fallback
	else
		element = elementResult
	end
	
	local roleSuccess, roleResult = pcall(function()
		return getRoleFromSuffix(suffix)
	end)
	
	if not roleSuccess then
		warn("[SlimeFactory] Error determining role:", roleResult)
		role = "Striker" -- Fallback
	else
		role = roleResult
	end
	
	-- Create the slime instance (FAB-005) with error handling
	local rarity, baseStats
	local creationSuccess, creationResult = pcall(function()
		local slimeRarity = generateRarity(word, root)
		local slimeStats = calculateStats(slimeRarity, role, 1, root, suffix)
		return slimeRarity, slimeStats
	end)
	
	if not creationSuccess then
		warn("[SlimeFactory] Error creating slime stats:", creationResult)
		return nil, "Error creating slime"
	end
	
	rarity, baseStats = creationResult
	
	local slime: SlimeInstance = {
		InstanceId = HttpService:GenerateGUID(false),
		WordId = word,
		Term = word:sub(1, 1):upper() .. word:sub(2), -- Capitalize for display
		Root = root,
		Suffix = suffix ~= "" and suffix or nil,
		Prefix = nil,
		Element = element,
		Role = role,
		Level = 1,
		XP = 0,
		EvolutionStage = 1,
		Stats = baseStats,
		ContextPoints = 0,
		ContextHistory = {},
		Rarity = rarity,
		ImaginaryTrait = nil,
		SignatureMove = nil,
		CreatedAt = os.time(),
		PhraseComponents = {
			{ InstanceId = "", Word = word, Term = word:sub(1, 1):upper() .. word:sub(2), Suffix = suffix ~= "" and suffix or nil, Role = role }
		},
		AggregatedStats = nil,
		SacrificeCount = 0,
		EvolutionPath = { word },
	}
	
	playerSlimes[player][slime.InstanceId] = slime
	
	-- Notify client
	self.Client.SlimeCreated:Fire(player, slime)
	print("[SlimeFactory] Created slime: " .. slime.Term .. " (" .. slime.Rarity .. " " .. slime.Role .. ")")
	
	-- Achievements
	local DataService = Knit.GetService("DataService")
	if DataService then
		DataService:UnlockAchievement(player, "first_slime")
		DataService:IncrementAchievementProgress(player, "slime_collector_10", 1)
		DataService:IncrementAchievementProgress(player, "slime_collector_50", 1)
		
		-- Element masters
		local elementMap = {
			Fire = "fire_master", Water = "water_master", Earth = "earth_master",
			Air = "air_master", Shadow = "shadow_master", Light = "light_master"
		}
		if elementMap[slime.Element] then
			DataService:IncrementAchievementProgress(player, elementMap[slime.Element], 1)
		end
	end
	
	return slime
end

-- Apply a modifier to an existing slime
function SlimeFactory:ApplyModifier(player: Player, instanceId: string, modifierKey: string): SlimeInstance?
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		warn("[SlimeFactory] Slime not found: " .. instanceId)
		return nil
	end
	
	local slime = inventory[instanceId]
	local modifier = MODIFIERS[modifierKey]
	
	if not modifier then
		warn("[SlimeFactory] Unknown modifier: " .. modifierKey)
		return nil
	end
	
	-- Check if already has this modifier
	if slime.Suffix == modifierKey then
		warn("[SlimeFactory] Slime already has modifier: " .. modifierKey)
		return nil
	end
	
	-- Apply the modifier
	local newTerm = slime.WordId .. modifierKey
	local newRole = getRoleFromSuffix(modifierKey)
	
	slime.Term = newTerm:sub(1, 1):upper() .. newTerm:sub(2)
	slime.WordId = newTerm
	slime.Suffix = modifierKey
	slime.Role = newRole
	
	-- Apply stat bonuses from modifier
	for stat, bonus in pairs(modifier.StatBonuses) do
		slime.Stats[stat] = slime.Stats[stat] + bonus
	end
	
	-- Increase evolution stage if significant
	if modifierKey == "ed" or modifierKey == "ing" or modifierKey == "er" then
		slime.EvolutionStage = math.min(slime.EvolutionStage + 1, MAX_EVOLUTION_STAGE)
	end
	
	-- Notify client
	self.Client.SlimeEvolved:Fire(player, slime)
	print("[SlimeFactory] Evolved slime: " .. slime.Term .. " with " .. modifier.Name)
	
	return slime
end

-- Get available modifiers for a slime
function SlimeFactory:GetAvailableModifiers(player: Player, instanceId: string): { Modifier }
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		return {}
	end
	
	local slime = inventory[instanceId]
	local available: { Modifier } = {}
	
	-- Find all modifiers that can be applied to this word
	for key, modifier in pairs(MODIFIERS) do
		-- Can't apply same modifier twice
		if slime.Suffix ~= key then
			-- Check if applying this modifier creates a valid word
			local testWord = slime.WordId .. key
			if #testWord >= 3 then
				table.insert(available, modifier)
			end
		end
	end
	
	return available
end

-- Add XP to a slime
function SlimeFactory:AddXP(player: Player, instanceId: string, amount: number): SlimeInstance?
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		return nil
	end
	
	local slime = inventory[instanceId]
	slime.XP += amount
	
	-- Check for level up
	local xpReq = INITIAL_XP_REQ * slime.Level
	while slime.XP >= xpReq do
		slime.XP -= xpReq
		slime.Level += 1
		
		-- Recalculate stats with new level
		local newStats = calculateStats(slime.Root, slime.Role, slime.Level)
		newStats = applyRarityMultiplier(newStats, slime.Rarity)
		slime.Stats = newStats
		
		xpReq = INITIAL_XP_REQ * slime.Level
		print("[SlimeFactory] " .. slime.Term .. " leveled up to " .. slime.Level)
	end
	
	return slime
end

-- Generate a signature move based on slime's word and element
local function generateSignatureMove(term: string, element: string): string
	local movePrefixes = {
		Fire = { "Infernal", "Blazing", "Flaming", "Scorching" },
		Water = { "Tidal", "Hydro", "Aquatic", "Flood" },
		Earth = { "Terra", "Stone", "Rock", "Mountain" },
		Air = { "Gust", "Wind", "Storm", "Zephyr" },
		Shadow = { "Dark", "Shadow", "Void", "Eclipse" },
		Light = { "Solar", "Radiant", "Luminous", "Divine" },
		Normal = { "Power", "Mega", "Ultra", "Hyper" },
	}
	
	local moveSuffixes = { "Strike", "Blast", "Burst", "Attack", "Smash" }
	
	local prefixes = movePrefixes[element] or movePrefixes.Normal
	local prefix = prefixes[math.random(1, #prefixes)]
	local suffix = moveSuffixes[math.random(1, #moveSuffixes)]
	
	return prefix .. " " .. suffix
end

-- Add context points (meaning through usage)
function SlimeFactory:AddContextPoints(player: Player, instanceId: string, questId: string, slot: string, outcome: string): boolean
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		return false
	end
	
	local slime = inventory[instanceId]
	slime.ContextPoints += 1
	
	-- Record history
	table.insert(slime.ContextHistory, {
		QuestId = questId,
		Slot = slot,
		Outcome = outcome,
	})
	
	-- Context points provide small stat boosts every 5 points
	local contextBonus = math.floor(slime.ContextPoints / 5)
	if contextBonus > 0 then
		local bonusPerPoint = 1
		for stat, _ in pairs(slime.Stats) do
			slime.Stats[stat] = slime.Stats[stat] + (bonusPerPoint * contextBonus)
		end
	end
	
	-- Check for Signature Move unlock at 100 CP
	if slime.ContextPoints >= 100 and not slime.SignatureMove then
		slime.SignatureMove = generateSignatureMove(slime.Term, slime.Element)
		print("[SlimeFactory] " .. slime.Term .. " unlocked Signature Move: " .. slime.SignatureMove)
	end
	
	return true
end

-- Calculate aggregated stats from phrase components (SLIME-007)
local function calculateAggregatedStats(components: { [number]: { InstanceId: string, Word: string, Term: string, Suffix: string?, Role: string } }, sacrificeCount: number): { [string]: number }
	local aggregated = { Logos = 0, Pathos = 0, Ethos = 0, Speed = 0 }
	
	for _, component in ipairs(components) do
		-- This would normally look up the component's stats from playerSlimes
		-- For now, we use a baseline calculation
		aggregated.Logos = aggregated.Logos + 20
		aggregated.Pathos = aggregated.Pathos + 15
		aggregated.Ethos = aggregated.Ethos + 15
		aggregated.Speed = aggregated.Speed + 10
	end
	
	-- Apply sacrifice bonus: +50% stats per sacrifice
	local sacrificeMultiplier = 1 + (sacrificeCount * 0.5)
	for stat, value in pairs(aggregated) do
		aggregated[stat] = math.floor(value * sacrificeMultiplier)
	end
	
	return aggregated
end

-- Validate evolution path (SLIME-005)
local function validateEvolutionPath(currentStage: number, evolutionType: string): boolean
	-- Stage 1 (Baseline): Can only add suffix
	if currentStage == 1 then
		return evolutionType == "suffix"
	-- Stage 2 (Elementary): Can add noun fusion
	elseif currentStage == 2 then
		return evolutionType == "suffix" or evolutionType == "fuse_noun"
	-- Stage 3 (Intermediate): Can add possessive
	elseif currentStage == 3 then
		return evolutionType == "suffix" or evolutionType == "fuse_noun" or evolutionType == "possessive"
	-- Stage 4 (Advanced): Can add adjective
	elseif currentStage == 4 then
		return evolutionType == "suffix" or evolutionType == "fuse_noun" or evolutionType == "possessive" or evolutionType == "adjective"
	-- Stage 5 (Graduate): Can add determiner
	elseif currentStage == 5 then
		return evolutionType == "determiner"
	end
	
	return false
end

-- Get available evolution types for a slime (SLIME-003)
function SlimeFactory:GetAvailableEvolutions(player: Player, instanceId: string): { { type: string, name: string, description: string, xpCost: number } }
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		return {}
	end
	
	local slime = inventory[instanceId]
	local available = {}
	
	for _, evoType in ipairs(EVOLUTION_TYPES) do
		if validateEvolutionPath(slime.EvolutionStage, evoType.type) then
			table.insert(available, evoType)
		end
	end
	
	return available
end

-- Evolve a slime (SLIME-003, SLIME-004)
function SlimeFactory:EvolveSlime(player: Player, instanceId: string, evolutionType: string, additionalWord: string?): (SlimeInstance?, string?)
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		return nil, "Slime not found"
	end
	
	local slime = inventory[instanceId]
	
	-- Validate evolution type for current stage
	if not validateEvolutionPath(slime.EvolutionStage, evolutionType) then
		return nil, "Cannot perform this evolution at stage " .. slime.EvolutionStage
	end
	
	-- Check XP cost
	local evoConfig
	for _, evo in ipairs(EVOLUTION_TYPES) do
		if evo.type == evolutionType then
			evoConfig = evo
			break
		end
	end
	
	if not evoConfig then
		return nil, "Unknown evolution type"
	end
	
	if slime.XP < evoConfig.xpCost then
		return nil, "Not enough XP. Need " .. evoConfig.xpCost .. ", have " .. slime.XP
	end
	
	-- Deduct XP
	slime.XP = slime.XP - evoConfig.xpCost
	
	-- Apply evolution based on type
	if evolutionType == "suffix" then
		-- Add suffix to the base word
		if not additionalWord then
			return nil, "Suffix word required"
		end
		local newWord = slime.WordId .. additionalWord
		slime.WordId = newWord
		slime.Term = newWord:sub(1, 1):upper() .. newWord:sub(2)
		slime.Suffix = additionalWord
		table.insert(slime.EvolutionPath, newWord)
		
	elseif evolutionType == "fuse_noun" then
		-- Fuse with another noun from inventory
		if not additionalWord then
			return nil, "Second noun required for fusion"
		end
		local newWord = slime.WordId .. additionalWord
		slime.WordId = newWord
		slime.Term = newWord:sub(1, 1):upper() .. newWord:sub(2)
		table.insert(slime.EvolutionPath, newWord)
		
	elseif evolutionType == "possessive" then
		-- Add possessive 's
		local newWord = slime.WordId .. "'s"
		slime.WordId = newWord
		slime.Term = newWord:sub(1, 1):upper() .. newWord:sub(2)
		table.insert(slime.EvolutionPath, "'s")
		
	elseif evolutionType == "adjective" then
		-- Add adjective prefix
		if not additionalWord then
			return nil, "Adjective word required"
		end
		local newWord = additionalWord .. " " .. slime.WordId
		slime.WordId = newWord
		slime.Term = newWord:sub(1, 1):upper() .. newWord:sub(2)
		table.insert(slime.EvolutionPath, "adj:" .. additionalWord)
		
	elseif evolutionType == "determiner" then
		-- Add determiner (the, that, a)
		if not additionalWord then
			return nil, "Determiner required (the, that, a)"
		end
		local newWord = additionalWord .. " " .. slime.WordId
		slime.WordId = newWord
		slime.Term = newWord:sub(1, 1):upper() .. newWord:sub(2)
		table.insert(slime.EvolutionPath, "det:" .. additionalWord)
	end
	
	-- Increment evolution stage
	slime.EvolutionStage = math.min(slime.EvolutionStage + 1, MAX_EVOLUTION_STAGE)
	
	-- Recalculate stats
	local root, suffix, _ = analyzeWord(slime.WordId)
	local role = getRoleFromSuffix(suffix)
	slime.Role = role
	slime.Stats = calculateStats(slime.Rarity, role, slime.Level, root, suffix)
	
	-- Update phrase components
	table.insert(slime.PhraseComponents, {
		InstanceId = HttpService:GenerateGUID(false),
		Word = slime.WordId,
		Term = slime.Term,
		Suffix = slime.Suffix,
		Role = slime.Role,
	})
	
	-- Recalculate aggregated stats
	slime.AggregatedStats = calculateAggregatedStats(slime.PhraseComponents, slime.SacrificeCount)
	
	-- Notify client
	self.Client.SlimeEvolved:Fire(player, slime)
	print("[SlimeFactory] Evolved slime: " .. slime.Term .. " to stage " .. slime.EvolutionStage .. " (" .. evolutionType .. ")")
	
	-- Check for Stage 5 achievement
	if slime.EvolutionStage == 5 then
		local DataService = Knit.GetService("DataService")
		if DataService then
			DataService:UnlockAchievement(player, "graduate_slime")
		end
	end
	
	return slime
end

-- Sacrifice a slime to boost another (SLIME-004)
function SlimeFactory:SacrificeSlime(player: Player, targetInstanceId: string, sacrificeInstanceId: string): (SlimeInstance?, string?)
	local inventory = playerSlimes[player]
	if not inventory or not inventory[targetInstanceId] or not inventory[sacrificeInstanceId] then
		return nil, "One or both slimes not found"
	end
	
	local target = inventory[targetInstanceId]
	local sacrifice = inventory[sacrificeInstanceId]
	
	-- Cannot sacrifice self
	if targetInstanceId == sacrificeInstanceId then
		return nil, "Cannot sacrifice self"
	end
	
	-- Cannot sacrifice Level 5 slimes
	if sacrifice.EvolutionStage >= 5 then
		return nil, "Cannot sacrifice max level slimes"
	end
	
	-- Add sacrifice info to target
	target.SacrificeCount = target.SacrificeCount + 1
	
	-- Add sacrificed slime's stats to target (50% contribution)
	local sacrificeStats = sacrifice.Stats
	target.Stats.Logos = target.Stats.Logos + math.floor(sacrificeStats.Logos * 0.5)
	target.Stats.Pathos = target.Stats.Pathos + math.floor(sacrificeStats.Pathos * 0.5)
	target.Stats.Ethos = target.Stats.Ethos + math.floor(sacrificeStats.Ethos * 0.5)
	target.Stats.Speed = target.Stats.Speed + math.floor(sacrificeStats.Speed * 0.5)
	
	-- Recalculate aggregated stats
	target.AggregatedStats = calculateAggregatedStats(target.PhraseComponents, target.SacrificeCount)
	
	-- Remove sacrificed slime from inventory
	playerSlimes[player][sacrificeInstanceId] = nil
	
	print("[SlimeFactory] Sacrificed " .. sacrifice.Term .. " to boost " .. target.Term)
	
	-- Achievement for triple sacrifice
	if target.SacrificeCount >= 3 then
		local DataService = Knit.GetService("DataService")
		if DataService then
			DataService:UnlockAchievement(player, "triple_sacrifice")
		end
	end
	
	return target
end

-- Get evolution stage info
function SlimeFactory:GetEvolutionStageInfo(stage: number): { grade: string, name: string, minWords: number }?
	for _, info in ipairs(GRADE_LEVEL_THRESHOLDS) do
		if info.stage == stage then
			return {
				grade = info.grade,
				name = EVOLUTION_STAGE_NAMES[stage] or "Unknown",
				minWords = info.minWords,
			}
		end
	end
	return nil
end

-- Get phrase display name
function SlimeFactory:GetPhraseDisplayName(instanceId: string, player: Player): string?
	local inventory = playerSlimes[player]
	if not inventory or not inventory[instanceId] then
		return nil
	end
	
	local slime = inventory[instanceId]
	return slime.Term
end



-- Grant evolution point to player (for phase objectives)
function SlimeFactory:GrantEvolutionPoint(player: Player)
	local DataService = Knit.GetService("DataService")
	if DataService then
		DataService:GrantEvolutionPoints(player, 1)
		print("[SlimeFactory] Granted 1 Evolution Point to " .. player.Name)
	end
end

-- Get player's slime collection
function SlimeFactory:GetPlayerSlimes(player: Player): { SlimeInstance }
	return playerSlimes[player] or {}
end

-- Get a specific slime
function SlimeFactory:GetSlime(player: Player, instanceId: string): SlimeInstance?
	if not playerSlimes[player] then return nil end
	return playerSlimes[player][instanceId]
end

-- Get player's companion slime
function SlimeFactory:GetCompanion(player: Player): SlimeInstance?
	if not playerSlimes[player] then return nil end
	
	-- Check if we have a companion stored in DataService
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if profile and profile.CompanionSlimeId then
		return playerSlimes[player][profile.CompanionSlimeId]
	end
	return nil
end

-- Server-side: Set companion (called from client via remote)
function SlimeFactory:SetCompanion(player: Player, instanceId: string): boolean
	if not playerSlimes[player] or not playerSlimes[player][instanceId] then
		warn("[SlimeFactory] Cannot set companion: slime not found")
		return false
	end
	
	-- Update player profile
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if profile then
		profile.CompanionSlimeId = instanceId
		local slime = playerSlimes[player][instanceId]
		print("[SlimeFactory] Set companion slime for " .. player.Name .. ": " .. slime.Term)
		
		-- Notify client
		self.Client.CompanionChanged:Fire(player, slime)
		
		-- Notify PetService to spawn the companion
		local PetService = Knit.GetService("PetService")
		if PetService then
			PetService:SpawnCompanion(player, slime)
		end
		
		-- Achievement
		DataService:UnlockAchievement(player, "pet_companion")
		
		return true
	end
	return false
end

-- Server-side: Clear companion
function SlimeFactory:ClearCompanion(player: Player): boolean
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	if profile then
		profile.CompanionSlimeId = nil
		print("[SlimeFactory] Cleared companion for " .. player.Name)
		
		-- Notify client
		self.Client.CompanionChanged:Fire(player, nil)
		
		-- Notify PetService to remove companion
		local PetService = Knit.GetService("PetService")
		if PetService then
			PetService:RemoveCompanion(player)
		end
		
		return true
	end
	return false
end

-- Save/Load integration
function SlimeFactory:LoadPlayerSlimes(player: Player, data: { SlimeInstance })
	if data then
		playerSlimes[player] = {}
		for _, slime in ipairs(data) do
			playerSlimes[player][slime.InstanceId] = slime
		end
	else
		playerSlimes[player] = {}
	end
end

function SlimeFactory:GetSaveData(player: Player): { SlimeInstance }
	if not playerSlimes[player] then return {} end
	
	local slimes = {}
	for _, slime in pairs(playerSlimes[player]) do
		table.insert(slimes, slime)
	end
	return slimes
end

-- Initialize for new players
Players.PlayerAdded:Connect(function(player)
	playerSlimes[player] = {}
	print("[SlimeFactory] Initialized for " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	-- Data is saved via DataService, just clean up reference
	playerSlimes[player] = nil
end)

return SlimeFactory
