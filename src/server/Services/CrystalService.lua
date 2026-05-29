--!strict
--==============================================================
-- MMMM Context: Manages the spawning of baseline letter crystals. The foundation of the entire ecological pipeline.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local Blueprint = require(ReplicatedStorage.Shared.TownBlueprint)

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

-- District configuration for letter spawning
local offset = Blueprint.Settings.OffsetFromCenter
local DISTRICT_POSITIONS = {
	["BrainyBorough"] = { Center = Blueprint.Districts.BrainyBorough.Direction * offset, Radius = 300 },   -- Academic/rare letters
	["HeartwoodGrove"] = { Center = Blueprint.Districts.HeartwoodGrove.Direction * offset, Radius = 300 },   -- Emotional words
	["WhisperWinds"] = { Center = Blueprint.Districts.WhisperWinds.Direction * offset, Radius = 300 },  -- Spiritual words
	["ActionAlley"] = { Center = Blueprint.Districts.ActionAlley.Direction * offset, Radius = 300 },  -- Physical words
}

-- District-specific letters
local DISTRICT_LETTERS = {
	["BrainyBorough"] = { "Q", "X", "Z", "J", "K" },      -- Academic/rare
	["HeartwoodGrove"] = { "L", "O", "V", "E", "M" },       -- Emotional words
	["WhisperWinds"] = { "S", "P", "I", "R", "A" },     -- Spiritual words
	["ActionAlley"] = { "B", "O", "D", "Y", "F" },       -- Physical words
}

-- Private state
local activeCrystals: { [string]: LetterCrystal } = {}
local activeCrystalCount = 0
local crystalModels: { [string]: Model } = {}
local playerInventories: { [Player]: { [string]: number } } = {} -- Letter -> Count
local rateLimits: { [Player]: { Collect: number, Use: number } } = {}

-- Get random district with weighted chance
local function getRandomDistrict(): string
	local roll = math.random(1, 100)
	if roll <= 40 then
		-- 40% chance: Random spawn (anywhere)
		return "Random"
	elseif roll <= 60 then
		-- 20% chance: BrainyBorough district
		return "BrainyBorough"
	elseif roll <= 75 then
		-- 15% chance: HeartwoodGrove district
		return "HeartwoodGrove"
	elseif roll <= 90 then
		-- 15% chance: WhisperWinds district
		return "WhisperWinds"
	else
		-- 10% chance: ActionAlley district
		return "ActionAlley"
	end
end

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
	-- Determine which district this crystal spawns in
	local district = getRandomDistrict()
	
	if district == "Random" then
		-- Random spawn anywhere in the world
		local x = math.random(-300, 300)
		local z = math.random(-300, 300)
		local y = 5 + math.random(0, 20)
		return Vector3.new(x, y, z)
	else
		-- Spawn in specific district
		local districtConfig = DISTRICT_POSITIONS[district]
		if districtConfig then
			local angle = math.random() * math.pi * 2
			local distance = math.random() * districtConfig.Radius
			local x = districtConfig.Center.X + math.cos(angle) * distance
			local z = districtConfig.Center.Z + math.sin(angle) * distance
			local y = 5 + math.random(0, 20)
			return Vector3.new(x, y, z)
		end
	end
	
	-- Fallback
	return Vector3.new(math.random(-300, 300), 10, math.random(-300, 300))
end

