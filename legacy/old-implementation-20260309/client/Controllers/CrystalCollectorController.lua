--!strict
-- Crystal Collection Controller
-- Handles crystal collection UI, visual feedback, and player interactions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CrystalCollectorController = Knit.CreateController { Name = "CrystalCollectorController" }

-- Configuration
local COLLECTION_RANGE = 25
local AUTO_COLLECT_RANGE = 5
local VISUAL_EFFECT_DURATION = 2
local COLLECTION_COOLDOWN = 0.5

-- State
local isEnabled = false
local lastCollectionTime = 0
local nearbyCrystals = {}
local collectionEffects = {}
local soundEffects = {}

-- UI References
local screenGui: ScreenGui? = nil
local collectionIndicator: Frame? = nil
local rangeIndicator: Frame? = nil

-- Services
local CrystalService: any = nil
local GameLoopService: any = nil

-- Sound effects setup
local function setupSoundEffects()
	soundEffects.collect = Instance.new("Sound")
	soundEffects.collect.SoundId = "rbxassetid://6788484923" -- Crystal collect sound
	soundEffects.collect.Volume = 0.5
	soundEffects.collect.Pitch = 1.2
	
	soundEffects.nearby = Instance.new("Sound")
	soundEffects.nearby.SoundId = "rbxassetid://6788484923" -- Same sound, lower pitch
	soundEffects.nearby.Volume = 0.3
	soundEffects.nearby.Pitch = 0.8
	
	soundEffects.error = Instance.new("Sound")
	soundEffects.error.SoundId = "rbxassetid://6788484923" -- Error sound
	soundEffects.error.Volume = 0.4
	soundEffects.error.Pitch = 0.6
end

-- UI Construction
local function buildUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Main GUI container
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CrystalCollector"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	-- Collection range indicator (shows when crystals are nearby)
	rangeIndicator = Instance.new("Frame")
	rangeIndicator.Name = "RangeIndicator"
	rangeIndicator.Size = UDim2.fromOffset(200, 4)
	rangeIndicator.Position = UDim2.new(0.5, -100, 0.9, -50)
	rangeIndicator.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	rangeIndicator.BorderSizePixel = 0
	rangeIndicator.BackgroundTransparency = 1
	rangeIndicator.Parent = screenGui
	
	local rangeCorner = Instance.new("UICorner")
	rangeCorner.CornerRadius = UDim.new(0, 2)
	rangeCorner.Parent = rangeIndicator
	
	-- Collection feedback indicator
	collectionIndicator = Instance.new("Frame")
	collectionIndicator.Name = "CollectionIndicator"
	collectionIndicator.Size = UDim2.fromOffset(300, 60)
	collectionIndicator.Position = UDim2.new(0.5, -150, 0.8, -30)
	collectionIndicator.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
	collectionIndicator.BorderSizePixel = 0
	collectionIndicator.BackgroundTransparency = 1
	collectionIndicator.Parent = screenGui
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 12)
	indicatorCorner.Parent = collectionIndicator
	
	local indicatorLabel = Instance.new("TextLabel")
	indicatorLabel.Name = "Label"
	indicatorLabel.Size = UDim2.fromScale(1, 1)
	indicatorLabel.BackgroundTransparency = 1
	indicatorLabel.TextColor3 = Color3.new(1, 1, 1)
	indicatorLabel.Font = Enum.Font.GothamBold
	indicatorLabel.TextSize = 18
	indicatorLabel.Text = ""
	indicatorLabel.Parent = collectionIndicator
end

-- Visual effects
local function createCollectionEffect(position: Vector3, rarity: string)
	local effect = Instance.new("Part")
	effect.Name = "CollectionEffect"
	effect.Size = Vector3.new(1, 1, 1)
	effect.Shape = Enum.PartType.Ball
	effect.Material = Enum.Material.Neon
	effect.Anchored = true
	effect.CanCollide = false
	effect.Position = position
	
	-- Color based on rarity
	local colors = {
		Common = Color3.fromRGB(180, 180, 180),
		Uncommon = Color3.fromRGB(34, 197, 94),
		Rare = Color3.fromRGB(59, 130, 246),
		Epic = Color3.fromRGB(168, 85, 247),
		Legendary = Color3.fromRGB(234, 179, 8)
	}
	effect.Color = colors[rarity] or colors.Common
	
	-- Add light
	local light = Instance.new("PointLight")
	light.Color = effect.Color
	light.Brightness = 5
	light.Range = 10
	light.Parent = effect
	
	-- Add particles
	local attachment = Instance.new("Attachment")
	attachment.Parent = effect
	
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(effect.Color)
	particles.Transparency = NumberSequence.new(0, 1)
	particles.Size = NumberSequence.new(1, 0)
	particles.Rate = 50
	particles.Lifetime = NumberRange.new(0.5, 1.5)
	particles.Speed = NumberRange.new(1, 5)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = attachment
	
	effect.Parent = workspace
	
	-- Animate and cleanup
	local tween = TweenService:Create(effect, TweenInfo.new(VISUAL_EFFECT_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(10, 10, 10),
		Transparency = 1
	})
	
	tween:Play()
	tween.Completed:Connect(function()
		effect:Destroy()
	end)
	
	return effect
