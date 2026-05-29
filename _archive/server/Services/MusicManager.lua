--!strict
-- Music Manager Service for Semantic Slime
-- Creates psychological safety and self-efficiency through district-specific music

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local MusicManager = Knit.CreateService {
    Name = "MusicManager",
    Client = {
        TrackChanged = Knit.CreateSignal(),
        PlaylistUpdated = Knit.CreateSignal(),
        VolumeAdjusted = Knit.CreateSignal(),
        DistrictChanged = Knit.CreateSignal(),
        TimeOfDayChanged = Knit.CreateSignal(),
    },
}

-- Types
export type MusicTrack = {
    Id: string,
    Name: string,
    AssetId: string,
    Duration: number,
    District: string,
    TimeOfDay: string?,
    Mood: string,
    Tempo: number,
    Volume: number,
    FadeIn: number,
    FadeOut: number,
}

export type Playlist = {
    Id: string,
    Name: string,
    District: string,
    Tracks: {MusicTrack},
    CurrentTrack: number,
    IsPlaying: boolean,
    Volume: number,
    CrossfadeDuration: number,
}

export type PlayerMusicPreferences = {
    MasterVolume: number,
    DistrictVolume: {[string]: number},
    TimeOfDayEnabled: boolean,
    CrossfadeEnabled: boolean,
    FavoriteTracks: {string},
    CustomPlaylists: {Playlist},
}

-- Configuration
local DEFAULT_VOLUME = 0.4
local CROSSFADE_DURATION = 3.0
local DISTRICT_DETECTION_RANGE = 100
local TIME_OF_DAY_CHECK_INTERVAL = 60 -- seconds

-- District musical themes based on Technical Bible
local DISTRICT_THEMES = {
    ["Town Square"] = {
        Mood = "Welcoming, peaceful, folk-inspired",
        Tempo = {80, 120},
        Instruments = {"acoustic_guitar", "flute", "light_percussion"},
        Description = "Home base - comforting and safe"
    },
    ["Scholar's District"] = {
        Mood = "Intellectual, classical, inspiring",
        Tempo = {60, 100},
        Instruments = {"piano", "strings", "harp"},
        Description = "Learning environment - focused and uplifting"
    },
    ["Merchant's Quarter"] = {
        Mood = "Playful, mysterious, rhythmic",
        Tempo = {100, 140},
        Instruments = {"lute", "drums", "bells"},
        Description = "Trading hub - energetic and engaging"
    },
    ["Artisan's Alley"] = {
        Mood = "Creative, artistic, uplifting",
        Tempo = {90, 130},
        Instruments = {"violin", "harp", "woodwinds"},
        Description = "Creation space - inspiring and joyful"
    },
    ["Guardian's Gate"] = {
        Mood = "Epic, adventurous, motivating",
        Tempo = {120, 160},
        Instruments = {"brass", "percussion", "choir"},
        Description = "Challenge area - heroic and energizing"
    },
    ["Shadow Spire"] = {
        Mood = "Mysterious, contemplative, deep",
        Tempo = {50, 90},
        Instruments = {"cello", "bass", "ambient"},
        Description = "Mystery zone - thoughtful and intriguing"
    },
    ["Herald's Heights"] = {
        Mood = "Celebratory, triumphant, grand",
        Tempo = {100, 150},
        Instruments = {"full_orchestra", "choir", "brass"},
        Description = "Achievement area - triumphant and grand"
    }
}

-- Time of day variations
local TIME_OF_DAY_MODIFIERS = {
    ["Dawn"] = {
        VolumeMultiplier = 0.7,
        TempoMultiplier = 0.9,
        Mood = "Gentle awakening"
    },
    ["Morning"] = {
        VolumeMultiplier = 0.9,
        TempoMultiplier = 1.0,
        Mood = "Fresh and energized"
    },
    ["Afternoon"] = {
        VolumeMultiplier = 1.0,
        TempoMultiplier = 1.0,
        Mood = "Peak activity"
    },
    ["Evening"] = {
        VolumeMultiplier = 0.8,
        TempoMultiplier = 0.95,
        Mood = "Winding down"
    },
    ["Night"] = {
        VolumeMultiplier = 0.6,
        TempoMultiplier = 0.85,
        Mood = "Restful and peaceful"
    }
}

-- Private state
local activePlaylists: {[string]: Playlist} = {}
local playerPreferences: {[number]: PlayerMusicPreferences} = {}
local currentDistricts: {[number]: string} = {}
local musicObjects: {[string]: Sound} = {}
local districtZones: {[string]: {Position: Vector3, Radius: number}} = {}

