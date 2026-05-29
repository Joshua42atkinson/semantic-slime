--!strict
--==============================================================
-- MMMM Context: Handles the lingering trails of Slimes and spatial effects, making language tangibly stick to the environment.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LexicalEffectsDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LexicalEffectsDB"))

local OozeController = Knit.CreateController {
	Name = "OozeController",
}

-- State
local currentOozeTraits = {
	IsActive = false,
	EffectId = nil :: string?,
	EndTime = 0,
}

local originalStats = {
	WalkSpeed = 16,
	JumpPower = 50,
	Gravity = workspace.Gravity,
}

local BASE_DURATION = 3 -- seconds to linger after stepping out

function OozeController:KnitStart()
	print("[OozeController] Started. Watch your step, semantic spillage detected!")

	local player = Players.LocalPlayer
	
	-- We'll use a fast loop to check floor material / touching parts instead of .Touched
	-- .Touched is unreliable for flat ground puddles
	RunService.Heartbeat:Connect(function(dt)
		local character = player.Character
		if not character then return end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end
		
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		-- Save original stats if not buffed
		if not currentOozeTraits.IsActive then
			originalStats.WalkSpeed = humanoid.WalkSpeed
			originalStats.JumpPower = humanoid.UseJumpPower and humanoid.JumpPower or 50
		end

		-- Setup raycast downwards to detect ooze
		local rayOrigin = humanoidRootPart.Position
		local rayDirection = Vector3.new(0, -4, 0)
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Include
		
		local oozeFolder = workspace:FindFirstChild("SemanticOozeFolder")
		if oozeFolder then
			rayParams.FilterDescendantsInstances = {oozeFolder}
			
			local hit = workspace:Raycast(rayOrigin, rayDirection, rayParams)
			if hit and hit.Instance and hit.Instance:GetAttribute("IsSemanticOoze") then
				-- We are standing in ooze!
				local element = hit.Instance:GetAttribute("LexicalElement") or "Normal"
				local root = hit.Instance:GetAttribute("LexicalRoot") or "Terra"
				local role = hit.Instance:GetAttribute("LexicalRole") or "Civilian"
				
				self:ApplyOozeEffect(element, root, role, humanoid)
				
				currentOozeTraits.IsActive = true
				currentOozeTraits.EndTime = os.clock() + BASE_DURATION
			end
		end
		
		-- Check for expiration
		if currentOozeTraits.IsActive and os.clock() > currentOozeTraits.EndTime then
			self:RemoveOozeEffect(humanoid)
		end
	end)
end

