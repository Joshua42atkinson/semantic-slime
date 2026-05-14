--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Service references (set in Start)
local CrystalService
local SlimeFactory
local WordExcavatorService
local MadLibService
local BattleService
local DataService

local GameLoopService = Knit.CreateService {
	Name = "GameLoopService",
	Client = {
		PhaseChanged = Knit.CreateSignal(),
		GameLoopEvent = Knit.CreateSignal(),
	},
	PhaseChanged = Knit.CreateSignal(),
	GameLoopEvent = Knit.CreateSignal(),
}

-- Game Loop Phases
export type GamePhase = 
	"Collection" |   -- Collecting letter crystals
	"Construction" | -- Building words from letters
	"Quest" |        -- Doing Mad Lib quests
	"Combat" |       -- Battling for quest slots
	"Rewards" |      -- Receiving rewards
	"Reflection"     -- Pedagogical breather

-- Configuration - Base durations (can be scaled dynamically)
local BASE_DURATIONS = {
	Collection = 45,    -- Seconds in collection phase (increased from 30)
	Construction = 30,  -- Seconds in construction phase (increased from 20)
	Quest = 90,         -- Seconds per quest (increased from 60)
	Combat = 45,        -- Seconds for combat (increased from 30)
	Rewards = 30,       -- Seconds for rewards display (increased from 10)
	Reflection = 15,    -- 15 seconds of pedagogical breather
}

-- Dynamic phase durations based on player count
local function getPhaseDuration(phase: GamePhase): number
	local base = BASE_DURATIONS[phase]
	local playerCount = #Players:GetPlayers()
	
	-- Scale: +5s per player, max +60s extra
	local scaling = math.min(playerCount * 5, 60)
	return base + scaling
end

-- Current phase durations (can be modified by objectives/bonuses)
local PHASE_DURATIONS = {
	Collection = BASE_DURATIONS.Collection,
	Construction = BASE_DURATIONS.Construction,
	Quest = BASE_DURATIONS.Quest,
	Combat = BASE_DURATIONS.Combat,
	Rewards = BASE_DURATIONS.Rewards,
	Reflection = BASE_DURATIONS.Reflection,
}

-- Private state
local currentPhase: GamePhase = "Collection"
local phaseEndTime: number = 0
local gameLoopRunning = false
local resonanceScores: { [string]: number } = {}
local resonanceActive: { [string]: boolean } = {}

-- Phase Objectives System
local PHASE_OBJECTIVES = {
	Collection = {
		{ Target = 5, Bonus = "Rare Crystal Spawn", Completed = false },
		{ Target = 10, Bonus = "Bonus Letters", Completed = false },
	},
	Construction = {
		{ Target = 3, Bonus = "Evolution Point", Completed = false },
		{ Target = 5, Bonus = "Reroll Quest Choice", Completed = false },
	},
	Quest = {
		{ Target = 2, Bonus = "Skip Next Battle", Completed = false },
		{ Target = 4, Bonus = "Double Rewards", Completed = false },
	},
	Combat = {
		{ Target = 1, Bonus = "Bonus XP", Completed = false },
		{ Target = 3, Bonus = "Context Points", Completed = false },
	},
	-- No specific objectives for Rewards phase typically
	Rewards = {},
}

-- Track player actions for objectives
local phaseProgress: { [GamePhase]: { [string]: number } } = {
	Collection = {},
	Construction = {},
	Quest = {},
	Combat = {},
}

-- Get or initialize player progress
local function getPlayerProgress(player: Player, phase: GamePhase): number
	local playerId = player.UserId
	if not phaseProgress[phase][playerId] then
		phaseProgress[phase][playerId] = 0
	end
	return phaseProgress[phase][playerId]
end

