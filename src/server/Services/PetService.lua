--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local PetService = Knit.CreateService {
    Name = "PetService",
    Client = {},
}

-- Config
local PET_OFFSET = Vector3.new(3, 4, 3) -- Behind and above

-- Element colors for companion slimes
local ELEMENT_COLORS = {
    Fire = Color3.fromRGB(255, 85, 0),
    Water = Color3.fromRGB(0, 170, 255),
    Earth = Color3.fromRGB(139, 90, 43),
    Air = Color3.fromRGB(200, 255, 255),
    Shadow = Color3.fromRGB(85, 0, 127),
    Light = Color3.fromRGB(255, 255, 170),
    Normal = Color3.fromRGB(0, 255, 150),
}

-- Private State
local ActivePets: { [Player]: string } = {} -- Maps Player to SlimeInstanceId

-- Rarity glow intensity
local RARITY_GLOW = {
    Common = 0.3,
    Uncommon = 0.4,
    Rare = 0.5,
    Epic = 0.6,
    Legendary = 0.75,
    Mythic = 0.9,
}

--[=[
    @private
    Gets or creates a basic Slime template.
]=]
function PetService:_getSlimeTemplate()
    local Assets = ReplicatedStorage:FindFirstChild("Assets")
    if not Assets then
        Assets = Instance.new("Folder")
        Assets.Name = "Assets"
        Assets.Parent = ReplicatedStorage
    end
    
    local template = Assets:FindFirstChild("Slime")
    if not template then
        -- Procedural fallback
        template = Instance.new("Part")
        template.Name = "Slime"
        template.Size = Vector3.new(1.5, 1.5, 1.5)
        template.Shape = Enum.PartType.Ball
        template.Material = Enum.Material.Neon
        template.Color = Color3.fromRGB(0, 255, 150)
        template.Transparency = 0.3
        template.CanCollide = false -- Important for pets to not push players
        template.CastShadow = false
        
        -- Add Attachment for AlignPosition
        local att = Instance.new("Attachment")
        att.Name = "BodyAttachment"
        att.Parent = template
        
        -- Add Eyes (Decal mock)
        local face = Instance.new("Decal")
        face.Texture = "rbxasset://textures/face.png" -- Default smile
        face.Face = Enum.NormalId.Front
        face.Parent = template
        
        template.Parent = Assets
    end
    return template
end

--[=[
    @private
    Creates a companion slime with element-based visuals.
]=]
function PetService:_createCompanionVisuals(slimeData: any): (Part, string)
    local template = self:_getSlimeTemplate()
    local companion = template:Clone()
    
    -- Get element color
    local elementColor = ELEMENT_COLORS[slimeData.Element] or ELEMENT_COLORS.Normal
    companion.Color = elementColor
    
    -- Apply rarity glow effect (via transparency)
    local rarityGlow = RARITY_GLOW[slimeData.Rarity] or 0.3
    companion.Transparency = 1 - rarityGlow
    
    -- Add element-specific attachments/effects
    if slimeData.Element == "Fire" then
        -- Add fire particles or spikes
        self:_addElementEffect(companion, "Fire", elementColor)
    elseif slimeData.Element == "Water" then
        self:_addElementEffect(companion, "Water", elementColor)
    elseif slimeData.Element == "Air" then
        self:_addElementEffect(companion, "Air", elementColor)
    elseif slimeData.Element == "Shadow" then
        self:_addElementEffect(companion, "Shadow", elementColor)
    elseif slimeData.Element == "Light" then
        self:_addElementEffect(companion, "Light", elementColor)
    elseif slimeData.Element == "Earth" then
        self:_addElementEffect(companion, "Earth", elementColor)
    end
    
    -- Store slime data for client reference
    companion:SetAttribute("SlimeInstanceId", slimeData.InstanceId)
    companion:SetAttribute("SlimeTerm", slimeData.Term)
    companion:SetAttribute("SlimeElement", slimeData.Element)
    companion:SetAttribute("SlimeRarity", slimeData.Rarity)
    companion:SetAttribute("SlimeRoot", slimeData.Root or "Terra")
    companion:SetAttribute("SlimeRole", slimeData.Role or "Civilian")
    companion:SetAttribute("IsCompanion", true)
    
    return companion, slimeData.Term
end