function OozeController:ApplyOozeEffect(element: string, root: string, role: string, humanoid: Humanoid)
	local effectData = LexicalEffectsDB.Elements[element] or LexicalEffectsDB.Elements.Normal
	local effectType = effectData.Effect
	local effectValue = effectData.Value
	
	-- Prevent re-applying the exact same buff every frame
	if currentOozeTraits.EffectId == element .. "_" .. effectType then return end
	currentOozeTraits.EffectId = element .. "_" .. effectType
	
	-- Reset any previous effects first
	self:ResetHumanoidToNormal(humanoid)
	
	-- Apply New Effect
	if effectType == "Speed" then
		humanoid.WalkSpeed = effectValue
		print("[OozeController] Zoom! Speed ooze.")
	elseif effectType == "Sticky" then
		humanoid.WalkSpeed = effectValue
		print("[OozeController] Ew! Sticky ooze.")
	elseif effectType == "Bounce" then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = effectValue
		print("[OozeController] Boing! Bouncy ooze.")
	elseif effectType == "Floaty" then
		workspace.Gravity = effectValue
		print("[OozeController] Whoa! Floaty ooze.")
	elseif effectType == "Slippery" then
		-- Hard to do frictionless shoes locally without messing with character physics parts,
		-- but we can give them "ice skate" momentum by tweaking CustomPhysicalProperties of their feet
		for _, part in pairs(humanoid.Parent:GetChildren()) do
			if part:IsA("BasePart") then
				if not part:GetAttribute("OriginalFriction") then
					part:SetAttribute("OriginalFriction", part.CustomPhysicalProperties and part.CustomPhysicalProperties.Friction or 0.3)
				end
				local props = PhysicalProperties.new(0, 0, 0, 100, 100) -- density, friction, elasticity, friction_weight, elasticity_weight
				part.CustomPhysicalProperties = props
			end
		end
		print("[OozeController] Whoops! Slippery ooze.")
	elseif effectType == "Blind" then
		-- Create a black UI overlay
		local player = Players.LocalPlayer
		local pgui = player:FindFirstChild("PlayerGui")
		if pgui then
			local blindScreen = pgui:FindFirstChild("SemanticBlindness")
			if not blindScreen then
				blindScreen = Instance.new("ScreenGui")
				blindScreen.Name = "SemanticBlindness"
				blindScreen.IgnoreGuiInset = true
				
				local frame = Instance.new("Frame")
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundColor3 = Color3.new(0,0,0)
				frame.BackgroundTransparency = 0.5
				frame.Parent = blindScreen
				
				blindScreen.Parent = pgui
			end
		end
	elseif effectType == "Glow" then
		local char = humanoid.Parent
		local rootPart = char:FindFirstChild("HumanoidRootPart")
		if rootPart and not rootPart:FindFirstChild("OozeGlow") then
			local light = Instance.new("PointLight")
			light.Name = "OozeGlow"
			light.Color = Color3.fromRGB(255, 255, 200)
			light.Range = 20
			light.Brightness = 3
			light.Parent = rootPart
		end
	end
	
	-- Size Modifier from Role
	local roleData = LexicalEffectsDB.Roles[role]
	if roleData and roleData.SizeMultiplier ~= 1.0 then
		local UIScale = humanoid:FindFirstChild("BodyWidthScale")
		if UIScale then
			for _, scaleValue in pairs(humanoid:GetChildren()) do
				if scaleValue:IsA("NumberValue") and scaleValue.Name:match("Scale") then
					if not scaleValue:GetAttribute("OriginalScale") then
						scaleValue:SetAttribute("OriginalScale", scaleValue.Value)
					end
					TweenService:Create(scaleValue, TweenInfo.new(0.5), { Value = scaleValue:GetAttribute("OriginalScale") * roleData.SizeMultiplier }):Play()
				end
			end
		end
	end
end

function OozeController:ResetHumanoidToNormal(humanoid: Humanoid)
	humanoid.WalkSpeed = originalStats.WalkSpeed
	if humanoid.UseJumpPower then
		humanoid.JumpPower = originalStats.JumpPower
	end
	workspace.Gravity = originalStats.Gravity
	
	for _, part in pairs(humanoid.Parent:GetChildren()) do
		if part:IsA("BasePart") and part:GetAttribute("OriginalFriction") then
			local og = part:GetAttribute("OriginalFriction")
			part.CustomPhysicalProperties = PhysicalProperties.new(0.7, og, 0.5)
		end
	end
	
	local player = Players.LocalPlayer
	local pgui = player:FindFirstChild("PlayerGui")
	if pgui then
		local blindScreen = pgui:FindFirstChild("SemanticBlindness")
		if blindScreen then blindScreen:Destroy() end
	end
	
	local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local glow = rootPart:FindFirstChild("OozeGlow")
		if glow then glow:Destroy() end
	end
end

function OozeController:RemoveOozeEffect(humanoid: Humanoid)
	currentOozeTraits.IsActive = false
	currentOozeTraits.EffectId = nil
	self:ResetHumanoidToNormal(humanoid)
	
	-- Reset Scale
	for _, scaleValue in pairs(humanoid:GetChildren()) do
		if scaleValue:IsA("NumberValue") and scaleValue.Name:match("Scale") and scaleValue:GetAttribute("OriginalScale") then
			TweenService:Create(scaleValue, TweenInfo.new(1.0), { Value = scaleValue:GetAttribute("OriginalScale") }):Play()
		end
	end
	
	print("[OozeController] Effects wore off.")
end

return OozeController
