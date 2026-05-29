--!strict
-- DataBridgeService.lua
-- Handles data synchronization between Ubuntu and Roblox Studio via MCP Bridge

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DataBridgeService = Knit.CreateService {
    Name = "DataBridgeService",
    Client = {
        DataSynced = Knit.CreateSignal(),
        BridgeStatus = Knit.CreateSignal(),
    },
}

-- Configuration
local BRIDGE_CONFIG = {
    ENDPOINT = "http://localhost:3001",
    POLL_INTERVAL = 0.2, -- 200ms as per MCP Bridge spec
    MAX_RETRIES = 3,
    TIMEOUT = 10,
}

-- Private state
local bridgeConnected = false
local pendingDataQueue = {}
local syncInProgress = false

-- Data types we can push
export type SyncData = {
    Type: "SlimeData" | "QuestProgress" | "PlayerStats" | "WorldState",
    PlayerId: string,
    Timestamp: number,
    Payload: {[string]: any},
}

-- MCP Bridge command wrappers
local function executeMCPCommand(command: string, params: any?): boolean
    local payload = {
        command = command,
        parameters = params or {},
        timestamp = tick(),
    }
    
    for attempt = 1, BRIDGE_CONFIG.MAX_RETRIES do
        local success, result = pcall(function()
            return HttpService:PostAsync(
                BRIDGE_CONFIG.ENDPOINT .. "/api/execute",
                HttpService:JSONEncode(payload),
                Enum.HttpContentType.ApplicationJson,
                false
            )
        end)
        
        if success then
            local response = HttpService:JSONDecode(result)
            if response.success then
                return true
            else
                warn("[DataBridgeService] MCP Command failed:", response.error)
            end
        else
            warn("[DataBridgeService] MCP Request attempt", attempt, "failed:", result)
        end
        
        task.wait(1) -- Wait before retry
    end
    
    return false
end

-- Test bridge connectivity
function DataBridgeService:TestConnection(): boolean
    local success = executeMCPCommand("get_services", {})
    bridgeConnected = success
    
    self.Client.BridgeStatus:FireAll({
        Connected = success,
        Timestamp = tick(),
        Endpoint = BRIDGE_CONFIG.ENDPOINT
    })
    
    return success
end

-- Push data to Ubuntu via MCP Bridge
function DataBridgeService:PushData(data: SyncData): boolean
    if not bridgeConnected then
        warn("[DataBridgeService] Bridge not connected - queueing data")
        table.insert(pendingDataQueue, data)
        return false
    end
    
    -- Create Lua script to handle data reception
    local scriptTemplate = [[
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data received from Ubuntu
local data = %s

-- Route to appropriate handler
if data.Type == "SlimeData" then
    local SlimeFactory = require(ReplicatedStorage.Shared.SlimeFactory)
    SlimeFactory:ProcessExternalData(data.Payload)
elseif data.Type == "QuestProgress" then
    local GameLoopService = game:GetService("ServerScriptService").Server.Services.GameLoopService
    GameLoopService:ProcessExternalQuestData(data.Payload)
elseif data.Type == "PlayerStats" then
    local DataService = game:GetService("ServerScriptService").Server.Services.DataService
    DataService:UpdatePlayerStats(data.PlayerId, data.Payload)
elseif data.Type == "WorldState" then
    local TownGenerator = game:GetService("ServerScriptService").Server.Services.TownGenerator
    TownGenerator:UpdateWorldState(data.Payload)
end

print("[DataBridge] Processed external data:", data.Type, "for player:", data.PlayerId)
]]
    
    local formattedScript = string.format(scriptTemplate, HttpService:JSONEncode(data))
    
    local success = executeMCPCommand("execute_luau", {
        script = formattedScript,
        runInPlayMode = true
    })
    
    if success then
        self.Client.DataSynced:FireAll({
            Type = data.Type,
            PlayerId = data.PlayerId,
            Success = true,
            Timestamp = tick()
        })
    end
    
    return success
end

-- Process queued data
local function processQueue()
    if #pendingDataQueue > 0 and not syncInProgress then
        syncInProgress = true
        
        task.spawn(function()
            while #pendingDataQueue > 0 do
                local data = table.remove(pendingDataQueue, 1)
                DataBridgeService:PushData(data)
                task.wait(0.1) -- Small delay between operations
            end
            syncInProgress = false
        end)
    end
end

-- Client methods
function DataBridgeService.Client:RequestSync(player: Player, dataType: string)
    if type(dataType) ~= "string" then return end
    return self.Server:RequestSync(player, dataType)
end

function DataBridgeService:RequestSync(player: Player, dataType: string)
    -- Create sync request for specific data type
    local syncData: SyncData = {
        Type = dataType,
        PlayerId = tostring(player.UserId),
        Timestamp = tick(),
        Payload = {
            RequestType = "Sync",
            RequestedBy = player.Name,
            DataNeeded = dataType
        }
    }
    
    return self:PushData(syncData)
end

-- Service lifecycle
function DataBridgeService:KnitStart()
    print("[DataBridgeService] Starting...")
    
    -- Test initial connection (max 3 attempts, then go silent)
    task.spawn(function()
        local maxAttempts = 3
        local attempt = 0
        while attempt < maxAttempts do
            attempt += 1
            if self:TestConnection() then
                print("[DataBridgeService] Connected to MCP Bridge!")
                return
            end
            if attempt < maxAttempts then
                task.wait(5)
            end
        end
        print("[DataBridgeService] MCP Bridge not available — running in offline mode. This is normal for Studio testing.")
    end)
    
    -- Process queue periodically
    task.spawn(function()
        while true do
            processQueue()
            task.wait(BRIDGE_CONFIG.POLL_INTERVAL)
        end
    end)
    
    print("[DataBridgeService] Started. Bridge endpoint:", BRIDGE_CONFIG.ENDPOINT)
end

function DataBridgeService:KnitStop()
    print("[DataBridgeService] Stopping...")
    bridgeConnected = false
end

-- Utility functions for other services
function DataBridgeService:SyncSlimeData(player: Player, slime: any)
    local data: SyncData = {
        Type = "SlimeData",
        PlayerId = tostring(player.UserId),
        Timestamp = tick(),
        Payload = {
            InstanceId = slime.InstanceId,
            Term = slime.Term,
            Stats = slime.Stats,
            Element = slime.Element,
            Role = slime.Role,
            Rarity = slime.Rarity,
            ContextPoints = slime.ContextPoints
        }
    }
    
    return self:PushData(data)
end

function DataBridgeService:SyncQuestProgress(player: Player, quest: any)
    local data: SyncData = {
        Type = "QuestProgress",
        PlayerId = tostring(player.UserId),
        Timestamp = tick(),
        Payload = {
            QuestId = quest.QuestId,
            Title = quest.Title,
            Progress = quest.Progress,
            Completed = quest.Completed,
            Rewards = quest.Rewards
        }
    }
    
    return self:PushData(data)
end

function DataBridgeService:SyncPlayerStats(player: Player, stats: {[string]: any})
    local data: SyncData = {
        Type = "PlayerStats",
        PlayerId = tostring(player.UserId),
        Timestamp = tick(),
        Payload = stats
    }
    
    return self:PushData(data)
end

function DataBridgeService:SyncWorldState(worldData: {[string]: any})
    local data: SyncData = {
        Type = "WorldState",
        PlayerId = "SYSTEM",
        Timestamp = tick(),
        Payload = worldData
    }
    
    return self:PushData(data)
end

return DataBridgeService
