--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local Blueprint = require(ReplicatedStorage.Shared.TownBlueprint)

local SynonymDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SynonymDatabase"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local SpawnerService = Knit.CreateService {
    Name = "SpawnerService",
    Client = {
        SlimeSpawned = Knit.CreateSignal(),
        SlimeDespawned = Knit.CreateSignal(),
    },
}

-- Config
local SPAWN_RADIUS_INNER = 150  -- Start of wilderness
local SPAWN_RADIUS_OUTER = 600  -- Edge of map
local SPAWN_Y = 5
local MAX_SLIMES = 50           -- Per element type
local SPAWN_INTERVAL = 2        -- Seconds between spawns

-- State
local slimes: { [string]: any } = {} -- [id] = {Position, Term, Element, Model}
local lastSpawn = 0
local slimeRemotes: Folder? = nil

-- District spawn zones — centers match TownBlueprint.Settings.OffsetFromCenter
local offset = Blueprint.Settings.OffsetFromCenter
local DISTRICT_ZONES = {
	BrainyBorough = { Center = Blueprint.Districts.BrainyBorough.Direction * offset, RadiusMin = 40, RadiusMax = 400, Element = "Air", Words = {"ancient", "logic", "brilliant", "precise", "knowledge", "archive", "scholar", "wisdom", "clarity"} },
	HeartwoodGrove  = { Center = Blueprint.Districts.HeartwoodGrove.Direction * offset,  RadiusMin = 40, RadiusMax = 400, Element = "Earth", Words = {"vibrant", "nature", "flourish", "blossom", "tender", "verdant", "gentle", "serene", "harvest"} },
	WhisperWinds= { Center = Blueprint.Districts.WhisperWinds.Direction * offset,  RadiusMin = 40, RadiusMax = 400, Element = "Light", Words = {"radiant", "ethereal", "dream", "spirit", "luminous", "ascend", "celestial", "vision", "inspire"} },
	ActionAlley  = { Center = Blueprint.Districts.ActionAlley.Direction * offset, RadiusMin = 40, RadiusMax = 400, Element = "Fire",  Words = {"blazing", "fierce", "ignite", "smolder", "ember", "furious", "combust", "volatile", "sear"} },
}

function SpawnerService:KnitStart()
    print("[SpawnerService] Initializing Etymon Spawner...")
    
    -- Setup remotes for non-Knit clients
    slimeRemotes = ReplicatedStorage:FindFirstChild("SlimeRemotes")
    if not slimeRemotes then
        slimeRemotes = Instance.new("Folder")
        slimeRemotes.Name = "SlimeRemotes"
        slimeRemotes.Parent = ReplicatedStorage
    end
    
    -- Start spawn loop
    RunService.Heartbeat:Connect(function(dt)
        self:Update(dt)
    end)
    
    -- Initial spawn
    for i = 1, 20 do
        self:SpawnOne()
    end
    
    print("[SpawnerService] Started. Initial slimes spawned.")
end

function SpawnerService:Update(dt: number)
    lastSpawn += dt
    
    if lastSpawn >= GameConfig.WORD_SPAWN_INTERVAL or lastSpawn >= SPAWN_INTERVAL then
        local totalSlimes = self:CountSlimes()
        if totalSlimes < GameConfig.MAX_WILD_WORDS then
            self:SpawnOne()
        end
        lastSpawn = 0
    end
end

function SpawnerService:CountSlimes(): number
    local count = 0
    for _ in pairs(slimes) do count += 1 end
    return count
end

function SpawnerService:GetSlimesInRadius(position: Vector3, radius: number): { any }
    local result = {}
    for id, slime in pairs(slimes) do
        if (slime.Position - position).Magnitude <= radius then
            result[id] = slime
        end
    end
    return result
end

