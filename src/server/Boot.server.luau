--!strict
-- Boot.server.luau
-- Server entry point for Semantic Slime.
-- Responsibilities: clean old state → init remotes → load services → start Knit.
-- World generation is handled by TownGenerator's KnitStart(), NOT here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- ================================================================
-- 0. Load CrashGuard for structured logging
-- ================================================================
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local CrashGuard = require(Shared:WaitForChild("CrashGuard"))

CrashGuard.BootStage("Server Initialization", 1, 5)
CrashGuard.Log("Boot", "Initializing server...")

-- ================================================================
-- 1. Cleanup old NPCs from previous sessions
-- ================================================================
CrashGuard.BootStage("NPC Cleanup", 2, 5)
local cleaned = 0
local knownNPCs = {
	"Barnaby", "Yorick", "Kael", "Martha", "Gribble", "Nyx",
	"Vlad", "Pygmalion", "Chesty", "Ozymandias", "Zafir", "Ignis", "Administrator",
}
for _, obj in ipairs(Workspace:GetChildren()) do
	if obj:IsA("Model") then
		for _, npcName in ipairs(knownNPCs) do
			if obj.Name == npcName or obj.Name:find(npcName) then
				obj:Destroy()
				cleaned += 1
				break
			end
		end
	end
end
if cleaned > 0 then
	CrashGuard.Log("Boot", "Cleaned up " .. cleaned .. " old NPC models")
end

-- ================================================================
-- 2. Load Knit framework
-- ================================================================
CrashGuard.BootStage("Knit Framework", 3, 5)
local Packages = ReplicatedStorage:WaitForChild("Packages", 10)
if not Packages then
	CrashGuard.Error("Boot", "FATAL — Packages folder not found in ReplicatedStorage!")
	return
end

local Knit = require(Packages:WaitForChild("Knit", 10))
if not Knit then
	CrashGuard.Error("Boot", "FATAL — Knit not found in Packages!")
	return
end
CrashGuard.Log("Boot", "Knit loaded successfully")

-- ================================================================
-- 3. Initialize Shared Remotes (must happen before services)
-- ================================================================
CrashGuard.BootStage("Remotes", 4, 5)
if Shared then
	local remotesModule = Shared:FindFirstChild("Remotes")
	if remotesModule and remotesModule:IsA("ModuleScript") then
		local ok, err = CrashGuard.SafeRequire("Boot", remotesModule)
		if ok then
			CrashGuard.Log("Boot", "Remotes initialized")
		end
	else
		CrashGuard.Warn("Boot", "Remotes module not found!")
	end
else
	CrashGuard.Warn("Boot", "Shared folder not found!")
end

-- ================================================================
-- 4. Load all Knit services
-- ================================================================
CrashGuard.BootStage("Services", 5, 5)
local ServicesFolder = ServerScriptService.Server.Services
local loadedCount = 0
local failedCount = 0
local failedNames = {}

for _, module in ipairs(ServicesFolder:GetChildren()) do
	if module:IsA("ModuleScript") then
		require(module)
		loadedCount += 1
	end
end

CrashGuard.BootReport(loadedCount, failedCount, failedNames)

-- ================================================================
-- 5. Start Knit
-- ================================================================
CrashGuard.Log("Boot", "Starting Knit...")
Knit.Start():andThen(function()
	CrashGuard.Log("Boot", "✅ Knit Started successfully!")
	CrashGuard.Log("Boot", "World generation will be handled by TownGenerator.KnitStart()")
end):catch(function(err)
	CrashGuard.Error("Boot", "Knit Start Failed: " .. tostring(err))
end)
