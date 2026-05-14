--!strict
-- Sound Effects System for Semantic Slime
-- Centralized sound management with accessibility support

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local SoundEffects = {}

-- Configuration
local MASTER_VOLUME = 0.5
local SFX_VOLUME = 0.6
local MUSIC_VOLUME = 0.3
local UI_VOLUME = 0.4

-- Sound categories
local SoundCategories = {
    SFX = "SoundEffects",
    UI = "UserInterface",
    Music = "BackgroundMusic",
    Ambient = "AmbientSounds"
}

-- Sound library with Roblox asset IDs
local SoundLibrary = {
    -- Crystal sounds
    CrystalCollect = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.4,
        Pitch = 1.0,
        Duration = 0.5
    },
    CrystalSpawn = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.3,
        Pitch = 0.9,
        Duration = 0.4
    },
    CrystalNearby = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.2,
        Pitch = 0.8,
        Duration = 0.3
    },
    
    -- Word construction sounds
    LetterAdd = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.3,
        Pitch = 1.1,
        Duration = 0.3
    },
    WordComplete = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.5,
        Pitch = 1.3,
        Duration = 0.6
    },
    WordError = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.4,
        Pitch = 0.8,
        Duration = 0.4
    },
    SlimeCreated = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.6,
        Pitch = 1.5,
        Duration = 0.8
    },
    
    -- Quest sounds
    QuestStart = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.4,
        Pitch = 1.0,
        Duration = 0.5
    },
    QuestComplete = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.5,
        Pitch = 1.2,
        Duration = 0.7
    },
    QuestSlotFill = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.3,
        Pitch = 1.0,
        Duration = 0.3
    },
    
    -- Battle sounds
    BattleStart = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.6,
        Pitch = 1.0,
        Duration = 1.0
    },
    Attack = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.5,
        Pitch = 1.2,
        Duration = 0.4
    },
    Defend = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.4,
        Pitch = 0.8,
        Duration = 0.3
    },
    Victory = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.7,
        Pitch = 1.3,
        Duration = 1.2
    },
    Defeat = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.SFX,
        Volume = 0.5,
        Pitch = 0.7,
        Duration = 0.8
    },
    
    -- UI sounds
    UIButton = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.UI,
        Volume = 0.3,
        Pitch = 1.0,
        Duration = 0.2
    },
    UIToggle = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.UI,
        Volume = 0.2,
        Pitch = 0.9,
        Duration = 0.2
    },
    UIError = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.UI,
        Volume = 0.4,
        Pitch = 0.6,
        Duration = 0.3
    },
    UISuccess = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.UI,
        Volume = 0.4,
        Pitch = 1.1,
        Duration = 0.3
    },
    
    -- Ambient sounds
    AmbientCrystal = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.Ambient,
        Volume = 0.2,
        Pitch = 1.0,
        Duration = 2.0,
        Loop = true
    },
    AmbientNature = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.Ambient,
        Volume = 0.3,
        Pitch = 1.0,
        Duration = 5.0,
        Loop = true
    },
    
    -- Music tracks
    MenuMusic = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.Music,
        Volume = 0.3,
        Pitch = 1.0,
        Duration = 30.0,
        Loop = true
    },
    GameMusic = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.Music,
        Volume = 0.3,
        Pitch = 1.0,
        Duration = 45.0,
        Loop = true
    },
    BattleMusic = {
        Id = "rbxassetid://6788484923",
        Category = SoundCategories.Music,
        Volume = 0.4,
        Pitch = 1.0,
        Duration = 20.0,
        Loop = true
    }
}

-- Active sounds tracking
local activeSounds = {}
local ambientSounds = {}
local musicTracks = {}

-- User settings
local userSettings = {
    MasterVolume = MASTER_VOLUME,
    SFXVolume = SFX_VOLUME,
    MusicVolume = MUSIC_VOLUME,
    UIVolume = UI_VOLUME,
    Muted = false,
    AudioCues = true,
    BackgroundMusic = true,
    AmbientSounds = true
}

-- Sound pool for performance
local soundPool = {}
local POOL_SIZE = 20

-- Initialize sound pool
local function initializeSoundPool()
    for i = 1, POOL_SIZE do
        local sound = Instance.new("Sound")
        sound.Name = "PooledSound" .. i
        table.insert(soundPool, sound)
    end
end

-- Get sound from pool
local function getSoundFromPool(): Sound?
    for _, sound in ipairs(soundPool) do
        if not sound.IsPlaying then
            return sound
        end
    end
    
    -- If all sounds are playing, create a new one
    local newSound = Instance.new("Sound")
    table.insert(soundPool, newSound)
    return newSound
end

-- Return sound to pool
local function returnSoundToPool(sound: Sound)
    sound:Stop()
    sound.SoundId = ""
    sound.Volume = 0
    sound.Pitch = 1
    sound.Looped = false
