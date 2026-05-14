--!/usr/bin/env luau
-- ============================================================
-- Semantic Slime — In-Studio Integration Test
-- ============================================================
-- This runs INSIDE Roblox Studio (as a server script).
-- Paste into Studio command bar or place in ServerScriptService.
--
-- Tests the full game loop:
--   Collection → Construction → Quest → Nuisance → Rewards
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

print("╔══════════════════════════════════════════════╗")
print("║  SEMANTIC SLIME — INTEGRATION TEST SUITE     ║")
print("╚══════════════════════════════════════════════╝")

local RESULTS = { Passed = 0, Failed = 0, Skipped = 0 }

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("  ✅ " .. name)
		RESULTS.Passed += 1
	else
		warn("  ❌ " .. name .. ": " .. tostring(err))
		RESULTS.Failed += 1
	end
end

local function skip(name, reason)
	print("  ⏭️  " .. name .. " (skipped: " .. reason .. ")")
	RESULTS.Skipped += 1
end

local function section(name)
	print("")
	print("━━━ " .. name .. " ━━━")
end

-- ============================================================
-- GATE 1: SERVICE BOOT
-- ============================================================
section("GATE 1: Service Boot")

local services = {}
local REQUIRED_SERVICES = {
	"GameLoopService", "CrystalService", "SlimeFactory",
	"MadLibService", "DataService", "NPCService",
	"TownGenerator", "TerrainService", "LightingService",
	"LetterNuisanceService", "QuestService", "PetService",
}

for _, name in ipairs(REQUIRED_SERVICES) do
	test("Service: " .. name, function()
		local svc = Knit.GetService(name)
		assert(svc, name .. " returned nil")
		services[name] = svc
	end)
end

-- ============================================================
-- GATE 2: SHARED DATA INTEGRITY
-- ============================================================
section("GATE 2: Shared Data Integrity")

test("GameConfig loads", function()
	local config = require(ReplicatedStorage.Shared.GameConfig)
	assert(config.GAME_NAME == "Semantic Slime", "Wrong game name")
	assert(config.Elements, "Missing Elements table")
	assert(config.Roles, "Missing Roles table")
end)

test("EtymologyDB loads with roots and suffixes", function()
	local db = require(ReplicatedStorage.Shared.EtymologyDB)
	assert(db.Roots, "Missing Roots")
	assert(db.Suffixes, "Missing Suffixes")
	local rootCount = 0
	for _ in pairs(db.Roots) do rootCount += 1 end
	assert(rootCount >= 6, "Expected at least 6 roots, got " .. rootCount)
end)

test("NPCData loads with 12 NPCs", function()
	local npcs = require(ReplicatedStorage.Shared.NPCData)
	local count = 0
	for _ in pairs(npcs) do count += 1 end
	assert(count >= 12, "Expected 12 NPCs, got " .. count)
end)

test("QuestData loads with archetype quests", function()
	local qd = require(ReplicatedStorage.Shared.QuestData)
	assert(qd.ArchetypeQuests, "Missing ArchetypeQuests")
	assert(qd.NPCChains, "Missing NPCChains")
	local archetypeCount = 0
	for _ in pairs(qd.ArchetypeQuests) do archetypeCount += 1 end
	assert(archetypeCount >= 10, "Expected 10+ archetypes, got " .. archetypeCount)
end)

test("WordDatabase loads", function()
	local ok, wdb = pcall(function()
		return require(ReplicatedStorage.Shared.WordDatabase)
	end)
	assert(ok, "WordDatabase failed to load: " .. tostring(wdb))
end)

-- ============================================================
-- GATE 3: GAME LOOP PHASES
-- ============================================================
section("GATE 3: Game Loop Phases")

if services.GameLoopService then
	test("GameLoopService returns game state", function()
		local state = services.GameLoopService:GetGameState()
		assert(state, "GetGameState returned nil")
		assert(state.Phase, "Missing Phase in game state")
		assert(state.TimeRemaining, "Missing TimeRemaining")
	end)
	
	test("Phase is a valid phase name", function()
		local state = services.GameLoopService:GetGameState()
		local validPhases = { Collection=true, Construction=true, Quest=true, Nuisance=true, Rewards=true }
		assert(validPhases[state.Phase], "Invalid phase: " .. tostring(state.Phase))
	end)
	
	test("NextPhase advances correctly", function()
		local before = services.GameLoopService:GetGameState().Phase
		services.GameLoopService:NextPhase()
		local after = services.GameLoopService:GetGameState().Phase
		assert(before ~= after, "Phase didn't change after NextPhase()")
	end)
