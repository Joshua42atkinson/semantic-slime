--!strict
--==============================================================
-- MMMM Context: Ethical Monetization Engine. Handles transparent donations for EdTech charity without predatory mechanics.
--==============================================================
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Config for Dev Products (USER MUST REPLACE WITH REAL IDs FROM ROBLOX DASHBOARD)
local DONATION_PRODUCTS = {
    [1000001] = { Amount = 50, Name = "Bronze Letter", Message = "A scholar's contribution!" },
    [1000002] = { Amount = 500, Name = "Silver Letter", Message = "A patron of the arts!" },
    [1000003] = { Amount = 5000, Name = "Golden Letter", Message = "A monumental philanthropic grant!" }
}

-- Target Title for Transparency
local SUPPORT_TARGET = "Supporting Educational Game Development"

local DonationService = Knit.CreateService {
    Name = "DonationService",
    Client = {
        DonationOccurred = Knit.CreateSignal(),
        BoardUpdated = Knit.CreateSignal(),
    },
}

local TopDonorsStore = nil
local RecentDonorsStore = nil

-- Caches
local TopDonorsCache = {}
local RecentDonorsCache = {}

function DonationService:KnitStart()
    print("[DonationService] Booting up Ethical Monetization Engine...")

    local ok, tStore = pcall(function() return DataStoreService:GetOrderedDataStore("PhilanthropistBoard_Top") end)
    if ok then TopDonorsStore = tStore end

    local ok2, rStore = pcall(function() return DataStoreService:GetDataStore("PhilanthropistBoard_Recent") end)
    if ok2 then RecentDonorsStore = rStore end

    -- Setup Receipt Processing
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        return self:ProcessReceipt(receiptInfo)
    end

    -- Initial Data Fetch
    task.spawn(function()
        self:RefreshBoardData()
        
        -- Refresh every 5 minutes
        while true do
            task.wait(300)
            self:RefreshBoardData()
        end
    end)
    
    print("[DonationService] Online. DevEx Support Target: " .. SUPPORT_TARGET)
end

function DonationService:ProcessReceipt(receiptInfo)
    local productId = receiptInfo.ProductId
    local playerId = receiptInfo.PlayerId
    local productObj = DONATION_PRODUCTS[productId]

    -- Check if it's a donation product
    if productObj then
        local player = Players:GetPlayerByUserId(playerId)
        
        if player then
            print(string.format("[DonationService] %s donated %d Robux!", player.Name, productObj.Amount))
            
            -- 1. Notify the server globally!
            self.Client.DonationOccurred:FireAll(player.Name, productObj.Amount, productObj.Name, productObj.Message)
            
            -- 2. Update Zeitgeist (A massive surge of "Light" energy)
            local ZeitgeistService = Knit.GetService("ZeitgeistService")
            if ZeitgeistService then
                -- Massively shift the server mood towards Light based on donation size
                local weight = math.floor(productObj.Amount / 10)
                for i = 1, weight do
                    ZeitgeistService:RecordSemanticEvent("Philanthropy", "Light", "support")
                end
            end
            
            -- 3. Record Data asynchronously
            task.spawn(function()
                self:RecordDonation(playerId, player.Name, productObj.Amount)
            end)
            
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- If it's not a donation product, let another system handle it or grant it
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

function DonationService:RecordDonation(userId: number, username: string, amount: number)
    if not TopDonorsStore or not RecentDonorsStore then return end

    -- Update Top Donors (OrderedDataStore)
    pcall(function()
        TopDonorsStore:IncrementAsync(tostring(userId), amount)
    end)

    -- Update Recent Donors (Standard DataStore array)
    pcall(function()
        local recent = RecentDonorsStore:GetAsync("RecentList") or {}
        table.insert(recent, 1, { Name = username, Amount = amount, Time = os.time() })
        
        -- Cap at 50 recent
        if #recent > 50 then
            table.remove(recent)
        end
        
        RecentDonorsStore:SetAsync("RecentList", recent)
    end)

    -- Immediately refresh the board for clients
    self:RefreshBoardData()
end

function DonationService:RefreshBoardData()
    if not TopDonorsStore or not RecentDonorsStore then return end

    local success, err = pcall(function()
        -- Fetch Top 10
        local pages = TopDonorsStore:GetSortedAsync(false, 10)
        local topData = pages:GetCurrentPage()
        
        TopDonorsCache = {}
        for rank, data in ipairs(topData) do
            -- Need to convert UserId back to Username, fallback to "Philanthropist"
            local name = "Philanthropist"
            pcall(function() name = Players:GetNameFromUserIdAsync(tonumber(data.key) or 0) end)
            
            table.insert(TopDonorsCache, { Rank = rank, Name = name, Amount = data.value })
        end

        -- Fetch Recent
        RecentDonorsCache = RecentDonorsStore:GetAsync("RecentList") or {}
    end)

    if success then
        self.Client.BoardUpdated:FireAll(TopDonorsCache, RecentDonorsCache, SUPPORT_TARGET)
    end
end

-- Allow clients to request the data instantly upon joining
function DonationService.Client:GetBoardData(player: Player)
    return TopDonorsCache, RecentDonorsCache, SUPPORT_TARGET
end

-- Allow clients to explicitly request a donation prompt
function DonationService.Client:PromptDonation(player: Player, productId: number)
    if DONATION_PRODUCTS[productId] then
        MarketplaceService:PromptProductPurchase(player, productId)
    end
end

return DonationService