-- Select letter with district preference
local function selectDistrictLetter(district: string): string
	if district == "Random" then
		return selectRandomLetter()
	end
	
	local districtLetters = DISTRICT_LETTERS[district]
	if districtLetters then
		-- 70% chance to get district-specific letter
		if math.random(1, 100) <= 70 then
			return districtLetters[math.random(1, #districtLetters)]
		end
	end
	
	return selectRandomLetter()
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
	part.CanCollide = false  -- Let players walk through to auto-collect
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
	
	-- ═══ ProximityPrompt: lets players see "Press E to Collect" ═══
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = crystal.Rarity .. " Crystal"
	prompt.ActionText = "Collect " .. crystal.Letter
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = part
	
	-- Wire the prompt to collection
	prompt.Triggered:Connect(function(player)
		CrystalService:CollectCrystal(player, crystal.InstanceId)
	end)
	
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
	
	-- Add spinning animation via Heartbeat
	task.spawn(function()
		while part and part.Parent do
			part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(2), 0)
			task.wait()
		end
	end)
	
	model.Parent = workspace
	return model
end

-- RemoteFunction handlers are set up in KnitStart after Remotes folder is guaranteed to exist

function CrystalService:KnitStart()
	print("[CrystalService] Started.")
	
	-- Get Remotes folder via require (avoids ModuleScript/Folder naming collision)
	local Shared = ReplicatedStorage:WaitForChild("Shared")
	local RemotesModule = Shared:FindFirstChild("Remotes")
	local RemotesFolder
	if RemotesModule and RemotesModule:IsA("ModuleScript") then
		RemotesFolder = require(RemotesModule)
	else
		RemotesFolder = Shared:WaitForChild("Remotes", 10)
	end
	
	if RemotesFolder then
		-- Set up RemoteFunction handlers
		local CollectCrystalRF = RemotesFolder:FindFirstChild("CollectCrystal")
		local GetInventoryRF = RemotesFolder:FindFirstChild("GetInventory")
		local UseLettersRF = RemotesFolder:FindFirstChild("UseLetters")
		local CanFormWordRF = RemotesFolder:FindFirstChild("CanFormWord")
		
		if CollectCrystalRF then
			CollectCrystalRF.OnServerInvoke = function(player, crystalId)
				if typeof(crystalId) ~= "string" then 
					warn("[CrystalService] Invalid crystalId type from " .. player.Name)
					return nil 
				end
				local success, result = pcall(function()
					return CrystalService:CollectCrystal(player, crystalId)
				end)
				if not success then
					warn("[CrystalService] Error collecting crystal:", result)
					return nil
				end
				return result
			end
		else
			warn("[CrystalService] CollectCrystal RemoteFunction not found")
		end
		
		if GetInventoryRF then
			GetInventoryRF.OnServerInvoke = function(player)
				local success, result = pcall(function()
					return CrystalService:GetPlayerInventory(player)
				end)
				if not success then
					warn("[CrystalService] Error getting inventory:", result)
					return {}
				end
				return result
			end
		end
		
		if UseLettersRF then
			UseLettersRF.OnServerInvoke = function(player, word)
				if typeof(word) ~= "string" then 
					warn("[CrystalService] Invalid word type from " .. player.Name)
					return false 
				end
				local success, result = pcall(function()
					return CrystalService:UseLetters(player, word)
				end)
				if not success then
					warn("[CrystalService] Error using letters:", result)
					return false
				end
				return result
			end
		end
		
		if CanFormWordRF then
			CanFormWordRF.OnServerInvoke = function(player, word)
				if typeof(word) ~= "string" then 
					warn("[CrystalService] Invalid word type from " .. player.Name)
					return false 
				end
				local success, result = pcall(function()
					return CrystalService:CanFormWord(player, word)
				end)
				if not success then
					warn("[CrystalService] Error checking if can form word:", result)
					return false
				end
				return result
			end
		end
	else
		warn("[CrystalService] Remotes folder not found — remote functions disabled")
	end
	
	-- Start spawning crystals periodically
	task.spawn(function()
		while true do
			task.wait(15) -- Spawn new crystal every 15 seconds
			if activeCrystalCount < 30 then -- Max 30 crystals in world
				self:SpawnCrystal()
			end
		end
	end)
	
	-- Initial spawn
	task.wait(2)
	self:SpawnStarterCrystals()
	
	for i = 1, 10 do
		self:SpawnCrystal()
	end
end

function CrystalService:SpawnStarterCrystals()
	-- Guarantee letters for first words: CAT, DOG, RUN, BIG + extras
	-- Placed close to spawn so a kid can build a word in under a minute
	local starterLetters = {"C", "A", "T", "D", "O", "G", "R", "U", "N", "B", "I", "E", "S", "H"}
	local center = Vector3.new(0, 5, 0)
	
	for i, letter in ipairs(starterLetters) do
		local angle = (i / #starterLetters) * math.pi * 2
		local radius = 12 -- Close to spawn!
		local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		
		local crystal: LetterCrystal = {
			InstanceId = HttpService:GenerateGUID(false),
			Letter = letter,
			Rarity = "Common",
			Position = pos,
		}
		
		activeCrystals[crystal.InstanceId] = crystal
		activeCrystalCount += 1
		crystalModels[crystal.InstanceId] = createCrystalModel(crystal)
	end
	print("[CrystalService] Spawned " .. #starterLetters .. " starter crystals near spawn (CAT, DOG, RUN, BIG).")
end

function CrystalService:SpawnCrystal()
	-- Determine district first (to get position AND letter preference)
	local district = getRandomDistrict()
	local letter = selectDistrictLetter(district)
	local rarity = selectRarity()
	local position = getRandomSpawnPosition()
	
	local crystal: LetterCrystal = {
		InstanceId = HttpService:GenerateGUID(false),
		Letter = letter,
		Rarity = rarity,
		Position = position,
	}
	
	activeCrystals[crystal.InstanceId] = crystal
	activeCrystalCount += 1
	crystalModels[crystal.InstanceId] = createCrystalModel(crystal)
	
	-- Broadcast to clients
	self.Client.CrystalSpawned:FireAll(crystal.InstanceId, crystal.Letter, crystal.Position, crystal.Rarity)
	print("[CrystalService] Spawned " .. rarity .. " crystal: " .. letter)
end

function CrystalService:CollectCrystal(player: Player, crystalId: string)
	local now = tick()
	if not rateLimits[player] then rateLimits[player] = { Collect = 0, Use = 0 } end
	if now - rateLimits[player].Collect < 0.2 then return nil end -- Rate limit: 5/sec
	rateLimits[player].Collect = now

	local crystal = activeCrystals[crystalId]
	if not crystal then return nil end
	
	-- Security: Distance Check
	if player.Character and player.Character.PrimaryPart then
		local distance = (player.Character.PrimaryPart.Position - crystal.Position).Magnitude
		if distance > 25 then
			warn("[Security] " .. player.Name .. " tried to collect crystal from too far away (Distance: " .. distance .. ")")
			return nil
		end
	end
	
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
	activeCrystalCount = math.max(0, activeCrystalCount - 1)
	
	-- Notify client
	self.Client.CrystalCollected:Fire(player, crystal.Letter, crystal.Rarity)
	print("[CrystalService] " .. player.Name .. " collected crystal: " .. crystal.Letter .. " (" .. crystal.Rarity .. ")")
	
	-- Track progress
	local success, GameLoopService = pcall(function()
		return Knit.GetService("GameLoopService")
	end)
	
	if success and GameLoopService then
		local progressSuccess, progressError = pcall(function()
			GameLoopService:IncrementProgress(player, "Collection", 1)
		end)
		if not progressSuccess then
			warn("[CrystalService] Error tracking progress:", progressError)
		end
	else
		warn("[CrystalService] GameLoopService not available for progress tracking")
	end
	
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
		local letter = string.sub(word, i, i):upper()
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
	local now = tick()
	if not rateLimits[player] then rateLimits[player] = { Collect = 0, Use = 0 } end
	if now - rateLimits[player].Use < 0.5 then return false end -- Rate limit: 2/sec
	rateLimits[player].Use = now

	if not self:CanFormWord(player, word) then
		return false
	end
	
	local inventory = playerInventories[player]
	
	-- Remove letters used (uppercase to match inventory keys)
	for i = 1, #word do
		local letter = string.sub(word, i, i):upper()
		inventory[letter] = (inventory[letter] or 1) - 1
	end
	
	return true
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	playerInventories[player] = nil
	rateLimits[player] = nil
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

-- Bonus methods for phase objectives
function CrystalService:SpawnRareCrystal(player: Player)
	-- Validate player
	if not player or not player.Parent then
		warn("[CrystalService] Invalid player for rare crystal spawn")
		return
	end
	
	-- Get safe player position
	local playerPos = Vector3.new(0, 10, 0) -- Default fallback
	if player.Character and player.Character.PrimaryPart then
		playerPos = player.Character.PrimaryPart.Position
	else
		warn("[CrystalService] Player character not found, using fallback position")
	end
	
	-- Spawn a guaranteed Rare or Epic crystal near the player
	local rarity = math.random(1, 100) <= 70 and "Epic" or "Rare"
	local letter = selectRandomLetter()
	
	local offset = Vector3.new(math.random(-30, 30), 10, math.random(-30, 30))
	local position = playerPos + offset
	
	local crystal: LetterCrystal = {
		InstanceId = HttpService:GenerateGUID(false),
		Letter = letter,
		Rarity = rarity,
		Position = position,
	}
	
	activeCrystals[crystal.InstanceId] = crystal
	activeCrystalCount += 1
	crystalModels[crystal.InstanceId] = createCrystalModel(crystal)
	
	self.Client.CrystalSpawned:FireAll(crystal.InstanceId, crystal.Letter, crystal.Position, crystal.Rarity)
	print("[CrystalService] Spawned bonus " .. rarity .. " crystal for " .. player.Name .. ": " .. letter)
end

function CrystalService:GrantBonusLetters(player: Player, amount: number)
	if not playerInventories[player] then
		playerInventories[player] = {}
	end
	
	-- Grant random common letters
	local commonLetters = {"E", "A", "I", "O", "N", "R", "T", "L", "S", "U"}
	for i = 1, amount do
		local letter = commonLetters[math.random(1, #commonLetters)]
		playerInventories[player][letter] = (playerInventories[player][letter] or 0) + 1
	end
	
	print("[CrystalService] Granted " .. amount .. " bonus letters to " .. player.Name)
end

return CrystalService
