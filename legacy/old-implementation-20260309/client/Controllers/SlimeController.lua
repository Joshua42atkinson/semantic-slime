--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local SynonymDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SynonymDatabase"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local SlimeVisuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SlimeVisuals"))

local ELEMENT_COLORS = SlimeVisuals.ELEMENT_COLORS


local SlimeController = Knit.CreateController { Name = "SlimeController" }

-- Constants
local DETECT_RANGE = 25
local FLEE_RANGE = 40
local BOUNCE_HEIGHT = 0.8
local BOUNCE_SPEED = 4

-- State
local slimes: { [string]: any } = {} -- [id] = SlimeData
local slimeRemotes: Folder? = nil

-- Types
type SlimeData = {
	Model: Model,
	Root: Part,
	Term: string,
	Element: string,
	State: "Idle" | "Alert" | "Fleeing" | "Captured",
	Origin: Vector3,
	Timer: number,
	Id: string,
	VFX: any?,
}


-- Create rich per-element VFX for a slime
local function createSlimeVFX(root: Part, element: string): any
	local color = ELEMENT_COLORS[element] or ELEMENT_COLORS.Normal
	local vfx = { particles = nil, light = nil, trail = nil }

	-- Two attachment points for Trail
	local att0 = Instance.new("Attachment")
	att0.Name = "FXTop"
	att0.Position = Vector3.new(0, 1.4, 0)
	att0.Parent = root

	local att1 = Instance.new("Attachment")
	att1.Name = "FXBot"
	att1.Position = Vector3.new(0, -1.4, 0)
	att1.Parent = root

	-- Per-element particles
	local p = Instance.new("ParticleEmitter")
	p.Name = "SlimeParticles"
	p.Lifetime = NumberRange.new(0.6, 1.4)
	p.SpreadAngle = Vector2.new(60, 60)
	p.LightEmission = 0.5
	p.LightInfluence = 0.5
	p.RotSpeed = NumberRange.new(-45, 45)
	p.Rotation = NumberRange.new(-180, 180)

	if element == "Fire" then
		p.Texture = "rbxasset://textures/particles/fire_main.dds"
		p.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 60)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 20, 0)),
		})
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(0.5, 1.2), NumberSequenceKeypoint.new(1, 0) })
		p.Rate = 22
		p.Speed = NumberRange.new(3, 7)
		p.Acceleration = Vector3.new(0, 6, 0)
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
		p.LightEmission = 1.0

	elseif element == "Water" then
		p.Color = ColorSequence.new(Color3.fromRGB(100, 180, 255))
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.7, 0.5), NumberSequenceKeypoint.new(1, 0) })
		p.Rate = 6
		p.Speed = NumberRange.new(1, 3)
		p.Acceleration = Vector3.new(0, 4, 0)
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })

	elseif element == "Air" then
		p.Texture = "rbxasset://textures/particles/smoke_main.dds"
		p.Color = ColorSequence.new(Color3.new(1, 1, 1))
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 2.0) })
		p.Rate = 4
		p.Speed = NumberRange.new(0.5, 2)
		p.Acceleration = Vector3.new(0, 1, 0)
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
		p.LightInfluence = 1.0

	elseif element == "Earth" then
		p.Texture = "rbxasset://textures/particles/smoke_main.dds"
		p.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 80)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 100, 40)),
		})
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0) })
		p.Rate = 5
		p.Speed = NumberRange.new(0.5, 1.5)
		p.Acceleration = Vector3.new(0, -3, 0)
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })

	elseif element == "Shadow" then
		p.Texture = "rbxasset://textures/particles/smoke_main.dds"
		p.Color = ColorSequence.new(Color3.fromRGB(80, 20, 120))
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0) })
		p.Rate = 12
		p.Speed = NumberRange.new(1, 3)
		p.Acceleration = Vector3.new(0, -2, 0)
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) })
		p.LightEmission = 0.0
		p.LightInfluence = 0.0

	elseif element == "Light" then
		p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		p.Color = ColorSequence.new(Color3.fromRGB(255, 245, 180))
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.3, 1.0), NumberSequenceKeypoint.new(1, 0) })
		p.Rate = 18
		p.Speed = NumberRange.new(2, 5)
		p.Acceleration = Vector3.new(0, 2, 0)
		p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
		p.SpreadAngle = Vector2.new(180, 180)
		p.LightEmission = 1.0

	else
		p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		p.Color = ColorSequence.new(color)
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0) })
		p.Rate = 6
		p.Speed = NumberRange.new(1, 2)
	end
	p.Parent = root
	vfx.particles = p

	-- Point light tuned per element
	local lightCfg = {
		Fire   = { Color = Color3.fromRGB(255, 140, 30),  Brightness = 2.5, Range = 20 },
		Water  = { Color = Color3.fromRGB(80, 160, 255),  Brightness = 1.0, Range = 14 },
		Air    = { Color = Color3.fromRGB(200, 220, 255),  Brightness = 0.6, Range = 12 },
		Earth  = { Color = Color3.fromRGB(80, 160, 60),   Brightness = 0.8, Range = 14 },
		Shadow = { Color = Color3.fromRGB(100, 20, 180),  Brightness = 0.4, Range = 10 },
		Light  = { Color = Color3.fromRGB(255, 250, 180),  Brightness = 3.5, Range = 24 },
		Normal = { Color = Color3.fromRGB(200, 220, 200),  Brightness = 0.8, Range = 14 },
	}
	local lc = lightCfg[element] or lightCfg.Normal
	local light = Instance.new("PointLight")
	light.Name = "SlimeGlow"
	light.Color = lc.Color
	light.Brightness = lc.Brightness
	light.Range = lc.Range
	light.Parent = root
	vfx.light = light

	-- Motion trail (enabled only during Fleeing state)
	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(1, 1, 1), 0.5)),
	})
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	trail.Lifetime = 0.3
	trail.MinLength = 0.05
	trail.Enabled = false
	trail.LightEmission = 0.6
	trail.Parent = root
	vfx.trail = trail

	return vfx
