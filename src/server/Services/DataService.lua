--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

--[=[
    @class DataService
    Handles all player data persistence.
    Source of Truth for: Inventory, Quests, Stats, Journal, Settings.
]=]
local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {
        DataLoaded = Knit.CreateSignal(),
        DataUpdated = Knit.CreateSignal(), -- (key, value)
    },
}

-- Config
local DATA_VERSION = "v3" -- Bumped for Full Schema
local playerDataStore = nil -- initialized in KnitStart
local AUTO_SAVE_INTERVAL = 300 -- 5 minutes
local MAX_PLAYER_LEVEL = 50 -- [PLAYER-002]
local XP_BASE = 500

-- Cache
local sessionData = {}

-- Function to Deep Copy Table
local function deepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Default Data Schema
local DEFAULT_DATA = {
    Level = 1,
    XP = 0,
    Stats = {
        Insight = 0,
        Aether = 0,
        Archetype = "Novice"
    },
    Inventory = {}, -- { [InstanceId]: WordInstance }
    Slimes = {}, -- { [InstanceId]: SlimeInstance }
    LetterInventory = {}, -- { [Letter]: Count }
    Quests = {}, -- { [QuestId]: QuestState }
    NPCProgress = {}, -- { [NPCId]: number }
    Journal = {}, -- { [Timestamp]: {Entry="Text", Type="Reflection"} }
    Achievements = {}, -- { [AchievementId]: number } (stores progress, if >= Requirement it is unlocked)
    GamePasses = {}, -- { [PassId]: boolean }
    GachaCollection = {}, -- { [InstanceId]: ImaginarySlime }
    Settings = {
        MusicVolume = 0.5,
        SFXVolume = 0.5
    },
    LinguisticLog = {
        Morphemes = {}, -- { [Morpheme]: { Pass = number, Fail = number } }
        Breadcrumbs = {}, -- { [Morpheme]: { last_used = number, mistakes = number } }
    },
}

