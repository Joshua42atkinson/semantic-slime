--!strict
-- EvolutionService.lua
-- Service for handling Phrase Slime Evolution System
-- Part XX of the Technical Bible - Five-Word Phrase Slime Evolution

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local EvolutionService = Knit.CreateService {
	Name = "EvolutionService",
	Client = {
		EvolutionStarted = Knit.CreateSignal(),
		EvolutionCompleted = Knit.CreateSignal(),
		SacrificePerformed = Knit.CreateSignal(),
	},
}

-- Types for phrase evolution
export type PhraseComponents = {
	BaseWord: string,
	Suffix: string?,
	FusedNoun: string?,
	FusedNounInstanceId: string?,
	Possessive: string?,
	PossessiveInstanceId: string?,
	Determiner: string?,
	Adjective: string?,
	EvolutionPath: { string },
	SacrificedSlimes: { string },
}

export type EvolutionType = "suffix" | "fuse_noun" | "possessive" | "adjective" | "determiner"

export type EvolutionResult = {
	Success: boolean,
	Slime: any?,
	Error: string?,
	NewTerm: string?,
}

-- Constants
local MAX_EVOLUTION_STAGE = 5
local STAT_RETENTION_RATE = 0.5 -- 50% of sacrificed slime stats transfer
local CP_RETENTION_RATE = 0.25 -- 25% of context points transfer

-- Available determiners for Stage 5 evolution
local DETERMINERS = { "a", "an", "the", "that", "this", "my", "your", "every", "no", "some" }

-- Suffix options available for Stage 2 evolution (by NPC archetype)
local SUFFIX_OPTIONS = {
	-- Pygmalion (Creator) - structural suffixes
	{ Suffix = "ful", Meaning = "full of", NPC = "Pygmalion", Role = "Support" },
	{ Suffix = "ize", Meaning = "to make", NPC = "Pygmalion", Role = "Striker" },
	{ Suffix = "ify", Meaning = "to make", NPC = "Pygmalion", Role = "Striker" },
	{ Suffix = "able", Meaning = "can be", NPC = "Pygmalion", Role = "Support" },
	-- Vlad (Lover) - descriptive adjectives
	{ Suffix = "ous", Meaning = "full of", NPC = "Vlad", Role = "Support" },
	{ Suffix = "ly", Meaning = "in a way", NPC = "Vlad", Role = "Support" },
	-- Martha (Caregiver) - emotional adjectives  
	{ Suffix = "ness", Meaning = "state of", NPC = "Martha", Role = "Tank" },
	{ Suffix = "ful", Meaning = "full of", NPC = "Martha", Role = "Support" },
	-- Kael (Hero) - action pairing
	{ Suffix = "er", Meaning = "one who", NPC = "Kael", Role = "Tank" },
	{ Suffix = "ing", Meaning = "doing", NPC = "Kael", Role = "Striker" },
	-- Nyx (Rebel) - negation suffixes
	{ Suffix = "less", Meaning = "without", NPC = "Nyx", Role = "Support" },
	-- Zafir (Magician) - transformation suffixes
	{ Suffix = "ify", Meaning = "to make", NPC = "Zafir", Role = "Striker" },
	{ Suffix = "ize", Meaning = "to make", NPC = "Zafir", Role = "Striker" },
	-- Chesty (Jester) - approximation
	{ Suffix = "ish", Meaning = "like", NPC = "Chesty", Role = "Civilian" },
}

-- NPC evolution role assignments (from Technical Bible)
local NPC_EVOLUTION_ROLES = {
	Barnaby = { Role = "word_identification", Stages = { 1 } },
	Yorick = { Role = "fuse_noun", Stages = { 2, 3 } },
	Kael = { Role = "action_pairing", Stages = { 2, 3 } },
	Martha = { Role = "emotional_adjectives", Stages = { 2, 4 } },
	Gribble = { Role = "possessives", Stages = { 3, 4 } },
	Nyx = { Role = "negation_suffixes", Stages = { 2 } },
	Vlad = { Role = "descriptive_adjectives", Stages = { 2, 4, 5 } },
	Pygmalion = { Role = "structural_suffixes", Stages = { 2 } },
	Chesty = { Role = "approximation_suffixes", Stages = { 2 } },
	Ozymandias = { Role = "determiners", Stages = { 4, 5 } },
	Zafir = { Role = "transformation_suffixes", Stages = { 2 } },
	Ignis = { Role = "formal_certification", Stages = { 5 } },
}

