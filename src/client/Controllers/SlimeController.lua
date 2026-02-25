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

-- Element Colors
local ELEMENT_COLORS: { [string]: Color3 } = {
	Fire = Color3.fromRGB(255, 100, 50),
	Water = Color3.fromRGB(50, 150, 255),
	Earth = Color3.fromRGB(139, 90, 43),
	Air = Color3.fromRGB(200, 200, 255),
	Shadow = Color3.fromRGB(100, 50, 150),
	Light = Color3.fromRGB(255, 220, 100),
	Normal = Color3.fromRGB(180, 180, 180),
}

-- Create VFX for a slime
local function createSlimeVFX(root: Part, element: string): any
	local vfx = {
		particles = nil,
		trail = nil,
		light = nil,
	}
	
	-- Particle Emitter
	local attachment = Instance.new("Attachment")
	attachment.Name = "ParticleAttach"
	attachment.Parent = root
	
	local particles = Instance.new("ParticleEmitter")
	particles.Name = "SlimeParticles"
	particles.Rate = 10
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Speed = NumberRange.new(1, 3)
	particles.Size = NumberSequence.new(0.5, 0)
	particles.Color = ColorSequence.new(root.Color)
	particles.Transparency = NumberSequence.new(0.5, 1)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = attachment
	vfx.particles = particles
	
	-- Point Light
	local light = Instance.new("PointLight")
	light.Name = "SlimeGlow"
	light.Color = root.Color
	light.Brightness = 1
	light.Range = 15
	light.Parent = root
	vfx.light = light
	
	-- Element-specific VFX
	if element == "Fire" then
		-- Fire flicker
		particles.Texture = "rbxasset://textures/particles/fire_main.dds"
		particles.Rate = 20
		light.Brightness = 2
	elseif element == "Water" then
		-- Bubble effect
		particles.Size = NumberSequence.new(0.3, 0.8, 0)
		particles.Rate = 5
	elseif element == "Shadow" then
		-- Dark mist
		particles.Transparency = NumberSequence.new(0.8, 1)
		particles.Rate = 15
		light.Brightness = 0.5
	elseif element == "Light" then
		-- Sparkles
		particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particles.Rate = 15
		light.Brightness = 3
	end
	
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

