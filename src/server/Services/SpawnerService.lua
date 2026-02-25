--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

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

-- District spawn zones (based on TownBlueprint)
local DISTRICT_ZONES = {
	Logos = { Center = Vector3.new(0, 0, -350), Radius = 200, Element = "Air" },
	Eros = { Center = Vector3.new(0, 0, 350), Radius = 200, Element = "Water" },
	Pneuma = { Center = Vector3.new(350, 0, 0), Radius = 200, Element = "Light" },
	Soma = { Center = Vector3.new(-350, 0, 0), Radius = 200, Element = "Fire" },
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
    -- Pick random position in wilderness ring
    local angle = math.random() * math.pi * 2
    local dist = math.random(SPAWN_RADIUS_INNER, SPAWN_RADIUS_OUTER)
    
    local x = math.cos(angle) * dist
    local z = math.sin(angle) * dist
    
    -- Determine element based on position (district influence)
    if not element then
        local pos = Vector3.new(x, 0, z)
        local closestDistrict = nil
        local closestDist = math.huge
        
        for district, zone in pairs(DISTRICT_ZONES) do
            local d = (pos - zone.Center).Magnitude
            if d < closestDist then
                closestDist = d
                closestDistrict = district
            end
        end
        
        if closestDistrict and math.random() < 0.6 then
            element = DISTRICT_ZONES[closestDistrict].Element
        else
            -- Random element
            local elements = {"Fire", "Water", "Earth", "Air", "Shadow", "Light"}
            element = elements[math.random(1, #elements)]
        end
    end
    
    -- Get random word from SynonymDatabase
    local term = SynonymDatabase.GetRandomWord(element)
    local wordElement = SynonymDatabase.GetElement(term) or element or "Normal"
    
    local id = HttpService:GenerateGUID(false)
    local position = Vector3.new(x, SPAWN_Y, z)
    
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