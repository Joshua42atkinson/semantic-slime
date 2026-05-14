--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local QuestData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("QuestData"))

local MadLibService = Knit.CreateService {
	Name = "MadLibService",
	Client = {
		QuestGenerated = Knit.CreateSignal(),
		SlotFilled = Knit.CreateSignal(),
		QuestCompleted = Knit.CreateSignal(),
	},
}

-- Types
export type NPCArchetype = "Innocent" | "Sage" | "Explorer" | "Hero" | "Magician" | "Lover" | "Jester" | "Everyman" | "Caregiver" | "Rebel" | "Creator" | "Ruler"

export type QuestSlot = {
	SlotId: string,
	SlotType: "ADJECTIVE" | "VERB" | "NOUN" | "ADVERB",
	RequiredElement: string?,
	RequiredRole: string?,
	TargetMorpheme: string?, -- QUEST-002: Prefix/Suffix required for this slot
	PlayerEntry: string?, -- The word/slime filling this slot
	PlayerId: string?,
	InstanceId: string?,
}

export type MadLibQuest = {
	QuestId: string,
	Title: string,
	Archetype: NPCArchetype,
	DramaticSituation: string,
	CompleteNarrative: string,
	Slots: { [string]: QuestSlot },
	Status: "Waiting" | "InProgress" | "Completed",
	Rewards: {
		XP: number,
		Insight: number,
		EvolutionPoints: number,
	},
	CreatedAt: number,
}

-- Configuration uses QuestData.ArchetypeQuests and QuestData.NPCChains

-- [NPC-007] In-character validation responses based on archetype
local NPC_VALIDATION_RESPONSES = {
    Innocent = {
        correct = {
            "Oh wow! That's PERFECT!",
            "Yay! You did it!",
            "That's exactly right! So cool!",
        },
        incorrect = {
            "Hmm, that doesn't quite match... Try thinking about {morpheme}!",
            "Oh no! That word doesn't have the right part. Can you try another?",
            "I believe in you! Maybe try a word with {morpheme}?",
        },
    },
    Sage = {
        correct = {
            "A most judicious choice.",
            "Indeed, that word fits admirably.",
            "Your linguistic intuition serves you well.",
        },
        incorrect = {
            "Consider the morphological structure... Does it contain {morpheme}?",
            "A thoughtful attempt, but the word must align with the lesson.",
            "Perhaps you might try a word containing {morpheme}.",
        },
    },
    Hero = {
        correct = {
            "With strength and purpose! Well done!",
            "A warrior's word! Excellent!",
            "That's the spirit! Perfect choice!",
        },
        incorrect = {
            "The challenge demands a word with {morpheme}!",
            "You must be stronger! Try a word that has {morpheme}!",
            "Focus! The answer lies in {morpheme}!",
        },
    },
    Jester = {
        correct = {
            "Ha! That's hilarious and correct!",
            "Perfectly ridiculous! I love it!",
            "Wowie! That's the funniest right answer ever!",
        },
        incorrect = {
            "Boop! That's not quite the silly word we need! Try {morpheme}!",
            "NOPE! Try again with {morpheme}, silly!",
            "Haha no! Make it funnier with {morpheme}!",
        },
    },
    Rebel = {
        correct = {
            "Ha! Take THAT, rules! Correct!",
            "Now THAT'S rebellious! Perfect!",
            "Breaking words correctly. Love it!",
        },
        incorrect = {
            "Ugh, that's too normal! Try something with {morpheme}!",
            "BORING! Add some {morpheme} to that word!",
            "You're not rebelling hard enough! Need {morpheme}!",
        },
    },
    Lover = {
        correct = {
            "How beautiful! That's absolutely lovely!",
            "My heart sings! Perfect choice!",
            "That's so sweet! I love it!",
        },
        incorrect = {
            "That's not very romantic... Try a word with {morpheme}?",
            "Oh dear, my heart isn't moved. Try {morpheme}!",
            "Speak to my heart! Use {morpheme}!",
        },
    },
    Everyman = {
        correct = {
            "Just right! Good honest word!",
            "That fits! Nice and normal!",
            "Solid choice! Works perfectly!",
        },
        incorrect = {
            "That's a bit odd... Try something with {morpheme}!",
            "Just say a normal word with {morpheme}!",
            "Keep it simple! Try {morpheme}!",
        },
    },
    Caregiver = {
        correct = {
            "Oh honey, that's perfect! Here, have a hug!",
            "You poor sweet thing! That's exactly right!",
            "There, there! You did so well!",
        },
        incorrect = {
            "Oh no sweetie, that doesn't quite work... Try {morpheme}?",
            "Don't cry! Let me help... try {morpheme}!",
            "It's okay! Just add {morpheme} to your word!",
        },
    },
    Explorer = {
        correct = {
            "Wow! A new discovery! That's right!",
            "Adventure pays off! Excellent!",
            "I never thought of that! Great exploration!",
        },
        incorrect = {
            "This terrain is tricky... Look for {morpheme}!",
            "Not quite an adventure yet! Try {morpheme}!",
            "Chart a new course! Use {morpheme}!",
        },
    },
    Creator = {
        correct = {
            "Magnificent! A work of art!",
            "You've crafted perfection!",
            "A masterpiece! Brilliant!",
        },
        incorrect = {
            "The composition isn't right... Try {morpheme}!",
            "We must reshape! Add {morpheme}!",
            "The structure needs work! Use {morpheme}!",
        },
    },
    Ruler = {
        correct = {
            "DECREE: That word is CORRECT!",
            "Your word is law. Well done!",
            "By royal command - perfect!",
        },
        incorrect = {
            "YOUR DECREE IS INVALID! Try {morpheme}!",
            "The kingdom demands {morpheme}! Obey!",
            "Guards! This word is unlawful! Try {morpheme}!",
        },
    },
    Magician = {
        correct = {
            "POOF! Magically correct!",
            "The magic words align! Wonderful!",
            "Abracadabra! Perfect spell!",
        },
        incorrect = {
            "The spell fizzled... Try {morpheme}!",
            "My magic needs {morpheme} to work!",
            "The words have no power! Add {morpheme}!",
        },
    },
}

