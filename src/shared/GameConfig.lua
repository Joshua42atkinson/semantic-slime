--!strict
-- GameConfig.lua
-- Central configuration for "Semantic Slime"
-- Change values here; never hardcode them in scripts.

local GameConfig = {}

GameConfig.GAME_NAME         = "Semantic Slime"
GameConfig.GAME_SUBTITLE     = "Where Language Comes Alive"
GameConfig.TOTAL_LEVELS      = 10               -- Player max level
GameConfig.NPC_NAME          = "The Archivist"  -- Prime guide NPC
GameConfig.INTERACT_DISTANCE = 15               -- studs

-- Core Gameplay Tunables
GameConfig.STARTER_INSIGHT   = 0                -- Starting currency
GameConfig.EVOLUTION_COST    = 5                -- Insight cost to evolve
GameConfig.EVOLUTION_LEVEL   = 10               -- Level required to evolve
GameConfig.MAX_EVOLUTION_STAGE = 4              -- Greater, Ascended, Divine, Cosmic

-- Lure Minigame Settings
GameConfig.LURE_TIMER        = 10               -- Seconds to select synonym
GameConfig.LURE_CHOICES      = 4                -- Number of synonym options
GameConfig.LURE_SUCCESS_BONUS = 2               -- Extra XP for fast/correct lure

-- Word Spawning
GameConfig.WORD_SPAWN_INTERVAL = 30             -- Seconds between wild spawns
GameConfig.MAX_WILD_WORDS    = 20               -- Max wild Etymons at once

-- Etymon Elements (matches EtymologyDB)
GameConfig.Elements = {
	Fire   = { Color = "EF4444", Emoji = "🔥" },
	Water  = { Color = "3B82F6", Emoji = "💧" },
	Earth  = { Color = "22C55E", Emoji = "🌍" },
	Air    = { Color = "CA8A04", Emoji = "💨" },
	Shadow = { Color = "6B21A8", Emoji = "🌑" },
	Light  = { Color = "F59E0B", Emoji = "✨" },
}

-- Etymon Roles (matches EtymologyDB suffixes)
GameConfig.Roles = {
	Tank     = { Icon = "🛡️", Desc = "High defense, protects allies" },
	Striker  = { Icon = "⚔️", Desc = "High attack, deals damage" },
	Caster   = { Icon = "🔮", Desc = "Magic attacks, area effect" },
	Assassin = { Icon = "🗡️", Desc = "Critical hits, fast attacks" },
	Support  = { Icon = "💚", Desc = "Heals and buffs allies" },
	Buffer   = { Icon = "📈", Desc = "Enhances team stats" },
	Healer   = { Icon = "💖", Desc = "Restores health" },
	Bruiser  = { Icon = "💪", Desc = "Balanced attack and defense" },
}

-- UI Colors
GameConfig.Colors = {
	Primary   = Color3.fromHex("4F46E5"), -- indigo
	Secondary = Color3.fromHex("10B981"), -- emerald
	Accent    = Color3.fromHex("F59E0B"), -- amber/gold
	Copper    = Color3.fromHex("B45309"), -- steampunk copper
	Iron      = Color3.fromHex("374151"), -- dark metal
	Dark      = Color3.fromHex("1E1B4B"), -- deep navy
	Charcoal  = Color3.fromHex("1F2937"), -- steampunk bg
	Light     = Color3.fromHex("EEF2FF"), -- lavender white
	Text      = Color3.fromHex("FFFFFF"),
	TextDim   = Color3.fromHex("A5B4FC"), -- muted lavender
	Base      = Color3.fromHex("2D2B55"), -- deep purple base
	Danger    = Color3.fromHex("EF4444"), -- red
	Steam     = Color3.fromHex("9CA3AF"), -- grey mist
}

-- Badge names per level
GameConfig.Badges = {
	[1] = "Rojo Conductor",
	[2] = "Agentic Builder",
	[3] = "Experience Architect",
}

return GameConfig
