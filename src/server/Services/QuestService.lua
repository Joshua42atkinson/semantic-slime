--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Types
export type StepState = {
    Id: string,
    Description: string, -- Added for UI
    IsComplete: boolean,
    Progress: number,
    Target: number
}

export type QuestState = {
    Id: string,
    Name: string, -- Added for UI
    Description: string, -- Added for UI
    IsActive: boolean,
    IsCompleted: boolean,
    Steps: { [string]: StepState }
}

export type PlayerData = {
    Quests: { [string]: QuestState },
    Inventory: { [string]: boolean } -- Added Inventory
}

-- Quest Definitions (Static + Dynamic cache)
local QuestDefinitions: { [string]: any } = {
    -- Starter Quest
    ["quest_starter"] = {
        Id = "quest_starter",
        Name = "First Words",
        Description = "Begin your journey by capturing your first Etymon in the wild.",
        Steps = {
            { Id = "step_1", Type = "Collect", TargetId = "any", Amount = 1, Description = "Capture your first word creature" }
        },
        Rewards = { xp = 25, insight = 5 }
    },
    -- Tutorial Quest
    ["quest_tutorial"] = {
        Id = "quest_tutorial",
        Name = "The Archivist's Request",
        Description = "The Archive needs help cataloging new words. Find and capture 3 Etymons.",
        Steps = {
            { Id = "step_1", Type = "Collect", TargetId = "any", Amount = 3, Description = "Capture 3 word creatures" }
        },
        Rewards = { xp = 50, insight = 10 }
    }
}

-- Use the same activePlayerData cache reference, but populated by DataService
local activePlayerData = {} 

local QuestService = Knit.CreateService {
    Name = "QuestService",
    Client = {
        QuestEvent = Knit.CreateSignal(),
        QuestLogUpdated = Knit.CreateSignal(),
    },
}

function QuestService:KnitStart()
    print("[QuestService] Starting...")
    
    -- Get services through Knit at runtime to avoid circular dependencies
    local DataService = Knit.GetService("DataService")
    local LogosService = Knit.GetService("LogosService")
    
    -- Connect to DataService data loaded signal
    DataService.Client.DataLoaded:Connect(function(player, data)
        activePlayerData[player] = data -- Direct reference
        print("[QuestService] Linked data for " .. player.Name)
        
        -- If first time (no quests), offer starter quest
        if not next(data.Quests) then
            print("No active quests. Ready for input.")
            -- Auto-offer starter quest
            task.wait(2) -- Brief delay for player to settle
            self:AcceptQuest(player, "quest_starter")
        else
            -- Restore active quests UI
            task.wait(1)
            for _, quest in pairs(data.Quests) do
                if quest.IsActive then
                    print("Restoring quest: " .. quest.Id)
                    -- Re-send quest to client
                    self:updateClientQuestLog(player)
                end
            end
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        activePlayerData[player] = nil
    end)

    -- Listen to LogosService events
    LogosService:GetWordCollectedEvent():Connect(function(player, word, instance)
        self:CheckWordObjective(player, word)
    end)
    
    print("[QuestService] Started successfully.")
end

-- ... (Existing AcceptQuest/CompleteStep)


-- Helper to convert AI JSON to internal Quest Definition
local function convertAIQuestToDefinition(questData: any): any
    local steps = {}
    if questData.objectives then
        for i, obj in ipairs(questData.objectives) do
            table.insert(steps, {
                Id = obj.id or ("step_" .. i),
                Type = (obj.type == "talk" and "interact") or "Collect", -- Map to internal types
                TargetId = obj.target or "any",
                Amount = 1, -- Default
                Description = obj.text or "Unknown Objective"
            })
        end
    end

    return {
        Id = "dynamic_" .. HttpService:GenerateGUID(false),
        Name = questData.title or "Unknown Quest",
        Description = questData.description or "...",
        Steps = steps,
        Rewards = questData.rewards or {xp = 10, insight = 0}
    }
end

function QuestService:GenerateDynamicQuest(player: Player)
    local AIService = Knit.GetService("AIService")
    local DataService = Knit.GetService("DataService")
    
    local profile = DataService:GetProfile(player)
    
    -- Async call to AI
    task.spawn(function()
        print("[QuestService] Asking AI for a quest for " .. player.Name)
        local aiData = AIService:GenerateQuest(profile)
        
        if aiData then
            local def = convertAIQuestToDefinition(aiData)
            
            -- Store definition temporarily (or in a dynamic cache)
            QuestDefinitions[def.Id] = def 
            
            self:AcceptQuest(player, def.Id)
        else
            warn("[QuestService] AI failed to generate quest.")
        end
    end)
end

