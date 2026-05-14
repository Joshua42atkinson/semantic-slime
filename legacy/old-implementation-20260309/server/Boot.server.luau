--!strict
print("[PhoenixProject] Boot: Initializing server...")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- Cleanup old NPCs from previous sessions
print("[PhoenixProject] Boot: Cleaning up old NPCs...")
local cleaned = 0
local knownNPCs = {"Barnaby", "Yorick", "Kael", "Martha", "Gribble", "Nyx", "Vlad", "Pygmalion", "Chesty", "Ozymandias", "Zafir", "Ignis", "Administrator"}
for _, obj in ipairs(Workspace:GetChildren()) do
    if obj:IsA("Model") then
        for _, npcName in ipairs(knownNPCs) do
            if obj.Name == npcName or obj.Name:find(npcName) then
                obj:Destroy()
                cleaned = cleaned + 1
                break
            end
        end
    end
end
print("[PhoenixProject] Boot: Cleaned up " .. cleaned .. " old NPC models")

print("[PhoenixProject] Boot: Creating EMERGENCY FLOOR...")
local emergencyFloor = Instance.new("Part")
emergencyFloor.Name = "EmergencyFloor"
emergencyFloor.Size = Vector3.new(5000, 100, 5000)
emergencyFloor.Position = Vector3.new(0, -50, 0)
emergencyFloor.Anchored = true
emergencyFloor.CanCollide = true
emergencyFloor.Transparency = 0 -- Solid
emergencyFloor.Material = Enum.Material.Grass
emergencyFloor.Color = Color3.fromRGB(85, 160, 85) -- Nice grass green
emergencyFloor.Parent = Workspace
print("[PhoenixProject] Boot: EMERGENCY FLOOR CREATED!")

-- Add some trees around spawn
local treePositions = {
    Vector3.new(50, 0, 30),
    Vector3.new(-40, 0, 50),
    Vector3.new(60, 0, -20),
    Vector3.new(-30, 0, -40),
    Vector3.new(20, 0, 60),
    Vector3.new(-60, 0, 10),
}

for i, pos in ipairs(treePositions) do
    -- Trunk
    local trunk = Instance.new("Part")
    trunk.Name = "TreeTrunk_" .. i
    trunk.Size = Vector3.new(4, 20, 4)
    trunk.Position = pos + Vector3.new(0, 10, 0)
    trunk.Anchored = true
    trunk.CanCollide = true
    trunk.Material = Enum.Material.Wood
    trunk.Color = Color3.fromRGB(101, 67, 33)
    trunk.Parent = Workspace
    
    -- Leaves
    local leaves = Instance.new("Part")
    leaves.Name = "TreeLeaves_" .. i
    leaves.Shape = Enum.PartType.Ball
    leaves.Size = Vector3.new(15, 15, 15)
    leaves.Position = pos + Vector3.new(0, 22, 0)
    leaves.Anchored = true
    leaves.CanCollide = true
    leaves.Material = Enum.Material.Grass
    leaves.Color = Color3.fromRGB(34, 139, 34)
    leaves.Parent = Workspace
end
print("[PhoenixProject] Boot: Trees created!")

print("[PhoenixProject] Boot: Waiting for packages...")
local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
if not Packages then
    warn("[PhoenixProject] Boot: Packages folder not found in ReplicatedStorage!")
    return
end
print("[PhoenixProject] Boot: Requiring Knit...")
local Knit = require(Packages:WaitForChild("Knit", 5))
if not Knit then
    warn("[PhoenixProject] Boot: Knit not found in Packages!")
    return
end

-- Initialize Shared modules that create remotes first
print("[PhoenixProject] Boot: Initializing Shared modules...")
local Shared = ReplicatedStorage:WaitForChild("Shared")
require(Shared:WaitForChild("Remotes"))
-- Load all services (pcall-protected so one failure doesn't crash everything)
print("[PhoenixProject] Boot: Loading Services...")
local ServicesFolder = ServerScriptService.Server.Services
local loadedCount = 0
local failedCount = 0
for _, module in ipairs(ServicesFolder:GetChildren()) do
    if module:IsA("ModuleScript") then
        print("[PhoenixProject] Boot: Loading Service -> " .. module.Name)
        local ok, err = pcall(function()
            require(module)
        end)
        if ok then
            loadedCount = loadedCount + 1
        else
            failedCount = failedCount + 1
            warn("[PhoenixProject] Boot: ❌ FAILED to load " .. module.Name .. ": " .. tostring(err))
        end
    end
end
print("[PhoenixProject] Boot: Loaded " .. loadedCount .. " services (" .. failedCount .. " failed)")

print("[PhoenixProject] Boot: Starting Knit...")
Knit.Start():andThen(function()
    print("[PhoenixProject] Boot: Knit Started. Spawning world...")
    
    -- Note: collectgarbage("collect") is not supported in Roblox
    
    -- Spawn World after Services are ready (wait for services to fully initialize)
    task.delay(3, function()
        print("[PhoenixProject] Boot: Attempting to load TownGenerator...")
        local TownGeneratorFolder = ServerScriptService.Server.Services
        local TownGenerator = require(TownGeneratorFolder:WaitForChild("TownGenerator", 10))
        if TownGenerator then
            print("[PhoenixProject] Boot: TownGenerator loaded! Calling SpawnWorld()...")
            local ok, err = pcall(function()
                TownGenerator.SpawnWorld()
            end)
            if not ok then
                warn("[PhoenixProject] Boot: TownGenerator.SpawnWorld() FAILED: " .. tostring(err))
            else
                print("[PhoenixProject] Boot: TownGenerator.SpawnWorld() completed successfully!")
            end
        else
            warn("[PhoenixProject] Boot: TownGenerator Service not found!")
        end
    end)
    
end):catch(function(err)
    warn("[PhoenixProject] Boot: Server Start Failed: " .. tostring(err))
end)