-- Grant bonus based on type
local function grantObjectiveBonus(player: Player, bonus: string)
	if bonus == "Rare Crystal Spawn" then
		-- Trigger rare crystal spawn for player
		if CrystalService then
			local success, err = pcall(function()
				CrystalService:SpawnRareCrystal(player)
			end)
			if not success then
				warn("[GameLoopService] Failed to spawn rare crystal:", err)
			end
		else
			warn("[GameLoopService] CrystalService not available for rare crystal spawn")
		end
	elseif bonus == "Bonus Letters" then
		-- Grant bonus letters
		if CrystalService then
			local success, err = pcall(function()
				CrystalService:GrantBonusLetters(player, 3)
			end)
			if not success then
				warn("[GameLoopService] Failed to grant bonus letters:", err)
			end
		else
			warn("[GameLoopService] CrystalService not available for bonus letters")
		end
	elseif bonus == "Evolution Point" then
		-- Grant evolution point
		if SlimeFactory then
			local success, err = pcall(function()
				SlimeFactory:GrantEvolutionPoint(player)
			end)
			if not success then
				warn("[GameLoopService] Failed to grant evolution point:", err)
			end
		else
			warn("[GameLoopService] SlimeFactory not available for evolution point")
		end
	elseif bonus == "Reroll Quest Choice" then
		-- Grant reroll token (stored in player data)
		if DataService then
			local success, err = pcall(function()
				DataService:GrantRerollToken(player)
			end)
			if not success then
				warn("[GameLoopService] Failed to grant reroll token:", err)
			end
		else
			warn("[GameLoopService] DataService not available for reroll token")
		end
	elseif bonus == "Skip Next Battle" then
		-- Mark player as battle-skip eligible
		if DataService then
			local success, err = pcall(function()
				DataService:GrantBattleSkip(player)
			end)
			if not success then
				warn("[GameLoopService] Failed to grant battle skip:", err)
			end
		else
			warn("[GameLoopService] DataService not available for battle skip")
		end
	elseif bonus == "Double Rewards" then
		-- Mark player for double rewards
		if DataService then
			local success, err = pcall(function()
				DataService:GrantDoubleRewards(player)
			end)
			if not success then
				warn("[GameLoopService] Failed to grant double rewards:", err)
			end
		else
			warn("[GameLoopService] DataService not available for double rewards")
		end
	end
end

-- Increment player progress and check for objectives
function GameLoopService:IncrementProgress(player: Player, phase: GamePhase, amount: number): string?
	local playerId = tostring(player.UserId)
	
	-- Track resonance if phase is complete
	if resonanceActive[playerId] and currentPhase == phase then
		resonanceScores[playerId] = (resonanceScores[playerId] or 0) + amount
		
		-- Notify client of resonance gain
		self.Client.GameLoopEvent:Fire(player, "ResonanceIncreased", {
			Score = resonanceScores[playerId],
			Multiplier = self:GetResonanceMultiplier(player)
		})
		
		return "Resonance"
	end

	phaseProgress[phase][playerId] = (phaseProgress[phase][playerId] or 0) + amount
	
	local progress = phaseProgress[phase][playerId]
	local objectives = PHASE_OBJECTIVES[phase]
	if not objectives then return nil end
	
	-- Check objectives
	local allComplete = true
	local justCompleted: string? = nil

	for _, objective in ipairs(objectives) do
		if not objective.Completed then
			if progress >= objective.Target then
				objective.Completed = true
				justCompleted = objective.Bonus
				print("[GameLoopService] Player " .. player.Name .. " completed objective: " .. objective.Bonus)
				
				-- Grant bonus
				grantObjectiveBonus(player, objective.Bonus)
				
				-- Notify client
				GameLoopService.Client.GameLoopEvent:Fire(player, "ObjectiveComplete", {
					Bonus = objective.Bonus,
					Target = objective.Target,
					Progress = progress,
				})
			else
				allComplete = false
			end
		end
	end
	
	-- If all objectives are now complete, enter Resonance mode
	if allComplete and not resonanceActive[playerId] then
		resonanceActive[playerId] = true
		resonanceScores[playerId] = 0
		
		self.Client.GameLoopEvent:Fire(player, "HighResonance", {
			Multiplier = 1.0
		})
		print("[GameLoopService] " .. player.Name .. " entered HIGH RESONANCE!")
	end
	
	return justCompleted
end

-- Reset objectives for a new phase
local function resetPhaseObjectives(phase: GamePhase)
	if PHASE_OBJECTIVES[phase] then
		for _, objective in ipairs(PHASE_OBJECTIVES[phase]) do
			objective.Completed = false
		end
	end
	-- Reset all player progress for this phase
	phaseProgress[phase] = {}
	
	-- Reset resonance for new phase cycle
	-- (Wait, resonance should probably last until Rewards phase)
	-- Actually, reset it here.
	resonanceActive = {}
	resonanceScores = {}
