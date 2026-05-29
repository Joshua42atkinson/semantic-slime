--!strict
--==============================================================
-- MMMM Context: Physical vanity for biological Slimes. Extends player expression while generating ethical charity revenue.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Config for Passes (USER MUST REPLACE WITH REAL IDs)
-- Unlike Developer Products which are consumable, Auras are Gamepasses
local COSMETIC_PASSES = {
    [2000001] = { Name = "Galactic Aura", Type = "Aura", Color = Color3.fromRGB(150, 0, 255) },
    [2000002] = { Name = "Holographic Aurora", Type = "Aura", Color = Color3.fromRGB(0, 255, 200) },
    [2000003] = { Name = "Abyssal Void", Type = "Aura", Color = Color3.fromRGB(0, 0, 0) },
}

local CosmeticService = Knit.CreateService {
    Name = "CosmeticService",
    Client = {
        AuraEquipped = Knit.CreateSignal(),
    },
}

-- Player session data for equipped cosmetics
local EquippedCosmetics: { [Player]: string } = {}

function CosmeticService:KnitStart()
    print("[CosmeticService] Aura Engine Online.")
    
    Players.PlayerRemoving:Connect(function(player)
        EquippedCosmetics[player] = nil
    end)
end

-- Check if player owns the Gamepass
function CosmeticService:CheckOwnership(player: Player, passId: number)
    local hasPass = false
    local success, err = pcall(function()
        hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    
    if not success then
        warn("[CosmeticService] Failed to check ownership: ", err)
    end
    
    return hasPass
end

-- Client triggers this to equip a specific aura ID
function CosmeticService.Client:EquipAura(player: Player, passId: number)
    return self.Server:EquipAura(player, passId)
end

function CosmeticService:EquipAura(player: Player, passId: number)
    local passData = COSMETIC_PASSES[passId]
    if not passData then return false, "Invalid Aura" end
    
    local owns = self:CheckOwnership(player, passId)
    if not owns then return false, "You do not own this Aura!" end
    
    EquippedCosmetics[player] = passData.Name
    print(string.format("[CosmeticService] %s equipped %s", player.Name, passData.Name))
    
    -- Re-apply aura to the player's current physical companion, if it exists
    local PetService = Knit.GetService("PetService")
    if PetService then
        local activePets = PetService:GetActivePets()
        if activePets and activePets[player] then
            local petModel = Workspace:FindFirstChild(player.Name .. "_Companion")
            if petModel then
                self:ApplyAuraToModel(petModel, passData.Name)
            end
        end
    end
    
    self.Client.AuraEquipped:Fire(player, passData.Name)
    return true, "Equipped " .. passData.Name
end

-- Fetch what a player currently has equipped
function CosmeticService:GetEquipped(player: Player)
    return EquippedCosmetics[player] or "None"
end

function CosmeticService.Client:GetEquipped(player: Player)
    return self.Server:GetEquipped(player)
end

-- Applies the visual particle emitters to the 3D model
function CosmeticService:ApplyAuraToModel(model: Model | Part, auraName: string)
    -- Find main body part
    local attachmentPart = model:IsA("Model") and model.PrimaryPart or model
    if not attachmentPart then return end
    
    -- Clean existing auras
    for _, child in ipairs(attachmentPart:GetChildren()) do
        if child.Name == "AuraEmitter" then
            child:Destroy()
        end
    end
    
    -- Define Aura visuals
    local auraVisuals = {
        ["Galactic Aura"] = {
            Texture = "rbxassetid://5042898956", -- Starlight
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 255))
            }),
            Size = NumberSequence.new(2, 0),
            Rate = 30,
            Speed = NumberRange.new(1, 4),
            Life = NumberRange.new(1.5, 3),
            Rotation = NumberRange.new(-180, 180),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0.4),
                NumberSequenceKeypoint.new(0.8, 0.4),
                NumberSequenceKeypoint.new(1, 1)
            })
        },
        ["Holographic Aurora"] = {
            Texture = "rbxassetid://4702172778", -- Scanline / grid
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 100))
            }),
            Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 4),
                NumberSequenceKeypoint.new(1, 6)
            }),
            Rate = 10,
            Speed = NumberRange.new(0, 0),
            Life = NumberRange.new(2, 4),
            Rotation = NumberRange.new(0, 0),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.7),
                NumberSequenceKeypoint.new(1, 1)
            })
        },
        ["Abyssal Void"] = {
            Texture = "rbxassetid://7335198031", -- Gloom / smoke
            Color = ColorSequence.new(Color3.new(0, 0, 0)),
            Size = NumberSequence.new(3, 8),
            Rate = 40,
            Speed = NumberRange.new(5, 10),
            Life = NumberRange.new(2, 5),
            Rotation = NumberRange.new(-360, 360),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.3, 0.1),
                NumberSequenceKeypoint.new(1, 1)
            })
        }
    }
    
    local visualConfig = auraVisuals[auraName]
    if not visualConfig then return end
    
    local attachment = Instance.new("Attachment")
    attachment.Name = "AuraEmitter"
    attachment.Parent = attachmentPart
    
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "AuraEmitter"
    emitter.Texture = visualConfig.Texture
    emitter.Color = visualConfig.Color
    emitter.Size = visualConfig.Size
    emitter.Rate = visualConfig.Rate
    emitter.Speed = visualConfig.Speed
    emitter.Lifetime = visualConfig.Life
    emitter.Rotation = visualConfig.Rotation
    emitter.Transparency = visualConfig.Transparency
    emitter.EmissionDirection = Enum.NormalId.Top
    emitter.ZOffset = 1
    emitter.LightEmission = 0.8
    emitter.Parent = attachment
end

return CosmeticService