-- Build the full phrase term from phrase components
local function buildPhraseTerm(components: PhraseComponents): string
	local parts = {}
	
	-- Determiner
	if components.Determiner then
		table.insert(parts, components.Determiner)
	end
	
	-- Adjective
	if components.Adjective then
		table.insert(parts, components.Adjective)
	end
	
	-- Base word + suffix (or just base word)
	if components.Suffix then
		table.insert(parts, components.BaseWord .. components.Suffix)
	else
		table.insert(parts, components.BaseWord)
	end
	
	-- Fused noun
	if components.FusedNoun then
		table.insert(parts, components.FusedNoun)
	end
	
	-- Possessive
	if components.Possessive then
		table.insert(parts, components.Possessive .. "'s")
	end
	
	-- Join with spaces and capitalize
	local term = table.concat(parts, " ")
	if #term > 0 then
		-- Capitalize first letter
		term = term:sub(1, 1):upper() .. term:sub(2)
	end
	
	return term
end

-- Calculate phrase stats (with aggregation from sacrificed slimes)
local function calculatePhraseStats(baseStats: { [string]: number }, aggregatedStats: { [string]: number }?, evolutionStage: number): { [string]: number }
	local stats = {}
	
	-- Start with base stats
	for stat, value in pairs(baseStats) do
		stats[stat] = value
	end
	
	-- Add aggregated stats from sacrificed slimes
	if aggregatedStats then
		for stat, value in pairs(aggregatedStats) do
			stats[stat] = (stats[stat] or 0) + value
		end
	end
	
	-- Apply complexity bonus (each evolution stage adds 10%)
	local complexityBonus = 1 + (evolutionStage - 1) * 0.1
	for stat, value in pairs(stats) do
		stats[stat] = math.floor(value * complexityBonus)
	end
	
	return stats
end

-- [SLIME-003] Perform slime evolution - add suffix
function EvolutionService:EvolveWithSuffix(player: Player, instanceId: string, suffix: string): EvolutionResult
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	
	if not slime then
		return { Success = false, Error = "Slime not found" }
	end
	
	if slime.EvolutionStage >= MAX_EVOLUTION_STAGE then
		return { Success = false, Error = "Slime has already reached maximum evolution stage" }
	end
	
	-- Validate suffix is available
	local validSuffix = false
	for _, opt in ipairs(SUFFIX_OPTIONS) do
		if opt.Suffix == suffix then
			validSuffix = true
			break
		end
	end
	
	if not validSuffix then
		return { Success = false, Error = "Invalid suffix: " .. suffix }
	end
	
	-- Apply suffix
	slime.Suffix = slime.Suffix or suffix
	slime.WordId = slime.BaseWord .. suffix
	slime.Term = buildPhraseTerm({
		BaseWord = slime.BaseWord,
		Suffix = suffix,
		FusedNoun = slime.FusedNoun,
		Possessive = slime.Possessive,
		Determiner = slime.Determiner,
		Adjective = slime.Adjective,
		EvolutionPath = {},
		SacrificedSlimes = {},
	})
	
	-- Update evolution stage
	slime.EvolutionStage = math.min(slime.EvolutionStage + 1, MAX_EVOLUTION_STAGE)
	
	-- Record evolution path
	if not slime.EvolutionPath then
		slime.EvolutionPath = {}
	end
	table.insert(slime.EvolutionPath, "suffix:" .. suffix)
	
	-- Notify client
	self.Client.EvolutionCompleted:Fire(player, slime)
	print("[EvolutionService] " .. player.Name .. "'s slime evolved with suffix: " .. suffix)
	
	return { Success = true, Slime = slime, NewTerm = slime.Term }
