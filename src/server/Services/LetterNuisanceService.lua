--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LetterNuisanceService = Knit.CreateService {
	Name = "LetterNuisanceService",
	Client = {
		NuisanceSpawned = Knit.CreateSignal(),
		NuisanceDespawned = Knit.CreateSignal(),
		NuisanceCaptured = Knit.CreateSignal(),
	},
}

-- Types
type FeralLetter = {
	InstanceId: string,
	Letter: string,
	Position: Vector3,
	TargetPlayer: Player?,
	Model: Model?,
}

-- Config
local ALPHABET = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local SPAWN_RADIUS = 150
local CHASE_SPEED = 12

-- State
local activeNuisances: { [string]: FeralLetter } = {}
local updateConnection = nil
local playerShields: { [Player]: boolean } = {}

function LetterNuisanceService:KnitStart()
	print("[LetterNuisanceService] Started.")
	
	-- Connect to GameLoop events
	local GameLoopService = Knit.GetService("GameLoopService")
	
	-- Handle collisions and movement on heartbeat
	local RunService = game:GetService("RunService")
	updateConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
end

function LetterNuisanceService:SpawnNuisanceLetters(count: number)
	for i = 1, count do
		local letter = ALPHABET[math.random(1, #ALPHABET)]
		local angle = math.random() * math.pi * 2
		local radius = math.random(30, SPAWN_RADIUS)
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		
		local position = Vector3.new(x, 10, z)
		
		-- Try to target a random player
		local players = Players:GetPlayers()
		local target = nil
		if #players > 0 then
			target = players[math.random(1, #players)]
			-- Spawn near them
			if target.Character and target.Character.PrimaryPart then
				position = target.Character.PrimaryPart.Position + Vector3.new(math.cos(angle) * 30, 10, math.sin(angle) * 30)
			end
		end
		
		local nuisance: FeralLetter = {
			InstanceId = HttpService:GenerateGUID(false),
			Letter = letter,
			Position = position,
			TargetPlayer = target,
		}
		
		activeNuisances[nuisance.InstanceId] = nuisance
		self:CreateVisuals(nuisance)
		
		self.Client.NuisanceSpawned:FireAll(nuisance.InstanceId, letter, position)
	end
	
	print("[LetterNuisanceService] Spawned " .. count .. " feral letters")
end

function LetterNuisanceService:EndNuisancePhase()
	-- Despawn all feral letters
	for id, nuisance in pairs(activeNuisances) do
		self:DespawnNuisance(id, false)
	end
	
	-- Clear shields
	playerShields = {}
	
	print("[LetterNuisanceService] Ended nuisance phase")
end

function LetterNuisanceService:GrantNuisanceShield(player: Player)
	playerShields[player] = true
end

function LetterNuisanceService:CreateVisuals(nuisance: FeralLetter)
	local model = Instance.new("Model")
	model.Name = "Feral_" .. nuisance.InstanceId
	
	local part = Instance.new("Part")
	part.Name = "Body"
	part.Size = Vector3.new(2, 2, 2)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 50, 50)
	part.Transparency = 0.5
	part.Anchored = true
	part.CanCollide = false
	part.Position = nuisance.Position
	part.Parent = model
	
	local bgui = Instance.new("BillboardGui")
	bgui.Size = UDim2.fromScale(4, 4)
	bgui.AlwaysOnTop = true
	bgui.Parent = part
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.Creepster
	label.TextScaled = true
	label.Text = nuisance.Letter
	label.Parent = bgui
	
	model.Parent = workspace
	nuisance.Model = model
end

function LetterNuisanceService:DespawnNuisance(id: string, captured: boolean)
	local nuisance = activeNuisances[id]
	if not nuisance then return end
	
	if nuisance.Model then
		nuisance.Model:Destroy()
	end
	
	activeNuisances[id] = nil
	self.Client.NuisanceDespawned:FireAll(id, captured)
end

function LetterNuisanceService:HandlePlayerCollision(player: Player, nuisance: FeralLetter)
	-- Player collided with feral letter
	local id = nuisance.InstanceId
	
	-- If player has shield, they auto-capture it
	if playerShields[player] then
		playerShields[player] = nil -- Consume shield
		self:CaptureNuisance(player, id)
		return
	end
	
	-- For now, just a small penalty (e.g., steal a letter or push back)
	local CrystalService = Knit.GetService("CrystalService")
	if CrystalService then
		-- In a full implementation, we'd remove a random letter. For now, just visual hit.
		self.Client.NuisanceDespawned:Fire(player, id, false) -- Tell client they got hit
	end
	
	-- Despawn it
	self:DespawnNuisance(id, false)
end

function LetterNuisanceService:CaptureNuisance(player: Player, id: string)
	local nuisance = activeNuisances[id]
	if not nuisance then return end
	
	-- Add to inventory
	local CrystalService = Knit.GetService("CrystalService")
	if CrystalService then
		-- Using private API indirectly or assume Remotes. We'll grant via DataService or CrystalService
		local DataService = Knit.GetService("DataService")
		-- Just broadcast to client to show it was captured, CrystalService handles actual inventory via remotes
	end
	
	print("[LetterNuisanceService] " .. player.Name .. " captured feral " .. nuisance.Letter)
	self:DespawnNuisance(id, true)
	self.Client.NuisanceCaptured:Fire(player, nuisance.Letter)
end

function LetterNuisanceService:Update(dt: number)
	for id, nuisance in pairs(activeNuisances) do
		-- Update target if needed
		if not nuisance.TargetPlayer or not nuisance.TargetPlayer.Parent then
			local players = Players:GetPlayers()
			if #players > 0 then
				nuisance.TargetPlayer = players[math.random(1, #players)]
			end
		end
		
		if nuisance.TargetPlayer and nuisance.TargetPlayer.Character and nuisance.TargetPlayer.Character.PrimaryPart and nuisance.Model and nuisance.Model.PrimaryPart then
			local targetPos = nuisance.TargetPlayer.Character.PrimaryPart.Position
			local currentPos = nuisance.Model.PrimaryPart.Position
			
			local dir = (targetPos - currentPos).Unit
			if dir ~= dir then dir = Vector3.new(0,0,0) end -- NaN check
			
			local newPos = currentPos + (dir * CHASE_SPEED * dt)
			newPos = Vector3.new(newPos.X, 10 + math.sin(tick() * 5) * 2, newPos.Z) -- Bobbing
			
			nuisance.Model.PrimaryPart.Position = newPos
			nuisance.Position = newPos
			
			-- Check collision
			if (targetPos - newPos).Magnitude < 4 then
				self:HandlePlayerCollision(nuisance.TargetPlayer, nuisance)
			end
		end
	end
end

return LetterNuisanceService