function QuestService:AcceptQuest(player: Player, questId: string)
    local data = activePlayerData[player]
    if not data then return end
    
    if data.Quests[questId] then return end -- Already accepted
    
    local def = QuestDefinitions[questId]
    if not def then warn("Quest definition NOT found for " .. questId) return end
    
    local steps = {}
    for _, step in ipairs(def.Steps) do
        steps[step.Id] = {
            Id = step.Id,
            Description = step.Description or "Complete objective",
            IsComplete = false,
            Progress = 0,
            Target = step.Amount or 1
        }
    end
    
    local questState: QuestState = {
        Id = questId,
        Name = def.Name,
        Description = def.Description,
        IsActive = true,
        IsCompleted = false,
        Steps = steps
    }
    
    -- Use DataService to update source of truth
    local DataService = Knit.GetService("DataService")
    DataService:UpdateQuest(player, questId, questState)
    
    print(player.Name .. " accepted quest: " .. def.Name)
    
    -- UI Update
    self:updateClientQuestLog(player)
    self:FireQuestEvent(player, "Accept", questId)
end

function QuestService:CompleteStep(player: Player, questId: string, stepId: string)
    local data = activePlayerData[player]
    if not data then return end 
    
    local quest = data.Quests[questId]
    if not quest or not quest.IsActive then return end
    
    local step = quest.Steps[stepId]
    if not step or step.IsComplete then return end
    
    step.IsComplete = true
    step.Progress = step.Target
    print(player.Name .. " completed step: " .. stepId)
    
    -- Update DataService
    local DataService = Knit.GetService("DataService")
    DataService:UpdateQuest(player, questId, quest)
    
    -- Check Quest Completion
    local allComplete = true
    for _, s in pairs(quest.Steps) do
        if not s.IsComplete then 
            allComplete = false 
            break 
        end
    end
    
    if allComplete then
        self:CompleteQuest(player, questId)
    else
        self:updateClientQuestLog(player)
    end
end

function QuestService:CompleteQuest(player: Player, questId: string)
    local data = activePlayerData[player]
    if not data then return end
    
    local quest = data.Quests[questId]
    if not quest then return end
    
    quest.IsActive = false
    quest.IsCompleted = true
    
    local DataService = Knit.GetService("DataService")
    DataService:UpdateQuest(player, questId, quest)
    
    local def = QuestDefinitions[questId]
    print(player.Name .. " COMPLETED QUEST: " .. (def and def.Name or "Unknown"))
    
    -- Rewards
    if def and def.Rewards then
         local profile = DataService:GetProfile(player)
         if profile and profile.Stats then
             -- Grant Insight
             if def.Rewards.insight then
                 local amount = tonumber(def.Rewards.insight) or 0
                 profile.Stats.Insight = (profile.Stats.Insight or 0) + amount
                 print("Granted " .. amount .. " Insight to " .. player.Name)
             end
             
             -- Grant XP (Global Player XP, not word XP)
             if def.Rewards.xp then
                 local amount = tonumber(def.Rewards.xp) or 0
                 profile.XP = (profile.XP or 0) + amount
                 print("Granted " .. amount .. " XP to " .. player.Name)
             end
             
             -- Notify Client of Stat update
             DataService.Client.DataUpdated:Fire(player, "Stats", profile.Stats)
         end
    end
    
    self:updateClientQuestLog(player)
    self:FireQuestEvent(player, "Complete", questId)
    
    -- TRIGGER REFLECTION
    self:StartReflection(player, questId)
end

function QuestService:StartReflection(player: Player, questId: string)
    print("Starting Reflection for " .. player.Name)
    local AIService = Knit.GetService("AIService")
    
    task.spawn(function()
        local reflectionPrompt = "The hero has just completed the quest '" .. questId .. "'. Ask them a Socratic question about their journey."
        local reflectionText = AIService:Chat("Mentor", reflectionPrompt)
        
        -- Store in Journal
        local DataService = Knit.GetService("DataService")
        DataService:AddJournalEntry(player, {
            Entry = reflectionText,
            Type = "Reflection",
            RelatedQuest = questId
        })
        
        print("Mentor says: " .. reflectionText)
    end)
end

function QuestService:FireQuestEvent(player: Player, eventType: string, questId: string)
    -- Use Knit signal instead of remote
    self.Client.QuestEvent:Fire(player, eventType, questId)
end

function QuestService:updateClientQuestLog(player: Player)
    -- Use Knit signal instead of remote
    if activePlayerData[player] then
        self.Client.QuestLogUpdated:Fire(player, activePlayerData[player].Quests)
    end
end

function QuestService:CheckWordObjective(player: Player, wordId: string)
    local data = activePlayerData[player]
    if not data then return end

    for _, quest in pairs(data.Quests) do
        if quest.IsActive and not quest.IsCompleted then
            local def = QuestDefinitions[quest.Id]
            if not def then continue end
            
            for stepId, step in pairs(quest.Steps) do
                -- Find definition for this step
                local stepDef = nil
                for _, s in ipairs(def.Steps) do
                    if s.Id == stepId then stepDef = s break end
                end

                if stepDef and stepDef.Type == "Collect" and not step.IsComplete then
                    if stepDef.TargetId == "any" or stepDef.TargetId == wordId then
                        self:CompleteStep(player, quest.Id, stepId)
                    end
                end
            end
        end
    end
end

return QuestService
