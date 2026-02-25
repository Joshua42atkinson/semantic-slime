--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local QuestController = {}
QuestController.__index = QuestController

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("QuestRemotes")
local QuestUpdated = Remotes:WaitForChild("QuestUpdated")
local QuestCompleted = Remotes:WaitForChild("QuestCompleted")

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
    
    QuestUpdated.OnClientEvent:Connect(onQuestUpdated)
    QuestCompleted.OnClientEvent:Connect(onQuestCompleted)
    
    local RemotesCommon = ReplicatedStorage:WaitForChild("Remotes")
    local ItemCollected = RemotesCommon:WaitForChild("ItemCollected", 5)
    if ItemCollected then
        ItemCollected.OnClientEvent:Connect(onItemCollected)
    end
    
    print("QuestController started.")
end

return QuestController
