--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Service references (set in Start)
local CrystalService
local SlimeFactory
local GachaService
local MadLibService
local BattleService
local DataService

local GameLoopService = Knit.CreateService {
	Name = "GameLoopService",
	Client = {
		PhaseChanged = Knit.CreateSignal(),
		GameLoopEvent = Knit.CreateSignal(),
	},
}

-- Game Loop Phases
export type GamePhase = 
	"Collection" |   -- Collecting letter crystals
	"Construction" | -- Building words from letters
	"Quest" |        -- Doing Mad Lib quests
	"Combat" |       -- Battling for quest slots
	"Rewards"        -- Receiving rewards

-- Configuration
local PHASE_DURATIONS = {
	Collection = 30,    -- Seconds in collection phase
	Construction = 20,  -- Seconds in construction phase
	Quest = 60,         -- Seconds per quest
	Combat = 30,        -- Seconds for combat
	Rewards = 10,       -- Seconds for rewards display
}

-- Private state
local currentPhase: GamePhase = "Collection"
local phaseEndTime: number = 0
local gameLoopRunning = false

-- Get service references
local function getServices()
	CrystalService = Knit.GetService("CrystalService")
	SlimeFactory = Knit.GetService("SlimeFactory")
	GachaService = Knit.GetService("GachaService")
	MadLibService = Knit.GetService("MadLibService")
	BattleService = Knit.GetService("BattleService")
	DataService = Knit.GetService("DataService")
end

-- Change game phase
local function setPhase(newPhase: GamePhase)
	local oldPhase = currentPhase
	currentPhase = newPhase
	phaseEndTime = os.time() + (PHASE_DURATIONS[newPhase] or 30)
	
	print("[GameLoopService] Phase changed: " .. oldPhase .. " -> " .. newPhase)
	
	-- Notify all clients
	GameLoopService.Client.PhaseChanged:FireAll(newPhase, PHASE_DURATIONS[newPhase])
	GameLoopService.Client.GameLoopEvent:FireAll("PhaseStart", newPhase)
end

-- Process the complete game loop
local function processGameLoop()
	while gameLoopRunning do
		local currentTime = os.time()
		
		-- Check if phase should end
		if currentTime >= phaseEndTime then
			-- Transition to next phase
			if currentPhase == "Collection" then
				setPhase("Construction")
			elseif currentPhase == "Construction" then
				setPhase("Quest")
			elseif currentPhase == "Quest" then
				setPhase("Rewards")
			elseif currentPhase == "Rewards" then
				setPhase("Collection")
			elseif currentPhase == "Combat" then
				-- Combat ends when battles finish, handled separately
			end
		end
		
		task.wait(1)
	end
end

-- Player completes a word construction
function GameLoopService:CompleteWordConstruction(player: Player, word: string): boolean
	if currentPhase ~= "Construction" then
		warn("[GameLoopService] Cannot construct words outside Construction phase")
		return false
	end
	
	-- Check if player has letters
	if not CrystalService:CanFormWord(player, word) then
		warn("[GameLoopService] Player doesn't have required letters")
		return false
	end
	
	-- Use letters
	if not CrystalService:UseLetters(player, word) then
		return false
	end
	
	-- Create slime
	local slime = SlimeFactory:CreateSlime(player, word)
	if slime then
		print("[GameLoopService] " .. player.Name .. " created slime: " .. slime.Term)
		
		-- Award context points for creating new slime
		SlimeFactory:AddContextPoints(player, slime.InstanceId, "creation", "base", "success")
		
		GameLoopService.Client.GameLoopEvent:Fire(player, "SlimeCreated", slime.Term)
		return true
	end
	
	return false
end

-- Player starts a Mad Lib quest
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
		setPhase("Rewards")
	elseif currentPhase == "Rewards" then
		setPhase("Collection")
	end
end

function GameLoopService:KnitStart()
	print("[GameLoopService] Starting...")
	
	-- Get service references
	getServices()
	
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
