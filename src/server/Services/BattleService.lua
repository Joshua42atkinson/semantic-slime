--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local BattleService = Knit.CreateService {
	Name = "BattleService",
	Client = {
		BattleStarted = Knit.CreateSignal(),
		BattleTurn = Knit.CreateSignal(),
		BattleEnded = Knit.CreateSignal(),
	},
}

-- Types
export type BattleParticipant = {
	PlayerId: string,
	InstanceId: string,
	SlimeName: string,
	HP: number,
	MaxHP: number,
	Stats: {
		Logos: number,
		Pathos: number,
		Ethos: number,
		Speed: number,
	},
	Element: string,
	Role: string,
	Rarity: string,
}

export type BattleState = {
	BattleId: string,
	QuestId: string,
	SlotId: string,
	Participants: { BattleParticipant },
	Status: "Waiting" | "InProgress" | "Completed",
	Turn: number,
	CurrentTurn: number, -- Index of current participant
	Log: { string },
	Winner: string?, -- InstanceId of winner
}

-- Configuration
local TURN_TIMEOUT = 30 -- Seconds per turn
local BASE_HP = 100

-- Private state
local activeBattles: { [string]: BattleState } = {}
local battleTimeouts: { [string]: any } = {}

-- Calculate HP from stats
local function calculateHP(stats: { [string]: number }): number
	return BASE_HP + (stats.Pathos * 2) + (stats.Ethos)
end

-- Determine turn order based on speed
local function determineTurnOrder(participants: { BattleParticipant }): { number }
	local order: { number } = {}
	
	for i = 1, #participants do
		table.insert(order, i)
	end
	
	-- Sort by speed (highest first)
	table.sort(order, function(a, b)
		return participants[a].Stats.Speed > participants[b].Stats.Speed
	end)
	
	return order
end

-- Calculate damage
local function calculateDamage(attacker: BattleParticipant, defender: BattleParticipant): number
	local baseDamage = attacker.Stats.Logos
	
	-- Role-based bonuses
	if attacker.Role == "Striker" then
		baseDamage = baseDamage * 1.2
	elseif attacker.Role == "Assassin" then
		baseDamage = baseDamage * 1.3
	elseif attacker.Role == "Caster" then
		baseDamage = baseDamage * 1.1
	end
	
	-- Apply defense reduction
	local defense = defender.Stats.Ethos
	local reduction = defense / (defense + 50) -- Diminishing returns
	local damageReduction = 1 - reduction
	
	baseDamage = baseDamage * damageReduction
	
	-- Elemental advantage
	local elementalAdvantage = {
		Fire = "Air",
		Water = "Fire",
		Earth = "Water",
		Air = "Earth",
		Shadow = "Light",
		Light = "Shadow",
	}
	
	if elementalAdvantage[attacker.Element] == defender.Element then
		baseDamage = baseDamage * 1.5
	elseif elementalAdvantage[defender.Element] == attacker.Element then
		baseDamage = baseDamage * 0.75
	end
	
	return math.floor(baseDamage)
end

