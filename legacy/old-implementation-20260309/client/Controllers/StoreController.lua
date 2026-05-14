--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local StoreUI = require(script.Parent.Parent.UI.StoreUI)

local StoreController = Knit.CreateController { Name = "StoreController" }

function StoreController:KnitStart()
	local MonetizationService = Knit.GetService("MonetizationService")
	
	-- Create UI
	local gui, container = StoreUI.Create()
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Define Items (Sync with Server ideally, but hardcoded for prototype)
	local ITEMS = {
		{ Id = 1001, Name = "Small Insight Pack (+50)", Price = 50, Type = "Product" },
		{ Id = 1002, Name = "Large Insight Pack (+200)", Price = 180, Type = "Product" },
		{ Id = 1003, Name = "Instant Evolution", Price = 25, Type = "Product" },
		{ Id = 2001, Name = "Double XP", Price = 400, Type = "GamePass" },
		{ Id = 2002, Name = "Rare Word Finder", Price = 300, Type = "GamePass" },
		{ Id = 2003, Name = "VIP Access", Price = 800, Type = "GamePass" },
	}
	
	-- Populate UI
	for _, item in ipairs(ITEMS) do
		StoreUI.AddItem(container, item.Id, item.Name, item.Price, item.Type, function(id)
            -- Play Sound
            local SoundManager = require(ReplicatedStorage.Shared.SoundManager)
            SoundManager.PlaySFX("UI_Purchase")
            
			if item.Type == "GamePass" then
				MonetizationService:PromptGamePass(id)
			else
				MonetizationService:PromptProduct(id)
			end
		end)
	end
	
	print("[StoreController] Shop Initialized.")
end

return StoreController