end

-- [SLIME-004] Fuse a noun (sacrifice another slime)
function EvolutionService:FuseNoun(player: Player, instanceId: string, sacrificeId: string): EvolutionResult
	local SlimeFactory = Knit.GetService("SlimeFactory")
	
	local slime = SlimeFactory:GetSlime(player, instanceId)
	local sacrifice = SlimeFactory:GetSlime(player, sacrificeId)
	
	if not slime then
		return { Success = false, Error = "Slime not found" }
	end
	
	if not sacrifice then
		return { Success = false, Error = "Sacrifice slime not found" }
	end
	
	if slime.EvolutionStage >= MAX_EVOLUTION_STAGE then
		return { Success = false, Error = "Slime has already reached maximum evolution stage" }
	end
	
	-- Check if already has a fused noun
	if slime.FusedNoun then
		return { Success = false, Error = "Slime already has a fused noun" }
	end
	
	-- Cannot sacrifice Level 5 slimes (they represent mastery)
	if sacrifice.EvolutionStage >= 5 then
		return { Success = false, Error = "Cannot sacrifice a fully evolved slime" }
	end
	
	-- Get sacrifice stats for aggregation
	local sacrificeStats = sacrifice.Stats
	local aggregatedStats = slime.AggregatedStats or {}
	
	-- Transfer 50% of sacrifice stats
	for stat, value in pairs(sacrificeStats) do
		local transferValue = math.floor(value * STAT_RETENTION_RATE)
		aggregatedStats[stat] = (aggregatedStats[stat] or 0) + transferValue
	end
	slime.AggregatedStats = aggregatedStats
	
	-- Transfer 25% of context points
	local transferredCP = math.floor(sacrifice.ContextPoints * CP_RETENTION_RATE)
	slime.ContextPoints = (slime.ContextPoints or 0) + transferredCP
	
	-- Update phrase components
	slime.FusedNoun = sacrifice.Term
	slime.FusedNounInstanceId = sacrificeId
	
	-- Build new term
	slime.Term = buildPhraseTerm({
		BaseWord = slime.BaseWord or slime.Root,
		Suffix = slime.Suffix,
		FusedNoun = sacrifice.Term,
		Possessive = slime.Possessive,
		Determiner = slime.Determiner,
		Adjective = slime.Adjective,
		EvolutionPath = {},
		SacrificedSlimes = {},
	})
	
	-- Update evolution stage
	slime.EvolutionStage = math.min(slime.EvolutionStage + 1, MAX_EVOLUTION_STAGE)
	
	-- Record evolution path
	if not slime.EvolutionPath then
		slime.EvolutionPath = {}
	end
	table.insert(slime.EvolutionPath, "fuse_noun:" .. sacrifice.Term)
	
	-- Track sacrificed slimes
	if not slime.SacrificedSlimes then
		slime.SacrificedSlimes = {}
	end
	table.insert(slime.SacrificedSlimes, sacrificeId)
	
	-- Remove sacrificed slime from inventory
	local DataService = Knit.GetService("DataService")
	local inventory = SlimeFactory:GetPlayerSlimes(player)
	inventory[sacrificeId] = nil
	
	-- Recalculate stats with aggregation
	slime.Stats = calculatePhraseStats(slime.Stats, aggregatedStats, slime.EvolutionStage)
	
	-- Update sacrifice count
	slime.SacrificeCount = (slime.SacrificeCount or 0) + 1
	
	-- Notify client
	self.Client.SacrificePerformed:Fire(player, slime, sacrificeId)
	self.Client.EvolutionCompleted:Fire(player, slime)
	print("[EvolutionService] " .. player.Name .. "'s slime fused with noun: " .. sacrifice.Term)
	
	return { Success = true, Slime = slime, NewTerm = slime.Term }
end