-- Process a turn
local function processTurn(battle: BattleState, attackerIndex: number): BattleParticipant?
	local attacker = battle.Participants[attackerIndex]
	if not attacker or attacker.HP <= 0 then
		return nil
	end
	
	-- Find valid target (first alive participant that's not attacker)
	local targetIndex = 0
	for i, participant in ipairs(battle.Participants) do
		if i ~= attackerIndex and participant.HP > 0 then
			targetIndex = i
			break
		end
	end
	
	if targetIndex == 0 then
		-- Only attacker remains, they win
		return attacker
	end
	
	local defender = battle.Participants[targetIndex]
	
	-- Calculate damage
	local damage = calculateDamage(attacker, defender)
	defender.HP = math.max(0, defender.HP - damage)
	
	-- Log the action
	local action = attacker.SlimeName .. " attacks " .. defender.SlimeName .. " for " .. damage .. " damage!"
	table.insert(battle.Log, action)
	
	-- Check if defender is defeated
	if defender.HP <= 0 then
		local defeatMsg = defender.SlimeName .. " has been defeated!"
		table.insert(battle.Log, defeatMsg)
	end
	
	return defender
end

-- Check for battle end
local function checkBattleEnd(battle: BattleState): string?
	local aliveCount = 0
	local lastAlive: string? = nil
	
	for _, participant in ipairs(battle.Participants) do
		if participant.HP > 0 then
			aliveCount += 1
			lastAlive = participant.InstanceId
		end
	end
	
	if aliveCount <= 1 then
		return lastAlive
	end
	
	return nil
end

function BattleService:KnitStart()
	print("[BattleService] Started.")
end

-- Start a battle for a quest slot
function BattleService:StartBattle(questId: string, slotId: string, participants: { BattleParticipant }): BattleState
	local battleId = game:GetService("HttpService"):GenerateGUID(false)
	
	-- Initialize HP for all participants
	for _, participant in ipairs(participants) do
		participant.MaxHP = calculateHP(participant.Stats)
		participant.HP = participant.MaxHP
	end
	
	-- Determine turn order
	local turnOrder = determineTurnOrder(participants)
	
	local battle: BattleState = {
		BattleId = battleId,
		QuestId = questId,
		SlotId = slotId,
		Participants = participants,
		Status = "InProgress",
		Turn = 1,
		CurrentTurn = turnOrder[1],
		Log = { "Battle started for quest slot!" },
		Winner = nil,
	}
	
	activeBattles[battleId] = battle
	
	-- Notify clients
	self.Client.BattleStarted:FireAll(battle)
	print("[BattleService] Battle started: " .. battleId .. " with " .. #participants .. " participants")
	
	-- Start the battle loop
	task.spawn(function()
		self:ProcessBattle(battleId)
	end)
	
	return battle
end

-- Process a battle to completion
function BattleService:ProcessBattle(battleId: string)
	local battle = activeBattles[battleId]
	if not battle then return end
	
	while battle.Status == "InProgress" do
		-- Get current attacker
		local attackerIndex = battle.CurrentTurn
		local attacker = battle.Participants[attackerIndex]
		
		-- Skip if attacker is defeated
		if not attacker or attacker.HP <= 0 then
			-- Move to next participant
			local nextIndex = (attackerIndex % #battle.Participants) + 1
			battle.CurrentTurn = nextIndex
			continue
		end
		
		-- Process turn
		processTurn(battle, attackerIndex)
		
		-- Notify of turn
		self.Client.BattleTurn:FireAll(battle)
		
		-- Check for battle end
		local winner = checkBattleEnd(battle)
		if winner then
			battle.Status = "Completed"
			battle.Winner = winner
			
			-- Find winner's name
			for _, p in ipairs(battle.Participants) do
				if p.InstanceId == winner then
					table.insert(battle.Log, p.SlimeName .. " wins the battle!")
					break
				end
			end
			
			break
		end
		
		-- Move to next turn
		local nextTurnIndex = (attackerIndex % #battle.Participants) + 1
		battle.CurrentTurn = nextTurnIndex
		
		-- Increment turn counter every full round
		if nextTurnIndex == 1 then
			battle.Turn += 1
		end
		
		-- Small delay between turns for effect
		task.wait(1)
	end
	
	-- Notify battle ended
	self.Client.BattleEnded:FireAll(battle)
	print("[BattleService] Battle ended: " .. battleId .. " Winner: " .. (battle.Winner or "None"))
end

-- Get battle state
function BattleService:GetBattle(battleId: string): BattleState?
	return activeBattles[battleId]
end

-- Client: Execute an action in battle
function BattleService.Client:ExecuteAction(player: Player, battleId: string, action: "Attack" | "Defend" | "Special")
	-- For turn-based combat, we can extend this
	-- For now, auto-battle is default
	return { Success = true, Message = "Action queued" }
end

-- Get battle log
function BattleService:GetBattleLog(battleId: string): { string }
	local battle = activeBattles[battleId]
	if not battle then return {} end
	return battle.Log
end

-- Clean up completed battles
function BattleService:CleanupBattle(battleId: string)
	task.delay(60, function()
		activeBattles[battleId] = nil
	end)
end

-- Helper to create battle participants from slime data
function BattleService:CreateParticipant(playerId: string, instanceId: string, slimeName: string, stats: { [string]: number }, element: string, role: string, rarity: string): BattleParticipant
	return {
		PlayerId = playerId,
		InstanceId = instanceId,
		SlimeName = slimeName,
		HP = calculateHP(stats),
		MaxHP = calculateHP(stats),
		Stats = stats,
		Element = element,
		Role = role,
		Rarity = rarity,
	}
end

return BattleService
