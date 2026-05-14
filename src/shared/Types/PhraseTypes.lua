--!strict
-- PhraseTypes.lua
-- Type definitions for the Phrase Slime Evolution System
-- Part XX of the Technical Bible

export type PhraseComponents = {
	BaseWord: string,              -- The original root word ("play")
	Suffix: string?,               -- Applied suffix, if any ("ful")
	FusedNoun: string?,           -- Fused noun word ("ball")
	FusedNounInstanceId: string?, -- InstanceId of the sacrificed slime
	Possessive: string?,           -- Possessive noun ("wiggle")
	PossessiveInstanceId: string?, -- InstanceId of the sacrificed slime
	Determiner: string?,           -- Determiner/article ("that")
	Adjective: string?,            -- Descriptive adjective ("red")
	EvolutionPath: { string },     -- Ordered list of evolution steps taken
	SacrificedSlimes: { string }, -- InstanceIds of all consumed slimes
}

export type EvolutionType = 
	"suffix"
	| "fuse_noun"
	| "possessive"
	| "adjective"
	| "determiner"

export type EvolutionResult = {
	Success: boolean,
	Slime: any?,                  -- The evolved slime instance
	Error: string?,
	NewTerm: string?,             -- The new display name
}

-- Grade level mappings for evolution stages
export type GradeLevel = "K-2" | "3-5" | "6-9" | "10-12" | "Graduate"

export type EvolutionStageInfo = {
	Stage: number,
	Name: string,                 -- "Baseline", "Elementary", etc.
	GradeLevel: GradeLevel,
	Description: string,
}

-- Evolution stage information mapping
local EVOLUTION_STAGES: { [number]: EvolutionStageInfo } = {
	{
		Stage = 1,
		Name = "Baseline",
		GradeLevel = "K-2",
		Description = "A simple root word — the foundation of all meaning",
	},
	{
		Stage = 2,
		Name = "Elementary",
		GradeLevel = "3-5",
		Description = "A word with a suffix — morphing into something more",
	},
	{
		Stage = 3,
		Name = "Intermediate", 
		GradeLevel = "6-9",
		Description = "A phrase — words combining to create meaning",
	},
	{
		Stage = 4,
		Name = "Advanced",
		GradeLevel = "10-12",
		Description = "A possessive phrase — showing ownership and relationship",
	},
	{
		Stage = 5,
		Name = "Graduate",
		GradeLevel = "Graduate",
		Description = "A complete noun phrase — the full architecture of English",
	},
}

-- NPC evolution role assignments (from Technical Bible Part XX)
export type NPCEvolutionRole = {
	Archetype: string,
	Role: string,                 -- "suffix", "fuse_noun", "possessive", "adjective", "determiner"
	AvailableStages: { number },  -- Which evolution stages this NPC can perform
}

local NPC_EVOLUTION_ROLES: { [string]: NPCEvolutionRole } = {
	Barnaby = {
		Archetype = "Innocent",
		Role = "word_identification",
		AvailableStages = { 1 },
	},
	Yorick = {
		Archetype = "Everyman", 
		Role = "fuse_noun",
		AvailableStages = { 2, 3 },
	},
	Kael = {
		Archetype = "Hero",
		Role = "action_pairing",
		AvailableStages = { 2, 3 },
	},
	Martha = {
		Archetype = "Caregiver",
		Role = "emotional_adjectives",
		AvailableStages = { 2, 4 },
	},
	Gribble = {
		Archetype = "Explorer",
		Role = "possessives",
		AvailableStages = { 3, 4 },
	},
	Nyx = {
		Archetype = "Rebel",
		Role = "negation_suffixes",
		AvailableStages = { 2 },
	},
	Vlad = {
		Archetype = "Lover",
		Role = "descriptive_adjectives",
		AvailableStages = { 2, 4, 5 },
	},
	Pygmalion = {
		Archetype = "Creator",
		Role = "structural_suffixes",
		AvailableStages = { 2 },
	},
	Chesty = {
		Archetype = "Jester",
		Role = "approximation_suffixes",
		AvailableStages = { 2 },
	},
	Ozymandias = {
		Archetype = "Sage",
		Role = "determiners",
		AvailableStages = { 4, 5 },
	},
	Zafir = {
		Archetype = "Magician",
		Role = "transformation_suffixes",
		AvailableStages = { 2 },
	},
	Ignis = {
		Archetype = "Ruler",
		Role = "formal_certification",
		AvailableStages = { 5 },
	},
}

return {
	PhraseComponents = {} :: PhraseComponents,
	EvolutionType = {} :: EvolutionType,
	EvolutionResult = {} :: EvolutionResult,
	GradeLevel = {} :: GradeLevel,
	EvolutionStageInfo = {} :: EvolutionStageInfo,
	EVOLUTION_STAGES = EVOLUTION_STAGES,
	NPC_EVOLUTION_ROLES = NPC_EVOLUTION_ROLES,
}