end

-- Calculate final volume based on category and user settings
local function calculateFinalVolume(category: string, baseVolume: number): number
    if userSettings.Muted then
        return 0
    end
    
    local categoryVolume = 1.0
    if category == SoundCategories.SFX then
        categoryVolume = userSettings.SFXVolume
    elseif category == SoundCategories.UI then
        categoryVolume = userSettings.UIVolume
    elseif category == SoundCategories.Music then
        categoryVolume = userSettings.MusicVolume
    elseif category == SoundCategories.Ambient then
        categoryVolume = userSettings.AmbientSounds and userSettings.SFXVolume or 0
    end
    
    return baseVolume * categoryVolume * userSettings.MasterVolume
end

-- Play a sound effect
local function playSoundInternal(soundName: string, position: Vector3?, parent: Instance?)
    local soundData = SoundLibrary[soundName]
    if not soundData then
        warn("[SoundEffects] Sound not found:", soundName)
        return nil
    end
    
    -- Check if user wants this type of sound
    if soundData.Category == SoundCategories.Music and not userSettings.BackgroundMusic then
        return nil
    end
    
    if soundData.Category == SoundCategories.Ambient and not userSettings.AmbientSounds then
        return nil
    end
    
    if soundData.Category == SoundCategories.UI and not userSettings.AudioCues then
        return nil
    end
    
    -- Get sound from pool
    local sound = getSoundFromPool()
    if not sound then
        warn("[SoundEffects] No available sounds in pool")
        return nil
    end
    
    -- Configure sound
    sound.SoundId = soundData.Id
    sound.Volume = calculateFinalVolume(soundData.Category, soundData.Volume)
    sound.Pitch = soundData.Pitch
    sound.Looped = soundData.Loop or false
    
    -- Set parent (default to SoundService for 2D sounds)
    if position then
        -- 3D sound
        sound.Parent = workspace
        sound.Position = position
    else
        -- 2D sound
        sound.Parent = SoundService
    end
    
    if parent then
        sound.Parent = parent
    end
    
    -- Play the sound
    sound:Play()
    
    -- Track active sound
    local soundId = HttpService:GenerateGUID(false)
    activeSounds[soundId] = sound
    
    -- Auto-cleanup for non-looping sounds
    if not soundData.Loop then
        task.delay(soundData.Duration + 0.5, function()
            if activeSounds[soundId] then
                returnSoundToPool(sound)
                activeSounds[soundId] = nil
            end
        end)
    end
    
    return sound
end

-- Public API
function SoundEffects.Play(soundName: string, position: Vector3?): Sound?
    return playSoundInternal(soundName, position)
end

function SoundEffects.PlayOnParent(soundName: string, parent: Instance): Sound?
    return playSoundInternal(soundName, nil, parent)
end

function SoundEffects.Play3D(soundName: string, position: Vector3): Sound?
    return playSoundInternal(soundName, position)
end

function SoundEffects.Play2D(soundName: string): Sound?
    return playSoundInternal(soundName, nil)
end

-- Stop a specific sound
function SoundEffects.Stop(soundName: string)
    for soundId, sound in pairs(activeSounds) do
        if sound.SoundId == SoundLibrary[soundName].Id then
            sound:Stop()
            returnSoundToPool(sound)
            activeSounds[soundId] = nil
        end
    end
end

-- Stop all sounds
function SoundEffects.StopAll()
    for soundId, sound in pairs(activeSounds) do
        sound:Stop()
        returnSoundToPool(sound)
    end
    activeSounds = {}
    
    -- Stop ambient sounds
    for _, sound in pairs(ambientSounds) do
        sound:Stop()
        returnSoundToPool(sound)
    end
    ambientSounds = {}
    
    -- Stop music tracks
    for _, sound in pairs(musicTracks) do
        sound:Stop()
        returnSoundToPool(sound)
    end
    musicTracks = {}
end

-- Ambient sound management
function SoundEffects.PlayAmbient(soundName: string, position: Vector3?)
    local soundData = SoundLibrary[soundName]
    if not soundData or soundData.Category ~= SoundCategories.Ambient then
        warn("[SoundEffects] Invalid ambient sound:", soundName)
        return
    end
    
    if not userSettings.AmbientSounds then
        return
    end
    
    -- Stop existing ambient sound of this type
    if ambientSounds[soundName] then
        ambientSounds[soundName]:Stop()
        returnSoundToPool(ambientSounds[soundName])
    end
    
    local sound = playSoundInternal(soundName, position)
    if sound then
        ambientSounds[soundName] = sound
    end
end

function SoundEffects.StopAmbient(soundName: string)
    if ambientSounds[soundName] then
        ambientSounds[soundName]:Stop()
        returnSoundToPool(ambientSounds[soundName])
        ambientSounds[soundName] = nil
    end
