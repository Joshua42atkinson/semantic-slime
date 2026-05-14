--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local StoreService = Knit.CreateService {
	Name = "StoreService",
	Client = {
		PurchaseCompleted = Knit.CreateSignal(),
		PurchaseFailed = Knit.CreateSignal(),
		CurrencyUpdated = Knit.CreateSignal(),
	},
}

-- Types
export type CosmeticItem = {
	ItemId: string,
	Name: string,
	Description: string,
	Price: number,
	Tier: "Basic" | "Premium" | "Deluxe" | "Legendary",
	Type: "SlimeSkin" | "PlayerHat" | "Trail" | "Emote" | "Avatar",
	AssetId: number?,
	ImageId: number?,
	Limited: boolean,
	LimitedQuantity: number?,
}

export type PurchaseResult = {
	Success: boolean,
	Item: CosmeticItem?,
	Error: string?,
}

-- Configuration: Cosmetic items
local STORE_ITEMS: { [string]: CosmeticItem } = {
	-- Basic Tier (100-500 crystals)
	["slime_blue"] = {
		ItemId = "slime_blue",
		Name = "Blue Berry Slime",
		Description = "A cool blue slime skin",
		Price = 200,
		Tier = "Basic",
		Type = "SlimeSkin",
		Limited = false,
	},
	["slime_green"] = {
		ItemId = "slime_green",
		Name = "Mint Fresh Slime",
		Description = "A refreshing green slime skin",
		Price = 200,
		Tier = "Basic",
		Type = "SlimeSkin",
		Limited = false,
	},
	["slime_pink"] = {
		ItemId = "slime_pink",
		Name = "Bubblegum Slime",
		Description = "A sweet pink slime skin",
		Price = 250,
		Tier = "Basic",
		Type = "SlimeSkin",
		Limited = false,
	},
	["trail_sparkle"] = {
		ItemId = "trail_sparkle",
		Name = "Sparkle Trail",
		Description = "Leave a trail of sparkles",
		Price = 300,
		Tier = "Basic",
		Type = "Trail",
		Limited = false,
	},
	["hat_crown"] = {
		ItemId = "hat_crown",
		Name = "Paper Crown",
		Description = "A simple paper crown",
		Price = 150,
		Tier = "Basic",
		Type = "PlayerHat",
		Limited = false,
	},
	
	-- Premium Tier (500-1500 crystals)
	["slime_rainbow"] = {
		ItemId = "slime_rainbow",
		Name = "Prismatic Slime",
		Description = "A shimmering rainbow slime",
		Price = 800,
		Tier = "Premium",
		Type = "SlimeSkin",
		Limited = true,
		LimitedQuantity = 500,
	},
	["slime_gold"] = {
		ItemId = "slime_gold",
		Name = "Golden Slime",
		Description = "A luxurious gold slime",
		Price = 1000,
		Tier = "Premium",
		Type = "SlimeSkin",
		Limited = true,
		LimitedQuantity = 200,
	},
	["trail_fire"] = {
		ItemId = "trail_fire",
		Name = "Flame Trail",
		Description = "Leave a trail of flames",
		Price = 700,
		Tier = "Premium",
		Type = "Trail",
		Limited = false,
	},
	["trail_storm"] = {
		ItemId = "trail_storm",
		Name = "Storm Trail",
		Description = "Leave a trail of lightning",
		Price = 750,
		Tier = "Premium",
		Type = "Trail",
		Limited = false,
	},
	["emote_dance"] = {
		ItemId = "emote_dance",
		Name = "Victory Dance",
		Description = "Show off your moves",
		Price = 500,
		Tier = "Premium",
		Type = "Emote",
		Limited = false,
	},
	["emote_spin"] = {
		ItemId = "emote_spin",
		Name = "Fancy Spin",
		Description = "A fancy spinning emote",
		Price = 500,
		Tier = "Premium",
		Type = "Emote",
		Limited = false,
	},
	
	-- Deluxe Tier (1500-3000 crystals)
	["slime_crystal"] = {
		ItemId = "slime_crystal",
		Name = "Crystal Slime",
		Description = "A translucent crystal slime",
		Price = 2000,
		Tier = "Deluxe",
		Type = "SlimeSkin",
		Limited = true,
		LimitedQuantity = 100,
	},
	["slime_neon"] = {
		ItemId = "slime_neon",
		Name = "Neon Slime",
		Description = "Glowing neon slime",
		Price = 2500,
		Tier = "Deluxe",
		Type = "SlimeSkin",
		Limited = true,
		LimitedQuantity = 75,
	},
	["trail_galaxy"] = {
		ItemId = "trail_galaxy",
		Name = "Galaxy Trail",
		Description = "A cosmic trail of stars",
		Price = 1800,
		Tier = "Deluxe",
		Type = "Trail",
		Limited = true,
		LimitedQuantity = 150,
	},
	["hat_wizard"] = {
		ItemId = "hat_wizard",
		Name = "Wizard Hat",
		Description = "A magical wizard hat",
		Price = 1500,
		Tier = "Deluxe",
		Type = "PlayerHat",
		Limited = false,
	},
	["emote_super"] = {
		ItemId = "emote_super",
		Name = "Super Pose",
		Description = "Strike a heroic pose",
		Price = 1500,
		Tier = "Deluxe",
		Type = "Emote",
		Limited = false,
	},
	
	-- Legendary Tier (3000+ crystals)
	["slime_legendary"] = {
		ItemId = "slime_legendary",
		Name = "Legendary Slime",
		Description = "The ultimate slime form",
		Price = 5000,
		Tier = "Legendary",
		Type = "SlimeSkin",
		Limited = true,
		LimitedQuantity = 25,
	},
	["slime_dragon"] = {
		ItemId = "slime_dragon",
		Name = "Dragon Slime",
		Description = "A fierce dragon slime",
		Price = 7500,
		Tier = "Legendary",
		Type = "SlimeSkin",
		Limited = true,
		LimitedQuantity = 10,
	},
	["trail_legendary"] = {
		ItemId = "trail_legendary",
		Name = "Legendary Trail",
		Description = "A trail fit for a legend",
		Price = 4000,
		Tier = "Legendary",
		Type = "Trail",
		Limited = true,
		LimitedQuantity = 30,
	},
	["hat_legendary"] = {
		ItemId = "hat_legendary",
		Name = "Hero Crown",
		Description = "Crown of the word hero",
		Price = 3500,
		Tier = "Legendary",
		Type = "PlayerHat",
		Limited = true,
		LimitedQuantity = 50,
	},
	["emote_legendary"] = {
		ItemId = "emote_legendary",
		Name = "Legendary Entrance",
		Description = "Make an entrance",
		Price = 3000,
		Tier = "Legendary",
		Type = "Emote",
		Limited = true,
		LimitedQuantity = 100,
	},
}