function SlimeController:SpawnSlime(id: string, term: string, position: Vector3, element: string)
	if slimes[id] then return end -- Already exists
	
	-- Create Visual Model
	local model = Instance.new("Model")
	model.Name = "Slime_" .. term
	
	-- Main body (squishy sphere)
	local part = Instance.new("Part")
	part.Name = "RootPart"
	part.Size = Vector3.new(3, 3, 3)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Parent = model
	
	-- Color based on Element
	part.Color = ELEMENT_COLORS[element] or ELEMENT_COLORS.Normal
	
	-- Inner core (darker shade)
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(1.5, 1.5, 1.5)
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.SmoothPlastic
	core.Color = part.Color:Lerp(Color3.new(0, 0, 0), 0.3)
	core.Transparency = 0.5
	core.Position = position
	core.Anchored = true
	core.CanCollide = false
	core.Parent = model
	
	-- Eyes
	for i, offset in ipairs({ Vector3.new(-0.5, 0.3, 1), Vector3.new(0.5, 0.3, 1) }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye" .. i
		eye.Size = Vector3.new(0.4, 0.4, 0.2)
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.SmoothPlastic
		eye.Color = Color3.new(1, 1, 1)
		eye.Position = position + offset
		eye.Anchored = true
		eye.CanCollide = false
		eye.Parent = model
		
		-- Pupil
		local pupil = Instance.new("Part")
		pupil.Name = "Pupil" .. i
		pupil.Size = Vector3.new(0.2, 0.2, 0.1)
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.SmoothPlastic
		pupil.Color = Color3.new(0, 0, 0)
		pupil.Position = position + offset + Vector3.new(0, 0, 0.15)
		pupil.Anchored = true
		pupil.CanCollide = false
		pupil.Parent = model
	end
	
	-- UI Billboard
	local bgui = Instance.new("BillboardGui")
	bgui.Name = "NameTag"
	bgui.Size = UDim2.fromScale(4, 1)
	bgui.AlwaysOnTop = true
	bgui.StudsOffset = Vector3.new(0, 3.5, 0)
	bgui.Parent = part
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = part.Color
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = term
	label.Parent = bgui
	
	-- Element indicator
	local elementLabel = Instance.new("TextLabel")
	elementLabel.Size = UDim2.fromScale(1, 0.5)
	elementLabel.Position = UDim2.fromScale(0, 1.2)
	elementLabel.BackgroundTransparency = 1
	elementLabel.TextColor3 = Color3.new(1, 1, 1)
	elementLabel.TextStrokeTransparency = 0
	elementLabel.Font = Enum.Font.Gotham
	elementLabel.TextSize = 12
	elementLabel.Text = element and GameConfig.Elements[element] and GameConfig.Elements[element].Emoji or "❓"
	elementLabel.Parent = bgui
	
	model.Parent = workspace
	
	-- Create VFX
	local vfx = createSlimeVFX(part, element)
	
	slimes[id] = {
		Model = model,
		Root = part,
		Term = term,
		Element = element or "Normal",
		State = "Idle",
		Origin = position,
		Timer = math.random() * math.pi * 2, -- Random phase offset
		Id = id,
		VFX = vfx,
	}
	
	print("[SlimeController] Spawned slime: " .. term .. " (" .. (element or "Normal") .. ")")
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
		
		local dist = (root.Position - slimeRoot.Position).Magnitude
		
		-- State Machine
		if slime.State == "Idle" then
			-- Bounce animation (Sine wave height)
			slime.Timer += dt * BOUNCE_SPEED
			local bounce = math.sin(slime.Timer) * BOUNCE_HEIGHT
			local squish = 1 + math.sin(slime.Timer * 2) * 0.1
			
			slimeRoot.Position = Vector3.new(
				slimeRoot.Position.X, 
				slime.Origin.Y + bounce, 
				slimeRoot.Position.Z
			)
			
			-- Squish effect
			slimeRoot.Size = Vector3.new(3 * squish, 3 / squish, 3 * squish)
			
			-- Random hop
			if math.random() < 0.002 then
				local hopDir = Vector3.new(
					(math.random() - 0.5) * 10,
					0,
					(math.random() - 0.5) * 10
				)
				slime.Origin = slime.Origin + hopDir
			end
			
			if dist < DETECT_RANGE then
				slime.State = "Alert"
				showAlertIndicator(slime)
			end
			
		elseif slime.State == "Alert" then
			-- Look at player
			local lookDir = (root.Position - slimeRoot.Position).Unit
			local targetCF = CFrame.lookAt(slimeRoot.Position, root.Position)
			slimeRoot.CFrame = slimeRoot.CFrame:Lerp(targetCF, dt * 5)
			
			-- Nervous bounce
			slime.Timer += dt * BOUNCE_SPEED * 2
			local bounce = math.sin(slime.Timer) * BOUNCE_HEIGHT * 0.5
			slimeRoot.Position = Vector3.new(
				slimeRoot.Position.X, 
				slime.Origin.Y + bounce, 
				slimeRoot.Position.Z
			)
			
			if dist > FLEE_RANGE then
				slime.State = "Idle"
			elseif dist < DETECT_RANGE * 0.5 then
				-- Too close, start fleeing
				slime.State = "Fleeing"
			end
			
		elseif slime.State == "Fleeing" then
			-- Run away from player
			local fleeDir = (slimeRoot.Position - root.Position).Unit
			local targetPos = slime.Origin + fleeDir * 20
			
			-- Keep in bounds (simple)
			targetPos = Vector3.new(
				math.clamp(targetPos.X, -400, 400),
				targetPos.Y,
				math.clamp(targetPos.Z, -400, 400)
			)
			
			slimeRoot.Position = slimeRoot.Position:Lerp(targetPos, dt * 3)
			slime.Origin = Vector3.new(slimeRoot.Position.X, slime.Origin.Y, slimeRoot.Position.Z)
			
			-- Fast bounce while fleeing
			slime.Timer += dt * BOUNCE_SPEED * 3
			local bounce = math.sin(slime.Timer) * BOUNCE_HEIGHT * 1.5
			slimeRoot.Position = Vector3.new(
				slimeRoot.Position.X, 
				slime.Origin.Y + bounce, 
				slimeRoot.Position.Z
			)
			
			if dist > FLEE_RANGE then
				slime.State = "Idle"
			end
		end
		
		-- Update VFX color based on state
		if slime.VFX and slime.VFX.light then
			if slime.State == "Alert" then
				slime.VFX.light.Brightness = 2
			elseif slime.State == "Fleeing" then
				slime.VFX.light.Brightness = 3
			else
				slime.VFX.light.Brightness = 1
			end
		end
	end
end

return SlimeController