end

-- Music management
function SoundEffects.PlayMusic(trackName: string)
    local soundData = SoundLibrary[trackName]
    if not soundData or soundData.Category ~= SoundCategories.Music then
        warn("[SoundEffects] Invalid music track:", trackName)
        return
    end
    
    if not userSettings.BackgroundMusic then
        return
    end
    
    -- Stop existing music
    SoundEffects.StopMusic()
    
    local sound = playSoundInternal(trackName)
    if sound then
        musicTracks[trackName] = sound
    end
end

function SoundEffects.StopMusic()
    for trackName, sound in pairs(musicTracks) do
        sound:Stop()
        returnSoundToPool(sound)
    end
    musicTracks = {}
end

-- Settings management
function SoundEffects.SetMasterVolume(volume: number)
    userSettings.MasterVolume = math.clamp(volume, 0, 1)
    SoundEffects.UpdateAllVolumes()
end

function SoundEffects.SetSFXVolume(volume: number)
    userSettings.SFXVolume = math.clamp(volume, 0, 1)
    SoundEffects.UpdateAllVolumes()
end

function SoundEffects.SetMusicVolume(volume: number)
    userSettings.MusicVolume = math.clamp(volume, 0, 1)
    SoundEffects.UpdateAllVolumes()
end

function SoundEffects.SetUIVolume(volume: number)
    userSettings.UIVolume = math.clamp(volume, 0, 1)
    SoundEffects.UpdateAllVolumes()
end

function SoundEffects.SetMuted(muted: boolean)
    userSettings.Muted = muted
    SoundEffects.UpdateAllVolumes()
end

function SoundEffects.SetAudioCues(enabled: boolean)
    userSettings.AudioCues = enabled
    
    if not enabled then
        -- Stop all UI sounds
        for soundId, sound in pairs(activeSounds) do
            local soundData = SoundLibrary[sound.Name]
            if soundData and soundData.Category == SoundCategories.UI then
                sound:Stop()
                returnSoundToPool(sound)
                activeSounds[soundId] = nil
            end
        end
    end
end

function SoundEffects.SetBackgroundMusic(enabled: boolean)
    userSettings.BackgroundMusic = enabled
    
    if not enabled then
        SoundEffects.StopMusic()
    end
end

function SoundEffects.SetAmbientSounds(enabled: boolean)
    userSettings.AmbientSounds = enabled
    
    if not enabled then
        for soundName, sound in pairs(ambientSounds) do
            sound:Stop()
            returnSoundToPool(sound)
        end
        ambientSounds = {}
    end
end

-- Update all active sounds with new volume settings
function SoundEffects.UpdateAllVolumes()
    -- Update active sounds
    for soundId, sound in pairs(activeSounds) do
        local soundData = SoundLibrary[sound.Name]
        if soundData then
            sound.Volume = calculateFinalVolume(soundData.Category, soundData.Volume)
        end
    end
    
    -- Update ambient sounds
    for soundName, sound in pairs(ambientSounds) do
        local soundData = SoundLibrary[soundName]
        if soundData then
            sound.Volume = calculateFinalVolume(soundData.Category, soundData.Volume)
        end
    end
    
    -- Update music tracks
    for trackName, sound in pairs(musicTracks) do
        local soundData = SoundLibrary[trackName]
        if soundData then
            sound.Volume = calculateFinalVolume(soundData.Category, soundData.Volume)
        end
    end
end

-- Get current settings
function SoundEffects.GetSettings(): {[string]: any}
    return {
        MasterVolume = userSettings.MasterVolume,
        SFXVolume = userSettings.SFXVolume,
        MusicVolume = userSettings.MusicVolume,
        UIVolume = userSettings.UIVolume,
        Muted = userSettings.Muted,
        AudioCues = userSettings.AudioCues,
        BackgroundMusic = userSettings.BackgroundMusic,
        AmbientSounds = userSettings.AmbientSounds
    }
end

-- Get sound library info
function SoundEffects.GetSoundLibrary(): {[string]: any}
    local library = {}
    for name, data in pairs(SoundLibrary) do
        library[name] = {
            Category = data.Category,
            Volume = data.Volume,
            Duration = data.Duration,
            Loop = data.Loop
        }
    end
    return library
end

-- Initialize
function SoundEffects.Initialize()
    print("[SoundEffects] Initializing sound effects system...")
    
    -- Initialize sound pool
    initializeSoundPool()
    
    -- Set default master volume
    SoundService.MasterVolume = MASTER_VOLUME
    
    print("[SoundEffects] Sound effects system initialized")
    print("[SoundEffects] Sound pool size:", #soundPool)
    print("[SoundEffects] Sound library size:", #SoundLibrary)
end

return SoundEffects
