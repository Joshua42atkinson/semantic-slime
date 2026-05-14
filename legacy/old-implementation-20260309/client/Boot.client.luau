print("[PhoenixProject] Boot: Initializing Client...")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[PhoenixProject] Boot: Waiting for Packages...")
local Packages = ReplicatedStorage:WaitForChild("Packages", 5)

if not Packages then
    warn("[PhoenixProject] Boot: Packages folder NOT FOUND on client!")
    return
end

print("[PhoenixProject] Boot: Requiring Knit...")
local Knit = require(Packages:WaitForChild("Knit", 5))
if not Knit then
    warn("[PhoenixProject] Boot: Knit NOT FOUND on client!")
    return
end

-- Ensure Remotes are created before controllers try to access them
print("[PhoenixProject] Boot: Initializing Shared modules...")
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if Shared then
    local remotesModule = Shared:FindFirstChild("Remotes")
    if remotesModule and remotesModule:IsA("ModuleScript") then
        require(remotesModule)
    end
end

-- Load all controllers (pcall-protected)
print("[PhoenixProject] Boot: Loading Controllers...")
local loadedCount = 0
local failedCount = 0
for _, module in ipairs(script.Parent.Controllers:GetChildren()) do
    if module:IsA("ModuleScript") then
        print("[PhoenixProject] Boot: Loading Controller -> " .. module.Name)
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
print("[PhoenixProject] Boot: Loaded " .. loadedCount .. " controllers (" .. failedCount .. " failed)")

Knit.Start():andThen(function()
    print("[PhoenixProject] Boot: Client Started via Knit.")
end):catch(function(err)
    warn("[PhoenixProject] Boot: Client Start Failed: " .. tostring(err))
end)