end


-- Create capture effect
local function createCaptureEffect(position: Vector3, success: boolean)
	-- Burst effect
	local burst = Instance.new("Part")
	burst.Name = "CaptureBurst"
	burst.Shape = Enum.PartType.Ball
	burst.Size = Vector3.new(2, 2, 2)
	burst.Position = position
	burst.Anchored = true
	burst.CanCollide = false
	burst.Material = Enum.Material.Neon
	burst.Color = success and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(239, 68, 68)
	burst.Transparency = 0.3
	burst.Parent = workspace
	
	-- Expand and fade
	TweenService:Create(burst, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Size = Vector3.new(15, 15, 15),
		Transparency = 1
	}):Play()
	
	Debris:AddItem(burst, 0.6)
	
	-- Particle burst
	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = workspace:FindFirstChild("Terrain")
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Speed = NumberRange.new(10, 20)
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Color = ColorSequence.new(burst.Color)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter:Emit(30)
	
	Debris:AddItem(attachment, 1)
end

-- Create alert indicator
local function showAlertIndicator(slime: SlimeData)
	local cue = Instance.new("Part")
	cue.Name = "AlertCue"
	cue.Size = Vector3.new(1, 1, 1)
	cue.Shape = Enum.PartType.Ball
	cue.CFrame = slime.Root.CFrame * CFrame.new(0, 4, 0)
	cue.Anchored = true
	cue.CanCollide = false
	cue.Material = Enum.Material.Neon
	cue.Color = Color3.fromRGB(255, 200, 0)
	cue.Transparency = 0.3
	cue.Parent = workspace
	
	-- Create "!" text
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(30, 30)
	gui.Adornee = cue
	gui.AlwaysOnTop = true
	gui.Parent = cue
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "!"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	
	-- Animate up and fade
	TweenService:Create(cue, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		CFrame = cue.CFrame * CFrame.new(0, 3, 0),
		Transparency = 1
	}):Play()
	
	Debris:AddItem(cue, 0.6)
end

