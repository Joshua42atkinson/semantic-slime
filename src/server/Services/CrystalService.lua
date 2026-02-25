--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CrystalService = Knit.CreateService {
	Name = "CrystalService",
	Client = {
		CrystalCollected = Knit.CreateSignal(),
		CrystalSpawned = Knit.CreateSignal(),
	},
}

-- Types
export type LetterCrystal = {
	InstanceId: string,
	Letter: string,
	Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary",
	Position: Vector3,
}

-- Configuration
local LETTER_RARITY = {
	-- High frequency letters (40%)
	{ Letter = "E", Weight = 12.02 },
	{ Letter = "A", Weight = 9.10 },
	{ Letter = "I", Weight = 8.12 },
	{ Letter = "O", Weight = 7.68 },
	{ Letter = "N", Weight = 6.95 },
	{ Letter = "R", Weight = 6.28 },
	{ Letter = "T", Weight = 5.92 },
	{ Letter = "L", Weight = 5.45 },
	{ Letter = "S", Weight = 5.37 },
	{ Letter = "U", Weight = 4.90 },
	-- Medium frequency (35%)
	{ Letter = "D", Weight = 4.11 },
	{ Letter = "G", Weight = 3.06 },
	{ Letter = "B", Weight = 2.22 },
	{ Letter = "C", Weight = 2.18 },
	{ Letter = "M", Weight = 2.05 },
	{ Letter = "H", Weight = 1.98 },
	{ Letter = "F", Weight = 1.65 },
	{ Letter = "W", Weight = 1.58 },
	{ Letter = "Y", Weight = 1.41 },
	{ Letter = "P", Weight = 1.33 },
	-- Low frequency (20%)
	{ Letter = "V", Weight = 1.04 },
	{ Letter = "K", Weight = 0.87 },
	{ Letter = "J", Weight = 0.40 },
	{ Letter = "X", Weight = 0.29 },
	-- Very rare (5%)
	{ Letter = "Q", Weight = 0.20 },
	{ Letter = "Z", Weight = 0.19 },
}

local RARITY_COLORS: { [string]: Color3 } = {
	Common = Color3.fromRGB(180, 180, 180),
	Uncommon = Color3.fromRGB(34, 197, 94),
	Rare = Color3.fromRGB(59, 130, 246),
	Epic = Color3.fromRGB(168, 85, 247),
	Legendary = Color3.fromRGB(234, 179, 8),
}

local RARITY_CHANCE = {
	Common = 40,
	Uncommon = 25,
	Rare = 18,
	Epic = 10,
	Legendary = 7,
}

-- Private state
local activeCrystals: { [string]: LetterCrystal } = {}
local crystalModels: { [string]: Model } = {}
local playerInventories: { [Player]: { [string]: number } } = {} -- Letter -> Count

-- Weighted random letter selection
local function selectRandomLetter(): string
	local totalWeight = 0
	for _, entry in ipairs(LETTER_RARITY) do
		totalWeight += entry.Weight
	end
	
	local random = math.random() * totalWeight
	local running = 0
	
	for _, entry in ipairs(LETTER_RARITY) do
		running += entry.Weight
		if random <= running then
			return entry.Letter
		end
	end
	
	return "E" -- Fallback
end

-- Determine rarity based on random chance
local function selectRarity(): string
	local roll = math.random(1, 100)
	local cumulative = 0
	
	local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}
	for _, rarity in ipairs(rarities) do
		local chance = RARITY_CHANCE[rarity] or 0
		cumulative += chance
		if roll <= cumulative then
			return rarity
		end
	end
	
	return "Common"
end

-- Calculate spawn position in world
local function getRandomSpawnPosition(): Vector3
	local x = math.random(-300, 300)
	local z = math.random(-300, 300)
	local y = 5 + math.random(0, 20) -- Above ground
	return Vector3.new(x, y, z)
end

