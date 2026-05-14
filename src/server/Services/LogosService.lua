--!strict
--==============================================================
-- MMMM Context: The core isomorphism engine. Calculates physical stats from linguistic morphology, binding word meaning to mechanical power.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local EtymologyDB = require(Shared:WaitForChild("EtymologyDB"))

local WordInstanceTypes = require(Shared.Types.WordInstance)
export type WordInstance = WordInstanceTypes.WordInstance

local LogosService = Knit.CreateService {
    Name = "LogosService",
    Client = {
        WordDiscovered = Knit.CreateSignal(),
        WordXPGained = Knit.CreateSignal(),
        WordEvolved = Knit.CreateSignal(),
    },
}

-- Constants
local INITIAL_XP_REQ = 100
local EVOLUTION_LEVEL = 10

-- Private
local playerInventory: { [Player]: { [string]: WordInstance } } = {} -- Keyed by InstanceId
local wordCollectedEvent = Instance.new("BindableEvent")

-- Helper: Analyze word to find Root and Suffix (Mock for prototype)
local function analyzeWord(word: string): (string, string)
    local term = word:lower()
    local foundRoot = "Terra" 
    for root, data in pairs(EtymologyDB.Roots) do
        -- Mock logic: check if word contains root key letters
        if term:find(root:lower()) then
            foundRoot = root
            break
        end
    end
    
    local foundSuffix = "tion"
    for suffix, _ in pairs(EtymologyDB.Suffixes) do
        if term:sub(-#suffix) == suffix then
            foundSuffix = suffix
            break
        end
    end
    return foundRoot, foundSuffix
end

local function calculateStats(root: string, suffix: string, level: number): WordInstanceTypes.WordStats
    local stats = { Logos = 10, Pathos = 10, Ethos = 10, Speed = 10 }
    local rootData = EtymologyDB.Roots[root]
    local suffixData = EtymologyDB.Suffixes[suffix]
    
    -- Base Stats
    if rootData then
        if rootData.StatFocus == "Logos" then stats.Logos += 10 end
        if rootData.StatFocus == "Pathos" then stats.Pathos += 10 end
        if rootData.StatFocus == "Ethos" then stats.Ethos += 10 end
        if rootData.StatFocus == "Speed" then stats.Speed += 10 end
    end
    
    if suffixData then
        if suffixData.Role == "Tank" then stats.Ethos += 15 end
        if suffixData.Role == "Striker" then stats.Logos += 15 end
        if suffixData.Role == "Support" then stats.Pathos += 15 end
    end

    -- Level Multiplier
    local multiplier = 1 + (level - 1) * 0.1
    stats.Logos = math.floor(stats.Logos * multiplier)
    stats.Pathos = math.floor(stats.Pathos * multiplier)
    stats.Ethos = math.floor(stats.Ethos * multiplier)
    stats.Speed = math.floor(stats.Speed * multiplier)
    
    return stats
end

-- Public API

function LogosService:KnitStart()
    print("[LogosService] Started.")
    
    Players.PlayerAdded:Connect(function(player)
        if not playerInventory[player] then
             playerInventory[player] = {}
        end
        print("[LogosService] Initialized for " .. player.Name)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        playerInventory[player] = nil
    end)
end

-- Event for other services to subscribe to word collection
function LogosService:GetWordCollectedEvent()
    return wordCollectedEvent.Event
end

-- Function to mint a new word monster
function LogosService.CreateInstant(player: Player, word: string): WordInstance
    local root, suffix = analyzeWord(word)
    local rootData = EtymologyDB.Roots[root]
    local suffixData = EtymologyDB.Suffixes[suffix]
    
    local newInstance: WordInstance = {
        InstanceId = HttpService:GenerateGUID(false),
        WordId = word:lower(),
        Term = word,
        XP = 0,
        Level = 1,
        EvolutionStage = 1,
        Element = rootData and rootData.Element or "Normal",
        Role = suffixData and suffixData.Role or "Civilian",
        Stats = calculateStats(root, suffix, 1),
        History = {}
    }
    
    return newInstance
end

function LogosService:CollectWord(player: Player, word: string)
    if not playerInventory[player] then return end
    
    -- Check uniqueness? For now, allow duplicates (gotta catch 'em all style)
    -- Or maybe enforce unique per word-type? 
    -- Let's allow duplicates but maybe check if they already have *this* exact wordId for simple collection logic.
    -- For prototype, let's just add it.
    
    local newInstance = self.CreateInstant(player, word)
    playerInventory[player][newInstance.InstanceId] = newInstance
    
    print(player.Name .. " captured Word Instance: " .. word .. " [" .. newInstance.InstanceId .. "]")
    
    -- Notify other server services via BindableEvent
    wordCollectedEvent:Fire(player, word, newInstance)
    
    -- Notify client via Knit signal
    self.Client.WordDiscovered:Fire(player, newInstance)
end

function LogosService:AddXP(player: Player, instanceId: string, amount: number)
    local inv = playerInventory[player]
    if not inv or not inv[instanceId] then return end
    
    local wordInstance = inv[instanceId]
    wordInstance.XP += amount
    
    -- Check Level Up
    local xpReq = INITIAL_XP_REQ * wordInstance.Level
    if wordInstance.XP >= xpReq then
        wordInstance.XP -= xpReq
        wordInstance.Level += 1
        -- Recalculate stats
        local root, suffix = analyzeWord(wordInstance.Term)
        wordInstance.Stats = calculateStats(root, suffix, wordInstance.Level)
        
        print(wordInstance.Term .. " leveled up to " .. wordInstance.Level .. "!")
        
        -- Check Evolution
        if wordInstance.Level >= EVOLUTION_LEVEL then
             -- Trigger evolution opportunity (could be manual, but for now auto-evolve stage)
             -- self:Evolve(player, instanceId) -- Maybe keep manual
        end
    end
    
    -- Notify client via Knit signal
    self.Client.WordXPGained:Fire(player, wordInstance)
end

function LogosService:Evolve(player: Player, instanceId: string)
    local inv = playerInventory[player]
    if not inv or not inv[instanceId] then return end
    
    local wordInstance = inv[instanceId]
    if wordInstance.Level < EVOLUTION_LEVEL then 
        warn("Not high enough level to evolve.")
        return 
    end
    
    -- Verify Insight Cost
    local DataService = Knit.GetService("DataService")
    
    local profile = DataService:GetProfile(player)
    if not profile then return end
    
    local insightCost = 5
    if profile.Stats.Insight < insightCost then
        warn("Not enough Insight to evolve.")
        return
    end
    
    -- Deduct Cost
    profile.Stats.Insight -= insightCost
    -- Notify Client about Stat update
    DataService.Client.DataUpdated:Fire(player, "Stats", profile.Stats)
    
    -- Apply Evolution
    wordInstance.EvolutionStage += 1
    wordInstance.Level = 1 -- Reset level on evolution
    wordInstance.XP = 0
    
    -- Name Change Logic
    local prefixes = {"Greater", "Ascended", "Divine", "Cosmic"}
    local prefix = prefixes[math.min(wordInstance.EvolutionStage - 1, #prefixes)] or "Ultra"
    
    -- Only prepend if not already there to avoid "Greater Greater Fire"
    if not string.find(wordInstance.Term, prefix) then
         wordInstance.Term = prefix .. " " .. wordInstance.Term
    end
    
    -- Stat Boost
    local root, suffix = analyzeWord(wordInstance.Term)
    local baseStats = calculateStats(root, suffix, 1)
    
    -- Apply Multiplier based on Stage
    local stageMultiplier = 1 + (wordInstance.EvolutionStage - 1) * 0.5 -- 1.5x, 2.0x, etc.
    
    for k, v in pairs(baseStats) do
        wordInstance.Stats[k] = math.floor(v * stageMultiplier)
    end

    print(wordInstance.Term .. " Evolved to Stage " .. wordInstance.EvolutionStage .. "!")
    
    -- Notify client via Knit signal
    self.Client.WordEvolved:Fire(player, wordInstance)
end

function LogosService:GetInventory(player: Player)
    return playerInventory[player] or {}
end

-- for DataService to load data
function LogosService:LoadInventory(player: Player, data: { [string]: WordInstance })
    if data then
        playerInventory[player] = data
    else
        playerInventory[player] = {}
    end
end

return LogosService
