--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Types
export type Word = {
    Id: string,
    Term: string,
    Definition: string,
}

local WordService = Knit.CreateService {
    Name = "WordService",
    Client = {
        WordCollected = Knit.CreateSignal(),
    },
}

-- Private
local playerWords: { [Player]: { [string]: boolean } } = {}

-- Public API

function WordService:KnitStart()
    print("[WordService] Started.")
    
    Players.PlayerAdded:Connect(function(player)
        playerWords[player] = {}
        print("[WordService] Initialized for " .. player.Name)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        playerWords[player] = nil
    end)
end

function WordService:AddWord(player: Player, wordId: string)
    if not playerWords[player] then return end
    
    if not playerWords[player][wordId] then
        playerWords[player][wordId] = true
        print(player.Name .. " collected word: " .. wordId)
        
        -- Notify client
        self.Client.WordCollected:Fire(player, wordId)
        
        -- Check for active quests that need this word
        local QuestService = Knit.GetService("QuestService")
        QuestService:CheckWordObjective(player, wordId)
    end
end

function WordService:HasWord(player: Player, wordId: string): boolean
    if not playerWords[player] then return false end
    return playerWords[player][wordId] == true
end

return WordService
