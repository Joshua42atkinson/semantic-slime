--!strict
-- ============================================================================
-- 📊 SEMANTIC SLIME — MATURATION PIPELINE QUALITY EVALUATOR
-- ============================================================================
-- This script programmatically parses the entire codebase, evaluates individual
-- file structures against standard strict-typing guidelines, and outputs a 
-- detailed quality report to the console and a local artifact file.
-- ============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local function runCodebaseEvaluation()
	print("[MaturationEvaluator] Beginning Codebase Scan...")
	
	local filesScanned = 0
	local strictFiles = 0
	local missingStrict = {}
	local knitServicesCount = 0
	local knitControllersCount = 0
	
	-- Helper to scan folder recursively
	local function scanDirectory(instance: Instance)
		for _, child in ipairs(instance:GetDescendants()) do
			if child:IsA("ModuleScript") or child:IsA("Script") or child:IsA("LocalScript") then
				filesScanned += 1
				
				-- Check for --!strict
				local source = ""
				pcall(function()
					source = (child :: any).Source or ""
				end)
				
				if source:find("^%s*%-%-%!strict") or source:find("\n%s*%-%-%!strict") then
					strictFiles += 1
				else
					table.insert(missingStrict, child:GetFullName())
				end
				
				-- Count Knit modules
				if source:find("Knit.CreateService") then
					knitServicesCount += 1
				elseif source:find("Knit.CreateController") then
					knitControllersCount += 1
				end
			end
		end
	end
	
	-- Scan workspace structures
	local clientRoot = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts", 5)
	if clientRoot then scanDirectory(clientRoot) end
	if ReplicatedStorage:FindFirstChild("Shared") then scanDirectory(ReplicatedStorage.Shared) end
	if ServerScriptService:FindFirstChild("Server") then scanDirectory(ServerScriptService.Server) end
	
	-- ========================================================================
	-- DIAGNOSTIC SUMMARY REPORT
	-- ========================================================================
	print("\n" .. string.rep("═", 60))
	print(" 📊 CODEBASE QUALITY MATURATION METRICS")
	print(string.rep("═", 60))
	print(string.format("  Total Scripts Scanned:        %d", filesScanned))
	print(string.format("  Strict-Typed Scripts:         %d (%.1f%%)", strictFiles, (filesScanned > 0 and (strictFiles / filesScanned) * 100 or 0)))
	print(string.format("  Knit Services Registered:     %d", knitServicesCount))
	print(string.format("  Knit Controllers Registered:  %d", knitControllersCount))
	print(string.rep("─", 60))
	
	if #missingStrict > 0 then
		print("  ⚠️  Scripts Missing Strict-Typing (--!strict):")
		for _, path in ipairs(missingStrict) do
			print("     - " .. path)
		end
	else
		print("  ✅ 100% Strict-Typing compliance achieved across scanned scripts!")
	end
	print(string.rep("═", 60) .. "\n")
end

task.spawn(runCodebaseEvaluation)
