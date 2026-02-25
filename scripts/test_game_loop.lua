--!/usr/bin/env luau
-- Test script for Semantic Slime game loop
-- Run this after server starts to verify all systems work

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

print("=== SEMANTIC SLIME GAME LOOP TEST ===")

local function waitForServices()
	local services = {
		GameLoopService = Knit.GetService("GameLoopService"),
		CrystalService = Knit.GetService("CrystalService"),
		SlimeFactory = Knit.GetService("SlimeFactory"),
		MadLibService = Knit.GetService("MadLibService"),
		BattleService = Knit.GetService("BattleService"),
		DataService = Knit.GetService("DataService"),
	}
	
	for name, service in pairs(services) do
		if not service then
			warn("Service not found: " .. name)
			return nil
		end
	end
	
	return services
end

local function testGameLoop(services)
	print("[Test] Starting game loop test...")
	
	-- Wait for player
	local player = Players.PlayerAdded:Wait()
	if not player then
		warn("[Test] No player found. Test requires player in game.")
		return
	end
	
	-- Initialize player data
	local DataService = services.DataService
	DataService:_LoadData(player)
	
	-- Test Collection Phase
	print("[Test] Testing Collection Phase...")
	local CrystalService = services.CrystalService
	CrystalService:SpawnCrystal()
	
	-- Wait for crystals to spawn
	task.wait(2)
	
	-- Test Construction Phase
	print("[Test] Testing Construction Phase...")
	local GameLoopService = services.GameLoopService
	local success = GameLoopService:CompleteWordConstruction(player, "test")
	if success then
		print("[Test] ✓ Created slime: test")
	else
		warn("[Test] ✗ Failed to create slime: test")
	end
	
	-- Test Quest Phase
	print("[Test] Testing Quest Phase...")
	local MadLibService = services.MadLibService
	local quest = MadLibService:GenerateQuest(player, "Hero")
	
	if quest then
		print("[Test] ✓ Generated quest: " .. quest.Title)
		
		-- Fill a slot
		local SlimeFactory = services.SlimeFactory
		local slimes = SlimeFactory:GetPlayerSlimes(player)
		local firstSlime = next(slimes)
		
		if firstSlime then
			local slotSuccess = MadLibService:FillSlot(player, quest.QuestId, quest.Slots[1].SlotId, firstSlime.InstanceId, firstSlime.Term)
			if slotSuccess then
				print("[Test] ✓ Filled slot with: " .. firstSlime.Term)
			else
				warn("[Test] ✗ Failed to fill slot")
			end
		else
			warn("[Test] No slimes available for quest")
		end
		
		-- Complete quest
		task.wait(1)
		local completed = MadLibService:CompleteQuest(player, quest.QuestId)
		if completed then
			print("[Test] ✓ Quest completed! Rewards: " .. tostring(completed.Rewards))
		else
			warn("[Test] ✗ Failed to complete quest")
		end
		
		-- Test Battle Phase (if multiple slimes)
		print("[Test] Testing Battle Phase...")
		if SlimeFactory then
			local allSlimes = SlimeFactory:GetPlayerSlimes(player)
			local slimeList = {}
			for _, slime in pairs(allSlimes) do
				table.insert(slimeList, slime)
			end
			
			if #slimeList >= 2 then
				local BattleService = services.BattleService
				local participants = {}
				for _, slime in ipairs(slimeList) do
					table.insert(participants, BattleService:CreateParticipant(
						player.Name,
						slime.InstanceId,
						slime.Term,
						slime.Stats,
						slime.Element,
						slime.Role,
						slime.Rarity
					))
				end
				
				if #participants >= 2 then
					local battle = BattleService:StartBattle("test_quest", "test_slot", participants)
					print("[Test] ✓ Battle started with " .. #participants .. " participants")
				else
					print("[Test] Not enough slimes for battle test")
				end
			else
				print("[Test] Skipping battle test - not enough slimes")
			end
		else
			print("[Test] BattleService not available")
		end
	else
		warn("[Test] Failed to generate quest")
	end
	
	print("[Test] === Game Loop Test Complete ===")
end

-- Wait for services to be ready
task.wait(5)

local services = waitForServices()
if services then
	testGameLoop(services)
else
	warn("[Test] Failed to get services")
end