end

-- Get current objective status for a player
function GameLoopService:GetObjectiveStatus(player: Player): { Phase: GamePhase, Progress: number, Objectives: { any } }
	local phase = currentPhase
	local progress = getPlayerProgress(player, phase)
	local objectives = PHASE_OBJECTIVES[phase] or {}
	
	return {
		Phase = phase,
		Progress = progress,
		Objectives = objectives,
	}
end

-- Calculate player resonance multiplier
function GameLoopService:GetResonanceMultiplier(player: Player): number
    local playerId = tostring(player.UserId)
    local score = resonanceScores[playerId] or 0
    
    -- Resonance Multiplier Formula: 1.0 + (score * 0.1)
    -- 10 micro-actions = +1.0x multiplier
    -- Capped at 5.0 per Technical Bible
    return math.min(1.0 + (score * 0.1), 5.0)
end

-- Get service references safely
local function getServices(): boolean
	local success = true
	
	-- Try to get each service with error handling
	local ok1, svc1 = pcall(function()
		return Knit.GetService("CrystalService")
	end)
	if ok1 and svc1 then
		CrystalService = svc1
	else
		warn("[GameLoopService] CrystalService not available")
		success = false
	end
	
	local ok2, svc2 = pcall(function()
		return Knit.GetService("SlimeFactory")
	end)
	if ok2 and svc2 then
		SlimeFactory = svc2
	else
		warn("[GameLoopService] SlimeFactory not available")
		success = false
	end
	
	local ok3, svc3 = pcall(function()
		return Knit.GetService("WordExcavatorService")
	end)
	if ok3 and svc3 then
		WordExcavatorService = svc3
	else
		warn("[GameLoopService] WordExcavatorService not available")
		success = false
	end
	
	local ok4, svc4 = pcall(function()
		return Knit.GetService("MadLibService")
	end)
	if ok4 and svc4 then
		MadLibService = svc4
	else
		warn("[GameLoopService] MadLibService not available")
		success = false
	end
	
	local ok5, svc5 = pcall(function()
		return Knit.GetService("BattleService")
	end)
	if ok5 and svc5 then
		BattleService = svc5
	else
		warn("[GameLoopService] BattleService not available")
		success = false
	end
	
	local ok6, svc6 = pcall(function()
		return Knit.GetService("DataService")
	end)
	if ok6 and svc6 then
		DataService = svc6
	else
		warn("[GameLoopService] DataService not available")
		success = false
	end
	
	return success
end

-- Change game phase
local function setPhase(newPhase: GamePhase)
	local oldPhase = currentPhase
	currentPhase = newPhase
	
	-- Update dynamic duration based on player count
	local duration = getPhaseDuration(newPhase)
	PHASE_DURATIONS[newPhase] = duration
	
	phaseEndTime = os.time() + duration
	
	print("[GameLoopService] Phase changed: " .. oldPhase .. " -> " .. newPhase)
	
	-- Reset objectives for the new phase
	resetPhaseObjectives(newPhase)
	
	-- Notify all clients
	GameLoopService.Client.PhaseChanged:FireAll(newPhase, duration)
	GameLoopService.Client.GameLoopEvent:FireAll("PhaseStart", newPhase)
	
	-- Notify server scripts
	GameLoopService.PhaseChanged:Fire(newPhase, duration)
	GameLoopService.GameLoopEvent:Fire("PhaseStart", newPhase)
end

-- Process the complete game loop
local function processGameLoop()
	while gameLoopRunning do
		local currentTime = os.time()
		
		-- Check if phase should end
		if currentTime >= phaseEndTime then
			-- Transition to next phase (matches Technical Bible Part X)
			-- Collection → Construction → Quest → Combat → Rewards → (repeat)
			if currentPhase == "Collection" then
				setPhase("Construction")
			elseif currentPhase == "Construction" then
				setPhase("Quest")
			elseif currentPhase == "Quest" then
				setPhase("Combat")
			elseif currentPhase == "Combat" then
				setPhase("Rewards")
			elseif currentPhase == "Rewards" then
				setPhase("Collection")
			elseif currentPhase == "Reflection" then
				-- Reflection is deprecated - redirect to Collection
				setPhase("Collection")
			end
		end
		
		task.wait(1)
	end