function MadLibService:GetValidationResponse(npcId: string, isCorrect: boolean, morpheme: string?): string
    local LoreDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Master_Lore"):WaitForChild("LoreDB"))
    local npcData = LoreDB.NPCs[npcId]
    local archetype = "Everyman"
    
    if npcData and npcData.Archetype then
        archetype = string.gsub(npcData.Archetype, "The ", "")
    end
    
    local responses = NPC_VALIDATION_RESPONSES[archetype] or NPC_VALIDATION_RESPONSES.Everyman
    local responseList = isCorrect and responses.correct or responses.incorrect
    local response = responseList[math.random(1, #responseList)]
    
    if morpheme then
        response = string.gsub(response, "{morpheme}", morpheme)
    end
    
    return response
end

-- [NPC-008] Quest completion responses - what NPCs say when you finish their Mad Lib
local NPC_COMPLETION_RESPONSES = {
    Innocent = {
        "WOWEE! You're AMAZING! That was SO COOL!",
        "Yay yay yay! You did it! You're the BEST!",
        "That was SO BEAUTIFUL! I loved every word!",
        "We did it TOGETHER! Best friend forever!",
    },
    Sage = {
        "A most satisfactory outcome. Your linguistic prowess grows.",
        "Indeed... the words aligned harmoniously. Well done.",
        "Your understanding deepens. This is but the beginning.",
        "The ancient texts speak of this moment. You honor them.",
    },
    Hero = {
        "A victory for the ages! The words have been conquered!",
        "With courage and wisdom, you have prevailed!",
        "The quest is complete! You are a true hero!",
        "This day shall be remembered! Well fought!",
    },
    Jester = {
        "HAHAHA! That was HILARIOUS! Perfect!",
        "OH WOW! That's the funniest thing EVER!",
        "Boop boop boop! You're a comedy GENIUS!",
        "Encore! ENCORE! That was AMAZING!",
    },
    Rebel = {
        "HA! Take THAT, conventional language!",
        "Rules? What rules? YOU make the rules!",
        "That's how you do it! Break ALL the words!",
        "Perfectly rebellious! I love your chaos!",
    },
    Lover = {
        "Oh my... that was BEAUTIFUL! My heart flutters!",
        "You speak such sweet words... I'm swooning!",
        "Loveeee! That's love in word form!",
        "My heart belongs to you and your words!",
    },
    Everyman = {
        "Just right! Good honest work there!",
        "That's what I'm talking about! Solid!",
        "Nothing fancy, just perfect! Well done!",
        "You get it! That's what I'm talking about!",
    },
    Caregiver = {
        "Oh honey, you did SO WELL! I'm proud of you!",
        "There, there... you did wonderfully!",
        "You poor sweet thing, look at you go!",
        "Let me give you a hug! You deserve it!",
    },
    Explorer = {
        "What an adventure! New words discovered!",
        "Into the unknown! You blaze new trails!",
        "Discovery after discovery! Fantastic!",
        "A new frontier conquered! Amazing!",
    },
    Creator = {
        "A MASTERPIECE! You've crafted perfection!",
        "The words align beautifully! A work of art!",
        "Magnificent! Simply magnificent!",
        "You've created something wonderful!",
    },
    Ruler = {
        "By royal decree: THAT IS CORRECT!",
        "Your word is law! Well done, subject!",
        "The crown recognizes your achievement!",
        "DECREE: You have performed admirably!",
    },
    Magician = {
        "ABRACADABRA! The magic words work!",
        "The spell is complete! Magnificent!",
        "POOF! Just like magic! Wonderful!",
        "Your wand work is impeccable!",
    },
}

function MadLibService:GetCompletionResponse(npcId: string): string
    local LoreDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Master_Lore"):WaitForChild("LoreDB"))
    local npcData = LoreDB.NPCs[npcId]
    local archetype = "Everyman"
    
    if npcData and npcData.Archetype then
        archetype = string.gsub(npcData.Archetype, "The ", "")
    end
    
    local responses = NPC_COMPLETION_RESPONSES[archetype] or NPC_COMPLETION_RESPONSES.Everyman
    return responses[math.random(1, #responses)]
end

local SLOT_TYPES = { "ADJECTIVE", "VERB", "NOUN", "ADVERB" }

local ELEMENT_THEMES = {
	Fire = { "blazing", "burning", "flaming", "scorching" },
	Water = { "flowing", "dripping", "waves", "ocean" },
	Earth = { "grounded", "ancient", "mountain", "stone" },
	Air = { "breezy", "swift", "windy", "sky" },
	Shadow = { "dark", "mysterious", "hidden", "secret" },
	Light = { "bright", "radiant", "shining", "golden" },
}

-- Private state
local activeQuests: { [string]: MadLibQuest } = {}
local playerActiveQuests: { [Player]: string } = {} -- Player -> QuestId

-- [QUEST-005] Morpheme Validation with Whitelist (Part VI of Technical Bible)
local function validateMorpheme(word: string, pattern: string): (boolean, string?)
	local lowerWord = word:lower()
	local lowerPattern = pattern:lower()
	
	-- Load the whitelist from EtymologyDB
	local EtymologyDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EtymologyDB"))
	local whitelist = EtymologyDB.MorphemeWhitelist
	
	-- First check whitelist if available (more accurate validation)
	if whitelist and whitelist[lowerPattern] then
		local validWords = whitelist[lowerPattern]
		local isWhitelisted = false
		for _, validWord in ipairs(validWords) do
			if validWord == lowerWord then
				isWhitelisted = true
				break
			end
		end
		
		if isWhitelisted then
			return true
		end
	end
	
	-- Strip markers for validation
	local cleanPattern = lowerPattern:gsub("-", "")
	
	if lowerPattern:sub(1, 1) == "-" then
		-- Suffix check
		if lowerWord:sub(-#cleanPattern) == cleanPattern then
			-- Additional check: warn about coincidental morphemes
			if lowerPattern == "un-" and lowerWord == "uncle" then
				return false, "That's tricky! 'Uncle' has 'un' but doesn't use 'un-' as a prefix. Try a word where 'un-' means 'not'!"
			end
			return true
		else
			return false, "Word must end with " .. cleanPattern
		end
	elseif lowerPattern:sub(-1, -1) == "-" then
		-- Prefix check
		if lowerWord:sub(1, #cleanPattern) == cleanPattern then
			-- Additional check: warn about coincidental morphemes
			if lowerPattern == "un-" and lowerWord == "uncle" then
				return false, "That's tricky! 'Uncle' has 'un' but doesn't use 'un-' as a prefix. Try a word where 'un-' means 'not'!"
			end
			if lowerPattern == "de-" and lowerWord == "debug" then
				return true, nil -- "debug" is a valid word with "de-"
			end
			return true
		else
			return false, "Word must start with " .. cleanPattern
		end
	else
		-- Root/Infix check
		if lowerWord:find(cleanPattern) then
			return true
		else
			return false, "Word must contain " .. cleanPattern
		end
	end
end

-- [QUEST-008] Tiered Hint System (Part VI of Technical Bible)
-- Tier 1: Maximum scaffolding (3 examples, definition tooltip, hint after 2 fails, wheel after 5)
-- Tier 2: Moderate scaffolding (1 example, morpheme-only tooltip, hint after 3 fails, wheel after 7)
-- Tier 3: Minimal scaffolding (no examples, no tooltip, hint after 5 fails, wheel after 10)

local HintConfig = {
	[1] = { ExamplesShown = 3, TooltipLevel = "definition", HintAfterFails = 2, ShowWheelAfterFails = 5 },
	[2] = { ExamplesShown = 1, TooltipLevel = "morpheme_only", HintAfterFails = 3, ShowWheelAfterFails = 7 },
	[3] = { ExamplesShown = 0, TooltipLevel = "none", HintAfterFails = 5, ShowWheelAfterFails = 10 },
}

local MORPHEME_DEFINITIONS = {
	["un-"] = "not / opposite of",
	["de-"] = "remove / reverse",
	["anti-"] = "against",
	["re-"] = "again / back",
	["pre-"] = "before",
	["-ify"] = "to make",
	["-ize"] = "to make / to cause",
	["-s"] = "more than one",
	["-ed"] = "already happened",
	["-ing"] = "happening now",
	["-er"] = "one who does",
	["-ful"] = "full of",
	["-ly"] = "in a certain way",
	["-ness"] = "state of being",
	["-able"] = "can be done",
	["-ible"] = "can be done",
	["-ish"] = "somewhat like",
	["-ous"] = "full of",
	["struct-"] = "build",
	["form-"] = "shape",
	["morph-"] = "shape / form",
	["phil-"] = "love",
	["amat-"] = "love",
	["path-"] = "feeling",
	["vis-"] = "see",
	["vid-"] = "see",
	["cogn-"] = "know",
	["-ology"] = "study of",
	["omni-"] = "all",
	["trans-"] = "across / change",
	["meta-"] = "beyond / about",
	["hyper-"] = "excessive",
	["-cracy"] = "rule by",
	["-archy"] = "rule / leadership",
	["reg-"] = "rule / straight",
	["meter"] = "measure",
	["ordin-"] = "order",
	["pseudo-"] = "false",
	["quasi-"] = "as if",
}

-- Track failed attempts per player per slot
local playerFailedAttempts: { [string]: { [string]: number } } = {} -- playerId -> slotId -> failCount

function MadLibService:GetHintData(playerId: string, slotId: string, morpheme: string?, tier: number): { HintType: string, Examples: {string}?, Definition: string?, WheelWords: {string}? }
	local config = HintConfig[tier] or HintConfig[1]
	local failCount = (playerFailedAttempts[playerId] and playerFailedAttempts[playerId][slotId]) or 0
	
	-- Check if should show selection wheel
	if failCount >= config.ShowWheelAfterFails then
		-- Return selection wheel with 5 valid words
		local EtymologyDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EtymologyDB"))
		local whitelist = EtymologyDB.MorphemeWhitelist
		local wheelWords = {}
		if whitelist and morpheme and whitelist[morpheme] then
			local validWords = whitelist[morpheme]
			for i = 1, math.min(5, #validWords) do
				table.insert(wheelWords, validWords[i])
			end
		end
		return {
			HintType = "wheel",
			WheelWords = wheelWords,
		}
	end
	
	-- Check if should show hint
	if failCount >= config.HintAfterFails then
		local definition = MORPHEME_DEFINITIONS[morpheme] or "a word part"
		return {
			HintType = "hint",
			Definition = definition,
		}
	end
	
	-- Check if should show examples
	local examples = {}
	if config.ExamplesShown > 0 and morpheme then
		local EtymologyDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EtymologyDB"))
		local whitelist = EtymologyDB.MorphemeWhitelist
		if whitelist and whitelist[morpheme] then
			local validWords = whitelist[morpheme]
			for i = 1, math.min(config.ExamplesShown, #validWords) do
				table.insert(examples, validWords[i])
			end
		end
	end
	
	local tooltip = ""
	if config.TooltipLevel == "definition" and morpheme then
		tooltip = MORPHEME_DEFINITIONS[morpheme] or ""
	elseif config.TooltipLevel == "morpheme_only" and morpheme then
		tooltip = morpheme
	end
	
	return {
		HintType = "examples",
		Examples = examples,
		Definition = tooltip ~= "" and tooltip or nil,
	}
end

function MadLibService:RecordFailedAttempt(playerId: string, slotId: string)
	if not playerFailedAttempts[playerId] then
		playerFailedAttempts[playerId] = {}
	end
	if not playerFailedAttempts[playerId][slotId] then
		playerFailedAttempts[playerId][slotId] = 0
	end
	playerFailedAttempts[playerId][slotId] = playerFailedAttempts[playerId][slotId] + 1
end

function MadLibService:GetSlotTier(archetype: NPCArchetype): number
	-- Map archetypes to tiers based on their position in the ring
	-- Tier 1: Barnaby, Yorick, Kael, Martha, Gribble (inner ring)
	-- Tier 2: Nyx, Vlad, Pygmalion, Chesty (middle ring)
	-- Tier 3: Ozymandias, Zafir, Ignis (outer ring)
	local tier1Archetypes = { "Innocent", "Everyman", "Hero", "Caregiver", "Explorer" }
	local tier2Archetypes = { "Rebel", "Lover", "Creator", "Jester" }
	local tier3Archetypes = { "Sage", "Magician", "Ruler" }
	
	for _, a in ipairs(tier1Archetypes) do
		if archetype == a then return 1 end
	end
	for _, a in ipairs(tier2Archetypes) do
		if archetype == a then return 2 end
	end
	for _, a in ipairs(tier3Archetypes) do
		if archetype == a then return 3 end
	end
	return 1 -- default to Tier 1
end

-- Extract slot words from template
local function extractSlots(template: string): { QuestSlot }
	local slots: { QuestSlot } = {}
	
	for word in string.gmatch(template, "{([^}]+)}") do
		local slotType = word
		
		local slot: QuestSlot = {
			SlotId = HttpService:GenerateGUID(false),
			SlotType = slotType,
			RequiredElement = nil,
			RequiredRole = nil,
			PlayerEntry = nil,
			PlayerId = nil,
			InstanceId = nil,
		}
		
		-- Set element requirements based on archetype
		if slotType == "ADJECTIVE" then
			slot.RequiredElement = nil -- Any element OK
		elseif slotType == "VERB" then
			slot.RequiredRole = "Striker"
		elseif slotType == "NOUN" then
			slot.RequiredRole = "Tank"
		elseif slotType == "ADVERB" then
			slot.RequiredRole = "Support"
		end
		
		table.insert(slots, slot)
	end
	
	return slots
end

-- Generate rewards based on archetype
local function generateRewards(archetype: NPCArchetype): { XP: number, Insight: number, EvolutionPoints: number }
	local baseRewards = {
		Innocent = { XP = 50, Insight = 10, EvolutionPoints = 2 },
		Sage = { XP = 40, Insight = 15, EvolutionPoints = 3 },
		Explorer = { XP = 45, Insight = 12, EvolutionPoints = 2 },
		Hero = { XP = 60, Insight = 8, EvolutionPoints = 1 },
		Magician = { XP = 35, Insight = 20, EvolutionPoints = 4 },
		Lover = { XP = 55, Insight = 10, EvolutionPoints = 2 },
		Jester = { XP = 45, Insight = 15, EvolutionPoints = 3 },
		Everyman = { XP = 50, Insight = 12, EvolutionPoints = 2 },
		Caregiver = { XP = 40, Insight = 18, EvolutionPoints = 3 },
		Rebel = { XP = 65, Insight = 5, EvolutionPoints = 1 },
		Creator = { XP = 50, Insight = 15, EvolutionPoints = 4 },
		Ruler = { XP = 40, Insight = 25, EvolutionPoints = 5 },
	}
	
	local rewards = baseRewards[archetype] or baseRewards.Hero
	
	-- Add some randomness
	rewards.XP = rewards.XP + math.random(0, 20)
	rewards.Insight = rewards.Insight + math.random(0, 5)
	
	return rewards
end

-- Build complete narrative with filled slots
local function buildNarrative(template: string, slots: { [string]: QuestSlot } | { QuestSlot }): string
	local narrative = template
	
	for _, slot in pairs(slots) do
		local replacement = slot.PlayerEntry or "[" .. slot.SlotType .. "]"
		narrative = narrative:gsub("{" .. slot.SlotType .. "}", replacement)
	end
	
	return narrative
end

local function _constructQuestFromTemplate(player: Player, template: any, archetype: NPCArchetype): MadLibQuest
	local quest: MadLibQuest = {
		QuestId = HttpService:GenerateGUID(false),
		Title = template.Title,
		Archetype = archetype,
		DramaticSituation = template.Template,
		CompleteNarrative = "",
		Slots = {},
		Status = "Waiting",
		Rewards = template.Rewards or generateRewards(archetype),
		CreatedAt = os.time(),
	}
	
	-- Extract slots from template
	local slotList = extractSlots(template.Template)
	for _, slot in ipairs(slotList) do
		quest.Slots[slot.SlotId] = slot
	end
	
	-- Build initial narrative
	quest.CompleteNarrative = buildNarrative(template.Template, slotList)
	
	-- Store quest
	activeQuests[quest.QuestId] = quest
	playerActiveQuests[player] = quest.QuestId
	
	-- Notify client
	MadLibService.Client.QuestGenerated:Fire(player, quest)
	print("[MadLibService] Generated quest: " .. quest.Title .. " for " .. player.Name)
	
	return quest
end

-- Generate a quest using AI / Archetypes
function MadLibService:GenerateQuest(player: Player, archetype: NPCArchetype?): MadLibQuest?
	-- Validate player
	if not player or not player.Parent then
		warn("[MadLibService] Invalid player for quest generation")
		return nil
	end
	
	-- Select random archetype if not specified
	local archetypes = { "Innocent", "Sage", "Explorer", "Hero", "Magician", "Lover", "Jester", "Everyman", "Caregiver", "Rebel", "Creator", "Ruler" }
	local selectionArchetype = archetype or archetypes[math.random(1, #archetypes)]
	
	-- [QUEST-001] 70% Archetype Chain / 30% Dynamic AI
	local roll = math.random(1, 100)
	if roll <= 30 then
		local success, AIService = pcall(function()
			return Knit.GetService("AIService")
		end)
		
		if success and AIService then
			local aiSuccess, aiResult = pcall(function()
				return AIService:GenerateMadLibQuest(selectionArchetype)
			end)
			
			if aiSuccess and aiResult then
				print("[MadLibService] Generated dynamic quest: " .. aiResult.title)
				local constructSuccess, constructResult = pcall(function()
					return _constructQuestFromTemplate(player, aiResult, selectionArchetype :: NPCArchetype)
				end)
				
				if constructSuccess then
					return constructResult
				else
					warn("[MadLibService] Error constructing AI quest:", constructResult)
				end
			else
				warn("[MadLibService] AI quest generation failed:", aiResult)
			end
		else
			warn("[MadLibService] AIService not available")
		end
	end
	
	-- Local Template Fallback
	local templates
	local templateSuccess, templateResult = pcall(function()
		return QuestData.ArchetypeQuests[selectionArchetype] or QuestData.ArchetypeQuests.Hero
	end)
	
	if not templateSuccess then
		warn("[MadLibService] Error getting quest templates:", templateResult)
		return nil
	end
	
	templates = templateResult
	
	if not templates or #templates == 0 then
		warn("[MadLibService] No templates available for archetype:", selectionArchetype)
		return nil
	end
	
	local template = templates[math.random(1, #templates)]
	
	local constructSuccess, constructResult = pcall(function()
		return _constructQuestFromTemplate(player, template, selectionArchetype :: NPCArchetype)
	end)
	
	if not constructSuccess then
		warn("[MadLibService] Error constructing quest from template:", constructResult)
		return nil
	end
	
	return constructResult
end

-- Generate a District-Themed NPC Quest
function MadLibService:GenerateNPCQuest(player: Player, npcId: string, questTier: number): MadLibQuest?
	local LoreDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Master_Lore"):WaitForChild("LoreDB"))
	local npcData = LoreDB.NPCs[npcId]
	
	local npcChains = QuestData.NPCChains[npcId]
	if not npcChains then
		warn("[MadLibService] No NPC Chains found for: " .. tostring(npcId))
		-- Fallback to random archetype quest derived from NPC data
		local rawArchetype = npcData and npcData.Archetype or "Hero"
		local archetype = rawArchetype:gsub("^The ", "") :: NPCArchetype
		return self:GenerateQuest(player, archetype)
	end
	
	local tier = math.clamp(questTier, 1, #npcChains)
	local template = npcChains[tier]
	
	-- Fetch archetype from LoreDB, stripping "The " prefix if present
	local rawArchetype = npcData and npcData.Archetype or "Hero"
	local archetype = rawArchetype:gsub("^The ", "") :: NPCArchetype
	
	-- [QUEST-003] Read equipped companion slime
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local companion = SlimeFactory:GetCompanion(player)
	
	local quest = _constructQuestFromTemplate(player, template, archetype)
	
	-- [QUEST-002] Wire LoreDB.Teaches[] into quest slot generation
	if npcData and npcData.Teaches and #npcData.Teaches > 0 then
		local targetMorpheme = npcData.Teaches[math.random(1, #npcData.Teaches)]
		
		-- Tag first suitable slot with the morpheme
		for _, slot in pairs(quest.Slots) do
			if slot.SlotType == "ADJECTIVE" or slot.SlotType == "NOUN" or slot.SlotType == "VERB" then
				slot.TargetMorpheme = targetMorpheme
				print("[MadLibService] Slot " .. slot.SlotId .. " targeted with morpheme: " .. targetMorpheme)
				break
			end
		end
	end
	
	-- [QUEST-004] Cross-domain quests: Modify rewards/difficulty based on companion
	if companion and npcData then
		local isPreferred = false
		for _, prefElem in ipairs(npcData.PreferredElement) do
			if companion.Element == prefElem then
				isPreferred = true
				break
			end
		end
		
		if isPreferred then
			-- Harmonic resonance: extra rewards
			quest.Rewards.XP = math.ceil(quest.Rewards.XP * 1.25)
			quest.Rewards.Insight = math.ceil(quest.Rewards.Insight * 1.2)
			print("[MadLibService] Harmonic resonance detected! " .. companion.Element .. " slime matches NPC domain. Rewards boosted.")
		else
			-- Dissonance: add a special difficult slot
			local dissonanceSlot: QuestSlot = {
				SlotId = HttpService:GenerateGUID(false),
				SlotType = "ADJECTIVE",
				RequiredElement = nil,
				RequiredRole = "Support",
				TargetMorpheme = "anti-", -- Harder morpheme for dissonance
				PlayerEntry = nil,
				PlayerId = nil,
				InstanceId = nil,
			}
			quest.Slots[dissonanceSlot.SlotId] = dissonanceSlot
			quest.Title = "[DISSONANCE] " .. quest.Title
			print("[MadLibService] Dissonance detected! " .. companion.Element .. " slime clashes with NPC domain. Added anti-morpheme slot.")
		end
	end
	
	return quest
end

-- Fill a slot in the quest with a player's slime/word
function MadLibService:FillSlot(player: Player, questId: string, slotId: string, instanceId: string, wordEntry: string): (boolean, string?)
	local quest = activeQuests[questId]
	if not quest then
		return false, "Quest not found"
	end
	
	local slot = quest.Slots[slotId]
	if not slot then
		return false, "Slot not found"
	end
	
	if slot.PlayerEntry then
		return false, "Slot already filled"
	end
	
	-- [QUEST-005] Morpheme Validation
	if slot.TargetMorpheme then
		local isValid, errorMsg = validateMorpheme(wordEntry, slot.TargetMorpheme)
		
		-- [ANALYTICS-001] Log attempt immediately
		local DataService = Knit.GetService("DataService")
		if DataService then
			DataService:LogLinguisticData(player, slot.TargetMorpheme, isValid)
		end
		
		if not isValid then
			-- [QUEST-006] Gentle guidance
			return false, errorMsg or "That word doesn't match the lesson!"
		end
	end
	
	-- Fill the slot
	slot.PlayerEntry = wordEntry
	slot.PlayerId = player.Name
	slot.InstanceId = instanceId
	
	-- Update narrative
	quest.CompleteNarrative = buildNarrative(quest.DramaticSituation, quest.Slots)
	
	-- Check if all slots are filled
	local allFilled = true
	for _, s in pairs(quest.Slots) do
		if not s.PlayerEntry then
			allFilled = false
			break
		end
	end
	
	if allFilled then
		quest.Status = "InProgress"
	end
	
	-- Notify
	self.Client.SlotFilled:Fire(player, quest)
	print("[MadLibService] " .. player.Name .. " filled slot " .. slotId .. " with '" .. wordEntry .. "'")
	
	return true
end

-- Get active quest for player
function MadLibService:GetPlayerQuest(player: Player): MadLibQuest?
	local questId = playerActiveQuests[player]
	if not questId then return nil end
	return activeQuests[questId]
end

-- Complete the quest and distribute rewards
function MadLibService:CompleteQuest(player: Player, questId: string): MadLibQuest?
	local quest = activeQuests[questId]
	if not quest then return nil end
	
	-- Verify all slots are filled
	for _, slot in pairs(quest.Slots) do
		if not slot.PlayerEntry then
			warn("[MadLibService] Cannot complete - slots not filled")
			return nil
		end
	end
	
	quest.Status = "Completed"
	
	-- Award rewards
	local DataService = Knit.GetService("DataService")
	
	DataService:AddXP(player, quest.Rewards.XP)
	DataService:AddInsight(player, quest.Rewards.Insight)
	
	DataService:IncrementAchievementProgress(player, "quest_5", 1)
	DataService:IncrementAchievementProgress(player, "quest_25", 1)
	
	-- Notify
	self.Client.QuestCompleted:Fire(player, quest)
	print("[MadLibService] Quest completed: " .. quest.Title)
	
	-- [QUEST-007] Log completed morphemes to profile
	for _, slot in pairs(quest.Slots) do
		if slot.TargetMorpheme then
			DataService:LogLinguisticData(player, slot.TargetMorpheme, true)
		end
	end
	
	-- Clean up after delay
	task.delay(60, function()
		activeQuests[questId] = nil
	end)
	
	return quest
end

-- Get available archetypes
function MadLibService:GetAvailableArchetypes(): { NPCArchetype }
	return { "Innocent", "Sage", "Explorer", "Hero", "Magician", "Lover", "Jester", "Everyman", "Caregiver", "Rebel", "Creator", "Ruler" }
end

-- Get slot suggestions for a player
function MadLibService.Client:GetSlotSuggestions(player: Player, slotType: string): { any }
	if type(slotType) ~= "string" then return {} end
	return self.Server:GetSlotSuggestions(player, slotType)
end

function MadLibService:GetSlotSuggestions(player: Player, slotType: string): { any }
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slimes = SlimeFactory:GetPlayerSlimes(player)
	
	-- Determine required role based on slot type (from extractSlots mapping logic)
	local roleMatch = nil
	if slotType == "VERB" then
		roleMatch = "Striker"
	elseif slotType == "NOUN" then
		roleMatch = "Tank"
	elseif slotType == "ADJECTIVE" or slotType == "ADVERB" then
		roleMatch = "Support"
	end
	
	local suggestions = {}
	if slimes then
		for _, slime in pairs(slimes) do
			if not roleMatch or slime.Role == roleMatch then
				table.insert(suggestions, slime)
			end
		end
	end
	
	return suggestions
end

function MadLibService:KnitStart()
	print("[MadLibService] Started.")
end

return MadLibService