--[=[
    @private
    Adds element-specific visual effects to the companion.
]=]
function PetService:_addElementEffect(companion: Part, element: string, color: Color3)
    -- Create a BillboardGui for element indicator
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ElementIndicator"
    billboard.Size = UDim2.new(0, 32, 0, 32)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = companion
    billboard.Parent = companion
    
    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundColor3 = color
    icon.BorderSizePixel = 0
    icon.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = icon
    
    -- Add glow effect for certain elements
    if element == "Fire" or element == "Light" then
        local light = Instance.new("PointLight")
        light.Color = color
        light.Range = 5
        light.Brightness = 2
        light.Parent = companion
    end
end

--[=[
    Spawns a companion slime for a player based on their selected slime.
]=]
function PetService:SpawnCompanion(player: Player, slimeData: any)
    local character = player.Character
    if not character then 
        warn("[PetService] Cannot spawn companion: no character")
        return 
    end
    
    -- Remove existing companion if any
    local existing = workspace:FindFirstChild(player.Name .. "_Companion")
    if existing then 
        local instanceId = existing:GetAttribute("SlimeInstanceId")
        local SpatterService = Knit.GetService("SemanticSpatterService")
        if SpatterService and instanceId then
            SpatterService:UntrackSlime(instanceId)
        end
        existing:Destroy() 
    end
    
    -- Create the companion with element visuals
    local companion, term = self:_createCompanionVisuals(slimeData)
    companion.Name = player.Name .. "_Companion"
    companion.CFrame = character:GetPivot() * CFrame.new(PET_OFFSET)
    
    -- Tag it so client can find it
    companion:SetAttribute("OwnerUserId", player.UserId)
    
    -- Parent to workspace
    companion.Parent = workspace
    
    -- Set Network Ownership to player for smooth client-side physics
    companion:SetNetworkOwner(player)
    
    local SpatterService = Knit.GetService("SemanticSpatterService")
    if SpatterService then
        SpatterService:TrackSlime(slimeData.InstanceId, companion, slimeData.Element, slimeData.Root or "Terra", slimeData.Role or "Civilian")
    end
    
    ActivePets[player] = slimeData.InstanceId
    
    local CosmeticService = Knit.GetService("CosmeticService")
    if CosmeticService then
        local currentAura = CosmeticService:GetEquipped(player)
        if currentAura and currentAura ~= "None" then
            CosmeticService:ApplyAuraToModel(companion, currentAura)
        end
    end
    
    print("[PetService] Spawned companion for " .. player.Name .. ": " .. term .. " (" .. slimeData.Element .. " " .. slimeData.Rarity .. ")")
end

--[=[
    Removes the companion slime for a player.
]=]
function PetService:RemoveCompanion(player: Player)
    local companion = workspace:FindFirstChild(player.Name .. "_Companion")
    if companion then
        local instanceId = companion:GetAttribute("SlimeInstanceId")
        local SpatterService = Knit.GetService("SemanticSpatterService")
        if SpatterService and instanceId then
            SpatterService:UntrackSlime(instanceId)
        end
        companion:Destroy()
        ActivePets[player] = nil
        print("[PetService] Removed companion for " .. player.Name)
    end
end

--[=[
    Legacy: Spawns a generic pet (used for initial setup).
]=]
function PetService:SpawnPet(player: Player)
    -- Remove existing pet if any
    local character = player.Character
    if not character then return end
    
    local existing = workspace:FindFirstChild(player.Name .. "_Pet")
    if existing then existing:Destroy() end
    
    local template = self:_getSlimeTemplate()
    local pet = template:Clone()
    pet.Name = player.Name .. "_Pet"
    pet.CFrame = character:GetPivot() * CFrame.new(PET_OFFSET)
    
    -- Tag it so client can find it
    pet:SetAttribute("OwnerUserId", player.UserId)
    
    -- Parent to workspace
    pet.Parent = workspace
    
    -- Set Network Ownership to player for smooth client-side physics
    pet:SetNetworkOwner(player)
    
    print("[PetService] Spawned pet for " .. player.Name)
end

function PetService:KnitStart()
    print("[PetService] Started.")
    
    -- Handle player joining
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            -- Wait a moment for char to be ready
            task.wait(1)
            
            -- Check if player has a companion saved and spawn it
            local DataService = Knit.GetService("DataService")
            local profile = DataService:GetProfile(player)
            if profile and profile.CompanionSlimeId then
                -- Get the slime data and spawn companion
                local SlimeFactory = Knit.GetService("SlimeFactory")
                local companionSlime = SlimeFactory:GetCompanion(player)
                if companionSlime then
                    self:SpawnCompanion(player, companionSlime)
                end
            else
                -- No companion, spawn generic pet
                self:SpawnPet(player)
            end
        end)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ActivePets[player] = nil
    end)
end

function PetService:GetActivePets()
    return ActivePets
end

return PetService