function SlimeController:KnitStart()
	self.LureService = Knit.GetService("LureService")
	
	-- Setup remote listener for slime spawns from server
	slimeRemotes = ReplicatedStorage:FindFirstChild("SlimeRemotes")
	if not slimeRemotes then
		slimeRemotes = Instance.new("Folder")
		slimeRemotes.Name = "SlimeRemotes"
		slimeRemotes.Parent = ReplicatedStorage
	end
	
	local spawnEvent = slimeRemotes:FindFirstChild("SlimeSpawned")
	if not spawnEvent then
		spawnEvent = Instance.new("RemoteEvent")
		spawnEvent.Name = "SlimeSpawned"
		spawnEvent.Parent = slimeRemotes
	end
	
	spawnEvent.OnClientEvent:Connect(function(id: string, term: string, position: Vector3, element: string)
		self:SpawnSlime(id, term, position, element)
	end)
	
	local despawnEvent = slimeRemotes:FindFirstChild("SlimeDespawned")
	if not despawnEvent then
		despawnEvent = Instance.new("RemoteEvent")
		despawnEvent.Name = "SlimeDespawned"
		despawnEvent.Parent = slimeRemotes
	end
	
	despawnEvent.OnClientEvent:Connect(function(id: string, captured: boolean)
		self:DespawnSlime(id, captured)
	end)
	
	-- Render Loop
	RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
	
	-- Input Handling (Click to Lure)
	local UserInputService = game:GetService("UserInputService")
	
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mouse = Players.LocalPlayer:GetMouse()
			local target = mouse.Target
			if target then
				-- Check if clicked on a slime
				local model = target:FindFirstAncestorOfClass("Model")
				if model and model.Name:sub(1, 6) == "Slime_" then
					local term = model.Name:sub(7)
					self:StartLure(term, model)
				end
			end
		end
	end)
	
	print("[SlimeController] Started. Ready to jiggle.")
end


local SlimeVisuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SlimeVisuals"))
local ELEMENT_COLORS = SlimeVisuals.ELEMENT_COLORS

function SlimeController:SpawnSlime(id: string, term: string, position: Vector3, element: string)
	if slimes[id] then return end -- Already exists
	
	-- Create Visual Model
	local model = Instance.new("Model")
	model.Name = "Slime_" .. term
	
	-- Build structure using shared visuals
	local root = SlimeVisuals.BuildStructure(model, term, element)
	model:SetPrimaryPartCFrame(CFrame.new(position))
	
	local color = ELEMENT_COLORS[element] or ELEMENT_COLORS.Normal
	
	-- UI Billboard
	local bgui = Instance.new("BillboardGui")
	bgui.Name = "NameTag"
	bgui.Size = UDim2.fromScale(6, 1.5)
	bgui.AlwaysOnTop = true
	bgui.StudsOffset = Vector3.new(0, 4.5, 0)
	bgui.Parent = root
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.TextStrokeColor3 = color:Lerp(Color3.new(0,0,0), 0.5)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = term:upper()
	label.Parent = bgui
	
	-- Element indicator
	local elementLabel = Instance.new("TextLabel")
	elementLabel.Size = UDim2.fromScale(1, 0.6)
	elementLabel.Position = UDim2.fromScale(0, 0.9)
	elementLabel.BackgroundTransparency = 1
	elementLabel.TextColor3 = Color3.new(1, 1, 1)
	elementLabel.TextStrokeTransparency = 0.5
	elementLabel.Font = Enum.Font.Gotham
	elementLabel.TextSize = 14
	elementLabel.Text = element and GameConfig.Elements[element] and GameConfig.Elements[element].Emoji or "❓"
	elementLabel.Parent = bgui
	
	model.Parent = workspace
	
	-- Create VFX
	local vfx = createSlimeVFX(root, element)
	
	slimes[id] = {
		Model = model,
		Root = root,
		Term = term,
		Element = element or "Normal",
		State = "Idle",
		Origin = position,
		Timer = math.random() * math.pi * 2, -- Random phase offset
		Id = id,
		VFX = vfx,
	}
	
	print("[SlimeController] Spawned detailed slime: " .. term .. " (" .. (element or "Normal") .. ")")
