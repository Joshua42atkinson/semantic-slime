--!strict
-- SoundManager.luau
-- Central module for managing audio in Lexical Legends.
-- Handles Background Music (BGM) cross-fading and Sound Effects (SFX).

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local SoundManager = {}

-- ── Configuration ───────────────────────────────────────────────────────────

-- Standard Roblox Asset IDs (Placeholders - Replace with custom assets!)
local SOUNDS = {
	-- Music
	BGM_Town       = "rbxassetid://1837873294", -- Cheerful/Upbeat
	BGM_Forge      = "rbxassetid://1840698188", -- Industrial/Mysterious

	-- SFX
	UI_Hover       = "rbxassetid://6895079853",
	UI_Click       = "rbxassetid://6895079972",
    UI_Purchase    = "rbxassetid://6022800566", -- Cash register/Success
	ItemPickup     = "rbxassetid://12221967",   
	LevelUp        = "rbxassetid://12222253",   
	QuestComplete  = "rbxassetid://255959142",  
	
    -- Slime SFX
    SlimeJump      = "rbxassetid://2425406085", -- Boing
    SlimeAlert     = "rbxassetid://7536965851", -- Surprise/Notice
    SlimeCapture   = "rbxassetid://130768297",  -- Poof/Magic
    
	ForgeProcess   = "rbxassetid://130768297",  
	ForgeSuccess   = "rbxassetid://6022800566", 
}

SoundManager.Sounds = SOUNDS

-- ── Internal State ─────────────────────────────────────────────────────────

local currentTrack: Sound? = nil
local sfxFolder: Folder? = nil

local MusicVolume = 0.4
local SFXVolume = 0.5

function SoundManager.SetMusicVolume(vol: number)
	MusicVolume = math.clamp(vol, 0, 1)
	if currentTrack then
		TweenService:Create(currentTrack, TweenInfo.new(0.2), {Volume = MusicVolume}):Play()
	end
end

function SoundManager.SetSFXVolume(vol: number)
	SFXVolume = math.clamp(vol, 0, 1)
end

-- Ensure container exists
local function getSFXFolder()
	if sfxFolder then return sfxFolder end
	
	local f = SoundService:FindFirstChild("SFX_Container")
	if not f then
		f = Instance.new("Folder")
		f.Name = "SFX_Container"
		f.Parent = SoundService
	end
	sfxFolder = f
	return f
end

-- ── Public API ─────────────────────────────────────────────────────────────

-- Play a sound effect globally (2D)
function SoundManager.PlaySFX(soundName: string, volume: number?, pitch: number?)
	local soundId = SOUNDS[soundName]
	if not soundId then 
		warn("[SoundManager] Sound not found:", soundName)
		return 
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = (volume or 1) * SFXVolume
	sound.Pitch = pitch or 1
	sound.Parent = getSFXFolder()
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	
	sound:Play()
end

-- Play background music with cross-fade
function SoundManager.PlayMusic(soundName: string, fadeTime: number?, volume: number?)
	local soundId = SOUNDS[soundName]
	if not soundId then return end
	
	if currentTrack and currentTrack.SoundId == soundId then
		return -- Already playing
	end
	
	local targetVol = (volume or 1) * MusicVolume
	local fade = fadeTime or 1
	
	-- Fade out old
	if currentTrack then
		local old = currentTrack
		TweenService:Create(old, TweenInfo.new(fade), {Volume = 0}):Play()
		task.delay(fade, function()
			old:Destroy()
		end)
	end
	
	-- Start new
	local newTrack = Instance.new("Sound")
	newTrack.SoundId = soundId
	newTrack.Volume = 0
	newTrack.Looped = true
	newTrack.Parent = SoundService
	newTrack:Play()
	
	TweenService:Create(newTrack, TweenInfo.new(fade), {Volume = targetVol}):Play()
	currentTrack = newTrack
end

-- Create a spatial sound part (3D)
function SoundManager.CreateSpatialSound(soundName: string, parent: Instance, looped: boolean?): Sound?
	local soundId = SOUNDS[soundName]
	if not soundId then return nil end
	
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Looped = looped or false
	sound.Volume = 0.5
	sound.RollOffMaxDistance = 60
	sound.Parent = parent
	
	return sound
end

-- Preload key assets
function SoundManager.Preload()
	local assets = {}
	for _, id in pairs(SOUNDS) do
		table.insert(assets, id)
	end
	-- Note: ContentProvider:PreloadAsync accepts instances, not strings directly efficiently in all contexts,
	-- but we'll leave this for now or implement if needed. 
	-- For now, Roblox handles streaming well.
end

return SoundManager