end

-- Player completes a word construction
function GameLoopService.Client:CompleteWordConstruction(player: Player, word: string): (boolean, string?)
	if type(word) ~= "string" then return false, "Invalid input" end
	return self.Server:CompleteWordConstruction(player, word)
end

function GameLoopService:CompleteWordConstruction(player: Player, word: string): (boolean, string?)
	if currentPhase ~= "Construction" then
		return false, "Cannot construct words outside Construction phase"
	end
	
	-- Check if CrystalService is available
	if not CrystalService then
		warn("[GameLoopService] CrystalService not available for word construction")
		return false, "Word construction service unavailable"
	end
	
	-- Check if player has letters
	local canForm, errorMsg = pcall(function()
		return CrystalService:CanFormWord(player, word)
	end)
	if not canForm then
		warn("[GameLoopService] Error checking if player can form word:", errorMsg)
		return false, "Error checking letters"
	end
	
	if not errorMsg then
		return false, "You don't have enough letters!"
	end
	
	-- Use letters
	local lettersUsed, useErrorMsg = pcall(function()
		return CrystalService:UseLetters(player, word)
	end)
	if not lettersUsed then
		warn("[GameLoopService] Error using letters:", useErrorMsg)
		return false, "Error consuming letters"
	end
	
	if not useErrorMsg then
		return false, "Error consuming letters"
	end
	
	-- Check if SlimeFactory is available
	if not SlimeFactory then
		warn("[GameLoopService] SlimeFactory not available for word construction")
		return false, "Slime creation service unavailable"
	end
	
	-- Create slime
	local slimeCreated, result = pcall(function()
		return SlimeFactory:CreateSlime(player, word)
	end)
	if not slimeCreated then
		warn("[GameLoopService] Error creating slime:", result)
		return false, "Error creating slime"
	end
	
	local slime, errorMsg = result
	if slime then
		print("[GameLoopService] " .. player.Name .. " created slime: " .. slime.Term)
		
		-- Award context points for creating new slime
		local pointsAdded, pointsError = pcall(function()
			SlimeFactory:AddContextPoints(player, slime.InstanceId, "creation", "base", "success")
		end)
		if not pointsAdded then
			warn("[GameLoopService] Error adding context points:", pointsError)
		end
		
		-- Track progress for Construction phase objectives
		self:IncrementProgress(player, "Construction", 1)
		
		GameLoopService.Client.GameLoopEvent:Fire(player, "SlimeCreated", slime.Term)
		return true
	end
	
	return false, errorMsg or "Construction failed"
end

-- Player starts a Mad Lib quest
function GameLoopService.Client:StartQuest(player: Player, archetype: string?)
	if archetype ~= nil and type(archetype) ~= "string" then return end
	return self.Server:StartQuest(player, archetype)
end

function GameLoopService:StartQuest(player: Player, archetype: string?)
	if currentPhase ~= "Quest" then
		warn("[GameLoopService] Can only start quests during Quest phase")
		return nil
	end
	
	local quest = MadLibService:GenerateQuest(player, archetype)
	if quest then
		GameLoopService.Client.GameLoopEvent:Fire(player, "QuestStarted", quest.Title)
	end
	
	return quest
end

-- Player fills a quest slot with their slime
function GameLoopService.Client:FillQuestSlot(player: Player, questId: string, slotId: string, slimeInstanceId: string): boolean
	if type(questId) ~= "string" or type(slotId) ~= "string" or type(slimeInstanceId) ~= "string" then return false end
	return self.Server:FillQuestSlot(player, questId, slotId, slimeInstanceId)
end

function GameLoopService:FillQuestSlot(player: Player, questId: string, slotId: string, slimeInstanceId: string): boolean
	-- Get the slime
	local slime = SlimeFactory:GetSlime(player, slimeInstanceId)
	if not slime then
		warn("[GameLoopService] Slime not found")
		return false
	end
	
	-- Fill the slot
	local success = MadLibService:FillSlot(player, questId, slotId, slimeInstanceId, slime.Term)
	if success then
		-- Check if this triggers combat (multiple players want same slot)
		-- For now, just grant context points
		SlimeFactory:AddContextPoints(player, slimeInstanceId, questId, slotId, "filled")
		
		GameLoopService.Client.GameLoopEvent:Fire(player, "SlotFilled", slime.Term)
	end
	
	return success