function DataService:KnitStart()
    -- Initialize DataStore (pcall for unpublished places)
    local ok, store = pcall(function()
        return DataStoreService:GetDataStore("LexicalLegendsData_" .. DATA_VERSION)
    end)
    if ok then
        playerDataStore = store
    else
        warn("[DataService] DataStore unavailable (publish place to enable): " .. tostring(store))
    end
    
    print("[DataService] Started.")
    
    -- Event Listeners
    Players.PlayerAdded:Connect(function(player)
        self:_LoadData(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:_SaveData(player)
    end)
    
    -- Server Shutdown
    game:BindToClose(function()
        for _, player in ipairs(Players:GetPlayers()) do
            task.spawn(function()
                self:_SaveData(player)
            end)
        end
        task.wait(3)
    end)
    
    -- Auto Save Loop
    task.spawn(function()
        while true do
            task.wait(AUTO_SAVE_INTERVAL)
            for _, player in ipairs(Players:GetPlayers()) do
                self:_SaveData(player)
            end
        end
    end)
end

-- Internal Load
function DataService:_LoadData(player: Player)
    local key = "Player_" .. player.UserId
    local success, data = pcall(function()
        return playerDataStore:GetAsync(key)
    end)
    
    if success then
        data = data or deepCopy(DEFAULT_DATA)
        -- Reconciliation: Fill missing keys from default
        for k, v in pairs(DEFAULT_DATA) do
            if data[k] == nil then
                data[k] = type(v) == "table" and deepCopy(v) or v
            end
            -- Shallow merge for 2nd level tables (Stats, Settings)
            if type(v) == "table" and type(data[k]) == "table" then
                for subK, subV in pairs(v) do
                    if data[k][subK] == nil then
                        data[k][subK] = subV
                    end
                end
            end
        end
        sessionData[player] = data
        print("[DataService] Loaded data for " .. player.Name)
    else
        warn("[DataService] Failed to load data for " .. player.Name)
        sessionData[player] = deepCopy(DEFAULT_DATA) -- Fallback
    end
    
    -- Hydrate other services safely (deferred to avoid circular dependency issues at boot)
    task.defer(function()
        -- Hydrate LogosService
        local logosOk, LogosService = pcall(function() return Knit.GetService("LogosService") end)
        if logosOk and LogosService and data and data.Inventory then
            pcall(function() LogosService:LoadInventory(player, data.Inventory) end)
        end
        
        -- Hydrate SlimeFactory
        local slimeOk, SlimeFactory = pcall(function() return Knit.GetService("SlimeFactory") end)
        if slimeOk and SlimeFactory and data and data.Slimes then
            pcall(function() SlimeFactory:LoadPlayerSlimes(player, data.Slimes) end)
        end
        
        -- Hydrate WordExcavatorService
        local excavatorOk, WordExcavatorService = pcall(function() return Knit.GetService("WordExcavatorService") end)
        if excavatorOk and WordExcavatorService and data and data.GachaCollection then
            pcall(function() WordExcavatorService:LoadPlayerGachaData(player, data.GachaCollection) end)
        end
    end)
    
    -- Notify Client
    self.Client.DataLoaded:Fire(player, sessionData[player])
end

function DataService.Client:GetProfile(player: Player)
    return self.Server:GetProfile(player)
end

function DataService.Client:CompleteTutorial(player: Player)
    local profile = self.Server:GetProfile(player)
    if profile then
        profile.TutorialCompleted = true
        self.Server:UnlockAchievement(player, "complete_tutorial")
        return true
    end
    return false
end

-- Internal Save
function DataService:_SaveData(player: Player)
    local data = sessionData[player]
    if not data then return end
    
    -- Gather latest state from other services if they hold authority
    local logosOk, LogosService = pcall(function() return Knit.GetService("LogosService") end)
    if logosOk and LogosService then
        pcall(function()
            data.Inventory = LogosService:GetInventory(player)
        end)
    end
    
    local slimeOk, SlimeFactory = pcall(function() return Knit.GetService("SlimeFactory") end)
    if slimeOk and SlimeFactory then
        pcall(function()
            local currentSlimes = SlimeFactory:GetPlayerSlimes(player)
            if currentSlimes then
                data.Slimes = currentSlimes
            end
            local companion = SlimeFactory:GetCompanion(player)
            if companion then
                data.CompanionSlimeId = companion.InstanceId
            end
        end)
    end
    
    local key = "Player_" .. player.UserId
    local success, err = pcall(function()
        playerDataStore:SetAsync(key, data)
    end)
    
    if success then
        print("[DataService] Saved data for " .. player.Name)
    else
        warn("[DataService] Failed to save data for " .. player.Name .. ": " .. tostring(err))
    end
end

-- Public API
function DataService:GetProfile(player: Player)
    return sessionData[player]
end

function DataService:UpdateQuest(player: Player, questId: string, questData: any)
    local profile = self:GetProfile(player)
    if profile then
        profile.Quests[questId] = questData
        -- Replicate update to client
        self.Client.DataUpdated:Fire(player, "Quests", profile.Quests)
    end
end

function DataService:AddJournalEntry(player: Player, entry: { Entry: string, Type: string, RelatedQuest: string? })
    local profile = self:GetProfile(player)
    if profile then
        local timestamp = os.time()
        profile.Journal[tostring(timestamp)] = {
            Entry = entry.Entry,
            Type = entry.Type,
            RelatedQuest = entry.RelatedQuest,
            Timestamp = timestamp
        }
        -- Replicate update to client
        self.Client.DataUpdated:Fire(player, "Journal", profile.Journal)
        print("[DataService] Added journal entry for " .. player.Name .. ": " .. entry.Type)
        return true
    end
    return false
end

function DataService:GetJournal(player: Player)
    local profile = self:GetProfile(player)
    if profile then
        return profile.Journal
    end
    return {}
end

-- Achievements system
function DataService:IncrementAchievementProgress(player: Player, achievementId: string, amount: number)
    local profile = self:GetProfile(player)
    if profile then
        if not profile.Achievements then profile.Achievements = {} end
        
        local current = profile.Achievements[achievementId] or 0
        local AchievementData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AchievementData"))
        local data = AchievementData[achievementId]
        
        if data and current < data.Requirement then
            profile.Achievements[achievementId] = current + amount
            if profile.Achievements[achievementId] >= data.Requirement then
                profile.Achievements[achievementId] = data.Requirement
                -- Replicate achievement unlock
                self.Client.DataUpdated:Fire(player, "AchievementUnlocked", achievementId)
                print("[DataService] " .. player.Name .. " unlocked achievement: " .. data.Name)
            end
            self.Client.DataUpdated:Fire(player, "Achievements", profile.Achievements)
        end
    end
end

function DataService:UnlockAchievement(player: Player, achievementId: string)
    self:IncrementAchievementProgress(player, achievementId, 1)
end

function DataService:AddXP(player: Player, amount: number)
	local profile = self:GetProfile(player)
	if not profile then return end
	
	profile.XP = (profile.XP or 0) + amount
	
	-- Calculate level
	local currentLevel = profile.Level or 1
	if currentLevel >= MAX_PLAYER_LEVEL then
		profile.Level = MAX_PLAYER_LEVEL
		profile.XP = 0
		return
	end
	
	-- Scaling XP Needed: Base * Level
	local xpNeeded = currentLevel * XP_BASE
	while profile.XP >= xpNeeded and currentLevel < MAX_PLAYER_LEVEL do
		profile.XP -= xpNeeded
		currentLevel += 1
		xpNeeded = currentLevel * XP_BASE
		
		print("[DataService] " .. player.Name .. " LEVELED UP to " .. currentLevel)
		-- Notify client of Level Up
		self.Client.DataUpdated:Fire(player, "LevelUp", currentLevel)
	end
	
	profile.Level = currentLevel
	self.Client.DataUpdated:Fire(player, "Level", profile.Level)
	self.Client.DataUpdated:Fire(player, "XP", profile.XP)
end

function DataService:AddInsight(player: Player, amount: number)
	local profile = self:GetProfile(player)
	if not profile then return end
	
	profile.Stats.Insight = (profile.Stats.Insight or 0) + amount
	self.Client.DataUpdated:Fire(player, "Stats", profile.Stats)
end

function DataService:LogLinguisticData(player: Player, morpheme: string, success: boolean)
    local profile = self:GetProfile(player)
    if not profile then return end
    
    if not profile.LinguisticLog then
        profile.LinguisticLog = { Morphemes = {}, Breadcrumbs = {} }
    end
    
    local log = profile.LinguisticLog
    if not log.Morphemes[morpheme] then
        log.Morphemes[morpheme] = { Pass = 0, Fail = 0 }
    end
    
    if success then
        log.Morphemes[morpheme].Pass += 1
    else
        log.Morphemes[morpheme].Fail += 1
        
        -- Update Breadcrumbs for targeted review
        if not log.Breadcrumbs[morpheme] then
            log.Breadcrumbs[morpheme] = { last_used = os.time(), mistakes = 0 }
        end
        log.Breadcrumbs[morpheme].mistakes += 1
        log.Breadcrumbs[morpheme].last_used = os.time()
    end
    
    self.Client.DataUpdated:Fire(player, "LinguisticLog", log)
end

-- Bonus methods used by GameLoopService objective system
function DataService:GrantRerollToken(player: Player)
    local profile = self:GetProfile(player)
    if not profile then return end
    profile.RerollTokens = (profile.RerollTokens or 0) + 1
    print("[DataService] Granted reroll token to " .. player.Name)
end

function DataService:GrantBattleSkip(player: Player)
    local profile = self:GetProfile(player)
    if not profile then return end
    profile.BattleSkip = true
    print("[DataService] Granted battle skip to " .. player.Name)
end

function DataService:GrantDoubleRewards(player: Player)
    local profile = self:GetProfile(player)
    if not profile then return end
    profile.DoubleRewards = true
    print("[DataService] Granted double rewards to " .. player.Name)
end

return DataService
