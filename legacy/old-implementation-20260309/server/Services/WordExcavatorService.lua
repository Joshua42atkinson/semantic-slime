--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local WordExcavatorService = Knit.CreateService {
	Name = "WordExcavatorService",
	Client = {
		PullResult = Knit.CreateSignal(),
		NewImaginarySlime = Knit.CreateSignal(),
	},
}

-- Types
export type ImaginarySlime = {
	InstanceId: string,
	Name: string,
	ImaginaryTrait: string,
	SignatureMove: string,
	Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic",
	Element: string,
	Role: string,
	Stats: {
		Logos: number,
		Pathos: number,
		Ethos: number,
		Speed: number,
	},
	FlavorText: string,
	Backstory: string,
}

-- Configuration
local RARITY_CHANCE = {
	Common = 40,
	Uncommon = 25,
	Rare = 18,
	Epic = 10,
	Legendary = 5,
	Mythic = 2,
}

local ELEMENTS = { "Fire", "Water", "Earth", "Air", "Shadow", "Light", "Normal" }
local ROLES = { "Tank", "Striker", "Support", "Caster", "Assassin", "Healer" }

-- AI Prompt Templates for Gacha
local TRAIT_TEMPLATES = {
	Common = {
		"Always humming quietly",
		"Slightly glows in moonlight",
		"Attracted to shiny objects",
		"Friendly to strangers",
		"Slightly bouncy",
	},
	Uncommon = {
		"Leaves rainbow trails",
		"Changes color with emotions",
		"Can phase through walls",
		"Speaks in riddles",
		"Dances when happy",
	},
	Rare = {
		"Can glimpse alternate futures",
		"Weaves dreams into reality",
		"Echoes ancient prophecies",
		"Bridges dimensions",
		"Commands elemental spirits",
	},
	Epic = {
		"Rewrites local reality",
		"Time flows differently around it",
		"Contains a tiny universe",
		"Speaks every language",
		"Drains life from opponents",
	},
	Legendary = {
		"Is an ancient deity reborn",
		"Carries the weight of ages",
		"Was once a cosmic entity",
		"Holds power over creation",
		"Dreams become prophecy",
	},
	Mythic = {
		"Exists beyond comprehension",
		"Is the embodiment of a concept",
		"Was present at the beginning",
		"Will persist until the end",
		"Represents pure meaning itself",
	},
}

local MOVE_TEMPLATES = {
	Tank = {
		"Stone Wall",
		"Guardian's Bulwark",
		"Impenetrable Defense",
		"Earth Shielder",
	},
	Striker = {
		"Lightning Strike",
		"Blade of Truth",
		"Fury Rush",
		"Meteor Fall",
	},
	Support = {
		"Healing Light",
		"Blessing of Hope",
		"Protective Aura",
		"Restorative Mist",
	},
	Caster = {
		"Arcane Burst",
		"Mystic Missile",
		"Sorcerer's Wrath",
		"Void Ray",
	},
	Assassin = {
		"Shadow Step",
		"Critical Strike",
		"Poison Dart",
		"Death Mark",
	},
	Healer = {
		"Life Fountain",
		"Gentle Touch",
		"Revival",
		"Nature's Grace",
	},
}

local FLAVOR_TEMPLATES = {
	"It bounces with inexplicable joy.",
	"It seems to know more than it lets on.",
	"Whispers can be heard when it sleeps.",
	"It leaves a trail of wonder wherever it goes.",
	"Its eyes hold ancient secrets.",
}

local BACKSTORY_TEMPLATES = {
	Hero = "Born from the dreams of a sleeping god, this slime seeks adventure.",
	Scholar = "Created from an ancient library's forgotten words.",
	Warrior = "Forged in the fires of linguistic battle.",
	Wanderer = "Appeared during a storm of fallen letters.",
	Guardian = "A protector of the word realm's borders.",
	Mystic = "Exists between the lines of reality.",
}

-- Private state
local playerGachaInventory: { [Player]: { [string]: ImaginarySlime } } = {}

