--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TradeService = Knit.CreateService {
	Name = "TradeService",
	Client = {
		TradeRequested = Knit.CreateSignal(),
		TradeAccepted = Knit.CreateSignal(),
		TradeCompleted = Knit.CreateSignal(),
		TradeCancelled = Knit.CreateSignal(),
	},
}

-- Types
export type TradeOffer = {
	TradeId: string,
	FromPlayer: Player,
	ToPlayer: Player,
	FromSlimes: { string },  -- InstanceIds
	ToSlimes: { string },    -- InstanceIds
	Status: "Pending" | "Accepted" | "Completed" | "Cancelled",
	FromAccepted: boolean,
	ToAccepted: boolean,
	CreatedAt: number,
}

-- Private state
local activeTrades: { [string]: TradeOffer } = {}
local pendingRequests: { [string]: { [Player]: number } } = {} -- player -> { targetPlayer -> timestamp }

-- [TRADE-001] Send trade request
function TradeService:RequestTrade(requester: Player, target: Player): (string?, string?)
	-- Can't trade with self
	if requester == target then
		return nil, "Cannot trade with yourself"
	end
	
	-- Cooldown check (30 seconds)
	if pendingRequests[requester] and pendingRequests[requester][target] then
		local lastRequest = pendingRequests[requester][target]
		if os.time() - lastRequest < 30 then
			return nil, "Please wait before requesting again"
		end
	end
	
	-- Store request
	if not pendingRequests[requester] then
		pendingRequests[requester] = {}
	end
	pendingRequests[requester][target] = os.time()
	
	-- Notify target player
	self.Client.TradeRequested:Fire(target, requester)
	print("[TradeService] " .. requester.Name .. " requested trade with " .. target.Name)
	
	return "request_sent", nil
end

-- [TRADE-002] Accept trade request
function TradeService:AcceptTrade(accepter: Player, requester: Player): (TradeOffer?, string?)
	-- Create new trade
	local tradeId = HttpService:GenerateGUID(false)
	
	local trade: TradeOffer = {
		TradeId = tradeId,
		FromPlayer = requester,
		ToPlayer = accepter,
		FromSlimes = {},
		ToSlimes = {},
		Status = "Pending",
		FromAccepted = false,
		ToAccepted = false,
		CreatedAt = os.time(),
	}
	
	activeTrades[tradeId] = trade
	
	-- Notify both players
	self.Client.TradeAccepted:Fire(requester, trade)
	self.Client.TradeAccepted:Fire(accepter, trade)
	print("[TradeService] Trade started between " .. requester.Name .. " and " .. accepter.Name)
	
	return trade, nil
end

-- [TRADE-003] Add slime to trade
function TradeService:AddSlime(player: Player, tradeId: string, instanceId: string): (boolean, string?)
	local trade = activeTrades[tradeId]
	if not trade then
		return false, "Trade not found"
	end
	
	-- Verify player is part of trade
	if player ~= trade.FromPlayer and player ~= trade.ToPlayer then
		return false, "Not part of this trade"
	end
	
	-- Check if trade is still pending
	if trade.Status ~= "Pending" then
		return false, "Trade is no longer pending"
	end
	
	-- Get slime info
	local SlimeFactory = Knit.GetService("SlimeFactory")
	local slime = SlimeFactory:GetSlime(player, instanceId)
	if not slime then
		return false, "Slime not found"
	end
	
	-- Check if slime can be traded (not fully evolved)
	local EvolutionService = Knit.GetService("EvolutionService")
	local canTrade, tradeError = EvolutionService:CanTradeSlime(player, instanceId)
	if not canTrade then
		return false, tradeError
	end
	
	-- Add to appropriate side
	if player == trade.FromPlayer then
		table.insert(trade.FromSlimes, instanceId)
	else
		table.insert(trade.ToSlimes, instanceId)
	end
	
	-- Reset accept status when items change
	trade.FromAccepted = false
	trade.ToAccepted = false
	
	print("[TradeService] " .. player.Name .. " added " .. slime.Term .. " to trade " .. tradeId)
	return true, nil
end

-- [TRADE-004] Remove slime from trade
function TradeService:RemoveSlime(player: Player, tradeId: string, instanceId: string): (boolean, string?)
	local trade = activeTrades[tradeId]
	if not trade then
		return false, "Trade not found"
	end
	
	if player ~= trade.FromPlayer and player ~= trade.ToPlayer then
		return false, "Not part of this trade"
	end
	
	if trade.Status ~= "Pending" then
		return false, "Trade is no longer pending"
	end
	
	-- Remove from appropriate side
	local removed = false
	if player == trade.FromPlayer then
		for i, id in ipairs(trade.FromSlimes) do
			if id == instanceId then
				table.remove(trade.FromSlimes, i)
				removed = true
				break
			end
		end
	else
		for i, id in ipairs(trade.ToSlimes) do
			if id == instanceId then
				table.remove(trade.ToSlimes, i)
				removed = true
				break
			end
		end
	end
	
	if not removed then
		return false, "Slime not in trade"
	end
	
	trade.FromAccepted = false
	trade.ToAccepted = false
	return true, nil