-- Initialize district zones (would be loaded from game world data)
local function initializeDistrictZones()
    districtZones = {
        ["Town Square"] = {Position = Vector3.new(0, 10, 0), Radius = 80},
        ["Scholar's District"] = {Position = Vector3.new(100, 10, 0), Radius = 60},
        ["Merchant's Quarter"] = {Position = Vector3.new(0, 10, 100), Radius = 70},
        ["Artisan's Alley"] = {Position = Vector3.new(-100, 10, 0), Radius = 60},
        ["Guardian's Gate"] = {Position = Vector3.new(0, 10, -100), Radius = 80},
        ["Shadow Spire"] = {Position = Vector3.new(150, 10, 150), Radius = 50},
        ["Herald's Heights"] = {Position = Vector3.new(-150, 10, -150), Radius = 60}
    }
end

-- Create default playlists for each district
local function createDefaultPlaylists()
    for districtName, theme in pairs(DISTRICT_THEMES) do
        local playlist: Playlist = {
            Id = HttpService:GenerateGUID(false),
            Name = districtName .. " Theme",
            District = districtName,
            Tracks = {},
            CurrentTrack = 1,
            IsPlaying = false,
            Volume = DEFAULT_VOLUME,
            CrossfadeDuration = CROSSFADE_DURATION,
        }
        
        -- Generate tracks based on theme (in production, these would be real audio assets)
        for i = 1, 20 do -- 20 tracks per district as planned
            local track: MusicTrack = {
                Id = HttpService:GenerateGUID(false),
                Name = districtName .. " Track " .. i,
                AssetId = "rbxassetid://6788484923", -- Placeholder asset ID
                Duration = 120 + (i * 10), -- Varying durations
                District = districtName,
                Mood = theme.Mood,
                Tempo = theme.Tempo[1] + (i % (theme.Tempo[2] - theme.Tempo[1] + 1)),
                Volume = DEFAULT_VOLUME,
                FadeIn = 2.0,
                FadeOut = 3.0,
            }
            
            table.insert(playlist.Tracks, track)
        end
        
        activePlaylists[districtName] = playlist
    end
end

-- Get player's current district based on position
local function getPlayerDistrict(player: Player): string?
    local character = player.Character
    if not character or not character.PrimaryPart then return nil end
    
    local playerPos = character.PrimaryPart.Position
    
    for districtName, zone in pairs(districtZones) do
        local distance = (playerPos - zone.Position).Magnitude
        if distance <= zone.Radius then
            return districtName
        end
    end
    
    return nil
end

-- Get current time of day
local function getTimeOfDay(): string
    local currentTime = os.date("*t")
    local hour = currentTime.hour
    
    if hour >= 5 and hour < 8 then
        return "Dawn"
    elseif hour >= 8 and hour < 12 then
        return "Morning"
    elseif hour >= 12 and hour < 17 then
        return "Afternoon"
    elseif hour >= 17 and hour < 20 then
        return "Evening"
    else
        return "Night"
    end
end

-- Apply time of day modifications to track
local function applyTimeOfDayModifications(track: MusicTrack, timeOfDay: string): MusicTrack
    local modifier = TIME_OF_DAY_MODIFIERS[timeOfDay]
    if not modifier then return track end
    
    local modifiedTrack = table.clone(track)
    modifiedTrack.Volume = track.Volume * modifier.VolumeMultiplier
    modifiedTrack.Tempo = math.floor(track.Tempo * modifier.TempoMultiplier)
    
    return modifiedTrack
end

-- Crossfade between tracks
local function crossfadeTracks(oldSound: Sound?, newSound: Sound, duration: number)
    if oldSound and oldSound.IsPlaying then
        -- Fade out old track
        local fadeOutTween = game:GetService("TweenService"):Create(
            oldSound,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Volume = 0}
        )
        fadeOutTween:Play()
        
        fadeOutTween.Completed:Connect(function()
            oldSound:Stop()
        end)
    end
    
    -- Fade in new track
    newSound.Volume = 0
    newSound:Play()
    
    local fadeInTween = game:GetService("TweenService"):Create(
        newSound,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Volume = newSound.Volume}
    )
    fadeInTween:Play()
end

