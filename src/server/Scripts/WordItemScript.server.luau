--!strict
local Players = game:GetService("Players")
local QuestService = require(game.ServerScriptService.Server.Services.QuestService)
local SoundManager = require(game.ReplicatedStorage.Shared.SoundManager)

local part = script.Parent
local wordId = part:GetAttribute("WordId") or "rock" -- Default to rock
local clickDetector = part:FindFirstChild("ClickDetector")

if not clickDetector then
	clickDetector = Instance.new("ClickDetector")
	clickDetector.Parent = part
end

clickDetector.MouseClick:Connect(function(player)
	print(player.Name .. " clicked on word item: " .. wordId)
	
	SoundManager.PlaySFX("ItemPickup")

	-- Add to inventory and check quests
	QuestService.AddWordToInventory(player, wordId)
	
	-- FX
	part.Transparency = 1
	part.CanCollide = false
	
	-- Destroy after a moment (or respawn later)
	task.wait(1)
	part:Destroy()
end)
