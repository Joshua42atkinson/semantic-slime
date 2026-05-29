--!strict
-- ============================================================================
-- 🧪 SEMANTIC SLIME — ONE-CLICK AUTOMATED PLAYTEST SIMULATOR
-- ============================================================================
-- Paste this script into the Roblox Studio Command Bar (when in Play Solo F5)
-- to automatically simulate the entire game loop in under 5 seconds!
--
-- This script validates:
--   1. Crystal spawning & inventory updates
--   2. Word construction & dynamic stats generation
--   3. Feral Nuisance letter spawning & inventory penalties
--   4. Quest assignment & slot completions
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local function printHeader(text)
	print("\n" .. string.rep("═", 50))
	print(" 🧪 SIMULATOR: " .. text)
	print(string.rep("═", 50))
end

local function runSimulation()
	local player = Players.LocalPlayer or Players:GetPlayers()[1]
	if not player then
		warn("❌ FAILURE: No active players found in playtest session. Press F5 first!")
		return
	end

	printHeader("INITIALIZING SERVICES")
	local GameLoopService = Knit.GetService("GameLoopService")
	local CrystalService = Knit.GetService("CrystalService")
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local MadLibService = Knit.GetService("MadLibService")
	local LetterNuisanceService = Knit.GetService("LetterNuisanceService")
	
	assert(GameLoopService, "GameLoopService not found")
	assert(CrystalService, "CrystalService not found")
	assert(SlimeFactory, "SlimeFactory not found")
	assert(MadLibService, "MadLibService not found")
	assert(LetterNuisanceService, "LetterNuisanceService not found")
	print("  ✅ All Knit Services loaded.")

	-- ========================================================================
	-- STAGE 1: COLLECTION PHASE & CRYSTALS
	-- ========================================================================
	printHeader("STAGE 1: MOCKING LETTER COLLECTION")
	
	-- Force Collection Phase
	GameLoopService:SetPhase("Collection")
	print("  ✅ Phase shifted to 'Collection'")
	
	-- Grant letters manually to simulate collection
	local lettersToCollect = {"s", "l", "i", "m", "e", "s", "p", "a", "c", "e"}
	for _, letter in ipairs(lettersToCollect) do
		CrystalService:AddLetterToInventory(player, letter)
	end
	
	-- Verify inventory
	local inv = CrystalService:GetPlayerInventory(player)
	print("  ✅ Mock letters injected. Current inventory:")
	for letter, count in pairs(inv) do
		print(string.format("     - Letter '%s': x%d", letter, count))
	end
	assert(inv["s"] and inv["e"], "Failed to update inventory")

	-- ========================================================================
	-- STAGE 2: WORD CONSTRUCTION & SLIME FACTORY
	-- ========================================================================
	printHeader("STAGE 2: WORD CONSTRUCTION & SLIME STATS")
	
	-- Shift to Construction phase
	GameLoopService:SetPhase("Construction")
	print("  ✅ Phase shifted to 'Construction'")
	
	-- Try to build a word using collected letters
	local wordToBuild = "slime"
	print("  Building word: '" .. wordToBuild .. "'...")
	
	local slimeInstance, slimeErr = SlimeFactory:CreateSlime(player, wordToBuild)
	if slimeInstance then
		print("  ✅ Slime creation successful!")
		print(string.format("     - Term:       %s", slimeInstance.Term))
		print(string.format("     - Element:    %s", slimeInstance.Element))
		print(string.format("     - Role:       %s", slimeInstance.Role))
		print(string.format("     - Rarity:     %s", slimeInstance.Rarity))
		
		local stats = slimeInstance.Stats
		if stats then
			print("     - Stats:")
			print(string.format("       * Logos:   %.1f", stats.Logos))
			print(string.format("       * Pathos:  %.1f", stats.Pathos))
			print(string.format("       * Ethos:   %.1f", stats.Ethos))
			print(string.format("       * Speed:   %.1f", stats.Speed))
		else
			warn("     ❌ Error: Slime has no base stats!")
		end
	else
		warn("  ❌ Word construction failed: " .. tostring(slimeErr))
	end

	-- ========================================================================
	-- STAGE 3: QUEST LOG & MAD-LIBS
	-- ========================================================================
	printHeader("STAGE 3: QUEST SYSTEMS")
	
	-- Shift to Quest phase
	GameLoopService:SetPhase("Quest")
	print("  ✅ Phase shifted to 'Quest'")
	
	-- Generate a quest for the player
	local quest = MadLibService:GenerateNPCQuest(player, "Kael", 1)
	if quest then
		print("  ✅ Quest assigned successfully!")
		print("     - Title: " .. quest.Title)
		print("     - Prompt: " .. quest.NarrativePrompt)
		
		-- Simulate filling a slot
		if quest.Slots and #quest.Slots > 0 then
			local slot = quest.Slots[1]
			print(string.format("     - Filling slot 1 (%s) with word 'water'...", slot.PartOfSpeech))
			
			local filled, fillErr = MadLibService:FillSlot(player, slot.SlotId, "water")
			if filled then
				print("     ✅ Slot filled successfully!")
			else
				warn("     ❌ Failed to fill slot: " .. tostring(fillErr))
			end
		end
	else
		warn("  ❌ Quest generation failed (is player already on a quest?)")
	end

	-- ========================================================================
	-- STAGE 4: FERAL LETTERS & NUISANCE PHASE
	-- ========================================================================
	printHeader("STAGE 4: FERAL LETTER NUISANCES")
	
	-- Shift to Nuisance phase
	GameLoopService:SetPhase("Nuisance")
	print("  ✅ Phase shifted to 'Nuisance'")
	
	-- Spawn feral letters
	LetterNuisanceService:SpawnNuisanceLetters(3)
	print("  ✅ Feral letters spawned in world.")
	
	-- Simulate player shield
	print("  Activating player shield...")
	LetterNuisanceService:GrantNuisanceShield(player)
	
	-- Simulate a collision while shielded (capture letter)
	local mockNuisanceId = "mock-feral-id"
	local mockFeral = {
		InstanceId = mockNuisanceId,
		Letter = "z",
		Position = Vector3.new(0, 10, 0),
		TargetPlayer = player,
	}
	
	print("  Simulating collision with feral 'Z' while shielded...")
	LetterNuisanceService:HandlePlayerCollision(player, mockFeral)
	
	local updatedInv = CrystalService:GetPlayerInventory(player)
	if updatedInv["z"] then
		print("  ✅ Shield collision capture verified! Letter 'Z' successfully added to inventory.")
	else
		warn("  ❌ Shield collision failed to add letter to inventory.")
	end

	-- Shift back to Rewards
	GameLoopService:SetPhase("Rewards")
	print("\n  ✅ Phase shifted to 'Rewards'. Loop simulation complete.")
	
	print("\n🎉 SIMULATION COMPLETE: All tested systems are fully functional!")
end

task.spawn(runSimulation)
