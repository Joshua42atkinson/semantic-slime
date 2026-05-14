--!strict
--==============================================================
-- MMMM Context: Paints the auditory landscape of Syllable Springs. Anchors the aesthetic vibe of a haunted, living lexicon.
--==============================================================
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundController = Knit.CreateController { Name = "SoundController" }

local SOUNDS = {
    QuestAccept = "rbxassetid://156644265",
    QuestComplete = "rbxassetid://12221984", -- Victory sound
    WordCollect = "rbxassetid://4612375233",
    LevelUp = "rbxassetid://4742512169",
    UIHover = "rbxassetid://421058133",
    UIClick = "rbxassetid://421058206",
    -- Ambience
    Birds = "rbxassetid://133189953", -- Morning nature
    Crickets = "rbxassetid://135540306", -- Night crickets
    Wind = "rbxassetid://5141065181" -- General ambience
}

-- Set to true to skip all sound loading (fixes crashes on Wine/unpublished places)
local DISABLE_SOUNDS = true -- TODO: set to false once published to Roblox

function SoundController:KnitStart()
    self.Sounds = {}
    
    if DISABLE_SOUNDS then
        print("[SoundController] Sounds DISABLED for local testing. Set DISABLE_SOUNDS = false when published.")
        return
    end
    
    -- Preload and Create Sound Instances
    local soundFolder = Instance.new("Folder")
    soundFolder.Name = "GameSounds"
    soundFolder.Parent = SoundService
    
    for name, id in pairs(SOUNDS) do
        local ok, err = pcall(function()
            local sound = Instance.new("Sound")
            sound.Name = name
            sound.SoundId = id
            sound.Volume = 0.5
            sound.Parent = soundFolder
            self.Sounds[name] = sound
        end)
        if not ok then
            warn("[SoundController] Failed to create sound " .. name .. ": " .. tostring(err))
        end
    end
    
    -- Listen to Signals via Knit (wrapped in pcall for resilience)
    local ok, err = pcall(function()
        local GameLoopService = Knit.GetService("GameLoopService")
        local SlimeFactory = Knit.GetService("SlimeFactory")
        local MadLibService = Knit.GetService("MadLibService")
        
        GameLoopService.PhaseChanged:Connect(function(phase, duration)
            self:UpdateAmbience(phase)
        end)
        
        SlimeFactory.SlimeCreated:Connect(function(slime)
            self:Play("WordCollect")
        end)
        
        MadLibService.QuestGenerated:Connect(function()
            self:Play("QuestAccept")
        end)
        
        MadLibService.QuestCompleted:Connect(function()
            self:Play("QuestComplete")
        end)
    end)
    
    if not ok then
        warn("[SoundController] Failed to connect signals: " .. tostring(err))
    end
    
    print("[SoundController] Loaded with Knit Signal listeners.")
end

function SoundController:UpdateAmbience(phase: string)
    -- Reset all ambience volumes
    local sounds = { self.Sounds.Birds, self.Sounds.Crickets, self.Sounds.Wind }
    local tweenInfo = TweenInfo.new(3)
    
    for _, sound in ipairs(sounds) do
        if sound then
            if not sound.IsPlaying then sound:Play() end
            TweenService:Create(sound, tweenInfo, { Volume = 0 }):Play()
        end
    end

    -- Fade in target ambience
    local target = nil
    if phase == "Collection" then
        target = self.Sounds.Birds
    elseif phase == "Construction" then
        target = self.Sounds.Wind
    elseif phase == "Nuisance" or phase == "Quest" then
        target = self.Sounds.Crickets
    end

    if target then
        TweenService:Create(target, tweenInfo, { Volume = 0.3 }):Play()
    end
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
