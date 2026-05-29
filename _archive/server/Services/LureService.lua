--!strict
--==============================================================
-- MMMM Context: Allows players to manipulate letter spawn rates locally. A tactical mechanic to attract specific vowel/consonant ratios.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Lazy-load SynonymDatabase to avoid +7MB memory spike at boot
-- (67,167-line / 1.5MB file — deferred until first use)
local SynonymDatabase
local function getSynonymDB()
	if not SynonymDatabase then
		SynonymDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SynonymDatabase"))
		print("[LureService] SynonymDatabase loaded on first use")
	end
	return SynonymDatabase
end
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local LureService = Knit.CreateService {
    Name = "LureService",
    Client = {
        SlimeSpawned = Knit.CreateSignal(), -- (id, term, pos, element)
        LureResult = Knit.CreateSignal(),   -- (success, message, xpGained)
    },
}

function LureService:KnitStart()
    print("[LureService] Started.")
end

-- Client Request to Lure - validates the capture attempt
function LureService.Client:AttemptLure(player: Player, targetTerm: string, usedWord: string)
	if type(targetTerm) ~= "string" or type(usedWord) ~= "string" then return { Success = false, Message = "Invalid input", XP = 0 } end
    return self.Server:ProcessLure(player, targetTerm, usedWord)
end

function LureService:ProcessLure(player: Player, targetTerm: string, usedWord: string)
    -- Validate inputs
    if not targetTerm or targetTerm == "" then
        return { Success = false, Message = "No target specified", XP = 0 }
    end
    
    -- Timeout case (empty selection)
    if not usedWord or usedWord == "" then
        return { Success = false, Message = "Time ran out! The Etymon escaped.", XP = 0 }
    end
    
    -- Check if this is a valid synonym using SynonymDatabase
    local isMatch = getSynonymDB().IsSynonym(targetTerm, usedWord)
    
    if isMatch then
        -- Capture Success!
        local LogosService = Knit.GetService("LogosService")
        local SpawnerService = Knit.GetService("SpawnerService")
        
        -- Add word to player's collection
        LogosService.CollectWord(player, targetTerm)
        
        -- Remove from wild spawns
        SpawnerService:CaptureSlime(player, targetTerm)
        
        -- Calculate XP bonus based on difficulty
        local difficulty = getSynonymDB().GetDifficulty(targetTerm) or 1
        local baseXP = 10
        local xpGained = baseXP * difficulty
        
        -- Add bonus XP to the word instance
        local inventory = LogosService.GetInventory(player)
        for instanceId, wordInstance in pairs(inventory) do
            if wordInstance.Term:lower() == targetTerm:lower() then
                LogosService.AddXP(player, instanceId, xpGained)
                break
            end
        end
        
        local element = getSynonymDB().GetElement(targetTerm) or "Normal"
        local emoji = GameConfig.Elements[element] and GameConfig.Elements[element].Emoji or "✨"
        
        print(string.format("[LureService] %s captured %s! (+%d XP)", player.Name, targetTerm, xpGained))
        
        -- Achievements
        local DataService = Knit.GetService("DataService")
        if DataService then
            DataService:UnlockAchievement(player, "first_word")
            DataService:IncrementAchievementProgress(player, "word_master_50", 1)
        end
        
        return { 
            Success = true, 
            Message = string.format("%s Captured %s!", emoji, targetTerm),
            XP = xpGained,
            Element = element
        }
    else
        -- Check if it was an antonym (critical fail)
        local entry = getSynonymDB()[targetTerm:lower()]
        local isAntonym = false
        
        if entry and entry.Antonyms then
            for _, ant in ipairs(entry.Antonyms) do
                if ant:lower() == usedWord:lower() then
                    isAntonym = true
                    break
                end
            end
        end
        
        if isAntonym then
            return { 
                Success = false, 
                Message = string.format("'%s' is the opposite! The Etymon fled in disgust.", usedWord),
                XP = 0 
            }
        else
            return { 
                Success = false, 
                Message = string.format("'%s' doesn't match. The Etymon slipped away.", usedWord),
                XP = 0 
            }
        end
    end
end

-- Get lure choices for a word (server-authoritative for anti-cheat)
function LureService.Client:GetLureChoices(player: Player, term: string)
	if type(term) ~= "string" then return {}, false end
    local choices, hasCorrect = getSynonymDB().GetLureChoices(term, GameConfig.LURE_CHOICES)
    return choices, hasCorrect
end

-- Server-side spawn trigger (called by SpawnerService or admin)
function LureService:SpawnWildSlime(term: string, position: Vector3, element: string?)
    local id = HttpService:GenerateGUID(false)
    local wordElement = element or getSynonymDB().GetElement(term) or "Normal"
    
    self.Client.SlimeSpawned:FireAll(id, term, position, wordElement)
    print("[LureService] Broadcast spawn: " .. term .. " (" .. wordElement .. ")")
    
    return id
end

-- Get word info for UI
function LureService.Client:GetWordInfo(player: Player, term: string)
	if type(term) ~= "string" then return nil end
    local entry = getSynonymDB()[term:lower()]
    if not entry then
        return nil
    end
    
    return {
        Term = term,
        Element = entry.Element,
        Difficulty = entry.Difficulty,
        HasSynonyms = entry.Synonyms and #entry.Synonyms > 0
    }
end

return LureService