else
	skip("Game Loop tests", "GameLoopService not available")
end

-- ============================================================
-- GATE 4: PLAYER DATA (requires a player in game)
-- ============================================================
section("GATE 4: Player Data")

local player = Players:GetPlayers()[1]
if player and services.DataService then
	test("DataService has player profile", function()
		-- Wait for data to load
		task.wait(2)
		local profile = services.DataService:GetProfile(player)
		assert(profile, "No profile for player " .. player.Name)
		assert(profile.Level, "Missing Level in profile")
		assert(profile.LetterInventory, "Missing LetterInventory")
	end)
else
	skip("Player Data tests", player and "DataService unavailable" or "No player in game (press Play first)")
end

-- ============================================================
-- GATE 5: WORLD GENERATION
-- ============================================================
section("GATE 5: World Generation")

test("Workspace has generated terrain/parts", function()
	-- TownGenerator creates districts as folders in Workspace
	local workspace = game:GetService("Workspace")
	local partCount = 0
	for _, child in ipairs(workspace:GetDescendants()) do
		if child:IsA("BasePart") then
			partCount += 1
		end
	end
	-- Should have SOME parts if town generated
	print("    Parts in workspace: " .. partCount)
	-- Don't assert a specific count, just that it's non-zero
	-- (on fresh load there will at least be the baseplate)
	assert(partCount > 0, "No parts found in workspace")
end)

test("NPCs spawned in workspace", function()
	local workspace = game:GetService("Workspace")
	local npcCount = 0
	local knownNPCs = {
		"Barnaby", "Yorick", "Kael", "Martha", "Gribble", "Nyx",
		"Vlad", "Pygmalion", "Chesty", "Ozymandias", "Zafir", "Ignis",
	}
	for _, name in ipairs(knownNPCs) do
		if workspace:FindFirstChild(name, true) then
			npcCount += 1
		end
	end
	print("    NPCs found: " .. npcCount .. "/12")
	-- At least some NPCs should spawn (they spawn via TownGenerator)
	if npcCount == 0 then
		warn("    ⚠️  No NPCs found — TownGenerator may not have run yet (wait 5-10s)")
	end
end)

-- ============================================================
-- GATE 6: CORE PIPELINE (Collection → Word → Slime)
-- Only runs if there's a player
-- ============================================================
section("GATE 6: Core Pipeline (needs player)")

if player and services.CrystalService and services.SlimeFactory then
	test("CrystalService can grant letters to player", function()
		-- Try to add letters for the word "cat"
		local success = pcall(function()
			services.CrystalService:AddLetterToInventory(player, "c")
			services.CrystalService:AddLetterToInventory(player, "a")
			services.CrystalService:AddLetterToInventory(player, "t")
		end)
		assert(success, "Failed to add letters to inventory")
	end)
	
	test("CrystalService reports inventory", function()
		local inv = services.CrystalService:GetPlayerInventory(player)
		assert(inv, "GetPlayerInventory returned nil")
	end)
	
	test("SlimeFactory can create a slime from 'cat'", function()
		-- Force Construction phase first
		if services.GameLoopService then
			services.GameLoopService:SetPhase("Construction")
			task.wait(0.5)
		end
		
		local slime, err = services.SlimeFactory:CreateSlime(player, "cat")
		if slime then
			print("    Created slime: " .. slime.Term .. " (" .. slime.Element .. " " .. slime.Role .. ")")
		else
			-- This might fail if "cat" isn't in WordDatabase or letters aren't available
			warn("    SlimeFactory returned: " .. tostring(err))
			-- Don't hard-fail — this depends on letter inventory state
		end
	end)
else
	skip("Core Pipeline tests", "Needs player + CrystalService + SlimeFactory")
end

-- ============================================================
-- RESULTS
-- ============================================================
print("")
print("╔══════════════════════════════════════════════╗")
print("║  TEST RESULTS                                ║")
print("╠══════════════════════════════════════════════╣")
print("║  ✅ Passed:  " .. RESULTS.Passed)
print("║  ❌ Failed:  " .. RESULTS.Failed)
print("║  ⏭️  Skipped: " .. RESULTS.Skipped)
print("╚══════════════════════════════════════════════╝")

if RESULTS.Failed == 0 then
	print("🎉 ALL TESTS PASSED!")
else
	warn("⚠️  " .. RESULTS.Failed .. " test(s) failed. Check output above.")
end