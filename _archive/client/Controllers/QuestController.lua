--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local QuestController = {}
QuestController.__index = QuestController

-- State
local activeQuests = {}

-- UI
local QuestLog = require(script.Parent.Parent.UI.QuestLog)
local NotificationController = require(script.Parent.NotificationController)
local questContainer = nil

-- Handlers

local function onQuestUpdated(questData)
    print("Quest Updated:", questData)
    activeQuests[questData.Id] = questData
    if questContainer then
        QuestLog.UpdateQuest(questContainer, questData)
    end
    NotificationController.ShowToast("Quest Updated: " .. (questData.Title or "Objective"), "📜")
end

local function onQuestCompleted(questId, rewards)
    print("Quest Completed:", questId, rewards)
    activeQuests[questId] = nil
    NotificationController.ShowCelebration("QUEST COMPLETE!", "You are a Word Master!")
end

local function onItemCollected(wordId)
    NotificationController.ShowToast("Collected: " .. wordId, "🎒", Color3.fromHex("#10B981"))
end

-- Public API

function QuestController.Start()
    questContainer = QuestLog.Create()
    
    -- Connect quest remotes (with timeouts)
    local QuestRemotes = ReplicatedStorage:WaitForChild("QuestRemotes", 10)
    if QuestRemotes then
        local QuestUpdated = QuestRemotes:FindFirstChild("QuestUpdated")
        local QuestCompleted = QuestRemotes:FindFirstChild("QuestCompleted")
        if QuestUpdated then QuestUpdated.OnClientEvent:Connect(onQuestUpdated) end
        if QuestCompleted then QuestCompleted.OnClientEvent:Connect(onQuestCompleted) end
    else
        warn("[QuestController] QuestRemotes not found — quest updates disabled")
    end
    
    -- Item collection (via Shared.Remotes)
    local remotesMod = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Remotes")
    local RemotesCommon = (remotesMod and remotesMod:IsA("ModuleScript")) and require(remotesMod) or nil
    if RemotesCommon then
        local ItemCollected = RemotesCommon:FindFirstChild("ItemCollected")
        if ItemCollected then
            ItemCollected.OnClientEvent:Connect(onItemCollected)
        end
    end
    
    print("QuestController started.")
end

return QuestController