end


function SlimeController:DespawnSlime(id: string, captured: boolean)
	local slime = slimes[id]
	if not slime then return end
	
	-- Create capture effect
	createCaptureEffect(slime.Root.Position, captured)
	
	-- Animate out
	if captured then
		-- Shrink and rise
		TweenService:Create(slime.Root, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = Vector3.new(0.1, 0.1, 0.1),
			Transparency = 1
		}):Play()
		
		-- Disable particles
		if slime.VFX and slime.VFX.particles then
			slime.VFX.particles.Enabled = false
		end
	end
	
	Debris:AddItem(slime.Model, 0.5)
	slimes[id] = nil
end

function SlimeController:StartLure(term: string, model: Model)
	print("Starting Lure for: " .. term)
	
	local LureUI = require(script.Parent.Parent.UI.LureUI)
	
	-- Get choices from SynonymDatabase
	local choices, hasCorrect = SynonymDatabase.GetLureChoices(term, GameConfig.LURE_CHOICES)
	
	LureUI.Mount(term, choices, function(selected)
		-- Check if correct
		local isCorrect = SynonymDatabase.IsSynonym(term, selected)
		
		if isCorrect then
			-- Send to Server
			local LureService = Knit.GetService("LureService")
			LureService.Client:AttemptLure(term, selected):andThen(function(result)
				print("Lure Result: ", result)
				if result.Success then
					-- Find and remove local slime
					for id, s in pairs(slimes) do
						if s.Term:lower() == term:lower() then
							self:DespawnSlime(id, true)
							break
						end
					end
				end
			end)
		else
			print("Wrong synonym! The slime escapes.")
			-- Make slime flee
			for id, s in pairs(slimes) do
				if s.Term:lower() == term:lower() then
					s.State = "Fleeing"
					task.delay(2, function()
						if slimes[id] then
							s.State = "Idle"
						end
					end)
					break
				end
			end
		end
		
		return isCorrect
	end)
end