-- [SLIME-004] Add possessive (second sacrifice)
function EvolutionService:AddPossessive(player: Player, instanceId: string, sacrificeId: string): EvolutionResult
	local SlimeFactory = Knit.GetService("SlimeFactory")
	
	local slime = SlimeFactory:GetSlime(player, instanceId)
	local sacrifice = SlimeFactory:GetSlime(player, sacrificeId)
	
	if not slime then
		return { Success = false, Error = "Slime not found" }
	end
	
	if not sacrifice then
		return { Success = false, Error = "Sacrifice slime not found" }
	end
	
	if slime.EvolutionStage < 3 then
		return { Success = false, Error = "Slime must reach Stage 3 before adding possessive" }
	end
	
	if slime.EvolutionStage >= MAX_EVOLUTION_STAGE then
		return { Success = false, Error = "Slime has already reached maximum evolution stage" }
	end
	
	if slime.Possessive then
		return { Success = false, Error = "Slime already has a possessive" }
	end
	
	-- Get sacrifice stats for aggregation
	local sacrificeStats = sacrifice.Stats
	local aggregatedStats = slime.AggregatedStats or {}
	
	-- Transfer 50% of sacrifice stats
	for stat, value in pairs(sacrificeStats) do
		local transferValue = math.floor(value * STAT_RETENTION_RATE)
		aggregatedStats[stat] = (aggregatedStats[stat] or 0) + transferValue
	end
	slime.AggregatedStats = aggregatedStats
	
	-- Transfer context points
	local transferredCP = math.floor(sacrifice.ContextPoints * CP_RETENTION_RATE)
	slime.ContextPoints = (slime.ContextPoints or 0) + transferredCP
	
	-- Update phrase components
	slime.Possessive = sacrifice.Term
	slime.PossessiveInstanceId = sacrificeId
	
	-- Build new term
	slime.Term = buildPhraseTerm({
		BaseWord = slime.BaseWord or slime.Root,
		Suffix = slime.Suffix,
		FusedNoun = slime.FusedNoun,
		Possessive = sacrifice.Term,
		Determiner = slime.Determiner,
		Adjective = slime.Adjective,
		EvolutionPath = {},
		SacrificedSlimes = {},
	})
	
	-- Update evolution stage
	slime.EvolutionStage = math.min(slime.EvolutionStage + 1, MAX_EVOLUTION_STAGE)
	
	-- Record evolution path
	if not slime.EvolutionPath then
		slime.EvolutionPath = {}
	end
	table.insert(slime.EvolutionPath, "possessive:" .. sacrifice.Term)
	
	-- Track sacrificed slimes
	if not slime.SacrificedSlimes then
		slime.SacrificedSlimes = {}
	end
	table.insert(slime.SacrificedSlimes, sacrificeId)
	
	-- Remove sacrificed slime
	local inventory = SlimeFactory:GetPlayerSlimes(player)
	inventory[sacrificeId] = nil
	
	-- Recalculate stats
	slime.Stats = calculatePhraseStats(slime.Stats, aggregatedStats, slime.EvolutionStage)
	slime.SacrificeCount = (slime.SacrificeCount or 0) + 1
	
	-- Notify client
	self.Client.SacrificePerformed:Fire(player, slime, sacrificeId)
	self.Client.EvolutionCompleted:Fire(player, slime)
	print("[EvolutionService] " .. player.Name .. "'s slime added possessive: " .. sacrifice.Term)
	
	return { Success = true, Slime = slime, NewTerm = slime.Term }
end