-- Game Pass configurations
local GAME_PASSES = {
	["double_xp"] = {
		PassId = "double_xp",
		Name = "Double XP",
		Description = "Earn 2x XP from quests",
		Price = 200,
	},
	["extra_slime_slot"] = {
		PassId = "extra_slime_slot",
		Name = "Extra Slime Slot",
		Description = "Carry 1 additional slime",
		Price = 500,
	},
	["premium_subscription"] = {
		PassId = "premium_subscription",
		Name = "Premium",
		Description = "Exclusive items and bonuses",
		Price = 100,
	},
}

-- Private state
local playerInventory: { [Player]: { [string]: CosmeticItem } } = {}

-- [STORE-001] Get all store items
function StoreService:GetStoreItems(): { CosmeticItem }
	local items = {}
	for _, item in pairs(STORE_ITEMS) do
		table.insert(items, item)
	end
	return items
end

-- [STORE-002] Get items by tier
function StoreService:GetItemsByTier(tier: string): { CosmeticItem }
	local items = {}
	for _, item in pairs(STORE_ITEMS) do
		if item.Tier == tier then
			table.insert(items, item)
		end
	end
	return items
end

-- [STORE-003] Get player's inventory
function StoreService:GetPlayerInventory(player: Player): { CosmeticItem }
	return playerInventory[player] or {}
end

-- [STORE-004] Purchase item with crystals
function StoreService:PurchaseWithCrystals(player: Player, itemId: string): PurchaseResult
	local item = STORE_ITEMS[itemId]
	if not item then
		return { Success = false, Error = "Item not found" }
	end
	
	-- Check if already owned
	if playerInventory[player] and playerInventory[player][itemId] then
		return { Success = false, Error = "Already owned" }
	end
	
	-- Check limited quantity
	if item.Limited and item.LimitedQuantity then
		-- This would check a server-side counter in production
	end
	
	-- Deduct crystals (would integrate with DataService)
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	
	if not profile or (profile.Crystals or 0) < item.Price then
		return { Success = false, Error = "Not enough crystals" }
	end
	
	profile.Crystals = profile.Crystals - item.Price
	
	-- Add to inventory
	if not playerInventory[player] then
		playerInventory[player] = {}
	end
	playerInventory[player][itemId] = item
	
	self.Client.PurchaseCompleted:Fire(player, item)
	print("[StoreService] " .. player.Name .. " purchased " .. item.Name)
	
	return { Success = true, Item = item }
end

-- [STORE-005] Purchase Game Pass
function StoreService:PurchaseGamePass(player: Player, passId: string): (boolean, string?)
	local pass = GAME_PASSES[passId]
	if not pass then
		return false, "Game pass not found"
	end
	
	-- Process purchase through MarketplaceService
	-- In production, this would use the actual GamePassId
	print("[StoreService] Processing Game Pass purchase: " .. pass.Name)
	
	return true, nil
end

-- [STORE-006] Get item details
function StoreService:GetItemDetails(itemId: string): CosmeticItem?
	return STORE_ITEMS[itemId]
end

-- [STORE-007] Check if player owns item
function StoreService:HasItem(player: Player, itemId: string): boolean
	if not playerInventory[player] then
		return false
	end
	return playerInventory[player][itemId] ~= nil
end

-- [STORE-008] Equip item
function StoreService:EquipItem(player: Player, itemId: string): (boolean, string?)
	if not playerInventory[player] or not playerInventory[player][itemId] then
		return false, "Item not owned"
	end
	
	local item = playerInventory[player][itemId]
	
	-- Update equipped item in profile
	local DataService = Knit.GetService("DataService")
	local profile = DataService:GetProfile(player)
	
	if not profile then
		return false, "Profile not found"
	end
	
	if not profile.EquippedItems then
		profile.EquippedItems = {}
	end
	
	profile.EquippedItems[item.Type] = itemId
	
	print("[StoreService] " .. player.Name .. " equipped " .. item.Name)
	return true, nil
end

-- Load player inventory from save
function StoreService:LoadInventory(player: Player, data: { string })
	playerInventory[player] = {}
	if data then
		for _, itemId in ipairs(data) do
			local item = STORE_ITEMS[itemId]
			if item then
				playerInventory[player][itemId] = item
			end
		end
	end
end

function StoreService:KnitStart()
	print("[StoreService] Started.")
end

return StoreService