function SlimeController:Update(dt: number)
	local player = Players.LocalPlayer
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	for id, slime in pairs(slimes) do
		local slimeRoot = slime.Root
		if not slimeRoot or not slimeRoot.Parent then 
			slimes[id] = nil
			continue 
		end
		
		-- Flatten distance check
		local flatSlimePos = Vector3.new(slimeRoot.Position.X, 0, slimeRoot.Position.Z)
		local flatRootPos = Vector3.new(root.Position.X, 0, root.Position.Z)
		local dist = (flatRootPos - flatSlimePos).Magnitude
		
		-- Raycast to find ground level
		local rayOrigin = Vector3.new(slimeRoot.Position.X, 500, slimeRoot.Position.Z)
		local rayDirection = Vector3.new(0, -1000, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {slime.Model, char}
		local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		
		-- Slime root is a 2.8 stud diameter sphere, so center is 1.4 studs above ground
		local targetGroundY = rayResult and (rayResult.Position.Y + 1.4) or slime.Origin.Y
		
		-- Smoothly interpolate origin.Y so slimes don't snap teleport on cliffs
		slime.Origin = Vector3.new(slime.Origin.X, slime.Origin.Y + (targetGroundY - slime.Origin.Y) * (dt * 10), slime.Origin.Z)
		
		-- State Machine
		if slime.State == "Idle" then
			-- Bounce animation (Sine wave height)
			slime.Timer += dt * BOUNCE_SPEED
			local bounce = math.sin(slime.Timer) * BOUNCE_HEIGHT
			local squish = 1 + math.sin(slime.Timer * 2) * 0.1
			
			-- Keep its original rotation but update position
			local curYRot = select(2, slimeRoot.CFrame:ToEulerAnglesYXZ())
			slimeRoot.CFrame = CFrame.new(
				slimeRoot.Position.X, 
				slime.Origin.Y + math.abs(bounce), 
				slimeRoot.Position.Z
			) * CFrame.Angles(0, curYRot, 0)
			
			-- Squish effect
			slimeRoot.Size = Vector3.new(2.8 * squish, 2.8 / squish, 2.8 * squish)
			
			-- Random hop occasionally
			if math.random() < 0.005 then
				local hopAngle = math.random() * math.pi * 2
				local hopDist = math.random() * 8
				local hopDir = Vector3.new(math.cos(hopAngle) * hopDist, 0, math.sin(hopAngle) * hopDist)
				slime.Origin = slime.Origin + hopDir
				-- Face the jump direction
				slimeRoot.CFrame = CFrame.new(slimeRoot.Position, slimeRoot.Position + hopDir)
			end
			
			if dist < DETECT_RANGE then
				slime.State = "Alert"
				showAlertIndicator(slime)
			end
			
		elseif slime.State == "Alert" then
			-- Look at player
			local targetCF = CFrame.lookAt(slimeRoot.Position, Vector3.new(root.Position.X, slimeRoot.Position.Y, root.Position.Z))
			slimeRoot.CFrame = slimeRoot.CFrame:Lerp(targetCF, dt * 8)
			
			-- Nervous bounce
			slime.Timer += dt * BOUNCE_SPEED * 2.5
			local bounce = math.sin(slime.Timer) * BOUNCE_HEIGHT * 0.6
			local squish = 1 + math.sin(slime.Timer * 5) * 0.05
			
			slimeRoot.Position = Vector3.new(
				slimeRoot.Position.X, 
				slime.Origin.Y + math.abs(bounce), 
				slimeRoot.Position.Z
			)
			slimeRoot.Size = Vector3.new(2.8 * squish, 2.8 / squish, 2.8 * squish)
			
			if dist > FLEE_RANGE then
				slime.State = "Idle"
			elseif dist < DETECT_RANGE * 0.6 then
				-- Too close, start fleeing
				slime.State = "Fleeing"
			end
			
		elseif slime.State == "Fleeing" then
			-- Run away from player
			local fleeDir = (flatSlimePos - flatRootPos).Unit
			if fleeDir.Magnitude == 0 or fleeDir ~= fleeDir then -- Prevent NaN
				fleeDir = Vector3.new(1, 0, 0)
			end
			
			local targetFlatPos = flatSlimePos + fleeDir * 20
			
			-- Keep in bounds (simple map limit)
			targetFlatPos = Vector3.new(
				math.clamp(targetFlatPos.X, -800, 800),
				0,
				math.clamp(targetFlatPos.Z, -800, 800)
			)
			
			-- Move XZ
			local currentPos = Vector3.new(slimeRoot.Position.X, 0, slimeRoot.Position.Z)
			local newPos = currentPos:Lerp(targetFlatPos, dt * 5)
			slime.Origin = Vector3.new(newPos.X, slime.Origin.Y, newPos.Z)
			
			-- Fast bounce while fleeing
			slime.Timer += dt * BOUNCE_SPEED * 3.5
			local bounce = math.sin(slime.Timer) * BOUNCE_HEIGHT * 1.5
			local squish = 1 + math.sin(slime.Timer * 3.5) * 0.15
			
			-- Look in flee direction
			local lookTarget = Vector3.new(targetFlatPos.X, slime.Origin.Y + math.abs(bounce), targetFlatPos.Z)
			local newCFrame = CFrame.new(Vector3.new(newPos.X, slime.Origin.Y + math.abs(bounce), newPos.Z), lookTarget)
			
			slimeRoot.CFrame = slimeRoot.CFrame:Lerp(newCFrame, dt * 10)
			slimeRoot.Size = Vector3.new(2.8 * squish, 2.8 / squish, 2.8 * squish)
			
			if dist > FLEE_RANGE then
				slime.State = "Idle"
			end
		end
		
		-- Update VFX based on state
		if slime.VFX then
			if slime.VFX.light then
				if slime.State == "Alert" then
					slime.VFX.light.Brightness = 2.5
				elseif slime.State == "Fleeing" then
					slime.VFX.light.Brightness = 4.0
				else
					slime.VFX.light.Brightness = 1.0
				end
			end
			if slime.VFX.trail then
				slime.VFX.trail.Enabled = (slime.State == "Fleeing")
			end
		end
	end
end

return SlimeController