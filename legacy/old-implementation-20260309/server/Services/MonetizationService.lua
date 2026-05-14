--!strict
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local MonetizationService = Knit.CreateService {
    Name = "MonetizationService",
    Client = {},
}

-- MOCK IDs for Testing
local PRODUCTS = {
    INSIGHT_PACK_SMALL = 1001, -- +50 Insight
    INSIGHT_PACK_LARGE = 1002, -- +200 Insight
    INSTANT_EVOLVE = 1003, -- Evolve focused word instantly (requires client context, tricky for product receipt)
}

local GAMEPASSES = {
    DOUBLE_XP = 2001,
    RARE_FINDER = 2002, -- Increased chance for shiny words
    VIP_ACCESS = 2003, -- Free entry to premium districts
}

function MonetizationService:KnitStart()
    local DataService = Knit.GetService("DataService")
    
    -- Setup Marketplace Callbacks
    
    -- 1. GamePass Purchase Finished
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
        if wasPurchased then
            self:HandleGamePass(player, passId)
        end
    end)
    
    -- 2. Process Receipt (Dev Products)
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        
        local productId = receiptInfo.ProductId
        local success, err = pcall(function()
            self:HandleProduct(player, productId)
        end)
        
        if success then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        else
            warn("Product purchase failed: " .. tostring(err))
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end
    
    -- Check GamePasses on Join
    Players.PlayerAdded:Connect(function(player)
        for _, id in pairs(GAMEPASSES) do
            -- Mock Check or Real Check
            -- In Studio, user owns everything if it's created by them, but mocking fails for uncreated assets.
            -- We'll rely on pcall
            task.spawn(function()
                 local success, hasPass = pcall(function()
                     return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
                 end)
                 if success and hasPass then
                     self:SetGamePassStatus(player, id, true)
                 end
            end)
        end
    end)
    
    print("[MonetizationService] Started.")
end

function MonetizationService:HandleGamePass(player: Player, passId: number)
    self:SetGamePassStatus(player, passId, true)
    print(player.Name .. " bought GamePass: " .. passId)
    -- Notify GUI via DataService update
end

function MonetizationService:SetGamePassStatus(player: Player, passId: number, active: boolean)
    local DataService = Knit.GetService("DataService")
    local profile = DataService:GetProfile(player)
    if profile then
        profile.GamePasses[tostring(passId)] = active
        -- Sync to client?
        DataService.Client.DataUpdated:Fire(player, "GamePasses", profile.GamePasses)
    end
end

function MonetizationService:HandleProduct(player: Player, productId: number)
    local DataService = Knit.GetService("DataService")
    local profile = DataService:GetProfile(player)
    if not profile then error("No Profile") end
    
    if productId == PRODUCTS.INSIGHT_PACK_SMALL then
        profile.Stats.Insight = (profile.Stats.Insight or 0) + 50
        print("Granted 50 Insight to " .. player.Name)
        DataService.Client.DataUpdated:Fire(player, "Stats", profile.Stats)
        
    elseif productId == PRODUCTS.INSIGHT_PACK_LARGE then
        profile.Stats.Insight = (profile.Stats.Insight or 0) + 200
        print("Granted 200 Insight to " .. player.Name)
        DataService.Client.DataUpdated:Fire(player, "Stats", profile.Stats)
    
    else
        warn("Unknown Product ID: " .. productId)
    end
end

-- Client Methods to prompt?
function MonetizationService.Client:PromptProduct(player, productId)
    MarketplaceService:PromptProductPurchase(player, productId)
end

function MonetizationService.Client:PromptGamePass(player, passId)
    MarketplaceService:PromptGamePassPurchase(player, passId)
end


return MonetizationService