end

-- [TRADE-005] Accept trade terms
function TradeService:AcceptTerms(player: Player, tradeId: string): (boolean, string?)
	local trade = activeTrades[tradeId]
	if not trade then
		return false, "Trade not found"
	end
	
	if player ~= trade.FromPlayer and player ~= trade.ToPlayer then
		return false, "Not part of this trade"
	end
	
	if trade.Status ~= "Pending" then
		return false, "Trade is not pending"
	end
	
	-- Set acceptance
	if player == trade.FromPlayer then
		trade.FromAccepted = true
	else
		trade.ToAccepted = true
	end
	
	-- Check if both accepted
	if trade.FromAccepted and trade.ToAccepted then
		trade.Status = "Accepted"
		-- Execute trade
		return self:ExecuteTrade(tradeId)
	end
	
	return true, nil
end

-- [TRADE-006] Execute completed trade
function TradeService:ExecuteTrade(tradeId: string): (boolean, string?)
	local trade = activeTrades[tradeId]
	if not trade then
		return false, "Trade not found"
	end
	
	local SlimeFactory = Knit.GetService("SlimeFactory")
	
	-- Transfer slimes from requester to accepter
	for _, instanceId in ipairs(trade.FromSlimes) do
		local slime = SlimeFactory:GetSlime(trade.FromPlayer, instanceId)
		if slime then
			-- Add to new owner's inventory
			local newSlime = SlimeFactory:CreateSlime(trade.ToPlayer, slime.WordId)
			if newSlime then
				newSlime.Level = slime.Level
				newSlime.XP = slime.XP
				newSlime.Stats = slime.Stats
				newSlime.Rarity = slime.Rarity
				newSlime.EvolutionStage = slime.EvolutionStage
			end
		end
	end
	
	-- Transfer slimes from accepter to requester
	for _, instanceId in ipairs(trade.ToSlimes) do
		local slime = SlimeFactory:GetSlime(trade.ToPlayer, instanceId)
		if slime then
			local newSlime = SlimeFactory:CreateSlime(trade.FromPlayer, slime.WordId)
			if newSlime then
				newSlime.Level = slime.Level
				newSlime.XP = slime.XP
				newSlime.Stats = slime.Stats
				newSlime.Rarity = slime.Rarity
				newSlime.EvolutionStage = slime.EvolutionStage
			end
		end
	end
	
	trade.Status = "Completed"
	
	-- Notify both players
	self.Client.TradeCompleted:Fire(trade.FromPlayer, trade)
	self.Client.TradeCompleted:Fire(trade.ToPlayer, trade)
	print("[TradeService] Trade " .. tradeId .. " completed")
	
	-- Clean up after delay
	task.delay(60, function()
		activeTrades[tradeId] = nil
	end)
	
	return true, nil
end

-- [TRADE-007] Cancel trade
function TradeService:CancelTrade(player: Player, tradeId: string): (boolean, string?)
	local trade = activeTrades[tradeId]
	if not trade then
		return false, "Trade not found"
	end
	
	if player ~= trade.FromPlayer and player ~= trade.ToPlayer then
		return false, "Not part of this trade"
	end
	
	trade.Status = "Cancelled"
	
	self.Client.TradeCancelled:Fire(trade.FromPlayer, trade)
	self.Client.TradeCancelled:Fire(trade.ToPlayer, trade)
	print("[TradeService] Trade " .. tradeId .. " cancelled by " .. player.Name)
	
	activeTrades[tradeId] = nil
	return true, nil
end

-- [TRADE-008] Get player's active trade
function TradeService:GetActiveTrade(player: Player): TradeOffer?
	for _, trade in pairs(activeTrades) do
		if trade.FromPlayer == player or trade.ToPlayer == player then
			if trade.Status == "Pending" or trade.Status == "Accepted" then
				return trade
			end
		end
	end
	return nil
end

-- [TRADE-009] Get trade details
function TradeService:GetTradeDetails(tradeId: string): TradeOffer?
	return activeTrades[tradeId]
end

function TradeService:KnitStart()
	print("[TradeService] Started.")
end

return TradeService
