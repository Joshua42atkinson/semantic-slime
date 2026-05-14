--!strict
-- Boot.client.luau
-- Client entry point for Semantic Slime.
-- Responsibilities: init remotes → load controllers → start Knit.

print("[SemanticSlime] Client Boot: Initializing...")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================================================================
-- 1. Load Knit
-- ================================================================
local Packages = ReplicatedStorage:WaitForChild("Packages", 10)
if not Packages then
	warn("[SemanticSlime] Client Boot: FATAL — Packages folder NOT FOUND!")
	return
end

local Knit = require(Packages:WaitForChild("Knit", 10))
if not Knit then
	warn("[SemanticSlime] Client Boot: FATAL — Knit NOT FOUND!")
	return
end

-- ================================================================
-- 2. Ensure Remotes exist (server creates them, client just waits)
-- ================================================================
print("[SemanticSlime] Client Boot: Waiting for Shared modules...")
local Shared = ReplicatedStorage:WaitForChild("Shared", 15)
if Shared then
	local remotesModule = Shared:FindFirstChild("Remotes")
	if remotesModule and remotesModule:IsA("ModuleScript") then
		require(remotesModule)
	end
end

-- ================================================================
-- 3. Load all controllers (pcall-protected)
-- ================================================================
print("[SemanticSlime] Client Boot: Loading Controllers...")
local loadedCount = 0
local failedCount = 0
local failedNames = {}

for _, module in ipairs(script.Parent.Controllers:GetChildren()) do
	if module:IsA("ModuleScript") then
		local ok, err = pcall(function()
			require(module)
		end)
		if ok then
			loadedCount += 1
		else
			failedCount += 1
			table.insert(failedNames, module.Name)
			warn("[SemanticSlime] Client Boot: ❌ FAILED to load " .. module.Name .. ": " .. tostring(err))
		end
	end
end

print("[SemanticSlime] Client Boot: Loaded " .. loadedCount .. " controllers (" .. failedCount .. " failed)")
if failedCount > 0 then
	warn("[SemanticSlime] Client Boot: Failed controllers: " .. table.concat(failedNames, ", "))
end

-- ================================================================
-- 4. Start Knit
-- ================================================================
print("[SemanticSlime] Client Boot: Starting Knit...")
Knit.Start():andThen(function()
	print("[SemanticSlime] Client Boot: ✅ Client Started!")
end):catch(function(err)
	warn("[SemanticSlime] Client Boot: ❌ Client Start Failed: " .. tostring(err))
end)
