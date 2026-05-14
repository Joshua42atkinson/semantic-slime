--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local SoloPlayService = Knit.CreateService {
	Name = "SoloPlayService",
	Client = {
		ModeChanged = Knit.CreateSignal(),
		BotPlayerSpawned = Knit.CreateSignal(),
	},
}

-- Types
export type BotPlayer = {
	BotId: string,
	Name: string,
	Level: number,
	Difficulty: "Easy" | "Medium" | "Hard",
	Behavior: "Helper" | "Challenger" | "Companion",
	Personality: string,
}

-- Configuration
local BOT_PERSONALITIES = {
	{
		Name = "Wordy",
		Personality = "helpful",
		Greeting = "Hey there! Let's learn together!",
		Encouragement = "Great job! You're doing amazing!",
	},
	{
		Name = "Sage",
		Personality = "wise",
		Greeting = "Greetings, fellow word seeker.",
		Encouragement = "Knowledge is power. Keep learning!",
	},
	{
		Name = "Spark",
		Personality = "energetic",
		Greeting = "WOW! This is gonna be FUN!",
		Encouragement = "FAST! Go even FASTER!",
	},
	{
		Name = "Chill",
		Personality = "calm",
		Greeting = "Nice to meet you. Let's take our time.",
		Encouragement = "No rush. You've got this.",
	},
}

-- Private state
local soloPlayers: { [Player]: { mode: string, bots: { BotPlayer } } } = {}
local isSoloModeEnabled = false

-- [SOLO-001] Enable solo mode for player
function SoloPlayService:EnableSoloMode(player: Player): boolean
	if soloPlayers[player] then
		return false -- Already in solo mode
	end
	
	soloPlayers[player] = {
		mode = "solo",
		bots = {},
	}
	
	isSoloModeEnabled = true
	self.Client.ModeChanged:Fire(player, "solo")
	print("[SoloPlayService] Enabled solo mode for " .. player.Name)
	
	return true
end

-- [SOLO-002] Disable solo mode
function SoloPlayService:DisableSoloMode(player: Player): boolean
	if not soloPlayers[player] then
		return false
	end
	
	soloPlayers[player] = nil
	self.Client.ModeChanged:Fire(player, "multiplayer")
	print("[SoloPlayService] Disabled solo mode for " .. player.Name)
	
	return true
end

-- [SOLO-003] Add AI companion bot
function SoloPlayService:AddCompanionBot(player: Player, personalityIndex: number): BotPlayer?
	if not soloPlayers[player] then
		return nil
	end
	
	local personality = BOT_PERSONALITIES[math.min(personalityIndex, #BOT_PERSONALITIES)]
	if not personality then
		personality = BOT_PERSONALITIES[1]
	end
	
	local bot: BotPlayer = {
		BotId = tostring(os.time()) .. "_" .. player.UserId,
		Name = personality.Name,
		Level = 1,
		Difficulty = "Medium",
		Behavior = "Companion",
		Personality = personality.Personality,
	}
	
	table.insert(soloPlayers[player].bots, bot)
	
	self.Client.BotPlayerSpawned:Fire(player, bot)
	print("[SoloPlayService] Added companion bot " .. bot.Name .. " for " .. player.Name)
	
	return bot
end

-- [SOLO-004] Remove bot
function SoloPlayService:RemoveBot(player: Player, botId: string): boolean
	if not soloPlayers[player] then
		return false
	end
	
	for i, bot in ipairs(soloPlayers[player].bots) do
		if bot.BotId == botId then
			table.remove(soloPlayers[player].bots, i)
			return true
		end
	end
	
	return false
end

-- [SOLO-005] Get player's bots
function SoloPlayService:GetPlayerBots(player: Player): { BotPlayer }
	if soloPlayers[player] then
		return soloPlayers[player].bots
	end
	return {}
end

-- [SOLO-006] Check if in solo mode
function SoloPlayService:IsSoloMode(player: Player): boolean
	return soloPlayers[player] ~= nil
end

-- [SOLO-007] Bot AI response for quests
function SoloPlayService:GetBotResponse(player: Player, context: string): string
	if not soloPlayers[player] or #soloPlayers[player].bots == 0 then
		return ""
	end
	
	local bot = soloPlayers[player].bots[1]
	
	-- Find personality
	local personality
	for _, p in ipairs(BOT_PERSONALITIES) do
		if p.Name == bot.Name then
			personality = p
			break
		end
	end
	
	if not personality then
		personality = BOT_PERSONALITIES[1]
	end
	
	-- Generate response based on context
	if context == "greeting" then
		return personality.Greeting
	elseif context == "encouragement" then
		return personality.Encouragement
	elseif context == "help" then
		if personality.Personality == "helpful" then
			return "Need help? Try combining words with suffixes!"
		elseif personality.Personality == "wise" then
			return "Consider the etymology. What is the root?"
		elseif personality.Personality == "energetic" then
			return "JUST DO IT! Add -ing to that word!"
		else
			return "Take your time. You'll figure it out."
		end
	end
	
	return "Let's keep learning!"
end

-- [SOLO-008] Bot helps with quest
function SoloPlayService:BotAssistQuest(player: Player): string?
	if not soloPlayers[player] or #soloPlayers[player].bots == 0 then
		return nil
	end
	
	local bot = soloPlayers[player].bots[1]
	
	-- Return a hint
	local hints = {
		"Try adding a suffix like -s or -ed",
		"Think about the root of the word",
		"Maybe try combining two words",
		"Consider using a prefix like un- or re-",
	}
	
	return bot.Name .. " suggests: " .. hints[math.random(1, #hints)]
end

-- [SOLO-009] Get solo mode status
function SoloPlayService:GetSoloModeStatus(): boolean
	return isSoloModeEnabled
end

function SoloPlayService:KnitStart()
	print("[SoloPlayService] Started.")
end

return SoloPlayService