-- Helper: Roll for rarity with luck multiplier
local function rollRarity(multiplier: number?): string
	local mult = multiplier or 1.0
	local rarityRank = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6 }
	local bestRarity = "Common"
	
	-- Determine number of "advantage" rolls based on multiplier
	-- 1.0x = 1 roll
	-- 2.5x = 2 rolls + guarantee Rare
	-- 5.0x = 5 rolls
	local rollCount = math.max(1, math.floor(mult))
	
	for i = 1, rollCount do
		local roll = math.random(1, 100)
		local cumulative = 0
		local currentRarity = "Common"
		
		for rarity, chance in pairs(RARITY_CHANCE) do
			cumulative += chance
			if roll <= cumulative then
				currentRarity = rarity
				break
			end
		end
		
		if rarityRank[currentRarity] > rarityRank[bestRarity] then
			bestRarity = currentRarity
		end
	end
	
	-- Guarantees from Technical Bible
	if mult >= 2.5 and rarityRank[bestRarity] < rarityRank.Rare then
		bestRarity = "Rare"
	end
	
	return bestRarity
end

-- Helper: Generate random stats based on rarity
local function generateStats(rarity: string): { [string]: number }
	local baseMultiplier = {
		Common = 1.0,
		Uncommon = 1.2,
		Rare = 1.5,
		Epic = 1.8,
		Legendary = 2.2,
		Mythic = 3.0,
	}
	
	local mult = baseMultiplier[rarity] or 1.0
	
	-- Random distribution with some base variance
	local base = 15 + math.random(0, 10)
	
	return {
		Logos = math.floor(base * mult * (0.8 + math.random() * 0.4)),
		Pathos = math.floor(base * mult * (0.8 + math.random() * 0.4)),
		Ethos = math.floor(base * mult * (0.8 + math.random() * 0.4)),
		Speed = math.floor(base * mult * (0.8 + math.random() * 0.4)),
	}
end

