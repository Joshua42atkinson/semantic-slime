--!strict
--==============================================================
-- MMMM Context: Manages interactive stations where players solve Mad Libs. Translates mechanical word-building into pedagogical outcomes.
--==============================================================
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LearningStationData = require(ReplicatedStorage.Shared.LearningStationData)

local LearningStationService = Knit.CreateService {
    Name = "LearningStationService",
    Client = {},
}

-- Track which players have discovered which stations
local discoveredStations = {}

function LearningStationService:KnitStart()
    print("[LearningStationService] Initialized")
end

-- Spawn a learning station in a building
function LearningStationService:SpawnStation(buildingName: string, districtName: string, cframe: CFrame)
    local stationData = LearningStationData.GetForBuilding(buildingName, districtName)
    if not stationData then
        warn("[LearningStationService] No station data for: " .. buildingName)
        return nil
    end
    
    -- Create the station model
    local station = Instance.new("Model")
    station.Name = "LearningStation_" .. stationData.Id
    
    -- Pedestal base
    local pedestal = Instance.new("Part")
    pedestal.Name = "Pedestal"
    pedestal.Size = Vector3.new(4, 6, 4)
    pedestal.CFrame = cframe * CFrame.new(0, 3, 0)
    pedestal.Anchored = true
    pedestal.Material = Enum.Material.Marble
    pedestal.Color = Color3.fromHex("#E2E8F0")
    pedestal.CanCollide = true
    pedestal.Parent = station
    
    -- Glowing orb on top
    local orb = Instance.new("Part")
    orb.Name = "KnowledgeOrb"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(3, 3, 3)
    orb.CFrame = cframe * CFrame.new(0, 8, 0)
    orb.Anchored = true
    orb.Material = Enum.Material.Neon
    orb.Color = stationData.WordRoot and Color3.fromHex("#60A5FA") or Color3.fromHex("#FCD34D")
    orb.Transparency = 0.2
    orb.Parent = station
    
    -- Point light
    local light = Instance.new("PointLight")
    light.Color = orb.Color
    light.Brightness = 2
    light.Range = 15
    light.Parent = orb
    
    -- Proximity prompt to interact
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LearnPrompt"
    prompt.ActionText = "Learn"
    prompt.ObjectText = stationData.Title
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0
    prompt.Parent = pedestal
    
    -- Store station data for client
    station:SetAttribute("StationId", stationData.Id)
    station:SetAttribute("Title", stationData.Title)
    station:SetAttribute("Content", stationData.Content)
    station:SetAttribute("WordRoot", stationData.WordRoot or "")
    
    -- Handle interaction
    prompt.Triggered:Connect(function(player)
        self:ShowStationUI(player, stationData)
    end)
    
    -- Billboard GUI label
    local billGui = Instance.new("BillboardGui")
    billGui.Size = UDim2.new(0, 200, 0, 50)
    billGui.StudsOffset = Vector3.new(0, 8, 0)
    billGui.AlwaysOnTop = true
    billGui.Parent = orb
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = stationData.Title
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billGui
    
    station.Parent = Workspace
    
    print("[LearningStationService] Spawned station: " .. stationData.Title)
    return station
end

-- Show the learning station UI to a player
function LearningStationService:ShowStationUI(player: Player, stationData: table)
    -- Track discovery
    if not discoveredStations[player.UserId] then
        discoveredStations[player.UserId] = {}
    end
    
    if not discoveredStations[player.UserId][stationData.Id] then
        discoveredStations[player.UserId][stationData.Id] = true
        -- Award XP or currency for discovering new station
        print("[LearningStationService] Player " .. player.Name .. " discovered: " .. stationData.Title)
    end
    
    -- Fire remote event to show UI
    local remotesMod = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Remotes")
    local remotes = (remotesMod and remotesMod:IsA("ModuleScript")) and require(remotesMod) or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes", 10)
    local showLearningEvent = remotes:WaitForChild("ShowLearningStation")
    showLearningEvent:FireClient(player, stationData)
end

-- Get discovery progress for a player
function LearningStationService:GetDiscoveryProgress(playerId: number): number
    local discovered = discoveredStations[playerId] or {}
    local totalStations = 0
    for _ in pairs(LearningStationData.Stations) do
        totalStations = totalStations + 1
    end
    
    local discoveredCount = 0
    for _ in pairs(discovered) do
        discoveredCount = discoveredCount + 1
    end
    
    return discoveredCount / totalStations
end

-- Spawn all stations for a district
function LearningStationService:SpawnDistrictStations(districtName: string, districtCenter: Vector3)
    local stations = LearningStationData.GetForDistrict(districtName)
    
    for _, stationData in ipairs(stations) do
        -- Position station in front of building area
        local pos = districtCenter + Vector3.new(
            (math.random() - 0.5) * 50,
            0,
            (math.random() - 0.5) * 50
        )
        local cf = CFrame.new(pos)
        
        self:SpawnStation(stationData.BuildingName, districtName, cf)
    end
end

return LearningStationService
