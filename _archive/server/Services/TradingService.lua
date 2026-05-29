--!strict
-- Trading Service for Semantic Slime
-- Educational trading system with auction house - NO ROBUX, pure learning economy

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TradingService = Knit.CreateService {
    Name = "TradingService",
    Client = {
        -- Trading events
        TradeRequestSent = Knit.CreateSignal(),
        TradeRequestReceived = Knit.CreateSignal(),
        TradeStarted = Knit.CreateSignal(),
        TradeAccepted = Knit.CreateSignal(),
        TradeDeclined = Knit.CreateSignal(),
        TradeCompleted = Knit.CreateSignal(),
        
        -- Auction house events
        AuctionCreated = Knit.CreateSignal(),
        AuctionBid = Knit.CreateSignal(),
        AuctionEnded = Knit.CreateSignal(),
        AuctionWon = Knit.CreateSignal(),
        
        -- Market events
        MarketItemListed = Knit.CreateSignal(),
        MarketItemSold = Knit.CreateSignal(),
        MarketItemRemoved = Knit.CreateSignal(),
    },
}

-- Types
export type TradeItem = {
    Type: "Slime" | "Crystal" | "Item" | "Knowledge",
    Id: string,
    Name: string,
    Description: string,
    Rarity: string,
    Value: number,
    Properties: {[string]: any},
}

export type Trade = {
    Id: string,
    InitiatorId: number,
    TargetId: number,
    InitiatorOffer: {TradeItem},
    TargetOffer: {TradeItem},
    Status: "Pending" | "Accepted" | "Declined" | "Completed",
    CreatedAt: number,
    ExpiresAt: number,
    Message: string?,
}

export type Auction = {
    Id: string,
    SellerId: number,
    Item: TradeItem,
    StartingBid: number,
    CurrentBid: number,
    CurrentBidderId: number?,
    Bids: {AuctionBid},
    StartTime: number,
    EndTime: number,
    Status: "Active" | "Ended" | "Cancelled",
    BuyoutPrice: number?,
    Description: string,
}

export type AuctionBid = {
    Id: string,
    BidderId: number,
    Amount: number,
    Timestamp: number,
}

export type MarketListing = {
    Id: string,
    SellerId: number,
    Item: TradeItem,
    Price: number,
    ListedAt: number,
    Status: "Active" | "Sold" | "Removed",
    BuyerId: number?,
}

export type PlayerEconomy = {
    UserId: number,
    KnowledgePoints: number,
    TradingReputation: number,
    CompletedTrades: number,
    SuccessfulAuctions: number,
    TotalEarned: number,
    TotalSpent: number,
    FavoriteCategories: {string},
}

-- Configuration
local TRADE_DURATION = 300 -- 5 minutes
local AUCTION_DURATION = 3600 -- 1 hour
local MAX_AUCTIONS_PER_PLAYER = 5
local MAX_MARKET_LISTINGS_PER_PLAYER = 10
local TRADING_FEE = 0.05 -- 5% fee
local MIN_REPUTATION_FOR_AUCTION = 10
local KNOWLEDGE_POINTS_PER_TRADE = 5
local MAX_OFFER_ITEMS = 8
local HISTORY_LIMIT = 50

local VALID_ITEM_TYPES = {
    Slime = true,
    Crystal = true,
    Item = true,
    Knowledge = true,
}

local VALID_RARITIES = {
    Common = true,
    Uncommon = true,
    Rare = true,
    Epic = true,
    Legendary = true,
}

-- Educational value multipliers
local EDUCATIONAL_MULTIPLIERS = {
    ["Slime"] = 1.5, -- Slimes have high educational value
    ["Crystal"] = 1.2, -- Crystals have moderate value
    ["Item"] = 1.0, -- Items have standard value
    ["Knowledge"] = 2.0, -- Knowledge items have highest value
}

