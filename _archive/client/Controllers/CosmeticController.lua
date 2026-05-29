--!strict
--==============================================================
-- MMMM Context: Client interface for Slime Auras. Allowing players to equip effects and showcase their philanthropy.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CosmeticController = Knit.CreateController { Name = "CosmeticController" }

function CosmeticController:KnitStart()
    local CosmeticService = Knit.GetService("CosmeticService")
    
    -- Listen for successful equipping
    CosmeticService.AuraEquipped:Connect(function(passName)
        print("[CosmeticController] Successfully equipped Aura: " .. passName)
        
        -- Play equip sound
        local SoundController = Knit.GetController("SoundController")
        if SoundController then
            SoundController:Play("LevelUp")
        end
    end)
    
    print("[CosmeticController] Online. Prepared to render Semantic Vanity.")
end

-- Used by a future UI screen to purchase an aura
function CosmeticController:PromptPurchase(passId: number)
    local player = game.Players.LocalPlayer
    MarketplaceService:PromptGamePassPurchase(player, passId)
end

-- Used by UI to attempt equipping
function CosmeticController:EquipAura(passId: number)
    local CosmeticService = Knit.GetService("CosmeticService")
    CosmeticService:EquipAura(passId):andThen(function(success, msg)
        if not success then
            warn("[CosmeticController] " .. msg)
        end
    end):catch(warn)
end

-- Get current state for UI
function CosmeticController:GetCurrentAura()
    local CosmeticService = Knit.GetService("CosmeticService")
    -- Return a promise to the UI
    return CosmeticService:GetEquipped()
end

return CosmeticController
