--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TypoService = Knit.CreateService {
	Name = "TypoService",
	Client = {
		TypoSpawned = Knit.CreateSignal(),
		TypoDefeated = Knit.CreateSignal(),
		BossSpawned = Knit.CreateSignal(),
		BossDefeated = Knit.CreateSignal(),
	},
}

-- Types
export type TypoEnemy = {
	InstanceId: string,
	TypoType: string,
	DisplayName: string,
	GlitchedWord: string,
	Element: string,
	Level: number,
	Health: number,
	MaxHealth: number,
	Attack: number,
	Defense: number,
	Speed: number,
	Weakness: string,
	Resistance: string,
	DropTable: { { item: string, chance: number } },
	IsBoss: boolean,
	Position: Vector3,
}

-- Configuration: 7 Typo enemy types
local TYPHO_TYPES = {
	["Glimmer"] = {
		Name = "Glimmer",
		Description = "A flickering typo that glows with corrupted meaning",
		BaseHealth = 50,
		BaseAttack = 8,
		BaseDefense = 3,
		BaseSpeed = 12,
		Element = "Light",
		Weakness = "Shadow",
		Resistance = "Light",
		GlitchedWords = { "lite", "lite", "brite", "nite", "whit" },
		QuestDrops = { "anti-" },
	},
	["Shadowcap"] = {
		Name = "Shadowcap",
		Description = "A dark typo that lurks in the corners of meaning",
		BaseHealth = 60,
		BaseAttack = 10,
		BaseDefense = 5,
		BaseSpeed = 8,
		Element = "Shadow",
		Weakness = "Light",
		Resistance = "Shadow",
		GlitchedWords = { "derk", "thur", "nite", "wurk" },
		QuestDrops = { "-less" },
	},
	["Flamer"] = {
		Name = "Flamer",
		Description = "A hotheaded typo that burns through vocabulary",
		BaseHealth = 45,
		BaseAttack = 15,
		BaseDefense = 2,
		BaseSpeed = 10,
		Element = "Fire",
		Weakness = "Water",
		Resistance = "Fire",
		GlitchedWords = { "fery", "fier", "burn", "helm" },
		QuestDrops = { "pre-" },
	},
	["Droplet"] = {
		Name = "Droplet",
		Description = "A soggy typo that drowns proper spelling",
		BaseHealth = 70,
		BaseAttack = 8,
		BaseDefense = 8,
		BaseSpeed = 6,
		Element = "Water",
		Weakness = "Fire",
		Resistance = "Water",
		GlitchedWords = { "watre", "wierd", "thier", "recieve" },
		QuestDrops = { "-ful" },
	},
	["Stoneheart"] = {
		Name = "Stoneheart",
		Description = "A stubborn typo that refuses correction",
		BaseHealth = 100,
		BaseAttack = 6,
		BaseDefense = 12,
		BaseSpeed = 4,
		Element = "Earth",
		Weakness = "Air",
		Resistance = "Earth",
		GlitchedWords = { "tru", "thru", "gal" },
		QuestDrops = { "struct-" },
	},
	["Breeze"] = {
		Name = "Breeze",
		Description = "A swift typo that blows letters around",
		BaseHealth = 40,
		BaseAttack = 12,
		BaseDefense = 3,
		BaseSpeed = 15,
		Element = "Air",
		Weakness = "Earth",
		Resistance = "Air",
		GlitchedWords = { "writ", " rite", "peice", "sence" },
		QuestDrops = { "-ly" },
	},
	["Glitch"] = {
		Name = "Glitch",
		Description = "A random collection of corrupted letters",
		BaseHealth = 55,
		BaseAttack = 11,
		BaseDefense = 5,
		BaseSpeed = 11,
		Element = "Normal",
		Weakness = "Normal",
		Resistance = "Normal",
		GlitchedWords = { "teh", "dont", "cant", "wont", "shud" },
		QuestDrops = { "un-" },
	},
}

