--!strict
print("[PhoenixProject] Boot: Initializing server...")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

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
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local RemotesModule = Shared:FindFirstChild("Remotes")
if RemotesModule then
    require(RemotesModule)
    print("[PhoenixProject] Boot: Remotes module initialized")
end

-- Track non-Knit services that need Start() called
local nonKnitServices = {}

-- Load all services
print("[PhoenixProject] Boot: Loading Services...")
local ServicesFolder = ServerScriptService.Server.Services
for _, module in ipairs(ServicesFolder:GetChildren()) do
    if module:IsA("ModuleScript") then
        print("[PhoenixProject] Boot: Loading Service -> " .. module.Name)
        local service = require(module)
        
        -- Check if this is a non-Knit service with a Start method
        -- Knit services are tables returned by Knit.CreateService
        -- Non-Knit services have a .Start function we need to call manually
        if service and type(service.Start) == "function" and not service._knit_service then
            table.insert(nonKnitServices, service)
            print("[PhoenixProject] Boot: Detected non-Knit service: " .. module.Name)
        end
    end
end

-- Start non-Knit services BEFORE Knit.Start()
print("[PhoenixProject] Boot: Starting non-Knit services...")
for _, service in ipairs(nonKnitServices) do
    if service.Start then
        local success, err = pcall(function()
            service.Start()
        end)
        if not success then
            warn("[PhoenixProject] Boot: Failed to start service: " .. tostring(err))
        end
    end
end

print("[PhoenixProject] Boot: Starting Knit...")
Knit.Start():andThen(function()
    print("[PhoenixProject] Boot: Knit Started. Spawning world...")
    
    -- Spawn World after Services are ready
    local TownGeneratorFolder = ServerScriptService.Server.Services
    local TownGenerator = require(TownGeneratorFolder:WaitForChild("TownGenerator", 5))
    if TownGenerator then
        print("[PhoenixProject] Boot: Calling TownGenerator.SpawnWorld()")
        TownGenerator.SpawnWorld()
    else
        warn("[PhoenixProject] Boot: TownGenerator Service not found!")
    end
    
end):catch(function(err)
    warn("[PhoenixProject] Boot: Server Start Failed: " .. tostring(err))
end)