-- Data stores
local tradingDataStore = nil -- initialized in KnitStart
local auctionDataStore = nil -- initialized in KnitStart
local marketDataStore = nil -- initialized in KnitStart
local economyDataStore = nil -- initialized in KnitStart
local tradeHistoryStore = nil -- initialized in KnitStart

-- Private state
local activeTrades: {[string]: Trade} = {}
local activeAuctions: {[string]: Auction} = {}
local marketListings: {[string]: MarketListing} = {}
local playerEconomies: {[number]: PlayerEconomy} = {}

-- Private functions
local function generateId(): string
    return HttpService:GenerateGUID(false)
end

function TradingService:GetTradeHistory(userId: number): {any}
    return loadTradeHistory(userId)
end

local function getPlayerEconomy(userId: number): PlayerEconomy
    if not playerEconomies[userId] then
        local success, data = pcall(function()
            return economyDataStore:GetAsync("Economy_" .. userId)
        end)
        
        if success and data then
            playerEconomies[userId] = data
        else
            -- Create new economy
            playerEconomies[userId] = {
                UserId = userId,
                KnowledgePoints = 100, -- Starting points
                TradingReputation = 0,
                CompletedTrades = 0,
                SuccessfulAuctions = 0,
                TotalEarned = 0,
                TotalSpent = 0,
                FavoriteCategories = {},
            }
            
            -- Save new economy
            pcall(function()
                economyDataStore:SetAsync("Economy_" .. userId, playerEconomies[userId])
            end)
        end
    end
    
    return playerEconomies[userId]
end

local function savePlayerEconomy(userId: number)
    local economy = playerEconomies[userId]
    if economy then
        pcall(function()
            economyDataStore:SetAsync("Economy_" .. userId, economy)
        end)
    end
end

local function loadTradeHistory(userId: number): {any}
    local success, history = pcall(function()
        return tradeHistoryStore:GetAsync("History_" .. userId) or {}
    end)

    if success and history then
        return history
    end

    return {}
end

local function saveTradeHistory(userId: number, history: {any})
    pcall(function()
        tradeHistoryStore:SetAsync("History_" .. userId, history)
    end)
end

local function recordTradeHistory(trade: Trade, status: string)
    local function addEntry(userId: number, role: string, offered: {TradeItem}, received: {TradeItem})
        local history = loadTradeHistory(userId)

        local entry = {
            Id = trade.Id,
            WithUserId = role == "Initiator" and trade.TargetId or trade.InitiatorId,
            Role = role,
            Offered = offered,
            Received = received,
            Status = status,
            Timestamp = os.time(),
        }

        table.insert(history, 1, entry)

        -- Cap history length
        if #history > HISTORY_LIMIT then
            while #history > HISTORY_LIMIT do
                table.remove(history)
            end
        end

        saveTradeHistory(userId, history)
    end

    addEntry(trade.InitiatorId, "Initiator", trade.InitiatorOffer, trade.TargetOffer)
    addEntry(trade.TargetId, "Target", trade.TargetOffer, trade.InitiatorOffer)
end

local function calculateItemValue(item: TradeItem): number
    local baseValue = item.Value
    local multiplier = EDUCATIONAL_MULTIPLIERS[item.Type] or 1.0
    
    -- Apply rarity multiplier
    local rarityMultipliers = {
        ["Common"] = 1.0,
        ["Uncommon"] = 1.5,
        ["Rare"] = 2.0,
        ["Epic"] = 3.0,
        ["Legendary"] = 5.0,
    }
    
    local rarityMultiplier = rarityMultipliers[item.Rarity] or 1.0
    
    return math.floor(baseValue * multiplier * rarityMultiplier)
end

local function validateTradeItem(item: TradeItem): boolean
    if type(item) ~= "table" then return false end

    -- Basic required fields
    if type(item.Id) ~= "string" or item.Id == "" then return false end
    if type(item.Name) ~= "string" or item.Name == "" then return false end
    if not VALID_ITEM_TYPES[item.Type] then return false end
    if not VALID_RARITIES[item.Rarity] then return false end
    if type(item.Value) ~= "number" or item.Value <= 0 then return false end

    -- Ownership checks would integrate with inventory services (SlimeFactory, CrystalService, etc.)
    -- Placeholder passes for now; hook here when inventory APIs are available.
    return true
