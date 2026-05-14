--!strict
-- Performance Monitor Service for Semantic Slime
-- Tracks server performance, service health, and player experience

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local PerformanceMonitor = Knit.CreateService {
    Name = "PerformanceMonitor",
    Client = {
        PerformanceUpdate = Knit.CreateSignal(),
    },
}

-- Configuration
local UPDATE_INTERVAL = 5 -- seconds
local MEMORY_WARNING_THRESHOLD = 500 -- MB
local FPS_WARNING_THRESHOLD = 30
local PLAYER_COUNT_WARNING = 100

-- Performance metrics
local metrics = {
    ServerFPS = 60,
    MemoryUsage = 0,
    PlayerCount = 0,
    ActiveCrystals = 0,
    ActiveSlimes = 0,
    ActiveBattles = 0,
    ServiceHealth = {},
    LastUpdate = tick(),
}

-- Service health tracking
local serviceStatus = {
    GameLoopService = "Unknown",
    CrystalService = "Unknown", 
    SlimeFactory = "Unknown",
    MadLibService = "Unknown",
    BattleService = "Unknown",
    DataBridgeService = "Unknown",
}

-- Private functions
local function getMemoryUsage(): number
    local success, result = pcall(function()
        return collectgarbage("count")
    end)
    return success and result or 0
end

local function getServerFPS(): number
    local success, result = pcall(function()
        return 1 / RunService.Heartbeat:Wait()
    end)
    return success and math.floor(result) or 60
end

local function checkServiceHealth(serviceName: string): string
    local success, service = pcall(function()
        return Knit.GetService(serviceName)
    end)
    
    if not success then
        return "Error"
    end
    
    if not service then
        return "Missing"
    end
    
    -- Try to call a simple method to test if service is responsive
    if serviceName == "GameLoopService" then
        local methodSuccess = pcall(function()
            service:GetGameState()
        end)
        return methodSuccess and "Healthy" or "Unresponsive"
    elseif serviceName == "CrystalService" then
        local methodSuccess = pcall(function()
            service:GetPlayerInventory(Players:GetChildren()[1])
        end)
        return methodSuccess and "Healthy" or "Unresponsive"
    end
    
    return "Healthy"
end

local function updateMetrics()
    -- Update basic metrics
    metrics.ServerFPS = getServerFPS()
    metrics.MemoryUsage = getMemoryUsage()
    metrics.PlayerCount = #Players:GetChildren()
    metrics.LastUpdate = tick()
    
    -- Update service health
    for serviceName, _ in pairs(serviceStatus) do
        serviceStatus[serviceName] = checkServiceHealth(serviceName)
    end
    metrics.ServiceHealth = serviceStatus
    
    -- Get service-specific metrics
    local success, CrystalService = pcall(function()
        return Knit.GetService("CrystalService")
    end)
    if success and CrystalService then
        local crystalSuccess = pcall(function()
            -- This would need to be implemented in CrystalService
            -- metrics.ActiveCrystals = CrystalService:GetActiveCrystalCount()
        end)
    end
    
    local success, SlimeFactory = pcall(function()
        return Knit.GetService("SlimeFactory")
    end)
    if success and SlimeFactory then
        local slimeSuccess = pcall(function()
            -- This would need to be implemented in SlimeFactory
            -- metrics.ActiveSlimes = SlimeFactory:GetActiveSlimeCount()
        end)
    end
    
    local success, BattleService = pcall(function()
        return Knit.GetService("BattleService")
    end)
    if success and BattleService then
        local battleSuccess = pcall(function()
            -- This would need to be implemented in BattleService
            -- metrics.ActiveBattles = BattleService:GetActiveBattleCount()
        end)
    end
end

local function checkPerformanceWarnings()
    local warnings = {}
    
    if metrics.MemoryUsage > MEMORY_WARNING_THRESHOLD then
        table.insert(warnings, "High memory usage: " .. math.floor(metrics.MemoryUsage) .. "MB")
    end
    
    if metrics.ServerFPS < FPS_WARNING_THRESHOLD then
        table.insert(warnings, "Low server FPS: " .. metrics.ServerFPS)
    end
    
    if metrics.PlayerCount > PLAYER_COUNT_WARNING then
        table.insert(warnings, "High player count: " .. metrics.PlayerCount)
    end
    
    -- Check service health
    for serviceName, status in pairs(serviceStatus) do
        if status ~= "Healthy" then
            table.insert(warnings, serviceName .. " status: " .. status)
        end
    end
    
    return warnings
end

local function broadcastPerformanceUpdate()
    local warnings = checkPerformanceWarnings()
    
    PerformanceMonitor.Client.PerformanceUpdate:FireAll({
        FPS = metrics.ServerFPS,
        Memory = math.floor(metrics.MemoryUsage),
        Players = metrics.PlayerCount,
        Crystals = metrics.ActiveCrystals,
        Slimes = metrics.ActiveSlimes,
        Battles = metrics.ActiveBattles,
        ServiceHealth = metrics.ServiceHealth,
        Warnings = warnings,
        Timestamp = metrics.LastUpdate,
    })
    
    -- Log warnings to server console
    if #warnings > 0 then
        warn("[PerformanceMonitor] Performance warnings detected:")
        for _, warning in ipairs(warnings) do
            warn("  - " .. warning)
        end
    end
end

-- Public methods
function PerformanceMonitor:GetMetrics(): {[string]: any}
    return metrics
end

function PerformanceMonitor:GetServiceHealth(): {[string]: string}
    return serviceStatus
end

function PerformanceMonitor:ForceUpdate()
    updateMetrics()
    broadcastPerformanceUpdate()
end

-- Service lifecycle
function PerformanceMonitor:KnitStart()
    print("[PerformanceMonitor] Starting performance monitoring...")
    
    -- Initial metrics collection
    updateMetrics()
    
    -- Start periodic updates
    task.spawn(function()
        while true do
            task.wait(UPDATE_INTERVAL)
            updateMetrics()
            broadcastPerformanceUpdate()
        end
    end)
    
    print("[PerformanceMonitor] Started. Monitoring every " .. UPDATE_INTERVAL .. " seconds.")
end

function PerformanceMonitor:KnitStop()
    print("[PerformanceMonitor] Stopped.")
end

-- Export for external access
return PerformanceMonitor
