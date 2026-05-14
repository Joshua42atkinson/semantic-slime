--!strict
-- LightingService.lua
-- Sets up and manages the world's lighting, atmosphere, and post-processing.
-- Creates a "Ghibli-warm" look: luminous, saturated, inviting.
-- Called by Boot and GameLoopService for phase transitions.

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LightingService = Knit.CreateService {
	Name = "LightingService",
	Client = {
		PhaseChanged = Knit.CreateSignal(), -- fires to all clients on phase change
	},
}

-- ============================================================
-- PHASE DEFINITIONS
-- Each phase has a full lighting snapshot the world tweens to.
-- ============================================================
local PHASES = {
	Dawn = {
		ClockTime       = 6.5,
		Brightness      = 1.4,
		Ambient         = Color3.fromRGB(80, 55, 40),    -- Warm but dim rose
		OutdoorAmbient  = Color3.fromRGB(100, 70, 50),
		FogColor        = Color3.fromRGB(220, 170, 130),
		FogEnd          = 1200,
		AtmosphereColor = Color3.fromRGB(220, 160, 100),
		AtmosphereHaze  = 1.2,
		AtmosphereGlare = 0.3,
		BloomIntensity  = 0.25,
		BloomThreshold  = 0.97,
		SaturationTweak = 0.12,
	},
	Day = {
		ClockTime       = 12.0,
		Brightness      = 1.8,
		Ambient         = Color3.fromRGB(70, 90, 110),
		OutdoorAmbient  = Color3.fromRGB(90, 120, 150),
		FogColor        = Color3.fromRGB(180, 210, 240),
		FogEnd          = 2000,
		AtmosphereColor = Color3.fromRGB(120, 180, 240),
		AtmosphereHaze  = 0.4,
		AtmosphereGlare = 0.1,
		BloomIntensity  = 0.15,
		BloomThreshold  = 0.98,
		SaturationTweak = 0.18,
	},
	Dusk = {
		ClockTime       = 18.5,
		Brightness      = 1.2,
		Ambient         = Color3.fromRGB(100, 55, 40),
		OutdoorAmbient  = Color3.fromRGB(120, 65, 45),
		FogColor        = Color3.fromRGB(180, 100, 80),
		FogEnd          = 900,
		AtmosphereColor = Color3.fromRGB(230, 110, 60),
		AtmosphereHaze  = 1.5,
		AtmosphereGlare = 0.4,
		BloomIntensity  = 0.3,
		BloomThreshold  = 0.93,
		SaturationTweak = 0.08,
	},
	Night = {
		ClockTime       = 22.0,
		Brightness      = 0.6,
		Ambient         = Color3.fromRGB(20, 28, 50),
		OutdoorAmbient  = Color3.fromRGB(15, 22, 40),
		FogColor        = Color3.fromRGB(10, 15, 35),
		FogEnd          = 600,
		AtmosphereColor = Color3.fromRGB(30, 50, 100),
		AtmosphereHaze  = 0.8,
		AtmosphereGlare = 0.1,
		BloomIntensity  = 0.5,
		BloomThreshold  = 0.85,
		SaturationTweak = -0.05,
	},
}

-- ============================================================
-- Post-processing instances (created once, tweened later)
-- ============================================================
local bloom: BloomEffect
local colorCorrect: ColorCorrectionEffect
local blur: BlurEffect
local atmosphere: Atmosphere

local function getOrCreate(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	return inst
end

local function buildPostProcessing()
	-- Bloom — glowing crystals and neon props should sparkle, NOT wash out the scene
	bloom = getOrCreate(Lighting, "BloomEffect", "WorldBloom") :: BloomEffect
	bloom.Size       = 10   -- was 24 — that's basically a fullscreen white flash
	bloom.Intensity  = 0.2
	bloom.Threshold  = 0.97 -- only very bright neon parts bloom

	-- Subtle blur (0 by default — only used for cinematic moments via tween)
	blur = getOrCreate(Lighting, "BlurEffect", "DepthBlur") :: BlurEffect
	blur.Size = 0

	-- Color correction — subtle warmth, NOT brightness boost
	colorCorrect = getOrCreate(Lighting, "ColorCorrectionEffect", "WorldColor") :: ColorCorrectionEffect
	colorCorrect.Brightness  = 0       -- was 0.02 which stacks and whitens
	colorCorrect.Contrast    = 0.04
	colorCorrect.Saturation  = 0.12
	colorCorrect.TintColor   = Color3.fromRGB(255, 248, 235)

	-- Atmosphere — depth haze. Density kept low so colors stay visible.
	atmosphere = getOrCreate(Lighting, "Atmosphere", "WorldAtmosphere") :: Atmosphere
	atmosphere.Density      = 0.25  -- was 0.35 — too thick = washed colours
	atmosphere.Offset       = 0.20
	atmosphere.Color        = Color3.fromRGB(160, 190, 230)
	atmosphere.Decay        = Color3.fromRGB(80, 100, 150)
	atmosphere.Glare        = 0.1   -- was 0.15
	atmosphere.Haze         = 0.5   -- was 0.8

	print("[LightingService] Post-processing effects built.")
end

-- Tween to a named phase
function LightingService:SetPhase(phaseName: string)
	local phase = PHASES[phaseName]
	if not phase then
		warn("[LightingService] Unknown phase: " .. phaseName)
		return
	end

	local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Tween core Lighting properties
	TweenService:Create(Lighting, tweenInfo, {
		ClockTime      = phase.ClockTime,
		Brightness     = phase.Brightness,
		Ambient        = phase.Ambient,
		OutdoorAmbient = phase.OutdoorAmbient,
		FogColor       = phase.FogColor,
		FogEnd         = phase.FogEnd,
	}):Play()

	-- Tween Atmosphere
	if atmosphere then
		TweenService:Create(atmosphere, tweenInfo, {
			Color = phase.AtmosphereColor,
			Haze  = phase.AtmosphereHaze,
			Glare = phase.AtmosphereGlare,
		}):Play()
	end

	-- Tween Bloom
	if bloom then
		TweenService:Create(bloom, tweenInfo, {
			Intensity  = phase.BloomIntensity,
			Threshold  = phase.BloomThreshold,
		}):Play()
	end

	-- Tween Color Correction
	if colorCorrect then
		TweenService:Create(colorCorrect, tweenInfo, {
			Saturation = phase.SaturationTweak,
		}):Play()
	end

	-- Notify clients (HUD splash, etc.)
	self.Client.PhaseChanged:FireAll(phaseName)

	print("[LightingService] Transitioning to phase: " .. phaseName)
end

function LightingService:KnitStart()
	buildPostProcessing()

	-- Safe, un-washed startup defaults (corrected from 0-255 mistake)
	Lighting.ClockTime      = 7
	Lighting.Brightness     = 1.4
	Lighting.Ambient        = Color3.fromRGB(80, 55, 40)
	Lighting.OutdoorAmbient = Color3.fromRGB(100, 70, 50)
	Lighting.FogColor       = Color3.fromRGB(220, 170, 130)
	Lighting.FogEnd         = 1200
	Lighting.FogStart       = 0
	Lighting.GeographicLatitude = 45
	Lighting.ShadowSoftness = 0.25

	print("[LightingService] World lit. Ghibli mode: ON. (No whitewash edition)")
end

return LightingService