end

-- Player completes a quest
function GameLoopService.Client:CompleteQuest(player: Player): boolean
	return self.Server:CompleteQuest(player)
end

function GameLoopService:CompleteQuest(player: Player): boolean
	local quest = MadLibService:GetPlayerQuest(player)
	if not quest then
		return false
	end
	
	-- Check if all slots are filled
	local allFilled = true
	for _, slot in pairs(quest.Slots) do
		if not slot.PlayerEntry then
			allFilled = false
			break
		end
	end
	
	if not allFilled then
		warn("[GameLoopService] Not all slots filled")
		return false
	end
	
	-- Complete quest
	local completedQuest = MadLibService:CompleteQuest(player, quest.QuestId)
	if completedQuest then
		-- Award XP to slimes that participated
		for _, slot in pairs(completedQuest.Slots) do
			if slot.InstanceId and slot.PlayerId == player.Name then
				SlimeFactory:AddXP(player, slot.InstanceId, 20)
			end
		end
		
		self:IncrementProgress(player, "Quest", 1)
		
		GameLoopService.Client.GameLoopEvent:Fire(player, "QuestCompleted", completedQuest.Title)
		return true
	end
	
	return false
end

-- Start combat for a quest slot
function GameLoopService:StartSlotCombat(questId: string, slotId: string, participants: { any }): any
	-- Transition to combat phase
	setPhase("Combat")
	
	-- Create battle participants
	local battleParticipants = {}
	for _, p in ipairs(participants) do
		local slime = SlimeFactory:GetSlime(p.Player, p.InstanceId)
		if slime then
			local participant = BattleService:CreateParticipant(
				p.Player.Name,
				slime.InstanceId,
				slime.Term,
				slime.Stats,
				slime.Element,
				slime.Role,
				slime.Rarity
			)
			table.insert(battleParticipants, participant)
		end
	end
	
	if #battleParticipants < 2 then
		-- Not enough participants, auto-fill
		setPhase("Quest")
		return nil
	end
	
	-- Start battle
	local battle = BattleService:StartBattle(questId, slotId, battleParticipants)
	
	-- Wait for battle to complete
	task.spawn(function()
		while battle.Status == "InProgress" do
			task.wait(1)
		end
		
		-- Return to quest phase
		setPhase("Quest")
		
		-- Award winner context points
		if battle.Winner then
			for _, p in ipairs(battleParticipants) do
				if p.InstanceId == battle.Winner then
					local player = Players:FindFirstChild(p.PlayerId)
					if player then
						SlimeFactory:AddContextPoints(player, p.InstanceId, questId, slotId, "victory")
					end
					break
				end
			end
		end
	end)
	
	return battle
end

-- Get current game state
function GameLoopService:GetGameState(): { Phase: GamePhase, TimeRemaining: number }
	return {
		Phase = currentPhase,
		TimeRemaining = math.max(0, phaseEndTime - os.time()),
	}
end

-- Manual phase control (for testing/admin)
function GameLoopService:SetPhase(phase: GamePhase)
	setPhase(phase)
end

-- Force start next phase
function GameLoopService:NextPhase()
	if currentPhase == "Collection" then
		setPhase("Construction")
	elseif currentPhase == "Construction" then
		setPhase("Quest")
	elseif currentPhase == "Quest" then
		setPhase("Combat")
	elseif currentPhase == "Combat" then
		setPhase("Rewards")
	elseif currentPhase == "Rewards" then
		setPhase("Collection")
	end
end

function GameLoopService:KnitStart()
	print("[GameLoopService] Starting...")
	
	-- Get service references safely
	local servicesLoaded = getServices()
	if not servicesLoaded then
		warn("[GameLoopService] Some services failed to load. Game loop will start with limited functionality.")
	end
	
	-- Start game loop
	gameLoopRunning = true
	
	-- Start with collection phase
	setPhase("Collection")
	
	-- Start the loop processor
	task.spawn(processGameLoop)
	
	print("[GameLoopService] Started. Current phase: " .. currentPhase)
end

-- Stop game loop on server shutdown
function GameLoopService:KnitStop()
	gameLoopRunning = false
	print("[GameLoopService] Stopped.")
end

return GameLoopService