end

-- Show collection feedback
local function showCollectionFeedback(letter: string, rarity: string)
	if not collectionIndicator or not collectionIndicator.Parent then return end
	
	local label = collectionIndicator:FindFirstChild("Label")
	if label then
		label.Text = "Collected " .. letter .. " (" .. rarity .. ")!"
	end
	
	-- Fade in
	local fadeIn = TweenService:Create(collectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2
	})
	fadeIn:Play()
	
	-- Fade out after delay
	task.delay(1.5, function()
		if collectionIndicator and collectionIndicator.Parent then
			local fadeOut = TweenService:Create(collectionIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			})
			fadeOut:Play()
		end
	end)
end

-- Show nearby indicator
local function showNearbyIndicator(crystalCount: number)
	if not rangeIndicator or not rangeIndicator.Parent then return end
	
	if crystalCount > 0 then
		-- Fade in and scale based on count
		local scale = math.min(crystalCount * 0.2, 1)
		local fadeIn = TweenService:Create(rangeIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.3,
			Size = UDim2.fromOffset(200 * scale, 4)
		})
		fadeIn:Play()
	else
		-- Fade out
		local fadeOut = TweenService:Create(rangeIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
		fadeOut:Play()
	end
end

-- Crystal detection
local function updateNearbyCrystals()
	local player = Players.LocalPlayer
	if not player or not player.Character or not player.Character.PrimaryPart then
		nearbyCrystals = {}
		return
	end
	
	local playerPos = player.Character.PrimaryPart.Position
	local newNearbyCrystals = {}
	
	-- Check all crystals in workspace
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name:match("^Crystal_") and obj:IsA("Model") then
			local crystalPart = obj:FindFirstChild("CrystalPart")
			if crystalPart then
				local distance = (playerPos - crystalPart.Position).Magnitude
				if distance <= COLLECTION_RANGE then
					table.insert(newNearbyCrystals, {
						Model = obj,
						Part = crystalPart,
						Distance = distance,
						Letter = obj:FindFirstChild("LetterLabel") and obj.LetterLabel.Text or "?",
						Rarity = "Common" -- Would need to be stored somewhere
					})
				end
			end
		end
	end
	
	nearbyCrystals = newNearbyCrystals
	showNearbyIndicator(#nearbyCrystals)
end

-- Auto-collection
local function attemptAutoCollection()
	local player = Players.LocalPlayer
	if not player or not player.Character or not player.Character.PrimaryPart then return end
	
	local playerPos = player.Character.PrimaryPart.Position
	local currentTime = tick()
	
	if currentTime - lastCollectionTime < COLLECTION_COOLDOWN then return end
	
	for _, crystal in ipairs(nearbyCrystals) do
		if crystal.Distance <= AUTO_COLLECT_RANGE then
			-- Try to collect the crystal
			local success, result = pcall(function()
				return CrystalService:CollectCrystal(player, crystal.Model.Name)
			end)
			
			if success and result then
				lastCollectionTime = currentTime
				
				-- Play sound
				if soundEffects.collect then
					soundEffects.collect:Play()
				end
				
				-- Visual effect
				createCollectionEffect(crystal.Part.Position, crystal.Rarity)
				
				-- UI feedback
				showCollectionFeedback(crystal.Letter, crystal.Rarity)
				
				print("[CrystalCollectorController] Auto-collected:", crystal.Letter)
				break -- Only collect one crystal per frame
			else
				if soundEffects.error then
					soundEffects.error:Play()
				end
			end
		end
	end
end

-- Manual collection
local function attemptCollection(targetCrystal: Model?)
	local player = Players.LocalPlayer
	if not player or not player.Character or not player.Character.PrimaryPart then return end
	
	local currentTime = tick()
	if currentTime - lastCollectionTime < COLLECTION_COOLDOWN then return end
	
	local crystalToCollect = targetCrystal
	
	-- If no target, find nearest crystal
	if not crystalToCollect then
		local playerPos = player.Character.PrimaryPart.Position
		local nearestDistance = COLLECTION_RANGE + 1
		local nearestCrystal = nil
		
		for _, crystal in ipairs(nearbyCrystals) do
			if crystal.Distance < nearestDistance then
				nearestDistance = crystal.Distance
				nearestCrystal = crystal.Model
			end
		end
		
		crystalToCollect = nearestCrystal
	end
	
	if crystalToCollect then
		local success, result = pcall(function()
			return CrystalService:CollectCrystal(player, crystalToCollect.Name)
		end)
		
		if success and result then
			lastCollectionTime = currentTime
			
			-- Play sound
			if soundEffects.collect then
				soundEffects.collect:Play()
			end
			
			-- Visual effect
			local crystalPart = crystalToCollect:FindFirstChild("CrystalPart")
			if crystalPart then
				createCollectionEffect(crystalPart.Position, result.Rarity or "Common")
			end
			
			-- UI feedback
			showCollectionFeedback(result.Letter or "?", result.Rarity or "Common")
			
			print("[CrystalCollectorController] Manually collected:", result.Letter)
		else
			if soundEffects.error then
				soundEffects.error:Play()
			end
			warn("[CrystalCollectorController] Collection failed:", result)
		end
	end
end

-- Input handling
local function onInputBegan(input, gameProcessed)
	if gameProcessed or not isEnabled then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		attemptCollection()
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.E then
			attemptCollection()
		end
	end
end

-- Service connections
local function connectToServices()
	-- Get CrystalService
	local success, service = pcall(function()
		return Knit.GetService("CrystalService")
	end)
	
	if success and service then
		CrystalService = service
		
		-- Connect to crystal events
		CrystalService.CrystalCollected:Connect(function(letter, rarity)
			print("[CrystalCollectorController] Crystal collected:", letter, rarity)
		end)
		
		CrystalService.CrystalSpawned:Connect(function(crystalId, letter, position, rarity)
			print("[CrystalCollectorController] Crystal spawned:", letter)
		end)
	else
		warn("[CrystalCollectorController] CrystalService not available")
	end
	
	-- Get GameLoopService
	local success, service = pcall(function()
		return Knit.GetService("GameLoopService")
	end)
	
	if success and service then
		GameLoopService = service
		
		-- Listen for phase changes
		GameLoopService.PhaseChanged:Connect(function(phase)
			isEnabled = (phase == "Collection")
			if not isEnabled then
				-- Hide UI when not in collection phase
				if rangeIndicator then
					rangeIndicator.BackgroundTransparency = 1
				end
			end
		end)
	else
		warn("[CrystalCollectorController] GameLoopService not available")
	end
end

-- Controller lifecycle
function CrystalCollectorController:KnitStart()
	print("[CrystalCollectorController] Starting...")
	
	-- Setup
	setupSoundEffects()
	buildUI()
	connectToServices()
	
	-- Start detection loop
	task.spawn(function()
		while true do
			if isEnabled then
				updateNearbyCrystals()
				attemptAutoCollection()
			end
			task.wait(0.1) -- Check 10 times per second
		end
	end)
	
	-- Connect input
	UserInputService.InputBegan:Connect(onInputBegan)
	
	print("[CrystalCollectorController] Started.")
end

function CrystalCollectorController:KnitStop()
	isEnabled = false
	
	-- Cleanup UI
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
	
	-- Cleanup effects
	for _, effect in pairs(collectionEffects) do
		if effect and effect.Parent then
			effect:Destroy()
		end
	end
	collectionEffects = {}
	
	print("[CrystalCollectorController] Stopped.")
end

-- Public methods
function CrystalCollectorController:SetEnabled(enabled: boolean)
	isEnabled = enabled
	if not enabled and rangeIndicator then
		rangeIndicator.BackgroundTransparency = 1
	end
end

function CrystalCollectorController:GetNearbyCrystalCount(): number
	return #nearbyCrystals
end

return CrystalCollectorController
