--!strict
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

print("[LightingManager] Initializing...")

-- Lighting States mapping to Phases
local PHASE_LIGHTING = {
	Collection = {
		TimeOfDay = "06:30:00", -- Dawn
		Ambient = Color3.fromRGB(150, 150, 200),
		OutdoorAmbient = Color3.fromRGB(100, 100, 150),
		Brightness = 1.5,
		AtmosphereDensity = 0.3,
		AtmosphereColor = Color3.fromRGB(255, 200, 150),
	},
	Construction = {
		TimeOfDay = "10:00:00", -- Morning
		Ambient = Color3.fromRGB(200, 200, 200),
		OutdoorAmbient = Color3.fromRGB(150, 150, 150),
		Brightness = 2.5,
		AtmosphereDensity = 0.1,
		AtmosphereColor = Color3.fromRGB(255, 255, 255),
	},
	Quest = {
		TimeOfDay = "17:30:00", -- Dusk
		Ambient = Color3.fromRGB(200, 150, 100),
		OutdoorAmbient = Color3.fromRGB(150, 100, 50),
		Brightness = 2.0,
		AtmosphereDensity = 0.4,
		AtmosphereColor = Color3.fromRGB(255, 100, 50),
	},
	Rewards = {
		TimeOfDay = "20:00:00", -- Evening
		Ambient = Color3.fromRGB(50, 50, 100),
		OutdoorAmbient = Color3.fromRGB(30, 30, 70),
		Brightness = 1.0,
		AtmosphereDensity = 0.2,
		AtmosphereColor = Color3.fromRGB(100, 100, 255),
	},
	Nuisance = {
		TimeOfDay = "00:00:00", -- Midnight (eerie letter-swarm feel)
		Ambient = Color3.fromRGB(30, 30, 50),
		OutdoorAmbient = Color3.fromRGB(10, 10, 30),
		Brightness = 0.8,
		AtmosphereDensity = 0.6,
		AtmosphereColor = Color3.fromRGB(50, 50, 50),
	}
}

local function applyLighting(phaseName: string, duration: number)
	local data = PHASE_LIGHTING[phaseName]
	if not data then return end
	
	print("[LightingManager] Shifting atmosphere for: " .. phaseName)
	
	local info = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	-- Tween properties
	local goals = {
		Ambient = data.Ambient,
		OutdoorAmbient = data.OutdoorAmbient,
		Brightness = data.Brightness,
	}
	
	TweenService:Create(Lighting, info, goals):Play()
	
	-- Note: TimeOfDay is a string and cannot be tweened directly via TweenService on Lighting
	-- We use ClockTime for smooth transitions if needed, but simple set works for now
	Lighting.ClockTime = math.random() -- Just to trigger a change for now, better to map ClockTime
	
	-- Map ClockTime specifically
	local clockGoal = 6 -- Default
	if phaseName == "Collection" then clockGoal = 6.5
	elseif phaseName == "Construction" then clockGoal = 10
	elseif phaseName == "Quest" then clockGoal = 17.5
	elseif phaseName == "Rewards" then clockGoal = 20
	elseif phaseName == "Nuisance" then clockGoal = 0 end
	
	TweenService:Create(Lighting, info, { ClockTime = clockGoal }):Play()

	-- Atmosphere properties if they exist
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		TweenService:Create(atmosphere, info, {
			Density = data.AtmosphereDensity,
			Color = data.AtmosphereColor
		}):Play()
	end
end

-- Wait for Knit to be started by Boot.server.luau safely
task.spawn(function()
    Knit.OnStart():await()
    
    local ok, GameLoopService = pcall(function()
        return Knit.GetService("GameLoopService")
    end)
    
    if not ok or not GameLoopService then
        warn("[LightingManager] GameLoopService not available")
        return
    end
    
    -- Listen for phase changes
    GameLoopService.PhaseChanged:Connect(function(phase, duration)
        applyLighting(phase, duration)
    end)
    
    -- Initial state
    local state = GameLoopService:GetGameState()
    if state and state.Phase then
        applyLighting(state.Phase, 5)
    end
    
    print("[LightingManager] Active and listening for PhaseChanged.")
end)
