--!strict
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundController = Knit.CreateController { Name = "SoundController" }

local SOUNDS = {
    QuestAccept = "rbxassetid://156644265",
    QuestComplete = "rbxassetid://12221984", -- Victory sound
    WordCollect = "rbxassetid://4612375233",
    LevelUp = "rbxassetid://4742512169",
    UIHover = "rbxassetid://421058133",
    UIClick = "rbxassetid://421058206"
}

function SoundController:KnitStart()
    self.Sounds = {}
    
    -- Preload and Create Sound Instances
    local soundFolder = Instance.new("Folder")
    soundFolder.Name = "GameSounds"
    soundFolder.Parent = SoundService
    
    for name, id in pairs(SOUNDS) do
        local sound = Instance.new("Sound")
        sound.Name = name
        sound.SoundId = id
        sound.Volume = 0.5
        sound.Parent = soundFolder
        self.Sounds[name] = sound
    end
    
    -- Listen to Signals
    local DataService = Knit.GetService("DataService")
    local LogosRemotes = ReplicatedStorage:WaitForChild("LogosRemotes")
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    -- Quest Sounds
    if Remotes:FindFirstChild("QuestEvent") then
        Remotes.QuestEvent.OnClientEvent:Connect(function(eventType, questId)
            if eventType == "Accept" then
                self:Play("QuestAccept")
            elseif eventType == "Complete" then
                self:Play("QuestComplete")
            end
        end)
    end
    
    -- Using the LogosRemotes for Word Collect is easy:
    if LogosRemotes:FindFirstChild("WordDiscovered") then
        LogosRemotes.WordDiscovered.OnClientEvent:Connect(function()
            self:Play("WordCollect")
        end)
    end
    
    if LogosRemotes:FindFirstChild("WordEvolved") then
        LogosRemotes.WordEvolved.OnClientEvent:Connect(function()
            self:Play("LevelUp")
        end)
    end
    
    print("[SoundController] Loaded.")
end

function SoundController:Play(soundName: string)
    local s = self.Sounds[soundName]
    if s then
        s:Play()
    else
        warn("Sound not found: " .. soundName)
    end
end

return SoundController