-- The Static Boss configuration
local STATIC_BOSS = {
	Name = "The Static",
	Description = "The void between meaning - the ultimate enemy of language",
	BaseHealth = 500,
	BaseAttack = 25,
	BaseDefense = 15,
	BaseSpeed = 5,
	Element = "Shadow",
	Weakness = "Light",
	Resistance = "Shadow",
	GlitchedWords = { "nthing", "evrything", "sumthing", "anyon" },
	Phase = 1,
	MaxPhase = 3,
}

-- Location-based spawn configuration
local DISTRICT_SPAWN_RULES = {
	["Heartwood Grove"] = {
		PrimaryTypes = { "Glimmer", "Shadowcap" },
		SecondaryTypes = { "Glitch" },
		MinLevel = 1,
		MaxLevel = 3,
		SpawnRate = 0.3,
	},
	["Action Alley"] = {
		PrimaryTypes = { "Flamer", "Droplet" },
		SecondaryTypes = { "Glitch", "Stoneheart" },
		MinLevel = 2,
		MaxLevel = 5,
		SpawnRate = 0.4,
	},
	["Whisper Winds"] = {
		PrimaryTypes = { "Breeze", "Droplet" },
		SecondaryTypes = { "Glimmer" },
		MinLevel = 3,
		MaxLevel = 6,
		SpawnRate = 0.35,
	},
	["The Brainy Borough"] = {
		PrimaryTypes = { "Glitch", "Shadowcap" },
		SecondaryTypes = { "Stoneheart" },
		MinLevel = 4,
		MaxLevel = 7,
		SpawnRate = 0.25,
	},
	["Town Hub"] = {
		PrimaryTypes = { "Flamer", "Stoneheart", "Glitch" },
		SecondaryTypes = { "Breeze", "Droplet" },
		MinLevel = 1,
		MaxLevel = 8,
		SpawnRate = 0.2,
	},
}

-- Private state
local activeTypoes: { [string]: TypoEnemy } = {}
local spawnedNPCs: { [string]: Model } = {}
local bossActive = false

