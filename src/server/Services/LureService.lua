--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local SynonymDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SynonymDatabase"))
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
    local isMatch = SynonymDatabase.IsSynonym(targetTerm, usedWord)
    
    if isMatch then
        -- Capture Success!
        local LogosService = Knit.GetService("LogosService")
        local SpawnerService = Knit.GetService("SpawnerService")
        
        -- Add word to player's collection
        LogosService.CollectWord(player, targetTerm)
        
        -- Remove from wild spawns
        SpawnerService:CaptureSlime(player, targetTerm)
        
        -- Calculate XP bonus based on difficulty
        local difficulty = SynonymDatabase.GetDifficulty(targetTerm) or 1
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
        
        local element = SynonymDatabase.GetElement(targetTerm) or "Normal"
        local emoji = GameConfig.Elements[element] and GameConfig.Elements[element].Emoji or "✨"
        
        print(string.format("[LureService] %s captured %s! (+%d XP)", player.Name, targetTerm, xpGained))
        
        return { 
            Success = true, 
            Message = string.format("%s Captured %s!", emoji, targetTerm),
            XP = xpGained,
            Element = element
        }
    else
        -- Check if it was an antonym (critical fail)
        local entry = SynonymDatabase[targetTerm:lower()]
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
    local choices, hasCorrect = SynonymDatabase.GetLureChoices(term, GameConfig.LURE_CHOICES)
    return choices, hasCorrect
end

-- Server-side spawn trigger (called by SpawnerService or admin)
function LureService:SpawnWildSlime(term: string, position: Vector3, element: string?)
    local id = HttpService:GenerateGUID(false)
    local wordElement = element or SynonymDatabase.GetElement(term) or "Normal"
    
    self.Client.SlimeSpawned:FireAll(id, term, position, wordElement)
    print("[LureService] Broadcast spawn: " .. term .. " (" .. wordElement .. ")")
    
    return id
end

-- Get word info for UI
function LureService.Client:GetWordInfo(player: Player, term: string)
    local entry = SynonymDatabase[term:lower()]
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