-- Play track for player
local function playTrackForPlayer(player: Player, track: MusicTrack, district: string)
    local preferences = playerPreferences[player.UserId]
    if not preferences then return end
    
    -- Apply volume preferences
    local finalVolume = track.Volume * preferences.MasterVolume
    local districtVolume = preferences.DistrictVolume[district] or 1.0
    finalVolume = finalVolume * districtVolume
    
    -- Apply time of day modifications if enabled
    local timeOfDay = getTimeOfDay()
    if preferences.TimeOfDayEnabled then
        track = applyTimeOfDayModifications(track, timeOfDay)
    end
    
    -- Create or get sound object
    local soundKey = player.UserId .. "_" .. track.Id
    local sound = musicObjects[soundKey]
    
    if not sound then
        sound = Instance.new("Sound")
        sound.SoundId = track.AssetId
        sound.Looped = false
        sound.Parent = SoundService
        musicObjects[soundKey] = sound
    end
    
    -- Set sound properties
    sound.Volume = finalVolume
    sound.TimePosition = 0
    
    -- Get current playing sound for crossfade
    local currentSoundKey = player.UserId .. "_current"
    local currentSound = musicObjects[currentSoundKey]
    
    -- Play with crossfade if enabled
    if preferences.CrossfadeEnabled and currentSound then
        crossfadeTracks(currentSound, sound, track.CrossfadeDuration or CROSSFADE_DURATION)
    else
        if currentSound then
            currentSound:Stop()
        end
        sound:Play()
    end
    
    -- Update current sound reference
    musicObjects[currentSoundKey] = sound
    
    -- Notify client
    MusicManager.Client.TrackChanged:Fire(player, track, district, timeOfDay)
end

-- Start playlist for player in district
local function startPlaylistForPlayer(player: Player, district: string)
    local playlist = activePlaylists[district]
    if not playlist or #playlist.Tracks == 0 then return end
    
    local preferences = playerPreferences[player.UserId]
    if not preferences then return end
    
    -- Get current track
    local track = playlist.Tracks[playlist.CurrentTrack]
    
    -- Play track
    playTrackForPlayer(player, track, district)
    
    -- Set up track completion handler
    local soundKey = player.UserId .. "_" .. track.Id
    local sound = musicObjects[soundKey]
    
    if sound then
        sound.Ended:Connect(function()
            -- Move to next track
            playlist.CurrentTrack = (playlist.CurrentTrack % #playlist.Tracks) + 1
            local nextTrack = playlist.Tracks[playlist.CurrentTrack]
            
            -- Play next track
            task.delay(1, function() -- Brief pause between tracks
                if player.Parent == Players then -- Player still in game
                    playTrackForPlayer(player, nextTrack, district)
                end
            end)
        end)
    end
    
    playlist.IsPlaying = true
end

-- Stop music for player
local function stopMusicForPlayer(player: Player)
    local currentSoundKey = player.UserId .. "_current"
    local currentSound = musicObjects[currentSoundKey]
    
    if currentSound then
        local fadeOutTween = game:GetService("TweenService"):Create(
            currentSound,
            TweenInfo.new(2.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Volume = 0}
        )
        fadeOutTween:Play()
        
        fadeOutTween.Completed:Connect(function()
            currentSound:Stop()
            musicObjects[currentSoundKey] = nil
        end)
    end
end

-- Monitor player position for district changes
local function startDistrictMonitoring(player: Player)
    local currentDistrict = nil
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player.Parent then
            connection:Disconnect()
            return
        end
        
        local newDistrict = getPlayerDistrict(player)
        
        if newDistrict ~= currentDistrict then
            local oldDistrict = currentDistrict
            currentDistrict = newDistrict
            
            if oldDistrict then
                -- Stop old district music
                stopMusicForPlayer(player)
            end
            
            if newDistrict then
                -- Start new district music
                currentDistricts[player.UserId] = newDistrict
                startPlaylistForPlayer(player, newDistrict)
                
                -- Notify client
                MusicManager.Client.DistrictChanged:Fire(player, oldDistrict, newDistrict)
            end
        end
    end)
end

-- Public methods
function MusicManager:GetPlayerPreferences(userId: number): PlayerMusicPreferences?
    return playerPreferences[userId]
end

function MusicManager:SetPlayerPreferences(userId: number, preferences: PlayerMusicPreferences)
    playerPreferences[userId] = preferences
    
    -- Apply changes if player is online
    local player = Players:GetPlayerByUserId(userId)
    if player then
        local currentDistrict = currentDistricts[userId]
        if currentDistrict then
            -- Restart music with new preferences
            stopMusicForPlayer(player)
            startPlaylistForPlayer(player, currentDistrict)
        end
    end
end

function MusicManager:GetDistrictPlaylist(district: string): Playlist?
    return activePlaylists[district]
end

function MusicManager:GetAllPlaylists(): {[string]: Playlist}
    return activePlaylists
end

function MusicManager:CreateCustomPlaylist(userId: number, playlist: Playlist): boolean
    local preferences = playerPreferences[userId]
    if not preferences then return false end
    
    -- Validate playlist
    if not playlist.Name or #playlist.Tracks == 0 then
        return false
    end
    
    -- Add to custom playlists
    table.insert(preferences.CustomPlaylists, playlist)
    
    return true
end

function MusicManager:PlayCustomTrack(player: Player, track: MusicTrack)
    playTrackForPlayer(player, track, "Custom")
end

