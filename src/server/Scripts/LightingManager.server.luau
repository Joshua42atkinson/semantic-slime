--!strict
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Setup Global Lighting
local function setupLighting()
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(50, 50, 50)
	Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
	
	-- Post Processing
	if not Lighting:FindFirstChild("Bloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "Bloom"
		bloom.Intensity = 0.4
		bloom.Size = 24
		bloom.Threshold = 0.8
		bloom.Parent = Lighting
	end
	
	if not Lighting:FindFirstChild("SunRays") then
		local rays = Instance.new("SunRaysEffect")
		rays.Name = "SunRays"
		rays.Intensity = 0.25
		rays.Parent = Lighting
	end
	
	if not Lighting:FindFirstChild("ColorCorrection") then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "ColorCorrection"
		cc.Saturation = 0.2
		cc.Contrast = 0.1
		cc.Parent = Lighting
	end
	
	if not Lighting:FindFirstChild("Atmosphere") then
		local atm = Instance.new("Atmosphere")
		atm.Name = "Atmosphere"
		atm.Density = 0.45 -- Thick air
		atm.Offset = 0
		atm.Color = Color3.fromHex("#1e1b4b") -- Indigo 950
		atm.Decay = Color3.fromHex("#312e81") -- Indigo 900
		atm.Glare = 0
		atm.Haze = 2
		atm.Parent = Lighting
	end
    
    -- Fog (Classic fallback)
    Lighting.FogColor = Color3.fromHex("#0f172a") -- Slate 900
    Lighting.FogEnd = 300 -- Close visibility
    Lighting.FogStart = 0
end

-- Static "Set and Setting" Lighting (Bright & Clear)
local function setBrightState()
    Lighting.ClockTime = 14 -- 2PM (Bright Sun)
    Lighting.Brightness = 2.5
    Lighting.GlobalShadows = true
    
    Lighting.Ambient = Color3.fromHex("#94a3b8") -- Slate 400 (Soft shadows)
    Lighting.OutdoorAmbient = Color3.fromHex("#f1f5f9") -- Slate 100 (Bright bounce)
    
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    
    -- Clear Fog
    Lighting.FogEnd = 10000 
    Lighting.FogStart = 500
    
    -- Sky Atmosphere
    local atm = Lighting:FindFirstChild("Atmosphere")
    if atm then
        atm.Density = 0.25 -- Light haze
        atm.Color = Color3.fromHex("#bae6fd") -- Sky Blue
        atm.Decay = Color3.fromHex("#f59e0b") -- Golden Decay
        atm.Glare = 0.5
        atm.Haze = 0.5
    end
end

setupLighting()
setBrightState()
print("Lighting Manager Started: Bright & Clear Mode Active.")
