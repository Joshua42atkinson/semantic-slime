--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local SynonymDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SynonymDatabase"))

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
	IsDefending: boolean?,
	UseSpecial: boolean?,
	HasFled: boolean?,
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
	
	if attacker.UseSpecial then
		baseDamage = baseDamage * 1.5
	end
	
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
	if defender.IsDefending then
		defense = defense * 1.5
	end
	
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
	if not attacker.IsDefending then
		local damage = calculateDamage(attacker, defender)
		defender.HP = math.max(0, defender.HP - damage)
		
		-- Log the action
		local action = attacker.SlimeName .. " attacks " .. defender.SlimeName .. " for " .. damage .. " damage!"
		if attacker.UseSpecial then
			action = "🎯 CRITICAL: " .. action
		end
		table.insert(battle.Log, action)
	else
		-- Defending doesn't deal damage
		table.insert(battle.Log, attacker.SlimeName .. " solidifies its linguistic boundaries!")
	end
	
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
function BattleService:StartBattle(questId: string, slotId: string, participants: { BattleParticipant }): BattleState?
	-- Validate inputs
	if type(questId) ~= "string" or #questId == 0 then
		warn("[BattleService] Invalid questId for battle start")
		return nil
	end
	
	if type(slotId) ~= "string" or #slotId == 0 then
		warn("[BattleService] Invalid slotId for battle start")
		return nil
	end
	
	if not participants or #participants < 2 then
		warn("[BattleService] Invalid participants for battle start")
		return nil
	end
	
	local battleId
	local battleIdSuccess, battleIdResult = pcall(function()
		return game:GetService("HttpService"):GenerateGUID(false)
	end)
	
	if not battleIdSuccess then
		warn("[BattleService] Error generating battle ID:", battleIdResult)
		return nil
	end
	
	battleId = battleIdResult
	
	-- Initialize HP for all participants with error handling
	local hpInitSuccess, hpInitResult = pcall(function()
		for _, participant in ipairs(participants) do
			participant.MaxHP = calculateHP(participant.Stats)
			participant.HP = participant.MaxHP
		end
	end)
	
	if not hpInitSuccess then
		warn("[BattleService] Error initializing participant HP:", hpInitResult)
		return nil
	end
	
	-- Determine turn order with error handling
	local turnOrder
	local turnOrderSuccess, turnOrderResult = pcall(function()
		return determineTurnOrder(participants)
	end)
	
	if not turnOrderSuccess then
		warn("[BattleService] Error determining turn order:", turnOrderResult)
		return nil
	end
	
	turnOrder = turnOrderResult
	
	if not turnOrder or #turnOrder == 0 then
		warn("[BattleService] No valid turn order generated")
		return nil
	end
	
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
	local notifySuccess, notifyResult = pcall(function()
		self.Client.BattleStarted:FireAll(battle)
	end)
	
	if not notifySuccess then
		warn("[BattleService] Error notifying clients of battle start:", notifyResult)
	end
	
	print("[BattleService] Battle started: " .. battleId .. " with " .. #participants .. " participants")
	
	-- Start the battle loop
	task.spawn(function()
		local advanceSuccess, advanceResult = pcall(function()
			self:AdvanceTurn(battleId)
		end)
		
		if not advanceSuccess then
			warn("[BattleService] Error advancing battle turn:", advanceResult)
		end
	end)
	
	return battle
end

-- Advance to the next phase of the battle
function BattleService:AdvanceTurn(battleId: string)
	local battle = activeBattles[battleId]
	if not battle or battle.Status ~= "InProgress" then return end
	
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
		
		self.Client.BattleEnded:FireAll(battle)
		print("[BattleService] Battle ended: " .. battleId .. " Winner: " .. (battle.Winner or "None"))
		
		-- Achievements
		local DataService = Knit.GetService("DataService")
		if DataService then
			for _, p in ipairs(battle.Participants) do
				if p.InstanceId == winner and p.PlayerId then
					local player = Players:FindFirstChild(p.PlayerId)
					if player then
						DataService:UnlockAchievement(player, "first_battle")
						DataService:IncrementAchievementProgress(player, "battle_master_10", 1)
						
						local GameLoopService = Knit.GetService("GameLoopService")
						if GameLoopService then
							GameLoopService:IncrementProgress(player, "Combat", 1)
						end
					end
					break
				end
			end
		end
		
		return
	end

	-- Identify current attacker
	local attackerIndex = battle.CurrentTurn
	local attacker = battle.Participants[attackerIndex]
	
	-- Skip if defeated
	if not attacker or attacker.HP <= 0 then
		self:NextTurn(battleId)
		return
	end
	
	-- Determine if attacker is NPC
	local isNpc = true
	if attacker.PlayerId then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name == attacker.PlayerId then
				isNpc = false
				break
			end
		end
	end
	
	if isNpc then
		task.delay(1.5, function()
			-- NPC auto-attacks
			attacker.UseSpecial = false
			attacker.IsDefending = false
			table.insert(battle.Log, "😈 " .. attacker.SlimeName .. " unleashes a feral semantic attack!")
			processTurn(battle, attackerIndex)
			self.Client.BattleTurn:FireAll(battle)
			self:NextTurn(battleId)
		end)
	else
		-- Wait for player input (UI handled on client)
		self.Client.BattleTurn:FireAll(battle)
		
		-- Setup 15s timeout timer
		local turnObj = {}
		battleTimeouts[battleId] = turnObj
		
		task.delay(15, function()
			if battleTimeouts[battleId] == turnObj and battle.CurrentTurn == attackerIndex and battle.Status == "InProgress" then
				-- Time is up!
				table.insert(battle.Log, "⏱️ " .. attacker.SlimeName .. " hesitated and missed their opening!")
				attacker.UseSpecial = false
				attacker.IsDefending = true -- default to defensive posture
				
				self.Client.BattleTurn:FireAll(battle)
				self:NextTurn(battleId)
			end
		end)
	end
end

-- Move turn index and check if a full round passed
function BattleService:NextTurn(battleId: string)
	local battle = activeBattles[battleId]
	if not battle then return end

	-- Small delay between turns for effect
	task.wait(1.5)

	local nextTurnIndex = (battle.CurrentTurn % #battle.Participants) + 1
	battle.CurrentTurn = nextTurnIndex
	
	if nextTurnIndex == 1 then
		battle.Turn += 1
	end
	
	self:AdvanceTurn(battleId)
end

-- Get battle state
function BattleService:GetBattle(battleId: string): BattleState?
	return activeBattles[battleId]
end

-- Client: Execute an action in battle
function BattleService.Client:ExecuteAction(player: Player, battleId: string, action: "Attack" | "Defend" | "Special" | "Flee"): { Success: boolean, Message: string }
	local battle = activeBattles[battleId]
	if not battle then
		return { Success = false, Message = "Battle not found" }
	end
	
	if battle.Status ~= "InProgress" then
		return { Success = false, Message = "Battle is not in progress" }
	end
	
	-- Find the player's participant
	local participantIndex = 0
	for i, p in ipairs(battle.Participants) do
		if p.PlayerId == player.Name then
			participantIndex = i
			break
		end
	end
	
	if participantIndex == 0 then
		return { Success = false, Message = "You are not in this battle" }
	end
	
	-- Check if it's this player's turn
	if battle.CurrentTurn ~= participantIndex then
		return { Success = false, Message = "Not your turn" }
	end
	
	local participant = battle.Participants[participantIndex]
	
	-- Handle different actions
	if action == "Attack" then
		-- Standard attack - set flag and process turn
		participant.UseSpecial = false
		participant.IsDefending = false
		
	elseif action == "Defend" then
		-- Mark participant as defending (reduces next damage by 50%)
		participant.IsDefending = true
		participant.UseSpecial = false
		return { Success = true, Message = "Defending - 50% damage reduction next turn" }
		
	elseif action == "Special" then
		-- Special attack costs 20 Pathos (HP) for 1.5x damage
		if participant.HP <= 20 then
			return { Success = false, Message = "Not enough Pathos (HP) for Special attack" }
		end
		participant.HP = participant.HP - 20
		participant.UseSpecial = true
		participant.IsDefending = false
		return { Success = true, Message = "Special attack used! -20 Pathos" }
		
	elseif action == "Flee" then
		-- Fleeing forfeits the battle
		participant.HasFled = true
		return { Success = true, Message = "You fled the battle" }
	end
	
	-- Cancel the timeout timer
	battleTimeouts[battleId] = nil
	
	-- Process the turn with the selected action
	processTurn(battle, participantIndex)
	self.Client.BattleTurn:FireAll(battle)
	
	-- Advance to next turn
	task.spawn(function()
		self:NextTurn(battleId)
	end)
	
	return { Success = true, Message = "Action executed: " .. action }
end

-- Client: Execute a semantic wordplay action
function BattleService.Client:ExecuteSemanticAction(player: Player, battleId: string, word: string): { Success: boolean, Message: string }
	local battle = activeBattles[battleId]
	if not battle or battle.Status ~= "InProgress" then
		return { Success = false, Message = "Battle not active" }
	end
	
	local participantIndex = 0
	for i, p in ipairs(battle.Participants) do
		if p.PlayerId == player.Name then
			participantIndex = i
			break
		end
	end
	
	if participantIndex == 0 or battle.CurrentTurn ~= participantIndex then
		return { Success = false, Message = "Wait for your turn to Rap!" }
	end
	
	local participant = battle.Participants[participantIndex]
	local wordData = SynonymDatabase[participant.SlimeName:lower()]
	
	word = word:lower():gsub("%s+", "")
	if word == "" then return { Success = false, Message = "Speak up!" } end
	
	-- Semantic Validation
	local isSynonym = wordData and table.find(wordData.Synonyms or {}, word)
	local isAntonym = wordData and table.find(wordData.Antonyms or {}, word)
	
	-- Reset modifiers flag
	participant.UseSpecial = false
	participant.IsDefending = false
	
	local successResult = false
	local successMessage = ""

	if isSynonym then
		participant.UseSpecial = true
		table.insert(battle.Log, "🎤 " .. player.Name .. " dropped a sick synonym: " .. word .. "!")
		successResult = true
		successMessage = "CRITICAL HIT! Semantic Resonance!"
		
		local DataService = Knit.GetService("DataService")
		if DataService then DataService:UnlockAchievement(player, "crit_strike") end
	elseif isAntonym then
		participant.IsDefending = true
		table.insert(battle.Log, "🛡️ " .. player.Name .. " invoked defense with an antonym: " .. word .. "!")
		successResult = true
		successMessage = "Antonym Defense Activated!"
		
		local DataService = Knit.GetService("DataService")
		if DataService then DataService:UnlockAchievement(player, "shield_block") end
	else
		-- In a real rap battle, fumbling the flow deals weak baseline damage, keeping the player alive but barely.
		table.insert(battle.Log, "❓ " .. player.Name .. " fumbled the flow with: " .. word .. "!")
		successResult = false
		successMessage = "Miss! Word is semantically weak."
	end
	
	-- Cancel the timeout timer
	battleTimeouts[battleId] = nil
	
	-- Resolve the player's turn manually now that they submitted input
	processTurn(battle, participantIndex) 
	self.Client.BattleTurn:FireAll(battle)
	
	task.spawn(function()
		self:NextTurn(battleId)
	end)
	
	return { Success = successResult, Message = successMessage }
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