function MusicManager:SetMasterVolume(userId: number, volume: number)
    local preferences = playerPreferences[userId]
    if not preferences then return end
    
    preferences.MasterVolume = math.clamp(volume, 0, 1)
    
    -- Apply to current playing music
    local currentDistrict = currentDistricts[userId]
    if currentDistrict then
        local playlist = activePlaylists[currentDistrict]
        if playlist and playlist.IsPlaying then
            local track = playlist.Tracks[playlist.CurrentTrack]
            if track then
                playTrackForPlayer(player, track, currentDistrict)
            end
        end
    end
    
    -- Notify client
    self.Client.VolumeAdjusted:Fire(player, "Master", preferences.MasterVolume)
end

function MusicManager:SetDistrictVolume(userId: number, district: string, volume: number)
    local preferences = playerPreferences[userId]
    if not preferences then return end
    
    preferences.DistrictVolume[district] = math.clamp(volume, 0, 1)
    
    -- Apply if currently in this district
    if currentDistricts[userId] == district then
        local playlist = activePlaylists[district]
        if playlist and playlist.IsPlaying then
            local track = playlist.Tracks[playlist.CurrentTrack]
            if track then
                playTrackForPlayer(player, track, district)
            end
        end
    end
    
    -- Notify client
    self.Client.VolumeAdjusted:Fire(player, district, preferences.DistrictVolume[district])
end

-- Service lifecycle
function MusicManager:KnitStart()
    print("[MusicManager] Starting music system for psychological safety...")
    
    -- Initialize systems
    initializeDistrictZones()
    createDefaultPlaylists()
    
    -- Set up player joining
    Players.PlayerAdded:Connect(function(player)
        -- Create default preferences
        playerPreferences[player.UserId] = {
            MasterVolume = DEFAULT_VOLUME,
            DistrictVolume = {},
            TimeOfDayEnabled = true,
            CrossfadeEnabled = true,
            FavoriteTracks = {},
            CustomPlaylists = {},
        }
        
        -- Start district monitoring
        task.delay(1, function()
            startDistrictMonitoring(player)
        end)
    end)
    
    -- Set up player leaving
    Players.PlayerRemoving:Connect(function(player)
        -- Stop music
        stopMusicForPlayer(player)
        
        -- Clean up data
        currentDistricts[player.UserId] = nil
        playerPreferences[player.UserId] = nil
        
        -- Clean up music objects
        for key, sound in pairs(musicObjects) do
            if key:find(tostring(player.UserId)) then
                sound:Destroy()
                musicObjects[key] = nil
            end
        end
    end)
    
    -- Set up time of day monitoring
    task.spawn(function()
        local lastTimeOfDay = getTimeOfDay()
        
        while true do
            task.wait(TIME_OF_DAY_CHECK_INTERVAL)
            
            local currentTimeOfDay = getTimeOfDay()
            if currentTimeOfDay ~= lastTimeOfDay then
                lastTimeOfDay = currentTimeOfDay
                
                -- Notify all players with time-of-day enabled
                for userId, preferences in pairs(playerPreferences) do
                    if preferences.TimeOfDayEnabled then
                        local player = Players:GetPlayerByUserId(userId)
                        if player and currentDistricts[userId] then
                            local district = currentDistricts[userId]
                            local playlist = activePlaylists[district]
                            if playlist and playlist.IsPlaying then
                                local track = playlist.Tracks[playlist.CurrentTrack]
                                if track then
                                    playTrackForPlayer(player, track, district)
                                end
                            end
                            
                            MusicManager.Client.TimeOfDayChanged:Fire(player, currentTimeOfDay)
                        end
                    end
                end
            end
        end
    end)
    
    print("[MusicManager] Music system started - Creating psychological safety through audio!")
end

function MusicManager:KnitStop()
    print("[MusicManager] Stopping music system...")
    
    -- Stop all music
    for _, player in ipairs(Players:GetPlayers()) do
        stopMusicForPlayer(player)
    end
    
    -- Clean up all music objects
    for _, sound in pairs(musicObjects) do
        sound:Destroy()
    end
    musicObjects = {}
    
    print("[MusicManager] Music system stopped.")
end

-- Client handlers
function MusicManager.Client:SetPreferences(player: Player, preferences: PlayerMusicPreferences)
    return self:SetPlayerPreferences(player.UserId, preferences)
end

function MusicManager.Client:SetMasterVolume(player: Player, volume: number)
    return self:SetMasterVolume(player.UserId, volume)
end

function MusicManager.Client:SetDistrictVolume(player: Player, district: string, volume: number)
    return self:SetDistrictVolume(player.UserId, district, volume)
end

function MusicManager.Client:CreateCustomPlaylist(player: Player, playlist: Playlist)
    return self:CreateCustomPlaylist(player.UserId, playlist)
end

function MusicManager.Client:PlayCustomTrack(player: Player, track: MusicTrack)
    return self:PlayCustomTrack(player, track)
end

return MusicManager