-- Create visual crystal model
local function createCrystalModel(crystal: LetterCrystal): Model
	local model = Instance.new("Model")
	model.Name = "Crystal_" .. crystal.InstanceId
	
	-- Main crystal body
	local part = Instance.new("Part")
	part.Name = "CrystalPart"
	part.Size = Vector3.new(1.5, 2, 1.5)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = RARITY_COLORS[crystal.Rarity]
	part.Transparency = 0.3
	part.Anchored = true
	part.CanCollide = true
	part.Position = crystal.Position
	part.Parent = model
	
	-- Inner core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(0.8, 1.2, 0.8)
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.SmoothPlastic
	core.Color = Color3.new(1, 1, 1)
	core.Transparency = 0.1
	core.Position = crystal.Position
	core.Anchored = true
	core.CanCollide = false
	core.Parent = model
	
	-- Letter label
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LetterLabel"
	billboard.Size = UDim2.fromScale(3, 2)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = part
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = crystal.Letter
	label.Parent = billboard
	
	-- Point light for glow
	local light = Instance.new("PointLight")
	light.Name = "Glow"
	light.Color = RARITY_COLORS[crystal.Rarity]
	light.Brightness = crystal.Rarity == "Legendary" and 5 or 2
	light.Range = 20
	light.Parent = part
	
	-- Particle effect
	local attachment = Instance.new("Attachment")
	attachment.Name = "Particles"
	attachment.Position = Vector3.new(0, 0, 0)
	attachment.Parent = part
	
	local particles = Instance.new("ParticleEmitter")
	particles.Name = "Sparkles"
	particles.Rate = 10
	particles.Lifetime = NumberRange.new(0.5, 1.5)
	particles.Speed = NumberRange.new(0.5, 2)
	particles.Size = NumberSequence.new(0.3, 0)
	particles.Color = ColorSequence.new(RARITY_COLORS[crystal.Rarity])
	particles.Transparency = NumberSequence.new(0.5, 1)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = attachment
	
	-- Add spinning animation script
	local rotateScript = Instance.new("Script")
	rotateScript.Name = "Rotate"
	rotateScript.Source = [[
		while true do
			script.Parent.CFrame = script.Parent.CFrame * CFrame.Angles(0, math.rad(2), 0)
			task.wait()
		end
	]]
	rotateScript.Parent = part
	
	model.Parent = workspace
	return model
end

function CrystalService:KnitStart()
	print("[CrystalService] Started.")
	
	-- Start spawning crystals periodically
	task.spawn(function()
		while true do
			task.wait(15) -- Spawn new crystal every 15 seconds
			if #activeCrystals < 30 then -- Max 30 crystals in world
				self:SpawnCrystal()
			end
		end
	end)
	
	-- Initial spawn
	task.wait(2)
	for i = 1, 10 do
		self:SpawnCrystal()
	end
end

function CrystalService:SpawnCrystal()
	local letter = selectRandomLetter()
	local rarity = selectRarity()
	
	local crystal: LetterCrystal = {
		InstanceId = HttpService:GenerateGUID(false),
		Letter = letter,
		Rarity = rarity,
		Position = getRandomSpawnPosition(),
	}
	
	activeCrystals[crystal.InstanceId] = crystal
	crystalModels[crystal.InstanceId] = createCrystalModel(crystal)
	
	-- Broadcast to clients
	self.Client.CrystalSpawned:FireAll(crystal.InstanceId, crystal.Letter, crystal.Position, crystal.Rarity)
	print("[CrystalService] Spawned " .. rarity .. " crystal: " .. letter)
end

function CrystalService:CollectCrystal(player: Player, crystalId: string)
	local crystal = activeCrystals[crystalId]
	if not crystal then return nil end
	
	-- Add to player inventory
	if not playerInventories[player] then
		playerInventories[player] = {}
	end
	
	playerInventories[player][crystal.Letter] = (playerInventories[player][crystal.Letter] or 0) + 1
	
	-- Remove from world
	if crystalModels[crystalId] then
		crystalModels[crystalId]:Destroy()
		crystalModels[crystalId] = nil
	end
	activeCrystals[crystalId] = nil
	
	-- Notify client
	self.Client.CrystalCollected:Fire(player, crystal.Letter, crystal.Rarity)
	print("[CrystalService] " .. player.Name .. " collected crystal: " .. crystal.Letter .. " (" .. crystal.Rarity .. ")")
	
	-- Return collected data for UI
	return {
		Letter = crystal.Letter,
		Rarity = crystal.Rarity,
		NewCount = playerInventories[player][crystal.Letter]
	}
end

function CrystalService:GetPlayerInventory(player: Player): { [string]: number }
	return playerInventories[player] or {}
end

function CrystalService:CanFormWord(player: Player, word: string): boolean
	local inventory = playerInventories[player]
	if not inventory then return false end
	
	local letters = {}
	for i = 1, #word do
		local letter = string.sub(word, i, i)
		letters[letter] = (letters[letter] or 0) + 1
	end
	
	for letter, count in pairs(letters) do
		if (inventory[letter] or 0) < count then
			return false
		end
	end
	
	return true
end

function CrystalService:UseLetters(player: Player, word: string): boolean
	if not self:CanFormWord(player, word) then
		return false
	end
	
	local inventory = playerInventories[player]
	
	-- Remove letters used
	for i = 1, #word do
		local letter = string.sub(word, i, i)
		inventory[letter] = (inventory[letter] or 1) - 1
	end
	
	return true
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	playerInventories[player] = nil
end)

-- Initialize inventory for new players
Players.PlayerAdded:Connect(function(player)
	playerInventories[player] = {}
	
	-- Give starter letters
	playerInventories[player] = {
		E = 3, A = 2, I = 2, O = 2, N = 2,
		R = 2, T = 2, L = 1, S = 1, U = 1,
	}
	print("[CrystalService] Initialized inventory for " .. player.Name)
end)

return CrystalService
