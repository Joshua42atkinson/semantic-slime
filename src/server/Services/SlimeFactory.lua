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
export type SlimeInstance = {
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

local RARITY_MULTIPLIERS = {
	Common = 1.0,
	Uncommon = 1.2,
	Rare = 1.5,
	Epic = 1.8,
	Legendary = 2.2,
	Mythic = 3.0,
}

local EVOLUTION_STAGE_NAMES = {
	"Normal",
	"Greater",
	"Ascended",
	"Divine",
	"Cosmic",
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

-- Calculate base stats from root and role
local function calculateStats(root: string, role: string, level: number): { [string]: number }
	local stats = {
		Logos = 10,
		Pathos = 10,
		Ethos = 10,
		Speed = 10,
	}
	
	local rootData = EtymologyDB.Roots and EtymologyDB.Roots[root]
	
	-- Apply root bonuses
	if rootData then
		if rootData.StatFocus == "Logos" then
			stats.Logos = stats.Logos + 10
		elseif rootData.StatFocus == "Pathos" then
			stats.Pathos = stats.Pathos + 10
		elseif rootData.StatFocus == "Ethos" then
			stats.Ethos = stats.Ethos + 10
		elseif rootData.StatFocus == "Speed" then
			stats.Speed = stats.Speed + 10
		end
	end
	
	-- Apply role bonuses
	if role == "Tank" then
		stats.Ethos = stats.Ethos + 15
	elseif role == "Striker" then
		stats.Logos = stats.Logos + 15
	elseif role == "Support" then
		stats.Pathos = stats.Pathos + 15
	elseif role == "Caster" then
		stats.Logos = stats.Logos + 10
		stats.Speed = stats.Speed + 5
	elseif role == "Assassin" then
		stats.Speed = stats.Speed + 15
	end
	
	-- Apply level multiplier
	local multiplier = 1 + (level - 1) * 0.1
	for stat, value in pairs(stats) do
		stats[stat] = math.floor(value * multiplier)
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

-- Generate rarity based on word properties
local function generateRarity(word: string, baseWord: string): string
	local roll = math.random(1, 100)
	
	-- Longer/more complex words have better chances
	local complexityBonus = math.min(#baseWord * 2, 20)
	roll = roll + complexityBonus
	
	-- Check for interesting word patterns
	if word:find("tion") or word:find("sion") then roll += 10 end
	if word:find("ness") or word:find("ment") then roll += 10 end
	
	if roll >= 98 then return "Mythic"
	elseif roll >= 93 then return "Legendary"
	elseif roll >= 83 then return "Epic"
	elseif roll >= 65 then return "Rare"
	elseif roll >= 40 then return "Uncommon"
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
function SlimeFactory:CreateSlime(player: Player, word: string): SlimeInstance?
	word = word:lower()
	
	-- Validate it's a real word (check in WordDatabase or basic validation)
	local isValidWord = WordDatabase[word] ~= nil or #word >= 3
	
	if not isValidWord then
		warn("[SlimeFactory] Invalid word: " .. word)
		return nil
	end
	
	-- Analyze the word
	local root, suffix, modifier = analyzeWord(word)
	
	-- Determine element and role
	local element = getElementFromRoot(root)
	local role = getRoleFromSuffix(suffix)
	
	-- Create the slime instance
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
		Stats = calculateStats(root, role, 1),
		ContextPoints = 0,
		ContextHistory = {},
		Rarity = generateRarity(word, root),
		ImaginaryTrait = nil,
		SignatureMove = nil,
		CreatedAt = os.time(),
	}
	
	-- Apply rarity multiplier
	slime.Stats = applyRarityMultiplier(slime.Stats, slime.Rarity)
	
	-- Add to player's collection
	if not playerSlimes[player] then
		playerSlimes[player] = {}
	end
	
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