function SpawnerService:SpawnOne(element: string?)
	-- Pick a random district to spawn in
	local districtNames = { "BrainyBorough", "HeartwoodGrove", "WhisperWinds", "ActionAlley" }
	local district = DISTRICT_ZONES[districtNames[math.random(1, #districtNames)]]

	-- If a specific element was requested, find the matching district
	if element then
		for _, zone in pairs(DISTRICT_ZONES) do
			if zone.Element == element then
				district = zone
				break
			end
		end
	end

	-- Random point inside the district city pad
	local angle = math.random() * math.pi * 2
	local radius = math.random(district.RadiusMin, district.RadiusMax)
	local offsetX = math.cos(angle) * radius
	local offsetZ = math.sin(angle) * radius

	local position = Vector3.new(
		district.Center.X + offsetX,
		district.Center.Y,
		district.Center.Z + offsetZ
	)

	-- Pick a word: 70% chance district vocabulary, 30% chance SynonymDatabase
	local term
	if math.random() < 0.7 and #district.Words > 0 then
		term = district.Words[math.random(1, #district.Words)]
	else
		local ok, result = pcall(function()
			return SynonymDatabase.GetRandomWord(district.Element)
		end)
		term = (ok and result) or district.Words[1]
	end

	local wordElement = district.Element

	local id = HttpService:GenerateGUID(false)
	self:CreateSlime(id, term, position, wordElement)
end

function SpawnerService:CreateSlime(id: string, term: string, pos: Vector3, element: string)
    -- Store server-side data
    slimes[id] = {
        Id = id,
        Term = term,
        Position = pos,
        Element = element,
        SpawnTime = tick(),
    }
    
    -- Notify all clients to spawn visual
    self.Client.SlimeSpawned:FireAll(id, term, pos, element)
    
    -- Also fire to SlimeRemotes for compatibility
    if slimeRemotes then
        local spawnEvent = slimeRemotes:FindFirstChild("SlimeSpawned")
        if spawnEvent and spawnEvent:IsA("RemoteEvent") then
            spawnEvent:FireAllClients(id, term, pos, element)
        end
    end
    
    print(string.format("[SpawnerService] Spawned %s (%s) at %s", term, element, tostring(pos)))
end

function SpawnerService:RemoveSlime(id: string, captured: boolean)
    local slime = slimes[id]
    if not slime then return end
    
    -- Notify all clients
    self.Client.SlimeDespawned:FireAll(id, captured)
    
    -- Also fire to SlimeRemotes for compatibility
    if slimeRemotes then
        local despawnEvent = slimeRemotes:FindFirstChild("SlimeDespawned")
        if despawnEvent and despawnEvent:IsA("RemoteEvent") then
            despawnEvent:FireAllClients(id, captured)
        end
    end
    
    slimes[id] = nil
    print(string.format("[SpawnerService] Removed %s (%s)", slime.Term, captured and "captured" or "despawned"))
end

-- Called by LureService when a player successfully captures a slime
function SpawnerService:CaptureSlime(player: Player, term: string): boolean
    -- Find the slime by term
    for id, slime in pairs(slimes) do
        if slime.Term:lower() == term:lower() then
            self:RemoveSlime(id, true)
            return true
        end
    end
    return false
end

-- Get slime data for a specific ID
function SpawnerService:GetSlime(id: string): any?
    return slimes[id]
end

-- Get all active slimes (for debugging/admin)
function SpawnerService:GetAllSlimes(): { [string]: any }
    return slimes
end

-- Force spawn a specific word (for testing/admin)
function SpawnerService:ForceSpawn(term: string, position: Vector3?, element: string?)
    local id = HttpService:GenerateGUID(false)
    local pos = position or Vector3.new(
        math.random(-SPAWN_RADIUS_OUTER, SPAWN_RADIUS_OUTER),
        SPAWN_Y,
        math.random(-SPAWN_RADIUS_OUTER, SPAWN_RADIUS_OUTER)
    )
    local wordElement = element or SynonymDatabase.GetElement(term) or "Normal"
    
    self:CreateSlime(id, term, pos, wordElement)
    return id
end

return SpawnerService