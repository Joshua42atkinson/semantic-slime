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
export type NPCArchetype = "Hero" | "Mentor" | "Trickster" | "Shadow" | "Herald"

export type QuestSlot = {
	SlotId: string,
	SlotType: "ADJECTIVE" | "VERB" | "NOUN" | "ADVERB",
	RequiredElement: string?,
	RequiredRole: string?,
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
		Hero = { XP = 50, Insight = 10, EvolutionPoints = 2 },
		Mentor = { XP = 40, Insight = 15, EvolutionPoints = 3 },
		Trickster = { XP = 45, Insight = 12, EvolutionPoints = 2 },
		Shadow = { XP = 60, Insight = 8, EvolutionPoints = 1 },
		Herald = { XP = 35, Insight = 20, EvolutionPoints = 4 },
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
function MadLibService:GenerateQuest(player: Player, archetype: NPCArchetype?): MadLibQuest
	-- Select random archetype if not specified
	local selectionArchetype = archetype or ({"Hero", "Mentor", "Trickster", "Shadow", "Herald"})[math.random(1, 5)]
	
	-- Get template for archetype
	local templates = QuestData.ArchetypeQuests[selectionArchetype] or QuestData.ArchetypeQuests.Hero
	local template = templates[math.random(1, #templates)]
	
	return _constructQuestFromTemplate(player, template, selectionArchetype :: NPCArchetype)
end

-- Generate a District-Themed NPC Quest
function MadLibService:GenerateNPCQuest(player: Player, npcId: string, questTier: number): MadLibQuest?
	local npcChains = QuestData.NPCChains[npcId]
	if not npcChains then
		warn("[MadLibService] No NPC Chains found for: " .. tostring(npcId))
		return nil
	end
	
	local tier = math.clamp(questTier, 1, #npcChains)
	local template = npcChains[tier]
	
	return _constructQuestFromTemplate(player, template, "Hero") -- Default to Hero archetype style behavior, or fetch NPC's actual archetype
end

-- Fill a slot in the quest with a player's slime/word
function MadLibService:FillSlot(player: Player, questId: string, slotId: string, instanceId: string, wordEntry: string): boolean
	local quest = activeQuests[questId]
	if not quest then
		warn("[MadLibService] Quest not found: " .. questId)
		return false
	end
	
	local slot = quest.Slots[slotId]
	if not slot then
		warn("[MadLibService] Slot not found: " .. slotId)
		return false
	end
	
	if slot.PlayerEntry then
		-- Slot already filled
		warn("[MadLibService] Slot already filled")
		return false
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
	local profile = DataService:GetProfile(player)
	
	if profile then
		profile.XP = (profile.XP or 0) + quest.Rewards.XP
		profile.Stats.Insight = (profile.Stats.Insight or 0) + quest.Rewards.Insight
		print("[MadLibService] Awarded " .. quest.Rewards.XP .. " XP and " .. quest.Rewards.Insight .. " Insight")
		
		DataService:IncrementAchievementProgress(player, "quest_5", 1)
		DataService:IncrementAchievementProgress(player, "quest_25", 1)
	end
	
	-- Notify
	self.Client.QuestCompleted:Fire(player, quest)
	print("[MadLibService] Quest completed: " .. quest.Title)
	
	-- Clean up after delay
	task.delay(60, function()
		activeQuests[questId] = nil
	end)
	
	return quest
end

-- Get available archetypes
function MadLibService:GetAvailableArchetypes(): { NPCArchetype }
	return { "Hero", "Mentor", "Trickster", "Shadow", "Herald" }
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