-- [SLIME-004] Add determiner and adjective (final evolution)
function EvolutionService:EvolveToComplete(player: Player, instanceId: string, determiner: string?, adjective: string?): EvolutionResult
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	
	if not slime then
		return { Success = false, Error = "Slime not found" }
	end
	
	if slime.EvolutionStage < 4 then
		return { Success = false, Error = "Slime must reach Stage 4 before final evolution" }
	end
	
	-- Validate determiner if provided
	if determiner then
		local validDet = false
		for _, det in ipairs(DETERMINERS) do
			if det == determiner then
				validDet = true
				break
			end
		end
		if not validDet then
			return { Success = false, Error = "Invalid determiner" }
		end
	end
	
	-- Update phrase components
	slime.Determiner = determiner
	slime.Adjective = adjective
	
	-- Build final term
	slime.Term = buildPhraseTerm({
		BaseWord = slime.BaseWord or slime.Root,
		Suffix = slime.Suffix,
		FusedNoun = slime.FusedNoun,
		Possessive = slime.Possessive,
		Determiner = determiner,
		Adjective = adjective,
		EvolutionPath = {},
		SacrificedSlimes = {},
	})
	
	-- Update evolution stage to max
	slime.EvolutionStage = MAX_EVOLUTION_STAGE
	
	-- Record evolution path
	if not slime.EvolutionPath then
		slime.EvolutionPath = {}
	end
	if determiner then
		table.insert(slime.EvolutionPath, "determiner:" .. determiner)
	end
	if adjective then
		table.insert(slime.EvolutionPath, "adjective:" .. adjective)
	end
	
	-- Apply complexity bonus for final form
	for stat, value in pairs(slime.Stats) do
		slime.Stats[stat] = math.floor(value * 1.2) -- Additional 20% bonus for complete phrase
	end
	
	-- Notify client
	self.Client.EvolutionCompleted:Fire(player, slime)
	print("[EvolutionService] " .. player.Name .. "'s slime reached complete phrase: " .. slime.Term)
	
	return { Success = true, Slime = slime, NewTerm = slime.Term }
end

-- Get available evolution options for a slime
function EvolutionService:GetEvolutionOptions(player: Player, instanceId: string): { any }
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	
	if not slime then
		return {}
	end
	
	local options = {}
	
	-- Stage 1 -> 2: Can add suffix
	if slime.EvolutionStage == 1 then
		options.suffixes = SUFFIX_OPTIONS
	end
	
	-- Stage 2 -> 3: Can fuse noun OR add another suffix
	if slime.EvolutionStage == 2 then
		options.suffixes = SUFFIX_OPTIONS
		options.canFuseNoun = true
	end
	
	-- Stage 3 -> 4: Can add possessive
	if slime.EvolutionStage == 3 then
		options.canAddPossessive = true
	end
	
	-- Stage 4 -> 5: Can add determiner and adjective
	if slime.EvolutionStage == 4 then
		options.determiners = DETERMINERS
		options.canComplete = true
	end
	
	-- Include current phrase info
	options.currentPhrase = {
		Term = slime.Term,
		EvolutionStage = slime.EvolutionStage,
		BaseWord = slime.BaseWord or slime.Root,
		Suffix = slime.Suffix,
		FusedNoun = slime.FusedNoun,
		Possessive = slime.Possessive,
		Determiner = slime.Determiner,
		Adjective = slime.Adjective,
	}
	
	return options
end

-- Get NPCs that can perform evolution for a slime
function EvolutionService:GetAvailableNPCs(player: Player, instanceId: string): { any }
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	
	if not slime then
		return {}
	end
	
	local available = {}
	local stage = slime.EvolutionStage
	
	for npcId, roleData in pairs(NPC_EVOLUTION_ROLES) do
		for _, availableStage in ipairs(roleData.Stages) do
			if availableStage == stage + 1 then
				table.insert(available, {
					NPCId = npcId,
					Role = roleData.Role,
					Stage = availableStage,
				})
				break
			end
		end
	end
	
	return available
end

-- Check if a slime can be traded (Level 5 slimes cannot be traded)
function EvolutionService:CanTradeSlime(player: Player, instanceId: string): (boolean, string?)
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	
	if not slime then
		return false, "Slime not found"
	end
	
	if slime.EvolutionStage >= 5 then
		return false, "Fully evolved slimes cannot be traded"
	end
	
	return true, nil
end

function EvolutionService:KnitStart()
	print("[EvolutionService] Started.")
end

return EvolutionService
