--!strict
--==============================================================
-- MMMM Context: Acts as the player's historical log of semantic discoveries. Connects personal progression to global lexicon growth.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local GalleryService = Knit.CreateService {
	Name = "GalleryService",
	Client = {
		ExhibitAdded = Knit.CreateSignal(),
		ExhibitRemoved = Knit.CreateSignal(),
		VoteCast = Knit.CreateSignal(),
	},
}

-- Types
export type GalleryExhibit = {
	ExhibitId: string,
	PlayerId: number,
	PlayerName: string,
	SlimeInstanceId: string,
	SlimeTerm: string,
	SlimeRarity: string,
	EvolutionStage: number,
	Caption: string,
	Likes: number,
	Dislikes: number,
	CreatedAt: number,
}

-- Configuration
local MAX_EXHIBITS = 100
local GALLERY_CATEGORIES = { "Newest", "TopRated", "Rarest", "MostEvolved" }

-- Private state
local exhibits: { [string]: GalleryExhibit } = {}
local exhibitOrder: { string } = {} -- Ordered list of exhibit IDs

-- [GALLERY-001] Add slime to gallery
function GalleryService:AddExhibit(player: Player, instanceId: string, caption: string): (GalleryExhibit?, string?)
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	
	if not slime then
		return nil, "Slime not found"
	end
	
	-- Check if already exhibited
	for _, exhibit in pairs(exhibits) do
		if exhibit.PlayerId == player.UserId and exhibit.SlimeInstanceId == instanceId then
			return nil, "Slime already in gallery"
		end
	end
	
	-- Create exhibit
	local exhibitId = tostring(os.time()) .. "_" .. player.UserId
	local exhibit: GalleryExhibit = {
		ExhibitId = exhibitId,
		PlayerId = player.UserId,
		PlayerName = player.Name,
		SlimeInstanceId = instanceId,
		SlimeTerm = slime.Term,
		SlimeRarity = slime.Rarity,
		EvolutionStage = slime.EvolutionStage,
		Caption = caption or "",
		Likes = 0,
		Dislikes = 0,
		CreatedAt = os.time(),
	}
	
	-- Add to gallery
	exhibits[exhibitId] = exhibit
	table.insert(exhibitOrder, 1, exhibitId)
	
	-- Trim if needed
	while #exhibitOrder > MAX_EXHIBITS do
		local removedId = table.remove(exhibitOrder)
		exhibits[removedId] = nil
	end
	
	self.Client.ExhibitAdded:Fire(nil, exhibit)
	print("[GalleryService] " .. player.Name .. " added " .. slime.Term .. " to gallery")
	
	return exhibit, nil
end

-- [GALLERY-002] Remove exhibit
function GalleryService:RemoveExhibit(player: Player, exhibitId: string): (boolean, string?)
	local exhibit = exhibits[exhibitId]
	
	if not exhibit then
		return false, "Exhibit not found"
	end
	
	if exhibit.PlayerId ~= player.UserId then
		return false, "Not your exhibit"
	end
	
	exhibits[exhibitId] = nil
	
	for i, id in ipairs(exhibitOrder) do
		if id == exhibitId then
			table.remove(exhibitOrder, i)
			break
		end
	end
	
	self.Client.ExhibitRemoved:Fire(nil, exhibitId)
	print("[GalleryService] Exhibit " .. exhibitId .. " removed")
	
	return true, nil
end

-- [GALLERY-003] Get gallery exhibits
function GalleryService:GetExhibits(category: string, offset: number, limit: number): { GalleryExhibit }
	local result = {}
	local sorted = {}
	
	-- Sort based on category
	if category == "Newest" then
		sorted = exhibitOrder
	elseif category == "TopRated" then
		-- Sort by likes
		local sortedExhibits = {}
		for id, _ in pairs(exhibits) do
			table.insert(sortedExhibits, id)
		end
		table.sort(sortedExhibits, function(a, b)
			return exhibits[a].Likes > exhibits[b].Likes
		end)
		sorted = sortedExhibits
	elseif category == "Rarest" then
		local rarityOrder = { "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common" }
		local sortedExhibits = {}
		for id, _ in pairs(exhibits) do
			table.insert(sortedExhibits, id)
		end
		table.sort(sortedExhibits, function(a, b)
			local rarityA = 0
			local rarityB = 0
			for i, r in ipairs(rarityOrder) do
				if exhibits[a].SlimeRarity == r then rarityA = i end
				if exhibits[b].SlimeRarity == r then rarityB = i end
			end
			return rarityA < rarityB
		end)
		sorted = sortedExhibits
	elseif category == "MostEvolved" then
		local sortedExhibits = {}
		for id, _ in pairs(exhibits) do
			table.insert(sortedExhibits, id)
		end
		table.sort(sortedExhibits, function(a, b)
			return exhibits[a].EvolutionStage > exhibits[b].EvolutionStage
		end)
		sorted = sortedExhibits
	else
		sorted = exhibitOrder
	end
	
	-- Apply pagination
	offset = offset or 1
	limit = limit or 20
	
	for i = offset, math.min(offset + limit - 1, #sorted) do
		local exhibit = exhibits[sorted[i]]
		if exhibit then
			table.insert(result, exhibit)
		end
	end
	
	return result
end

-- [GALLERY-004] Vote on exhibit
function GalleryService:Vote(player: Player, exhibitId: string, isLike: boolean): (boolean, string?)
	local exhibit = exhibits[exhibitId]
	
	if not exhibit then
		return false, "Exhibit not found"
	end
	
	if exhibit.PlayerId == player.UserId then
		return false, "Cannot vote on your own exhibit"
	end
	
	if isLike then
		exhibit.Likes = exhibit.Likes + 1
	else
		exhibit.Dislikes = exhibit.Dislikes + 1
	end
	
	self.Client.VoteCast:Fire(nil, exhibitId, isLike)
	
	return true, nil
end

-- [GALLERY-005] Get exhibit details
function GalleryService:GetExhibitDetails(exhibitId: string): GalleryExhibit?
	return exhibits[exhibitId]
end

-- [GALLERY-006] Get player's exhibits
function GalleryService:GetPlayerExhibits(player: Player): { GalleryExhibit }
	local result = {}
	
	for _, exhibit in pairs(exhibits) do
		if exhibit.PlayerId == player.UserId then
			table.insert(result, exhibit)
		end
	end
	
	return result
end

-- [GALLERY-007] Get gallery stats
function GalleryService:GetGalleryStats(): { totalExhibits: number, categories: { string } }
	return {
		totalExhibits = #exhibitOrder,
		categories = GALLERY_CATEGORIES,
	}
end

function GalleryService:KnitStart()
	print("[GalleryService] Started.")
end

return GalleryService