-- Helper: Generate a random imaginary slime
local function generateImaginarySlime(rarity: string): ImaginarySlime
	local element = ELEMENTS[math.random(1, #ELEMENTS)]
	local role = ROLES[math.random(1, #ROLES)]
	
	local traits = TRAIT_TEMPLATES[rarity] or TRAIT_TEMPLATES.Common
	local trait = traits[math.random(1, #traits)]
	
	local moves = MOVE_TEMPLATES[role] or MOVE_TEMPLATES.Tank
	local move = moves[math.random(1, #moves)]
	
	local flavor = FLAVOR_TEMPLATES[math.random(1, #FLAVOR_TEMPLATES)]
	local backstory = BACKSTORY_TEMPLATES[math.random(1, #BACKSTORY_TEMPLATES)]
	
	-- Generate creative name
	local prefixes = {
		Common = { "Tiny", "Fluffy", "Glimmer", "Spark", "Puff" },
		Uncommon = { "Mystic", "Shadow", "Storm", "Blaze", "Frost" },
		Rare = { "Ethereal", "Phantom", "Crimson", "Azure", "Golden" },
		Epic = { "Celestial", "Void", "Astral", "Dream", "Nightmare" },
		Legendary = { "Ancient", "Eternal", "Divine", "Primordial", "Infinite" },
		Mythic = { "Cosmic", "Omniscient", "Transcendent", "Absolute", "Ultimate" },
	}
	
	local bases = {
		"Slime", "Wisp", "Sprout", "Petal", "Shard", "Echo", "Spark", "Glow",
		"Whisper", "Breeze", "Flame", "Wave", "Stone", "Leaf", "Feather",
	}
	
	local prefixList = prefixes[rarity] or prefixes.Common
	local prefix = prefixList[math.random(1, #prefixList)]
	local base = bases[math.random(1, #bases)]
	local name = prefix .. " " .. base
	
	-- Add suffix for higher rarities
	if rarity == "Epic" then
		name = name .. " of " .. element
	elseif rarity == "Legendary" then
		name = "The " .. name .. " " .. move
	elseif rarity == "Mythic" then
		name = "☽ " .. name .. " ☾"
	end
	
	return {
		InstanceId = game:GetService("HttpService"):GenerateGUID(false),
		Name = name,
		ImaginaryTrait = trait,
		SignatureMove = move,
		Rarity = rarity,
		Element = element,
		Role = role,
		Stats = generateStats(rarity),
		FlavorText = flavor,
		Backstory = backstory,
	}
end

-- Try to enhance slime with AI (optional)
local function enhanceWithAI(slime: ImaginarySlime): ImaginarySlime
	-- In a full implementation, this would call AIService to generate
	-- more creative and personalized content. For now, we use templates.
	return slime
end

function WordExcavatorService:KnitStart()
	print("[WordExcavatorService] Started.")
end

-- Pull from the gacha (costs currency)
function WordExcavatorService:PullGacha(player: Player, pullType: "Single" | "Multi"): { ImaginarySlime }
	local results: { ImaginarySlime } = {}
	local count = pullType == "Multi" and 10 or 1
	
	-- Get resonance multiplier from GameLoopService
	local GameLoopService = Knit.GetService("GameLoopService")
	local multiplier = 1.0
	if GameLoopService then
		multiplier = GameLoopService:GetResonanceMultiplier(player)
		if multiplier > 1.0 then
			print("[WordExcavatorService] " .. player.Name .. " using Resonance Multiplier: " .. multiplier)
		end
	end

	for i = 1, count do
		local rarity = rollRarity(multiplier)
		local slime = generateImaginarySlime(rarity)
		slime = enhanceWithAI(slime)
		
		-- Add to inventory
		if not playerGachaInventory[player] then
			playerGachaInventory[player] = {}
		end
		playerGachaInventory[player][slime.InstanceId] = slime
		
		table.insert(results, slime)
		
		print("[WordExcavatorService] " .. player.Name .. " pulled: " .. slime.Name .. " (" .. slime.Rarity .. ")")
	end
	
	-- Notify client
	self.Client.PullResult:Fire(player, results)
	
	-- IfMythic or Legendary, also fire special notification
	for _, slime in ipairs(results) do
		if slime.Rarity == "Mythic" or slime.Rarity == "Legendary" then
			self.Client.NewImaginarySlime:Fire(player, slime)
		end
	end
	
	return results
end

-- Get player's gacha collection
function WordExcavatorService:GetPlayerGachaCollection(player: Player): { ImaginarySlime }
	if not playerGachaInventory[player] then
		return {}
	end
	
	local slimes = {}
	for _, slime in pairs(playerGachaInventory[player]) do
		table.insert(slimes, slime)
	end
	
	return slimes
end

-- Get a specific imaginary slime
function WordExcavatorService:GetImaginarySlime(player: Player, instanceId: string): ImaginarySlime?
	if not playerGachaInventory[player] then
		return nil
	end
	return playerGachaInventory[player][instanceId]
end

-- Load player gacha data
function WordExcavatorService:LoadPlayerGachaData(player: Player, data: { ImaginarySlime })
	if data then
		playerGachaInventory[player] = {}
		for _, slime in ipairs(data) do
			playerGachaInventory[player][slime.InstanceId] = slime
		end
	else
		playerGachaInventory[player] = {}
	end
end

-- Get save data
function WordExcavatorService:GetSaveData(player: Player): { ImaginarySlime }
	if not playerGachaInventory[player] then return {} end
	
	local slimes = {}
	for _, slime in pairs(playerGachaInventory[player]) do
		table.insert(slimes, slime)
	end
	return slimes
end

-- Get rate info for UI
function WordExcavatorService:GetRateInfo(): { [string]: number }
	return RARITY_CHANCE
end

-- Initialize
Players.PlayerAdded:Connect(function(player)
	playerGachaInventory[player] = {}
	print("[WordExcavatorService] Initialized for " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	playerGachaInventory[player] = nil
end)

return WordExcavatorService
