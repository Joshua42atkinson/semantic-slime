local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Main Remotes folder
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage:WaitForChild("Shared")

-- Game state
local GameStateChanged = Instance.new("RemoteEvent")
GameStateChanged.Name = "GameStateChanged"
GameStateChanged.Parent = Remotes

-- Word Constructor
local OpenWordConstructor = Instance.new("RemoteEvent")
OpenWordConstructor.Name = "OpenWordConstructor"
OpenWordConstructor.Parent = Remotes

-- Learning Station
local ShowLearningStation = Instance.new("RemoteEvent")
ShowLearningStation.Name = "ShowLearningStation"
ShowLearningStation.Parent = Remotes

-- Crystal Collection - RemoteFunction for picking up crystals
local CollectCrystal = Instance.new("RemoteFunction")
CollectCrystal.Name = "CollectCrystal"
CollectCrystal.Parent = Remotes

-- Player Inventory - RemoteFunction to get current letters
local GetInventory = Instance.new("RemoteFunction")
GetInventory.Name = "GetInventory"
GetInventory.Parent = Remotes

-- Use Letters for Word Construction - RemoteFunction
local UseLetters = Instance.new("RemoteFunction")
UseLetters.Name = "UseLetters"
UseLetters.Parent = Remotes

-- Can Form Word - RemoteFunction (check without using)
local CanFormWord = Instance.new("RemoteFunction")
CanFormWord.Name = "CanFormWord"
CanFormWord.Parent = Remotes

-- Crystal spawned event (for client to know where crystals are)
local CrystalSpawned = Instance.new("RemoteEvent")
CrystalSpawned.Name = "CrystalSpawned"
CrystalSpawned.Parent = Remotes

-- Crystal collected event
local CrystalCollected = Instance.new("RemoteEvent")
CrystalCollected.Name = "CrystalCollected"
CrystalCollected.Parent = Remotes

-- Slime Factory remotes
local CreateSlime = Instance.new("RemoteFunction")
CreateSlime.Name = "CreateSlime"
CreateSlime.Parent = Remotes

local GetPlayerSlimes = Instance.new("RemoteFunction")
GetPlayerSlimes.Name = "GetPlayerSlimes"
GetPlayerSlimes.Parent = Remotes

local SetCompanion = Instance.new("RemoteFunction")
SetCompanion.Name = "SetCompanion"
SetCompanion.Parent = Remotes

local GetCompanion = Instance.new("RemoteFunction")
GetCompanion.Name = "GetCompanion"
GetCompanion.Parent = Remotes

-- NPC Remotes folder (for interaction system)
local NPCRemotes = Instance.new("Folder")
NPCRemotes.Name = "NPCRemotes"
NPCRemotes.Parent = ReplicatedStorage

local Interact = Instance.new("RemoteFunction")
Interact.Name = "Interact"
Interact.Parent = NPCRemotes

local TriggerInteraction = Instance.new("RemoteEvent")
TriggerInteraction.Name = "TriggerInteraction"
TriggerInteraction.Parent = NPCRemotes

-- Quest Remotes folder (for quest system)
local QuestRemotes = Instance.new("Folder")
QuestRemotes.Name = "QuestRemotes"
QuestRemotes.Parent = ReplicatedStorage

local QuestUpdated = Instance.new("RemoteEvent")
QuestUpdated.Name = "QuestUpdated"
QuestUpdated.Parent = QuestRemotes

local QuestCompleted = Instance.new("RemoteEvent")
QuestCompleted.Name = "QuestCompleted"
QuestCompleted.Parent = QuestRemotes

-- Logos Remotes folder (for word discovery system)
local LogosRemotes = Instance.new("Folder")
LogosRemotes.Name = "LogosRemotes"
LogosRemotes.Parent = ReplicatedStorage

local WordDiscovered = Instance.new("RemoteEvent")
WordDiscovered.Name = "WordDiscovered"
WordDiscovered.Parent = LogosRemotes

return Remotes