end

local function validateOffer(offer: {TradeItem}, userId: number): boolean
    if type(offer) ~= "table" then return false end
    if #offer == 0 or #offer > MAX_OFFER_ITEMS then return false end

    local totalValue = 0
    for _, item in ipairs(offer) do
        if not validateTradeItem(item) then
            return false
        end
        totalValue += calculateItemValue(item)
    end

    return totalValue > 0
end

local function canPlayerTrade(userId: number): boolean
    local economy = getPlayerEconomy(userId)
    
    -- Check if player has sufficient reputation
    if economy.TradingReputation < -50 then
        return false -- Too low reputation
    end
    
    return true
end

local function awardKnowledgePoints(userId: number, amount: number, reason: string)
    local economy = getPlayerEconomy(userId)
    economy.KnowledgePoints += amount
    
    -- Award reputation for positive trading
    if amount > 0 then
        economy.TradingReputation += math.floor(amount / 10)
    end
    
    savePlayerEconomy(userId)
    
    -- Notify player
    local player = Players:GetPlayerByUserId(userId)
    if player then
        -- Would send notification about knowledge points earned
        print("[TradingService] Awarded", amount, "knowledge points to", player.Name, "for:", reason)
    end
end

local function executeTrade(trade: Trade): boolean
    -- Validate offers
    if not validateOffer(trade.InitiatorOffer, trade.InitiatorId) then
        return false
    end
    if not validateOffer(trade.TargetOffer, trade.TargetId) then
        return false
    end

    -- Validate both players can trade
    if not canPlayerTrade(trade.InitiatorId) or not canPlayerTrade(trade.TargetId) then
        return false
    end
    
    -- Check if both players have sufficient knowledge points for fees
    local initiatorEconomy = getPlayerEconomy(trade.InitiatorId)
    local targetEconomy = getPlayerEconomy(trade.TargetId)
    
    local initiatorFee = calculateTradeFee(trade.InitiatorOffer)
    local targetFee = calculateTradeFee(trade.TargetOffer)
    
    if initiatorEconomy.KnowledgePoints < initiatorFee or targetEconomy.KnowledgePoints < targetFee then
        return false
    end
    
    -- Deduct fees
    initiatorEconomy.KnowledgePoints -= initiatorFee
    targetEconomy.KnowledgePoints -= targetFee
    
    -- Execute trade (would integrate with other services)
    -- For now, just award knowledge points and update reputation
    
    -- Award knowledge points for successful trade
    local tradeValue = calculateTotalTradeValue(trade.InitiatorOffer) + calculateTotalTradeValue(trade.TargetOffer)
    local knowledgeReward = math.floor(tradeValue / 100) + KNOWLEDGE_POINTS_PER_TRADE
    
    awardKnowledgePoints(trade.InitiatorId, knowledgeReward, "Completed trade")
    awardKnowledgePoints(trade.TargetId, knowledgeReward, "Completed trade")
    
    -- Update trade statistics
    initiatorEconomy.CompletedTrades += 1
    targetEconomy.CompletedTrades += 1
    initiatorEconomy.TotalEarned += calculateTotalTradeValue(trade.TargetOffer)
    targetEconomy.TotalEarned += calculateTotalTradeValue(trade.InitiatorOffer)
    initiatorEconomy.TotalSpent += calculateTotalTradeValue(trade.InitiatorOffer)
    targetEconomy.TotalSpent += calculateTotalTradeValue(trade.TargetOffer)
    
    -- Update favorite categories
    updateFavoriteCategories(trade.InitiatorId, trade.TargetOffer)
    updateFavoriteCategories(trade.TargetId, trade.InitiatorOffer)
    
    savePlayerEconomy(trade.InitiatorId)
    savePlayerEconomy(trade.TargetId)

    -- Record history on success
    recordTradeHistory(trade, "Completed")

    return true