-- Helper: Create a Typo enemy instance
local function createTypoInstance(typoType: string, level: number, isBoss: boolean): TypoEnemy
	local config = isBoss and STATIC_BOSS or TYPHO_TYPES[typoType]
	if not config then
		config = TYPHO_TYPES["Glitch"]
	end
	
	local levelMultiplier = 1 + (level - 1) * 0.15
	
	return {
		InstanceId = HttpService:GenerateGUID(false),
		TypoType = typoType,
		DisplayName = config.Name,
		GlitchedWord = config.GlitchedWords[math.random(1, #config.GlitchedWords)],
		Element = config.Element,
		Level = level,
		Health = math.floor(config.BaseHealth * levelMultiplier),
		MaxHealth = math.floor(config.BaseHealth * levelMultiplier),
		Attack = math.floor(config.BaseAttack * levelMultiplier),
		Defense = math.floor(config.BaseDefense * levelMultiplier),
		Speed = math.floor(config.BaseSpeed * levelMultiplier),
		Weakness = config.Weakness,
		Resistance = config.Resistance,
		DropTable = config.QuestDrops and { { item = config.QuestDrops[1], chance = 0.5 } } or {},
		IsBoss = isBoss,
		Position = Vector3.zero,
	}
end

-- Helper: Calculate damage with elemental weakness
local function calculateDamage(attackStat: number, defenseStat: number, attackerElement: string, defenderElement: string, defenderWeakness: string): number
	local baseDamage = attackStat - (defenseStat * 0.5)
	
	-- Elemental effectiveness
	if defenderWeakness == attackerElement then
		baseDamage = baseDamage * 1.5
	elseif defenderElement == attackerElement then
		baseDamage = baseDamage * 0.5
	end
	
	return math.max(1, math.floor(baseDamage))
end

-- [TYPHO-001] Spawn a Typo enemy
function TypoService:SpawnTypo(distribution: string, level: number, position: Vector3): TypoEnemy?
	local spawnRules = DISTRICT_SPAWN_RULES[distribution]
	if not spawnRules then
		warn("[TypoService] Unknown district: " .. distribution)
		return nil
	end
	
	-- Determine typo type
	local typoType
	local roll = math.random()
	if roll < 0.6 and #spawnRules.PrimaryTypes > 0 then
		typoType = spawnRules.PrimaryTypes[math.random(1, #spawnRules.PrimaryTypes)]
	elseif #spawnRules.SecondaryTypes > 0 then
		typoType = spawnRules.SecondaryTypes[math.random(1, #spawnRules.SecondaryTypes)]
	else
		typoType = "Glitch"
	end
	
	local clampedLevel = math.clamp(level, spawnRules.MinLevel, spawnRules.MaxLevel)
	local typo = createTypoInstance(typoType, clampedLevel, false)
	typo.Position = position
	
	activeTypoes[typo.InstanceId] = typo
	
	self.Client.TypoSpawned:Fire(nil, typo)
	print("[TypoService] Spawned " .. typo.DisplayName .. " at " .. distribution .. " (Level " .. clampedLevel .. ")")
	
	return typo
end

-- [TYPHO-002] Spawn The Static boss
function TypoService:SpawnBoss(position: Vector3): TypoEnemy?
	if bossActive then
		warn("[TypoService] Boss already active!")
		return nil
	end
	
	local boss = createTypoInstance("The Static", 10, true)
	boss.Position = position
	
	activeTypoes[boss.InstanceId] = boss
	bossActive = true
	
	self.Client.BossSpawned:Fire(nil, boss)
	print("[TypoService] Spawned THE STATIC boss!")
	
	return boss
end

-- [TYPHO-003] Attack a Typo
function TypoService:AttackTypo(player: Player, typoId: string, slimeAttack: number, slimeElement: string): (number, boolean, string?)
	local typo = activeTypoes[typoId]
	if not typo then
		return 0, false, "Typo not found"
	end
	
	local damage = calculateDamage(slimeAttack, typo.Defense, slimeElement, typo.Element, typo.Weakness)
	typo.Health = typo.Health - damage
	
	local isDefeated = typo.Health <= 0
	
	if isDefeated then
		-- Remove from active
		activeTypoes[typoId] = nil
		
		if typo.IsBoss then
			bossActive = false
			self.Client.BossDefeated:Fire(player, typo)
			print("[TypoService] " .. player.Name .. " defeated THE STATIC!")
		else
			self.Client.TypoDefeated:Fire(player, typo)
			print("[TypoService] " .. player.Name .. " defeated " .. typo.DisplayName)
		end
	end
	
	return damage, isDefeated, nil
end

-- [TYPHO-004] Get active Typoes in area
function TypoService:GetTypoesInArea(center: Vector3, radius: number): { TypoEnemy }
	local result = {}
	
	for _, typo in pairs(activeTypoes) do
		if (typo.Position - center).Magnitude <= radius then
			table.insert(result, typo)
		end
	end
	
	return result
end

-- [TYPHO-005] Get boss status
function TypoService:IsBossActive(): boolean
	return bossActive
end

-- [TYPHO-006] Get all active Typoes
function TypoService:GetActiveTypoes(): { TypoEnemy }
	return activeTypoes
end

-- [TYPHO-007] Elemental weakness checker
function TypoService:CheckElementalWeakness(attackerElement: string, defenderTypoId: string): string
	local typo = activeTypoes[defenderTypoId]
	if not typo then
		return "normal"
	end
	
	if attackerElement == typo.Weakness then
		return "super_effective"
	elseif attackerElement == typo.Resistance then
		return "not_effective"
	end
	
	return "normal"
end

function TypoService:KnitStart()
	print("[TypoService] Started.")
end

return TypoService
