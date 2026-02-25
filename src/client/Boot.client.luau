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

-- Load all controllers
print("[PhoenixProject] Boot: Loading Controllers...")
for _, module in ipairs(script.Parent.Controllers:GetChildren()) do
    if module:IsA("ModuleScript") then
        print("[PhoenixProject] Boot: Loading Controller -> " .. module.Name)
        require(module)
    end
end

Knit.Start():andThen(function()
    print("[PhoenixProject] Boot: Client Started via Knit.")
end):catch(function(err)
    warn("[PhoenixProject] Boot: Client Start Failed: " .. tostring(err))
end)