end

local function calculateTradeFee(offer: {TradeItem}): number
    local totalValue = calculateTotalTradeValue(offer)
    return math.floor(totalValue * TRADING_FEE)
end

local function calculateTotalTradeValue(offer: {TradeItem}): number
    local total = 0
    for _, item in ipairs(offer) do
        total += calculateItemValue(item)
    end
    return total
end

local function updateFavoriteCategories(userId: number, items: {TradeItem})
    local economy = getPlayerEconomy(userId)
    
    for _, item in ipairs(items) do
        if not economy.FavoriteCategories[item.Type] then
            economy.FavoriteCategories[item.Type] = 0
        end
        economy.FavoriteCategories[item.Type] += 1
    end
end

-- Public methods
function TradingService:GetPlayerEconomy(userId: number): PlayerEconomy
    return getPlayerEconomy(userId)
end

function TradingService:SendTradeRequest(targetUserId: number, offerItems: {TradeItem}, message: string?): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local initiatorId = player.UserId
    
    -- Validate player can trade
    if not canPlayerTrade(initiatorId) then
        return false
    end
    
    -- Validate target player
    if not canPlayerTrade(targetUserId) then
        return false
    end
    
    -- Validate offer items
    if not validateOffer(offerItems, initiatorId) then
        return false
    end
    
    -- Check if player is already in a trade
    for _, trade in pairs(activeTrades) do
        if (trade.InitiatorId == initiatorId or trade.TargetId == initiatorId) and 
           trade.Status == "Pending" then
            return false -- Already in a trade
        end
    end
    
    -- Create trade
    local tradeId = generateId()
    local trade: Trade = {
        Id = tradeId,
        InitiatorId = initiatorId,
        TargetId = targetUserId,
        InitiatorOffer = offerItems,
        TargetOffer = {},
        Status = "Pending",
        CreatedAt = os.time(),
        ExpiresAt = os.time() + TRADE_DURATION,
        Message = message,
    }
    
    activeTrades[tradeId] = trade
    
    -- Notify target player
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    if targetPlayer then
        self.Client.TradeRequestReceived:Fire(targetPlayer, trade)
    end
    
    -- Notify initiator
    self.Client.TradeRequestSent:Fire(player, trade)
    
    -- Auto-expire trade
    task.delay(TRADE_DURATION, function()
        if activeTrades[tradeId] and activeTrades[tradeId].Status == "Pending" then
            activeTrades[tradeId].Status = "Declined"
            
            local initiatorPlayer = Players:GetPlayerByUserId(initiatorId)
            local targetPlayer = Players:GetPlayerByUserId(targetUserId)
            
            if initiatorPlayer then
                self.Client.TradeDeclined:Fire(initiatorPlayer, "Trade expired")
            end
            
            if targetPlayer then
                self.Client.TradeDeclined:Fire(targetPlayer, "Trade expired")
            end
            
            activeTrades[tradeId] = nil
        end
    end)
    
    return true
end

function TradingService:AcceptTradeRequest(tradeId: string, counterOffer: {TradeItem}): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local trade = activeTrades[tradeId]
    if not trade or trade.TargetId ~= player.UserId then
        return false
    end
    
    if trade.Status ~= "Pending" then
        return false
    end
    
    -- Validate counter offer
    if not validateOffer(counterOffer, player.UserId) then
        return false
    end
    
    -- Update trade
    trade.TargetOffer = counterOffer
    trade.Status = "Accepted"
    
    -- Execute trade
    local success = executeTrade(trade)
    
    if success then
        -- Notify both players
        local initiatorPlayer = Players:GetPlayerByUserId(trade.InitiatorId)
        local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
        recordTradeHistory(trade, "Completed")
        
        if initiatorPlayer then
            self.Client.TradeCompleted:Fire(initiatorPlayer, trade)
        end
        
        if targetPlayer then
            self.Client.TradeCompleted:Fire(targetPlayer, trade)
        end
    else
        -- Trade failed
        trade.Status = "Declined"
        recordTradeHistory(trade, "Declined")
        
        local initiatorPlayer = Players:GetPlayerByUserId(trade.InitiatorId)
        local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
        
        if initiatorPlayer then
            self.Client.TradeDeclined:Fire(initiatorPlayer, "Trade failed - insufficient resources")
        end
        
        if targetPlayer then
            self.Client.TradeDeclined:Fire(targetPlayer, "Trade failed - insufficient resources")
        end
    end
    
    activeTrades[tradeId] = nil
    
    return success
end

function TradingService:DeclineTradeRequest(tradeId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local trade = activeTrades[tradeId]
    if not trade then return false end
    
    if trade.InitiatorId ~= player.UserId and trade.TargetId ~= player.UserId then
        return false
    end
    
    trade.Status = "Declined"
    
    -- Notify both players
    local initiatorPlayer = Players:GetPlayerByUserId(trade.InitiatorId)
    local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
    
    if initiatorPlayer then
        self.Client.TradeDeclined:Fire(initiatorPlayer, "Trade declined")
    end
    
    if targetPlayer then
        self.Client.TradeDeclined:Fire(targetPlayer, "Trade declined")
    end
    
    activeTrades[tradeId] = nil
    
    return true
end

function TradingService:CreateAuction(item: TradeItem, startingBid: number, buyoutPrice: number?, duration: number?, description: string?): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local sellerId = player.UserId
    
    -- Validate player can create auction
    local economy = getPlayerEconomy(sellerId)
    if economy.TradingReputation < MIN_REPUTATION_FOR_AUCTION then
        return false
    end
    
    -- Check auction limit
    local playerAuctionCount = 0
    for _, auction in pairs(activeAuctions) do
        if auction.SellerId == sellerId and auction.Status == "Active" then
            playerAuctionCount += 1
        end
    end
    
    if playerAuctionCount >= MAX_AUCTIONS_PER_PLAYER then
        return false
    end
    
    -- Validate item
    if not validateTradeItem(item) then
        return false
    end
    
    -- Validate bid amounts
    if startingBid <= 0 or (buyoutPrice and buyoutPrice <= startingBid) then
        return false
    end
    
    -- Create auction
    local auctionId = generateId()
    local auction: Auction = {
        Id = auctionId,
        SellerId = sellerId,
        Item = item,
        StartingBid = startingBid,
        CurrentBid = startingBid,
        CurrentBidderId = nil,
        Bids = {},
        StartTime = os.time(),
        EndTime = os.time() + (duration or AUCTION_DURATION),
        Status = "Active",
        BuyoutPrice = buyoutPrice,
        Description = description or "",
    }
    
    activeAuctions[auctionId] = auction
    
    -- Save auction
    pcall(function()
        auctionDataStore:SetAsync("Auction_" .. auctionId, auction)
    end)
    
    -- Notify all players
    self.Client.AuctionCreated:FireAll(auction)
    
    -- Auto-end auction
    task.delay(duration or AUCTION_DURATION, function()
        endAuction(auctionId)
    end)
    
    return true
end

function TradingService:PlaceBid(auctionId: string, bidAmount: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local bidderId = player.UserId
    local auction = activeAuctions[auctionId]
    
    if not auction or auction.Status ~= "Active" then
        return false
    end
    
    if auction.SellerId == bidderId then
        return false -- Cannot bid on own auction
    end
    
    -- Validate bid
    if bidAmount <= auction.CurrentBid then
        return false -- Bid must be higher than current bid
    end
    
    -- Check if player has sufficient knowledge points
    local economy = getPlayerEconomy(bidderId)
    if economy.KnowledgePoints < bidAmount then
        return false
    end
    
    -- Create bid
    local bid: AuctionBid = {
        Id = generateId(),
        BidderId = bidderId,
        Amount = bidAmount,
        Timestamp = os.time(),
    }
    
    -- Update auction
    auction.CurrentBid = bidAmount
    auction.CurrentBidderId = bidderId
    table.insert(auction.Bids, bid)
    
    -- Save auction
    pcall(function()
        auctionDataStore:SetAsync("Auction_" .. auctionId, auction)
    end)
    
    -- Check for buyout
    if auction.BuyoutPrice and bidAmount >= auction.BuyoutPrice then
        endAuction(auctionId, true)
    else
        -- Notify players
        self.Client.AuctionBid:FireAll(auction, bid)
    end
    
    return true
end

function TradingService:CreateMarketListing(item: TradeItem, price: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local sellerId = player.UserId
    
    -- Check listing limit
    local playerListingCount = 0
    for _, listing in pairs(marketListings) do
        if listing.SellerId == sellerId and listing.Status == "Active" then
            playerListingCount += 1
        end
    end
    
    if playerListingCount >= MAX_MARKET_LISTINGS_PER_PLAYER then
        return false
    end
    
    -- Validate item and price
    if not validateTradeItem(item) or price <= 0 then
        return false
    end
    
    -- Create listing
    local listingId = generateId()
    local listing: MarketListing = {
        Id = listingId,
        SellerId = sellerId,
        Item = item,
        Price = price,
        ListedAt = os.time(),
        Status = "Active",
        BuyerId = nil,
    }
    
    marketListings[listingId] = listing
    
    -- Save listing
    pcall(function()
        marketDataStore:SetAsync("Listing_" .. listingId, listing)
    end)
    
    -- Notify all players
    self.Client.MarketItemListed:FireAll(listing)
    
    return true
end

function TradingService:BuyFromMarket(listingId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local buyerId = player.UserId
    local listing = marketListings[listingId]
    
    if not listing or listing.Status ~= "Active" then
        return false
    end
    
    if listing.SellerId == buyerId then
        return false -- Cannot buy own listing
    end
    
    -- Check if buyer has sufficient knowledge points
    local buyerEconomy = getPlayerEconomy(buyerId)
    if buyerEconomy.KnowledgePoints < listing.Price then
        return false
    end
    
    -- Execute purchase
    buyerEconomy.KnowledgePoints -= listing.Price
    
    local sellerEconomy = getPlayerEconomy(listing.SellerId)
    sellerEconomy.KnowledgePoints += listing.Price
    
    -- Update listing
    listing.Status = "Sold"
    listing.BuyerId = buyerId
    
    -- Award knowledge points for successful transaction
    awardKnowledgePoints(buyerId, math.floor(listing.Price / 50), "Market purchase")
    awardKnowledgePoints(listing.SellerId, math.floor(listing.Price / 50), "Market sale")
    
    -- Update statistics
    buyerEconomy.TotalSpent += listing.Price
    sellerEconomy.TotalEarned += listing.Price
    
    savePlayerEconomy(buyerId)
    savePlayerEconomy(listing.SellerId)
    
    -- Save listing
    pcall(function()
        marketDataStore:SetAsync("Listing_" .. listingId, listing)
    end)
    
    -- Notify players
    self.Client.MarketItemSold:FireAll(listing)
    
    return true
end

function TradingService:GetActiveAuctions(): {Auction}
    local activeAuctionsList = {}
    
    for _, auction in pairs(activeAuctions) do
        if auction.Status == "Active" then
            table.insert(activeAuctionsList, auction)
        end
    end
    
    return activeAuctionsList
end

function TradingService:GetMarketListings(): {MarketListing}
    local activeListings = {}
    
    for _, listing in pairs(marketListings) do
        if listing.Status == "Active" then
            table.insert(activeListings, listing)
        end
    end
    
    return activeListings
end

-- Private helper functions
function endAuction(auctionId: string, buyout: boolean?)
    local auction = activeAuctions[auctionId]
    if not auction or auction.Status ~= "Active" then
        return
    end
    
    auction.Status = "Ended"
    
    -- Award item to winner if there's a bid
    if auction.CurrentBidderId then
        local winnerEconomy = getPlayerEconomy(auction.CurrentBidderId)
        local sellerEconomy = getPlayerEconomy(auction.SellerId)
        
        -- Transfer knowledge points
        winnerEconomy.KnowledgePoints -= auction.CurrentBid
        sellerEconomy.KnowledgePoints += auction.CurrentBid
        
        -- Award knowledge points for successful auction
        local knowledgeReward = math.floor(auction.CurrentBid / 100) + 10
        awardKnowledgePoints(auction.SellerId, knowledgeReward, "Successful auction")
        awardKnowledgePoints(auction.CurrentBidderId, math.floor(knowledgeReward / 2), "Auction win")
        
        -- Update statistics
        sellerEconomy.SuccessfulAuctions += 1
        sellerEconomy.TotalEarned += auction.CurrentBid
        winnerEconomy.TotalSpent += auction.CurrentBid
        
        savePlayerEconomy(auction.SellerId)
        savePlayerEconomy(auction.CurrentBidderId)
        
        -- Notify players
        local winnerPlayer = Players:GetPlayerByUserId(auction.CurrentBidderId)
        local sellerPlayer = Players:GetPlayerByUserId(auction.SellerId)
        
        if winnerPlayer then
            self.Client.AuctionWon:Fire(winnerPlayer, auction)
        end
        
        if sellerPlayer then
            self.Client.AuctionEnded:Fire(sellerPlayer, auction)
        end
    end
    
    -- Save auction
    pcall(function()
        auctionDataStore:SetAsync("Auction_" .. auctionId, auction)
    end)
    
    activeAuctions[auctionId] = nil
end

-- Service lifecycle
function TradingService:KnitStart()
    print("[TradingService] Starting educational trading system...")
    
    -- Load active auctions and listings
    -- In production, you'd load these from data stores
    
    print("[TradingService] Educational trading system started.")
end

function TradingService:KnitStop()
    print("[TradingService] Stopping educational trading system...")
    
    -- Save all active data
    for auctionId, auction in pairs(activeAuctions) do
        pcall(function()
            auctionDataStore:SetAsync("Auction_" .. auctionId, auction)
        end)
    end
    
    for listingId, listing in pairs(marketListings) do
        pcall(function()
            marketDataStore:SetAsync("Listing_" .. listingId, listing)
        end)
    end
    
    print("[TradingService] Educational trading system stopped.")
end

-- Client handlers
function TradingService.Client:SendTradeRequest(player: Player, targetUserId: number, offerItems: {TradeItem}, message: string?)
    return self:SendTradeRequest(targetUserId, offerItems, message)
end

function TradingService.Client:AcceptTradeRequest(player: Player, tradeId: string, counterOffer: {TradeItem})
    return self:AcceptTradeRequest(tradeId, counterOffer)
end

function TradingService.Client:DeclineTradeRequest(player: Player, tradeId: string)
    return self:DeclineTradeRequest(tradeId)
end

function TradingService.Client:CreateAuction(player: Player, item: TradeItem, startingBid: number, buyoutPrice: number?, duration: number?, description: string?)
    return self:CreateAuction(item, startingBid, buyoutPrice, duration, description)
end

function TradingService.Client:PlaceBid(player: Player, auctionId: string, bidAmount: number)
    return self:PlaceBid(auctionId, bidAmount)
end

function TradingService.Client:CreateMarketListing(player: Player, item: TradeItem, price: number)
    return self:CreateMarketListing(item, price)
end

function TradingService.Client:BuyFromMarket(player: Player, listingId: string)
    return self:BuyFromMarket(listingId)
end

function TradingService.Client:GetActiveAuctions(player: Player)
    return self:GetActiveAuctions()
end

function TradingService.Client:GetMarketListings(player: Player)
    return self:GetMarketListings()
end

return TradingService
